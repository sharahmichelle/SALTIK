import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_pond.dart';
import 'statistics_graph.dart';

class PondDetailPage extends StatelessWidget {
  final String speciesName;
  final String scientificName;
  final String userRole;

  const PondDetailPage({
    Key? key,
    required this.speciesName,
    required this.userRole,
    required this.scientificName,
  }) : super(key: key);

  Stream<QuerySnapshot> getPondsForSpecies(String species) {
    return FirebaseFirestore.instance
        .collection('species')
        .doc(species.toLowerCase())
        .collection('ponds')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          speciesName.toUpperCase(),
          style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Scientific name: $scientificName",
              style: GoogleFonts.workSans(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getPondsForSpecies(speciesName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No ponds available for this species"));
                }

                var ponds = snapshot.data!.docs.map((doc) {
                  return {
                    "id": doc.id,
                    ...doc.data() as Map<String, dynamic>
                  };
                }).toList();

                 ponds.sort((a, b) {
                  final aName = (a["pond_name"] ?? "").toString().toLowerCase();
                  final bName = (b["pond_name"] ?? "").toString().toLowerCase();
                  return aName.compareTo(bName);
                });

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: ponds.length,
                  itemBuilder: (context, index) {
                    final pond = ponds[index];
                    bool isEmpty = !pond.containsKey("salinity");

                    double? salinity = pond["salinity"] is num
                        ? pond["salinity"].toDouble()
                        : double.tryParse(pond["salinity"].toString());

                    final Map<String, Map<String, double>> speciesSalinityRanges = {
                      "tilapia": {"low": 5, "high": 20},
                      "shrimp": {"low": 5, "high": 25},
                      "milkfish": {"low": 15, "high": 25},
                    };

                    double lowThreshold = speciesSalinityRanges[speciesName.toLowerCase()]?["low"] ?? 10;
                    double highThreshold = speciesSalinityRanges[speciesName.toLowerCase()]?["high"] ?? 30;

                    Color salinityColor;
                    if (salinity == null) {
                      salinityColor = Colors.grey;
                    } else if (salinity < lowThreshold) {
                      salinityColor = const Color.fromARGB(255, 238, 221, 66);
                    } else if (salinity > highThreshold) {
                      salinityColor = const Color.fromARGB(255, 179, 38, 28);
                    } else {
                      salinityColor = const Color.fromARGB(255, 34, 131, 210);
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatisticsPage(pondId: pond['id'], speciesName: speciesName,), 
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: salinityColor,
                            child: isEmpty
                                ? null
                                : Text(
                                    "${salinity?.toInt() ?? 0} ppt",
                                    style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            pond["pond_name"] ?? "Unnamed Pond",
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Status: ${pond["status"] ?? 'Unknown'}", style: const TextStyle(fontSize: 12)),
                          Text("Salinity: ${salinity?.toInt() ?? 0} ppt", style: const TextStyle(fontSize: 12)),
                          Text("Life Stage: ${pond["lifestage"] ?? 'Unknown'}", style: const TextStyle(fontSize: 12)),

                          const Spacer(), // Removed misplaced Spacer()

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                if (userRole != "Laborer") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Only laborers are allowed to edit a pond.")),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditPondPage(
                                      speciesName: speciesName,
                                      userRole: userRole,
                                      pondId: pond["id"],
                                      pondData: pond,
                                    ),
                                  ),
                                );
                              },

                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                if (userRole != "Laborer") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Only laborers are allowed to delete a pond.")),
                                  );
                                  return;
                                }

                                deletePond(context, speciesName, pond["id"]);
                              },

                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                if (userRole != "Laborer") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Only laborers are allowed to add a pond.")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditPondPage(
                      speciesName: speciesName,
                      userRole: userRole,
                      pondId: null,
                      pondData: null,
                    ),
                  ),
                );
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Add Pond", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deletePond(BuildContext context, String species, String pondId) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Deletion"),
      content: const Text("Are you sure you want to delete this pond? This will also delete all associated data."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.blue),)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
      ],
    ),
  );

  if (confirmDelete == true) {
    try {
      // First, delete all sensor logs under this pond
      QuerySnapshot sensorLogsSnapshot = await FirebaseFirestore.instance
          .collection('species')
          .doc(species.toLowerCase())
          .collection('ponds')
          .doc(pondId)
          .collection('sensor_logs')
          .get();

      // Delete each sensor log
      for (var logDoc in sensorLogsSnapshot.docs) {
        await logDoc.reference.delete();
      }

      // Now delete the pond document itself
      await FirebaseFirestore.instance
          .collection('species')
          .doc(species.toLowerCase())
          .collection('ponds')
          .doc(pondId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pond and associated data deleted successfully!")));
    } catch (e) {
      print("Error deleting pond or associated data: $e");
    }
  }
}
}
