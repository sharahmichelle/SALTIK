import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'statistics_list.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StatisticsPage(),
    );
  }
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime? startDate;
  DateTime? endDate;

  final List<Map<String, dynamic>> readings = [
    {"date_time": "January 21, 2025 at 01:30:00 PM UTC+8", "salinity": 16, "temperature": 25},
    {"date_time": "February 18, 2025 at 10:38:00 AM UTC+8", "salinity": 20, "temperature": 24},
    {"date_time": "March 14, 2025 at 02:06:00 AM UTC+8", "salinity": 28, "temperature": 26},
    {"date_time": "March 27, 2025 at 10:12:00 AM UTC+8", "salinity": 32, "temperature": 30},
    {"date_time": "April 01, 2025 at 12:18:00 PM UTC+8", "salinity": 30, "temperature": 31},
    {"date_time": "May 14, 2025 at 01:23:00 PM UTC+8", "salinity": 31, "temperature": 29},
    {"date_time": "May 25, 2025 at 07:17:00 PM UTC+8", "salinity": 29, "temperature": 30},
    {"date_time": "June 06, 2025 at 03:30:00 AM UTC+8", "salinity": 26, "temperature": 28},
    {"date_time": "June 30, 2025 at 11:31:00 PM UTC+8", "salinity": 23, "temperature": 27},
    {"date_time": "July 29, 2025 at 12:59:00 AM UTC+8", "salinity": 31, "temperature": 29},
  ];

  List<FlSpot> getSalinitySpots() {
  List<Map<String, dynamic>> filteredReadings = getFilteredReadings();
  return List.generate(filteredReadings.length, (index) {
    return FlSpot(index.toDouble(), filteredReadings[index]["salinity"].toDouble());
  });
}

List<FlSpot> getTemperatureSpots() {
  List<Map<String, dynamic>> filteredReadings = getFilteredReadings();
  return List.generate(filteredReadings.length, (index) {
    return FlSpot(index.toDouble(), filteredReadings[index]["temperature"].toDouble());
  });
}


  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= readings.length) return const SizedBox();

    String rawDateTime = readings[index]["date_time"];
    rawDateTime = rawDateTime.replaceAll(RegExp(r' UTC[+-]\d+'), ''); 

    DateFormat inputFormat = DateFormat("MMMM d, yyyy 'at' hh:mm:ss a");
    DateTime parsedDateTime = inputFormat.parse(rawDateTime);
    String formattedDateTime = DateFormat("MM/dd/yy h:mm a").format(parsedDateTime);

    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Transform.translate(
        offset: const Offset(-17, 0),
        child: Transform.rotate(
          angle: -0.9,
          child: FittedBox(
            child: Text(
              formattedDateTime,
              style: const TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return Text(value.toInt().toString(),
        style: const TextStyle(fontSize: 12), textAlign: TextAlign.left);
  }

  // Filter the readings based on the selected start and end dates
  List<Map<String, dynamic>> getFilteredReadings() {
    if (startDate == null || endDate == null) {
      return readings; 
    }

    return readings.where((reading) {
      DateFormat inputFormat = DateFormat("MMMM d, yyyy 'at' hh:mm:ss a");
      DateTime parsedDateTime = inputFormat.parse(reading["date_time"].replaceAll(RegExp(r' UTC[+-]\d+'), ''));
      return parsedDateTime.isAfter(startDate!) && parsedDateTime.isBefore(endDate!);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredReadings = getFilteredReadings();

    double minY = filteredReadings
        .expand((e) => [e["salinity"] as num, e["temperature"] as num])
        .reduce(min)
        .toDouble();
    double maxY = filteredReadings
        .expand((e) => [e["salinity"] as num, e["temperature"] as num])
        .reduce(max)
        .toDouble();
    double interval = 4.ceil().toDouble();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const Text(
                "SALINITY AND \n TEMPERATURE \n CHANGES",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Color(0xFF545454), height: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Here is the graph showing the changes \n in salinity levels and temperature of \n Milkfish Pond 1",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Legend at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(width: 18, height: 18, color: Colors.blue),
                      const SizedBox(width: 5),
                      const Text("Salinity", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Container(width: 18, height: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      const Text("Temperature", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Graph with 80% width
              FractionallySizedBox(
                widthFactor: 0.8,
                child: SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (filteredReadings.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.8),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: leftTitleWidgets,
                            reservedSize: 40,
                            interval: interval,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: bottomTitleWidgets,
                            reservedSize: 40,
                            interval: 1,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData: ExtraLinesData(
                        extraLinesOnTop: true,
                        horizontalLines: [
                          HorizontalLine(
                            y: minY,
                            color: Colors.grey.withOpacity(0.5),
                            strokeWidth: 1,
                          ),
                          HorizontalLine(
                            y: maxY,
                            color: Colors.grey.withOpacity(0.5),
                            strokeWidth: 1,
                          ),
                        ],
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: getSalinitySpots(),
                          isCurved: false,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: getTemperatureSpots(),
                          isCurved: false,
                          color: Colors.grey,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              Column(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? selectedStartDate = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (selectedStartDate != null) {
                              setState(() {
                                startDate = selectedStartDate;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                startDate == null ? 'Select Start Date' : DateFormat('MM/dd/yyyy').format(startDate!),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Date',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? selectedEndDate = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (selectedEndDate != null) {
                              setState(() {
                                endDate = selectedEndDate;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                endDate == null ? 'Select End Date' : DateFormat('MM/dd/yyyy').format(endDate!),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20), 

                // SEE LIST FORMAT BUTTON
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StatisticListPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, 
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    child: const Text(
                      'See in list format',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
           ]
          )
        )
      )  
    );
  }
}