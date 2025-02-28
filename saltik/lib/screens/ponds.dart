import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pond_status.dart';

class PondPage extends StatelessWidget {
  const PondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> species = [
      {
        "name": "MILKFISH",
        "scientificName": "Chanos chanos",
        "ponds": "0",  // Modify based on database
        "image": "lib/assets/milkfish.jpg"
      },
      {
        "name": "TILAPIA (NILE)",
        "scientificName": "Oreochromis niloticus",
        "ponds": "0",
        "image": "lib/assets/tilapia.jpg"
      },
      {
        "name": "SHRIMP (PACIFIC WHITE)",
        "scientificName": "Litopenaeus vannamei",
        "ponds": "0",
        "image": "lib/assets/shrimp.jpg"
      },
    ];

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
                  ponds: item["ponds"]!,
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