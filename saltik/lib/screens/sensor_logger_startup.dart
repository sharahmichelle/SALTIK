import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saltik/screens/sensor_logger.dart'; // path to your SensorLogger class

Future<void> startSensorLoggerOnStartup() async {
  List<String> speciesList = ['milkfish', 'shrimp (pacific white)', 'tilapia (nile)'];

  String? latestPondId;
  String? latestSpecies;
  Timestamp? latestTimestamp;

  for (String species in speciesList) {
    QuerySnapshot pondsSnapshot = await FirebaseFirestore.instance
        .collection('species')
        .doc(species.toLowerCase())
        .collection('ponds')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (pondsSnapshot.docs.isNotEmpty) {
      var doc = pondsSnapshot.docs.first;
      Timestamp? ts = doc['timestamp'];

      if (latestTimestamp == null || ts!.compareTo(latestTimestamp) > 0) {
        latestTimestamp = ts;
        latestPondId = doc.id;
        latestSpecies = species;
      }
    }
  }

  if (latestPondId != null && latestSpecies != null) {
    SensorLogger().startLogging(latestPondId, latestSpecies);
    print("✅ Started logging to latest pond: $latestPondId ($latestSpecies)");
  } else {
    print("⚠️ No valid pond found for logging.");
  }
}
