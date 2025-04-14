import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pond_status.dart';

class PondPage extends StatefulWidget {
   final String userRole;

  const PondPage({Key? key, required this.userRole}) : super(key: key);

  @override
  _PondPageState createState() => _PondPageState();
}

class _PondPageState extends State<PondPage> {
  final List<Map<String, dynamic>> species = [
    {
      "name": "MILKFISH",
      "scientificName": "Chanos chanos",
      "image": "lib/assets/milkfish.jpg",
      "ponds": 0,
    },
    {
      "name": "TILAPIA (NILE)",
      "scientificName": "Oreochromis niloticus",
      "image": "lib/assets/tilapia.jpg",
      "ponds": 0,
    },
    {
      "name": "SHRIMP (PACIFIC WHITE)",
      "scientificName": "Litopenaeus vannamei",
      "image": "lib/assets/shrimp.jpg",
      "ponds": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchPondCounts(); // Fetch pond counts when the page loads
  }

  void _fetchPondCounts() {
    for (var speciesItem in species) {
      FirebaseFirestore.instance
          .collection('species')
          .doc(speciesItem["name"]!.toLowerCase()) // Match Firestore doc names
          .collection('ponds')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          speciesItem["ponds"] = snapshot.docs.length; // Update count dynamically
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "CURRENT STATUS OF THE PONDS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 67, 67, 67),
                    ),
                  ),
                ),
                const Text(
                  "Choose which aquatic species",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: species.length,
              itemBuilder: (context, index) {
                final item = species[index];
                return _buildSpeciesCard(
                  context,
                  name: item["name"]!,
                  scientificName: item["scientificName"]!,
                  ponds: item["ponds"].toString(), // Convert to string for display
                  imagePath: item["image"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(
    BuildContext context, {
    required String name,
    required String scientificName,
    required String ponds,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to PondDetailPage with species-specific details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PondDetailPage(
              speciesName: name, // Pass species name
              scientificName: scientificName, // Pass scientific name
              userRole: widget.userRole,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 170,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Stack(
          children: [
            ClipRRect(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 75,
              child: Container(
                color: const Color.fromARGB(255, 96, 173, 235).withOpacity(0.6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Scientific name: $scientificName",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ponds: $ponds",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
