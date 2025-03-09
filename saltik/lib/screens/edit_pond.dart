import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditPondPage extends StatefulWidget {
  final String speciesName;
  final String? pondId;
  final Map<String, dynamic>? pondData;

  const AddEditPondPage({
    Key? key,
    required this.speciesName,
    this.pondId,
    this.pondData,
  }) : super(key: key);

  @override
  _AddEditPondPageState createState() => _AddEditPondPageState();
}

class _AddEditPondPageState extends State<AddEditPondPage> {
  String? selectedLifeStage;
  String? selectedStatus;
  String? salinity; // Holds the real-time salinity value

  final List<String> lifeStages = ["Egg", "Juvenile", "Adult"];
  final List<String> occupancyStatuses = ["Occupied", "Empty"];

  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensor");

  @override
  void initState() {
    super.initState();

    if (widget.pondId == null) {
      selectedLifeStage = lifeStages.first;
      selectedStatus = occupancyStatuses.first;
      _fetchRealtimeSalinity(); // Fetch salinity only when adding a new pond
    } else {
      setState(() {
        selectedLifeStage = widget.pondData?["lifestage"] ?? lifeStages.first;
        selectedStatus = widget.pondData?["status"] ?? occupancyStatuses.first;
        salinity = widget.pondData?["salinity"]?.toString() ?? "N/A"; // Keep existing salinity when editing
      });
    }
  }

  /// Fetch real-time salinity from Firebase Realtime Database
  void _fetchRealtimeSalinity() {
  _sensorRef.child("salinity").once().then((event) {
    var salinityData = event.snapshot.value;
    if (salinityData != null && mounted) { // Check if the widget is still active
      setState(() {
        salinity = salinityData.toString();
      });
    }
  }).catchError((error) {
    if (mounted) {
      print("Error fetching salinity: $error");
    }
  });
}

  Future<void> savePond() async {
    if (selectedLifeStage == null || selectedStatus == null || salinity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields and ensure salinity is available")),
      );
      return;
    }

    final data = {
      "lifestage": selectedLifeStage,
      "status": selectedStatus,
      "salinity": double.tryParse(salinity ?? "0") ?? 0.0, // Convert salinity to double
    };

    try {
      final pondCollection = FirebaseFirestore.instance
          .collection('species')
          .doc(widget.speciesName.toLowerCase())
          .collection('ponds');

      if (widget.pondId == null) {
        await pondCollection.add(data);
      } else {
        await pondCollection.doc(widget.pondId).update(data);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving pond: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.speciesName.toUpperCase(),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Select the correct information for your pond",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              
              // Salinity Display
              Text(
                "Salinity (ppt): ${salinity ?? 'Loading...'}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),

              buildSelectionGroup("Life Stage", lifeStages, selectedLifeStage, (value) {
                setState(() {
                  selectedLifeStage = value;
                });
              }),

              buildSelectionGroup("Occupancy Status", occupancyStatuses, selectedStatus, (value) {
                setState(() {
                  selectedStatus = value;
                });
              }),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: savePond,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Done", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectionGroup(String title, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Column(
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedValue,
              onChanged: onChanged,
              activeColor: Colors.blue,
            );
          }).toList(),
        ),
      ],
    );
  }
}
