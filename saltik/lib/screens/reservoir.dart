import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ReservoirPage extends StatefulWidget {
  @override
  _ReservoirPageState createState() => _ReservoirPageState();
}

class _ReservoirPageState extends State<ReservoirPage> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensor");

  String temperature = "Loading...";
  String ecValue = "Loading...";
  String salinity = "Loading...";

  @override
  void initState() {
    super.initState();
    // Listen for real-time updates
    _sensorRef.onValue.listen((DatabaseEvent event) {
      var data = event.snapshot.value as Map<dynamic, dynamic>?; // Convert snapshot to Map
      if (data != null) {
        setState(() {
          temperature = data["temperature"].toString();
          ecValue = data["ec_value"].toString();
          salinity = data["salinity"].toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservoir Sensor Data")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🌡️ Temperature: $temperature °C", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("⚡ EC Value: $ecValue", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("🌊 Salinity: $salinity", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
