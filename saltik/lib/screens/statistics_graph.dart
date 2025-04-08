import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'statistics_list.dart';

class StatisticsPage extends StatefulWidget {
  final String pondId;
  final String speciesName;

  const StatisticsPage({Key? key, required this.pondId, required this.speciesName}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Stream<QuerySnapshot> _getDataStream() {
    Query query = FirebaseFirestore.instance
        .collection('species')
        .doc(widget.speciesName.toLowerCase())
        .collection('ponds')
        .doc(widget.pondId)
        .collection('sensor_logs')
        .orderBy('timestamp', descending: false);

    if (_startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!));
    }
    if (_endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Data Trends",
          style: GoogleFonts.workSans(fontWeight: FontWeight.normal),
        ),
        // centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 0),
              Text(
                "Here is the graph showing the changes in salinity levels and temperature of \n"
                "${widget.speciesName.toLowerCase()}",
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _getDataStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No data available for selected dates."));
                  }

                  List<FlSpot> salinityData = [];
                  List<FlSpot> temperatureData = [];
                  List<String> dateLabels = [];

                  int index = 0;
                  for (var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  
                  // Ensure the timestamp exists
                  if (data['timestamp'] == null) {
                    continue; // Skip this document if timestamp is missing
                  }

                  double salinity = (data['salinity'] ?? 0).toDouble();
                  double temperature = (data['temperature'] ?? 0).toDouble();
                  Timestamp timestamp = data['timestamp'] as Timestamp;
                  String datePart = DateFormat('MM/dd/yy').format(timestamp.toDate());
                  String timePart = DateFormat('hh:mm a').format(timestamp.toDate());
                  String dateLabel = '$datePart\n$timePart';

                  dateLabels.add(dateLabel);
                  salinityData.add(FlSpot(index.toDouble(), salinity));
                  temperatureData.add(FlSpot(index.toDouble(), temperature));
                  index++;
                }

                  return Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 80,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= dateLabels.length) return const Text("");

                                    List<String> parts = dateLabels[index].split('\n');
                                    String date = parts[0];
                                    String time = parts.length > 1 ? parts[1] : "";

                                    return Transform.rotate(
                                      angle: -0.3,
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "$date\n",
                                              style: GoogleFonts.workSans(
                                                fontSize: 10,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            TextSpan(
                                              text: time,
                                              style: GoogleFonts.workSans(
                                                fontSize: 10,
                                                color: Colors.black, // Time in black
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: salinityData,
                                color: Colors.blue,
                                isCurved: true,
                                barWidth: 3,
                              ),
                              LineChartBarData(
                                spots: temperatureData,
                                color: Colors.grey,
                                isCurved: true,
                                barWidth: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 12, height: 12, color: Colors.blue),
                          const SizedBox(width: 5),
                          const Text("Salinity"),
                          const SizedBox(width: 16),
                          Container(width: 12, height: 12, color: Colors.grey),
                          const SizedBox(width: 5),
                          const Text("Temperature"),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateSelector(context, "Start Date", true),
                  _buildDateSelector(context, "End Date", false),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(30, 30), backgroundColor: const Color.fromARGB(255, 99, 203, 251)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticListPage(
                        pondId: widget.pondId,
                        speciesName: widget.speciesName,
                      ),
                    ),
                  );
                },
                child: const Text("See in list format", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, String title, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => _selectDate(context, isStart),
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (isStart ? _startDate : _endDate) != null
                      ? DateFormat('yyyy-MM-dd').format((isStart ? _startDate : _endDate)!)
                      : "Select",
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
