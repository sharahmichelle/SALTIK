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
    _initializeFirebaseListeners();
  }

  void _initializeFirebaseListeners() {
    _sensorRef.child("temperature").onValue.listen((event) {
      var tempData = event.snapshot.value;
      if (tempData != null) {
        setState(() {
          temperature = tempData.toString();
        });
      }
    });

    _sensorRef.child("ec_value").onValue.listen((event) {
      var ecData = event.snapshot.value;
      if (ecData != null) {
        setState(() {
          ecValue = ecData.toString();
        });
      }
    });

    _sensorRef.child("salinity").onValue.listen((event) {
      var salinityData = event.snapshot.value;
      if (salinityData != null) {
        setState(() {
          salinity = salinityData.toString();
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
            Text("\ud83c\udf21\ufe0f Temperature: $temperature °C", style: TextStyle(fontSize: 24)),
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
