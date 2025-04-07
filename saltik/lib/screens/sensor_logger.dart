import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class SensorLogger {
  static final SensorLogger _instance = SensorLogger._internal();
  factory SensorLogger() => _instance;
  SensorLogger._internal();

  Timer? _timer;
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensor");
  String? _pondId;
  String? salinity = "N/A";
  String? temperature = "N/A";

  /// Start logging sensor data every 5 seconds
  void startLogging(String pondId, String speciesName) {
    if (_timer != null && _timer!.isActive) {
      print("⚠️ Sensor logging is already running.");
      return;
    }

    _pondId = pondId;
    _fetchRealtimeSensorData();

    print("✅ Starting background sensor logging for Pond ID: $_pondId");

    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {   // change for testing purposes
      print("⏳ Timer tick: Logging sensor data...");
      _logSensorData(speciesName);
    });
  }

  /// Fetch real-time salinity & temperature
  void _fetchRealtimeSensorData() {
    _sensorRef.child("salinity").onValue.listen((event) {
      var data = event.snapshot.value;
      if (data != null) salinity = data.toString();
    });

    _sensorRef.child("temperature").onValue.listen((event) {
      var data = event.snapshot.value;
      if (data != null) temperature = data.toString();
    });
  }

  /// Log data to Firestore
  Future<void> _logSensorData(String speciesName) async {
    if (_pondId == null || salinity == null || temperature == null) {
      print("⚠️ Cannot log data. Missing values.");
      return;
    }

    final data = {
      "salinity": double.tryParse(salinity ?? "0") ?? 0.0,
      "temperature": double.tryParse(temperature ?? "0") ?? 0.0,
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('species')
          .doc(speciesName.toLowerCase())
          .collection('ponds')
          .doc(_pondId)
          .collection('sensor_logs')
          .add(data);

      print("✅ Sensor data logged successfully: $data");

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'sensor_logs_channel',
          title: "Sensor Data Logged",
          body: "Salinity: ${salinity}ppt, Temperature: ${temperature}°C",
        ),
      );
    } catch (e) {
      print("❌ Error logging sensor data: $e");
    }
  }
}