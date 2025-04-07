import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';

class StatisticListPage extends StatefulWidget {
  final String pondId;
  final String speciesName;

  const StatisticListPage({Key? key, required this.pondId, required this.speciesName}) : super(key: key);

  @override
  _StatisticListPageState createState() => _StatisticListPageState();
}

class _StatisticListPageState extends State<StatisticListPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Stream<QuerySnapshot> _getDataStream() {
    return FirebaseFirestore.instance
        .collection('species')
        .doc(widget.speciesName.toLowerCase())
        .collection('ponds')
        .doc(widget.pondId)
        .collection('sensor_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _exportToExcel(BuildContext context, List<QueryDocumentSnapshot> docs) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sensor Data'];

  // Add headers
  sheetObject.appendRow([
    TextCellValue("Date"),
    TextCellValue("Time"),
    TextCellValue("Salinity (ppt)"),
    TextCellValue("Temperature (°C)")
  ]);

  // Add data rows
  for (var doc in docs) {
    var data = doc.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();
    double salinity = (data['salinity'] ?? 0).toDouble();
    double temperature = (data['temperature'] ?? 0).toDouble();

    sheetObject.appendRow([
      TextCellValue(DateFormat('MM/dd/yyyy').format(dateTime)),
      TextCellValue(DateFormat('hh:mm a').format(dateTime)),
      DoubleCellValue(salinity),
      DoubleCellValue(temperature),
    ]);
  }

  // Request storage permission
  if (await Permission.storage.request().isGranted) {
    // Get the Downloads directory
    String? downloadsPath = await AndroidPathProvider.downloadsPath;
    if (downloadsPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to access Downloads folder.")),
      );
      return;
    }

    String filePath = "$downloadsPath/SensorData.xlsx";

    // Save the file
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel file saved in Downloads: $filePath")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permission denied! Unable to save Excel file.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Data List",
          style: GoogleFonts.workSans(fontWeight: FontWeight.normal, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0.5,

        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () async {
            var snapshot = await FirebaseFirestore.instance
                .collection('species')
                .doc(widget.speciesName.toLowerCase())
                .collection('ponds')
                .doc(widget.pondId)
                .collection('sensor_logs')
                .orderBy('timestamp', descending: true)
                .get();

            List<QueryDocumentSnapshot> docs = snapshot.docs;

            if (docs.isNotEmpty) {
              await _exportToExcel(context, docs);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No data available to export."))
              );
            }
          },
          ),
        ],
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 0, // Allows flexible height
              minWidth: double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Here is the list showing the changes in salinity levels and temperature of \n${widget.speciesName.toLowerCase()} pond",
                  style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by date",
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                    border: OutlineInputBorder(
                      borderRadius: 
                      BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                ),

                const SizedBox(height: 16),
                SizedBox( // Limits the height of ListView so scrolling works properly
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getDataStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs;

                      List<QueryDocumentSnapshot> filteredDocs = docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        Timestamp timestamp = data['timestamp'] as Timestamp;
                        String formattedDate = DateFormat('MM/dd/yyyy').format(timestamp.toDate());

                        return _searchQuery.isEmpty || formattedDate.contains(_searchQuery);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return const Center(child: Text("No data found for the selected date."));
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll conflicts
                        itemCount: filteredDocs.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          var data = filteredDocs[index].data() as Map<String, dynamic>;
                          double salinity = (data['salinity'] ?? 0).toDouble();
                          double temperature = (data['temperature'] ?? 0).toDouble();
                          Timestamp timestamp = data['timestamp'] as Timestamp;
                          DateTime dateTime = timestamp.toDate();

                          return ListTile(
                            leading: ClipOval(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [Colors.white, Colors.blue],
                                    radius: 0.55
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${salinity.toInt()} ppt",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              DateFormat('MMMM dd, yyyy').format(dateTime),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Temperature: ${temperature.toInt()}°C"),
                            trailing: Text(
                              DateFormat('hh:mm a').format(dateTime),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
