import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sensor_logger.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class AddEditPondPage extends StatefulWidget {
  final String speciesName;
  final String? pondId;
  final Map<String, dynamic>? pondData;
  final String userRole;

const AddEditPondPage({
  Key? key,
  required this.speciesName,
  required this.userRole,
  this.pondId,
  this.pondData,
}) : super(key: key);


  @override
  _AddEditPondPageState createState() => _AddEditPondPageState();
}

class _AddEditPondPageState extends State<AddEditPondPage> {
  String? selectedLifeStage;
  String? selectedStatus;
  String? salinity;
  String? temperature;
  String? _pondId;
  static Timer? _sensorLoggingTimer;

  final List<String> lifeStages = ["Egg", "Juvenile", "Adult"];
  final List<String> occupancyStatuses = ["Occupied", "Empty"];

  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensor");

  @override
  void initState() {
    super.initState();
    _pondId = widget.pondId;

    selectedLifeStage = widget.pondData?["lifestage"] ?? lifeStages.first;
    selectedStatus = widget.pondData?["status"] ?? occupancyStatuses.first;
    salinity = widget.pondData?["salinity"]?.toString() ?? "N/A";
    temperature = widget.pondData?["temperature"]?.toString() ?? "N/A";

    _initializeNotifications();
    _fetchRealtimeSalinity();
    _fetchRealtimeTemperature();
  }

  @override
  void dispose() {
    print("🛑 Disposing: Cancelling Timer...");
    if (_sensorLoggingTimer?.isActive ?? false) {
      _sensorLoggingTimer?.cancel();
    }
    super.dispose();
  }

  /// Initialize Awesome Notifications
  void _initializeNotifications() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'sensor_logs_channel',
          channelName: 'Sensor Logs',
          channelDescription: 'Logs salinity and temperature updates',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          ledColor: Colors.white,
        ),
      ],
      debug: true,
    );
  }

  /// Show notification for background updates
  // Future<void> _showNotification(String title, String body) async {
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: 1,
  //       channelKey: 'sensor_logs_channel',
  //       title: title,
  //       body: body,
  //       notificationLayout: NotificationLayout.Default,
  //     ),
  //   );
  // }

  /// Fetch real-time salinity from Firebase
  void _fetchRealtimeSalinity() {
    _sensorRef.child("salinity").onValue.listen((event) {
      var salinityData = event.snapshot.value;
      if (salinityData != null && mounted) {
        setState(() {
          salinity = salinityData.toString();
        });
      }
    }, onError: (error) {
      if (mounted) {
        print("Error fetching salinity: $error");
      }
    });
  }

  /// Fetch real-time temperature from Firebase
  void _fetchRealtimeTemperature() {
    _sensorRef.child("temperature").onValue.listen((event) {
      var tempData = event.snapshot.value;
      if (tempData != null && mounted) {
        setState(() {
          temperature = tempData.toString();
        });
      }
    }, onError: (error) {
      if (mounted) {
        print("Error fetching temperature: $error");
      }
    });
  }



  /// Start periodic sensor data logging every 5 seconds (for testing)
  // void _startSensorLogging() {
  //   if (_sensorLoggingTimer != null && _sensorLoggingTimer!.isActive) {
  //     print("⚠️ Sensor logging is already running.");
  //     return; // Prevent multiple timers
  //   }

  //   print("✅ Starting sensor logging every 5 seconds...");

  //   _sensorLoggingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
  //     print("⏳ Timer tick: Logging sensor data...");
  //     _logSensorData();
  //   });
  // }

  /// Log sensor data with timestamp to Firestore
  // Future<void> _logSensorData() async {
  //   print("🔍 Debugging Sensor Log:");
  //   print("🆔 Pond ID: $_pondId");
  //   print("🌊 Salinity: $salinity");
  //   print("🌡 Temperature: $temperature");

  //   if (salinity == null || temperature == null || widget.pondId == null) {
  //     print("⚠️ Cannot log data. Missing values.");
  //     return;
  //   }

  //   final data = {
  //     "salinity": double.tryParse(salinity ?? "0") ?? 0.0,
  //     "temperature": double.tryParse(temperature ?? "0") ?? 0.0,
  //     "timestamp": FieldValue.serverTimestamp(), // Firestore timestamp
  //   };

  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('species')
  //         .doc(widget.speciesName.toLowerCase())
  //         .collection('ponds')
  //         .doc(widget.pondId)
  //         .collection('sensor_logs')
  //         .add(data);

  //     print("✅ Sensor data logged successfully: $data");

  //     _showNotification(
  //       "Sensor Data Logged",
  //       "Salinity: ${salinity}ppt, Temperature: ${temperature}°C",
  //     );

  //     print("✅ Sensor data logged: $data");
  //   } catch (e) {
  //     print("❌ Error logging sensor data: $e");
  //   }
  // }

  Future<void> savePond() async {
    if (widget.userRole != "Laborer") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You do not have permission to perform this action.")),
      );
      return;
    }

    if (selectedLifeStage == null || selectedStatus == null || salinity == null || temperature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields and ensure sensor data is available")),
      );
      return;
    }

  final data = {
    "lifestage": selectedLifeStage,
    "status": selectedStatus,
    "salinity": double.tryParse(salinity ?? "0") ?? 0.0,
    "temperature": double.tryParse(temperature ?? "0") ?? 0.0,
    "timestamp": FieldValue.serverTimestamp(), // ✅ Add timestamp here
  };

  try {
    final pondCollection = FirebaseFirestore.instance
        .collection('species')
        .doc(widget.speciesName.toLowerCase())
        .collection('ponds');

    if (widget.pondId == null) {
      // ✅ Create new pond with timestamp
      DocumentReference newPondRef = await pondCollection.add(data);
      setState(() {
        _pondId = newPondRef.id;
      });
      print("✅ New pond created with ID: $_pondId");

      SensorLogger().startLogging(_pondId!, widget.speciesName);
    } else {
      // ✅ Update existing pond with new timestamp
      await pondCollection.doc(widget.pondId).update(data);
      print("✅ Pond updated with ID: ${widget.pondId}");

      SensorLogger().startLogging(widget.pondId!, widget.speciesName);
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
      backgroundColor: Colors.white,
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
      body: 
      SingleChildScrollView(
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
              Text("Salinity (ppt): ${salinity ?? 'Loading...'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text("Temperature (°C): ${temperature ?? 'Loading...'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 30),
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
