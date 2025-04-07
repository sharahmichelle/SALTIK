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
  StreamSubscription? _timestampSubscription;

  /// Start logging sensor data every 10 minutes
  void startLogging(String pondId, String speciesName) {
  // Cancel existing timer if there is one
  if (_timer != null && _timer!.isActive) {
    print("🛑 Cancelling existing timer...");
    _timer!.cancel();
  }

  // Start logging if timer is not active
  if (_timer == null || !_timer!.isActive) {
    _pondId = pondId;
    print("✅ Starting sensor logging for Pond ID: $_pondId, Species: $speciesName");

    _fetchRealtimeSensorData();

    _timer = Timer.periodic(const Duration(hours: 1), (timer) {    
      print("⏳ Timer tick: Logging sensor data...");
      _logSensorData(speciesName);
    });
  } else {
    print("! Sensor logging is already running.");
  }
}

  /// Real-time tracking of the pond to ensure we are logging to the most recent pond based on timestamp
  void startRealtimePondTracking(List<String> speciesList) {
  _timestampSubscription?.cancel();  // Cancel any previous subscriptions

  // Listen for changes to the pond timestamps across all species
  for (String species in speciesList) {
    FirebaseFirestore.instance
        .collection('species')
        .doc(species.toLowerCase())
        .collection('ponds')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((pondSnapshot) {
      if (pondSnapshot.docs.isNotEmpty) {
        var latestDoc = pondSnapshot.docs.first;
        Timestamp? newTimestamp = latestDoc['timestamp'];
        String newPondId = latestDoc.id;

        if (_pondId != newPondId) {
          _pondId = newPondId;
          print("✅ Switched to latest pond: $newPondId for species $species");

          // Cancel the previous logging timer and start logging the new pond
          startLogging(_pondId!, species);
        }
      }
    });
  }
}

  /// Fetch real-time and initial salinity & temperature values
  void _fetchRealtimeSensorData() async {
    var salinitySnap = await _sensorRef.child("salinity").get();
    var tempSnap = await _sensorRef.child("temperature").get();

    if (salinitySnap.exists) salinity = salinitySnap.value.toString();
    if (tempSnap.exists) temperature = tempSnap.value.toString();

    _sensorRef.child("salinity").onValue.listen((event) {
      if (event.snapshot.value != null) {
        salinity = event.snapshot.value.toString();
      }
    });

    _sensorRef.child("temperature").onValue.listen((event) {
      if (event.snapshot.value != null) {
        temperature = event.snapshot.value.toString();
      }
    });
  }

  /// Log data to Firestore
  Future<void> _logSensorData(String speciesName) async {
    if (_pondId == null || salinity == null || temperature == null) {
      print("⚠️ Missing pondId or sensor values. Cannot log.");
      return;
    }

    double sal = double.tryParse(salinity ?? "0") ?? 0.0;
    double temp = double.tryParse(temperature ?? "0") ?? 0.0;

    final data = {
      "salinity": sal,
      "temperature": temp,
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

      print("✅ Sensor data logged: $data");

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          channelKey: 'sensor_logs_channel',
          title: "Sensor Log Saved for ${speciesName}",
          body: "Salinity: ${sal}ppt, Temperature: ${temp}°C",
        ),
      );
    } catch (e) {
      print("❌ Error logging sensor data: $e");
    }
  }
}
