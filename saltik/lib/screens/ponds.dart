import 'package:flutter/material.dart';

class PondPage extends StatelessWidget {
  const PondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> species = [
      {
        "name": "MILKFISH",
        "scientificName": "Chanos chanos",
        "ponds": "0",  // value is based on the database, modifyyy!!!!
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
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "CURRENT STATUS OF THE PONDS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 67, 67, 67),
                  ),
                ),
                const SizedBox(height: 5),
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
          // List of species
          Expanded(
            child: ListView.builder(
              itemCount: species.length,
              itemBuilder: (context, index) {
                final item = species[index];
                return _buildSpeciesCard(
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

    Widget _buildSpeciesCard({
    required String name,
    required String scientificName,
    required String ponds,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      height: 150, // Total height of the card
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          ClipRRect(
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0, // Keep it at the bottom
            left: 0,
            right: 0,
            height: 75,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                color: Colors.blue.withOpacity(0.4),
              ),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ponds: $ponds",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}