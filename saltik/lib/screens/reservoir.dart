import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensor");

  String temperature = "Loading...";
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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
        child: Column(
          children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Padding(
                  padding: EdgeInsets.only(top: 0), 
                  child: Image.asset(
                  'lib/assets/saltik-logo-v1.png', 
                  height: 300, 
                  fit: BoxFit.contain,
                ),
                ),
                Transform.translate(
                offset: Offset(0, -70),
                child: Column(
                  children: [
                    _buildCircularIndicator("$salinity ppt", Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      "TILAPIA (NILE)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Average Salinity of Ponds",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      "0 ponds require immediate attention",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
                SizedBox(height: 0),
                Transform.translate(
                offset: Offset(0, -50),
                child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text("View Details"),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -10),
                child: Column(
                  children: [
                    _buildCircularIndicator("$temperature °C", Colors.grey),
              SizedBox(height: 10),
              Text(
                "Average Temperature",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ), 
              ],
          ),
            ],
          ),
      ),
      ),
    ), 
    );
  }

  Widget _buildCircularIndicator(String value, Color color) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
