import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final Map<String, String> _pondNameCache = {};

  Future<String> _getPondName(String speciesId, String pondId) async {
    final key = "$speciesId/$pondId";
    if (_pondNameCache.containsKey(key)) {
      return _pondNameCache[key]!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("species")
          .doc(speciesId)
          .collection("ponds")
          .doc(pondId)
          .get();

      if (doc.exists) {
        final name = doc.data()?["pond_name"] ?? pondId;
        _pondNameCache[key] = name;
        return name;
      } else {
        return pondId;
      }
    } catch (e) {
      return pondId;
    }
  }

  String _extractFromPath(List<String> segments, String key) {
    int index = segments.indexOf(key);
    if (index != -1 && index + 1 < segments.length) {
      return segments[index + 1];
    }
    return "Unknown";
  }

  Gradient _getSalinityGradient(int salinity) {
    if (salinity >= 28) {
      return const RadialGradient(colors: [Colors.red, Colors.white], radius: 0.9);
    } else if (salinity >= 20) {
      return const RadialGradient(colors: [Colors.blue, Colors.white], radius: 0.9);
    } else {
      return const RadialGradient(colors: [Colors.yellow, Colors.white], radius: 0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "HISTORICAL\nREADINGS\nOF EACH POND",
              style: GoogleFonts.workSans(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 67, 67, 67),
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              "Here is a list of past readings \nfrom each pond",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                hintText: "Search by date",
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collectionGroup('sensor_logs').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var docs = snapshot.data!.docs;

                  docs.sort((a, b) {
                    var aTimestamp = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    var bTimestamp = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    return bTimestamp?.compareTo(aTimestamp ?? Timestamp.fromDate(DateTime(0))) ?? 0;
                  });

                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      var ts = data['timestamp'] as Timestamp?;
                      if (ts != null) {
                        String dateStr = DateFormat("MMMM d, yyyy").format(ts.toDate()).toLowerCase();
                        return dateStr.contains(_searchQuery);
                      }
                      return false;
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(child: Text("No readings found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      Timestamp? timestamp = data['timestamp'] as Timestamp?;
                      DateTime? dateTime = timestamp?.toDate();
                      String formattedDate = dateTime != null
                          ? DateFormat("MMMM d, yyyy").format(dateTime)
                          : "Unknown Date";
                      String formattedTime = dateTime != null
                          ? DateFormat("hh:mm a").format(dateTime)
                          : "Unknown Time";

                      double salinity = (data["salinity"] ?? 0).toDouble();
                      int roundedSalinity = salinity.round();
                      double temperature = (data["temperature"] ?? 0).toDouble();

                      List<String> pathSegments = doc.reference.path.split('/');
                      String species = _extractFromPath(pathSegments, "species");
                      String pond = _extractFromPath(pathSegments, "ponds");

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        leading: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _getSalinityGradient(roundedSalinity),
                          ),
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "$salinity\n",
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Species: ${species.toLowerCase()}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    FutureBuilder<String>(
                                      future: _getPondName(species, pond),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text(
                                            "Pond: loading...",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF5E5E5E),
                                            ),
                                          );
                                        } else {
                                          return Text(
                                            "Pond: ${snapshot.data ?? pond}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF5E5E5E),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      "Temperature: ${temperature.toStringAsFixed(1)}°C",
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color.fromARGB(255, 67, 67, 67),
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
}
