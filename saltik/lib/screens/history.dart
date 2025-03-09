import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Stream<List<Map<String, dynamic>>> fetchAllHistory() async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> historyList = [];

    try {
      QuerySnapshot speciesSnapshot = await firestore.collection("ponds").get();

      for (var speciesDoc in speciesSnapshot.docs) {
        String speciesName = speciesDoc.id;
        QuerySnapshot historySnapshot = await firestore
            .collection("ponds")
            .doc(speciesName)
            .collection("history")
            .get();

        for (var historyDoc in historySnapshot.docs) {
          Map<String, dynamic> data = historyDoc.data() as Map<String, dynamic>;
          data["species"] = speciesName;
          historyList.add(data);
        }
      }

      // Sorting the list by date (latest first)
      historyList.sort((a, b) {
        Timestamp? dateA = a["date_time"] as Timestamp?;
        Timestamp? dateB = b["date_time"] as Timestamp?;
        return (dateB?.toDate().compareTo(dateA?.toDate() ?? DateTime(0))) ?? 0;
      });

      yield historyList;
    } catch (e, stackTrace) {
      print(stackTrace);
      yield [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              "HISTORICAL\nREADINGS\nOF EACH POND",
              style: GoogleFonts.workSans(
                textStyle: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 67, 67, 67),
                  height: 1.2,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              "Here is a list of past readings \n from each pond",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchAllHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No readings found"));
                  }

                  var historyList = snapshot.data!;

                  return ListView.builder(
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      var reading = historyList[index];

                      Timestamp? timestamp = reading["date_time"] as Timestamp?;
                      String formattedDate = timestamp != null
                          ? DateFormat("MMMM d, yyyy").format(timestamp.toDate())
                          : "Unknown Date";
                      String formattedTime = timestamp != null
                          ? DateFormat("hh:mm a").format(timestamp.toDate())
                          : "Unknown Time";

                      double salinity = double.tryParse(reading["salinity"].toString()) ?? 0.0;
                      int roundedSalinity = salinity.round();
                      Gradient circleGradient = getSalinityGradient(roundedSalinity);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        leading: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: circleGradient,
                          ),
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${reading["salinity"]}\n",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                const TextSpan(
                                  text: "ppt",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: GoogleFonts.workSans(
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Species: ${reading["species"] ?? "Unknown"}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5E5E5E),
                                      ),
                                    ),
                                    Text(
                                      "Pond: ${reading["pond_no"] ?? "Unknown"}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5E5E5E),
                                      ),
                                    ),
                                    Text(
                                      "Temperature: ${reading["temp"] ?? "Unknown"}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5E5E5E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                formattedTime,
                                style: GoogleFonts.workSans(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color.fromARGB(255, 67, 67, 67),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // TEMPORARY SALINITY LEVEL TOLERANCE RANGE
  Gradient getSalinityGradient(int salinity) {
    if (salinity >= 28) {
      return const RadialGradient(
        colors: [Colors.red, Colors.white],
        center: Alignment.center,
        radius: 0.9,
      );
    } else if (salinity >= 20 && salinity < 28) {
      return const RadialGradient(
        colors: [Colors.blue, Colors.white],
        center: Alignment.center,
        radius: 0.9,
      );
    } else {
      return const RadialGradient(
        colors: [Colors.yellow, Colors.white],
        center: Alignment.center,
        radius: 0.9,
      );
    }
  }
}
