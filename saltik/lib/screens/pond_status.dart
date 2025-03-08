import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_pond.dart';

class PondDetailPage extends StatelessWidget {
  final String speciesName;
  final String scientificName;

  const PondDetailPage({
    Key? key,
    required this.speciesName,
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

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isEmpty || salinity == null
                              ? Colors.grey
                              : (salinity < 30 ? Colors.blue : Colors.red),
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
                          "Pond ${index + 1}",
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Status: ${pond["status"]}", style: const TextStyle(fontSize: 12)),
                        Text("Salinity: ${salinity?.toInt() ?? 0} ppt", style: const TextStyle(fontSize: 12)),
                        Text("Life Stage: ${pond["lifestage"] ?? 'Unknown'}", style: const TextStyle(fontSize: 12)),

                        // if (!isEmpty) ...[
                        //   Text("Salinity: ${salinity?.toInt() ?? 0} ppt", style: const TextStyle(fontSize: 12)),
                        //   Text("Life Stage: ${pond["lifestage"] ?? 'Unknown'}", style: const TextStyle(fontSize: 12)),
                        // ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditPondPage(
                                      speciesName: speciesName,
                                      pondId: pond["id"],
                                      pondData: pond,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deletePond(context, speciesName, pond["id"]),
                            ),
                          ],
                        ),
                      ],
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditPondPage(
                        speciesName: speciesName,
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
        content: const Text("Are you sure you want to delete this pond?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('species')
            .doc(species.toLowerCase())
            .collection('ponds')
            .doc(pondId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pond deleted successfully!")));
      } catch (e) {
        print("Error deleting pond: $e");
      }
    }
  }
}
