import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PondDetailPage extends StatelessWidget {
  final String speciesName;
  final String scientificName;

  const PondDetailPage({
    Key? key,
    required this.speciesName,
    required this.scientificName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> ponds = [
      {"salinity": 22, "status": "Occupied", "lifeStage": "Juvenile"},
      {"status": "Empty"},
      {"status": "Empty"},
      {"salinity": 31, "status": "Occupied", "lifeStage": "Adult"},
      {"salinity": 37, "status": "Occupied", "lifeStage": "Adult"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(speciesName.toUpperCase(),
            style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Text(
              "Scientific name: $scientificName",
              style: GoogleFonts.workSans(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: ponds.length,
                itemBuilder: (context, index) {
                  final pond = ponds[index];
                  bool isEmpty = !pond.containsKey("salinity");
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: isEmpty
                            ? Colors.grey
                            : pond["salinity"] < 30
                                ? Colors.blue
                                : Colors.red,
                        child: isEmpty
                            ? null
                            : Text(
                                "${pond["salinity"]} ppt",
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
                      Text("Status: ${pond["status"]}",
                          style: const TextStyle(fontSize: 12)),
                      if (!isEmpty) ...[
                        Text("Salinity: ${pond["salinity"]} ppt",
                            style: const TextStyle(fontSize: 12)),
                        Text("Life Stage: ${pond["lifeStage"]}",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("Add Pond" , style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, ),
              child: const Text("Edit Pond" , style: TextStyle(color: Colors.white)),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 2), // Red outline
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Optional: Rounded edges
                ),
              ),
              child: const Text(
                "Remove Pond",
                style: TextStyle(color: Colors.red), // Match text color to outline
              ),
            ),
          ],
        ),
      ),
    );
  }
}