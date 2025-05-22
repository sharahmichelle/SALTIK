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
          "STATISTICS",
          style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
        ),
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
                "SALINITY AND \n TEMPERATURE \n CHANGES",
                style: GoogleFonts.workSans(fontWeight: FontWeight.bold, color: Color(0xFF545454), fontSize: 18, height: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  text: "Here is the graph showing the changes \n in salinity levels and temperature of \n",
                  style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF545454)),
                  children: [
                    TextSpan(
                      text: widget.speciesName.toLowerCase(),
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF545454)
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text("Salinity", style: GoogleFonts.workSans(color: Color(0xFF545454), fontSize:12)),
                  const SizedBox(width: 10),
                  Container(width: 12, height: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text("Temperature", style: GoogleFonts.workSans(color: Color(0xFF545454), fontSize:12)),
                ],
              ),
              const SizedBox(height: 15),

              // LineChart Widget
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

                    // Convert UTC timestamp to local time (in this case, Philippine Time)
                    // DateTime utcDateTime = timestamp.toDate();
                    // DateTime localDateTime = utcDateTime.add(Duration(hours: 8));
                    // // Now format the local time to display correctly
                    // String datePart = DateFormat('MM/dd/yy').format(localDateTime);
                    // String timePart = DateFormat('hh:mm a').format(localDateTime);
                    // String dateLabel = '$datePart\n$timePart';

                    DateTime localDateTime = timestamp.toDate().toLocal();
                    String datePart = DateFormat('MM/dd/yy').format(localDateTime);
                    String timePart = DateFormat('hh:mm a').format(localDateTime);
                    String dateLabel = '$datePart\n$timePart';

                    // String datePart = DateFormat('MM/dd/yy').format(timestamp.toDate());
                    // String timePart = DateFormat('hh:mm a').format(timestamp.toDate());
                    // String dateLabel = '$datePart\n$timePart';

                    dateLabels.add(dateLabel);
                    salinityData.add(FlSpot(index.toDouble(), salinity));
                    temperatureData.add(FlSpot(index.toDouble(), temperature));
                    index++;
                  }

                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false), 
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: true,
                              horizontalInterval: 5,  // LINE INTERVAL!!!!!  
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.3), // softer color
                                  strokeWidth: 1,
                                  // dashArray: null,
                                );
                              },
                            ), 
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 70,  // ADJUSTED SIZE FOR INTERVAL!!!!
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= dateLabels.length) return const Text("");

                                    List<String> parts = dateLabels[index].split('\n');
                                    String date = parts[0];
                                    String time = parts.length > 1 ? parts[1] : "";

                  
                                     return Padding(
                                      padding: const EdgeInsets.only(top:20),
                                      child: Transform.rotate(
                                        angle: -1.3,
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
                                              text: "$time",
                                              style: GoogleFonts.workSans(
                                                fontSize: 10,
                                                color: Colors.black, 
                                                fontWeight: FontWeight.bold,
                                               ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                     );
                                  },
                                ),
                              ),
                               leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,  
                                  interval: 5,
                                  reservedSize: 30,  // Adjust the reserved space for left Y-axis
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(0), // Display Y-axis value (integer format)
                                      style: GoogleFonts.workSans(fontSize: 12, color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false), 
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: salinityData,
                                color: Colors.blue,
                                isCurved: false,
                                barWidth: 3,
                                dotData: FlDotData(show: true), 
                               
                              ),
                              LineChartBarData(
                                spots: temperatureData,
                                color: Colors.grey,
                                isCurved: false,
                                barWidth: 3,
                                dotData: FlDotData(show: true), 
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,  // Set width to 80% of the screen
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateSelector(context, "Start Date", true),
                        _buildDateSelector(context, "End Date", false),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                child: const Text("See in list format", style: TextStyle(color: Colors.black, fontSize:12, fontWeight: FontWeight.w600)),
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
      Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF545454))),
      GestureDetector(
        onTap: () => _selectDate(context, isStart),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              FittedBox(
                child: Text(
                  isStart
                      ? (_startDate != null
                          ? DateFormat('MM/dd/yyyy').format(_startDate!)
                          : 'Select Start Date')
                      : (_endDate != null
                          ? DateFormat('MM/dd/yyyy').format(_endDate!)
                          : 'Select End Date'),
                  style: GoogleFonts.workSans(fontSize: 10,color: Color(0xFF545454)),
                ),
              ),
              const SizedBox(width:5), 
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    ],
  );
}
}