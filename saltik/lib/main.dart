// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';
// // import 'screens/splashscreen.dart';

// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: 
// //       SplashScreen(),
// //     );
// //   }
// // }

// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'screens/splashscreen.dart';
// //import 'firebase_options.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:workmanager/workmanager.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//   options: FirebaseOptions(
//     apiKey: 'AIzaSyACbx9uRQf_gW85TYH09SRio8ra7dm2xK0',
//     appId: '1:261059511428:android:e8c7acc426b58a0bb9eed1',
//     messagingSenderId: '261059511428',
//     projectId: 'saltik-198',
//     storageBucket: 'saltik-198.firebasestorage.app',
//   )
// );

//   runApp(MyApp());
// }

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   //FirebaseDatabase.instance.setPersistenceEnabled(true);
// //   await Firebase.initializeApp();  // No FirebaseOptions needed
// //   runApp(MyApp());
// // }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         textTheme: GoogleFonts.workSansTextTheme(),
//       ),
//       home: SplashScreen(),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'screens/splashscreen.dart';

void initializeNotifications() {
  AwesomeNotifications().initialize(
    null, // Use default icon
    [
      NotificationChannel(
        channelKey: 'sensor_logs_channel',
        channelName: 'Sensor Logs',
        channelDescription: 'Logs salinity and temperature updates',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
  );

  // Request permission if needed
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}

Future<void> showNotification(String title, String body) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'sensor_logs_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
    ),
  );
}

/// Periodically logs salinity and temperature every hour
void startSensorLogging() {
  Timer.periodic(const Duration(minutes: 1), (Timer timer) async {  // Changed to 1 minute for testing
    try {
      DatabaseReference sensorRef = FirebaseDatabase.instance.ref("sensor");

      var salinitySnapshot = await sensorRef.child("salinity").get();
      var temperatureSnapshot = await sensorRef.child("temperature").get();

      if (salinitySnapshot.exists && temperatureSnapshot.exists) {
        double salinity = double.tryParse(salinitySnapshot.value.toString()) ?? 0.0;
        double temperature = double.tryParse(temperatureSnapshot.value.toString()) ?? 0.0;

        List<String> speciesList = ['milkfish', 'shrimp (pacific white)', 'tilapia (nile)']; // Replace with actual species names

        DocumentReference? latestDocRef;

        for (String species in speciesList) {
          // Get the latest pond for the species, sorted by timestamp descending
          QuerySnapshot pondSnapshot = await FirebaseFirestore.instance
              .collection('species')
              .doc(species.toLowerCase())
              .collection('ponds')
              .orderBy('timestamp', descending: true) // Order by timestamp, most recent first
              .limit(1)  // Only get the most recent pond
              .get();

          if (pondSnapshot.docs.isNotEmpty) {
            // Get the most recent pond reference
            latestDocRef = pondSnapshot.docs.first.reference;

            // Update the most recent pond document with the new sensor data
            await latestDocRef.update({
              "salinity": salinity,
              "temperature": temperature,
              //"timestamp": FieldValue.serverTimestamp(),  // Update the timestamp as well
            });

            // Show notification
            await showNotification(
              "Sensor Log Updated for $species",
              "Salinity: $salinity ppt, Temperature: $temperature°C",
            );

            print("✅ Updated most recent pond data successfully!");
          } else {
            print("⚠️ No ponds found for species: $species.");
          }
        }
      } else {
        print("⚠️ Failed to fetch salinity/temperature data.");
      }
    } catch (e) {
      print("❌ Error logging sensor data: $e");
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyACbx9uRQf_gW85TYH09SRio8ra7dm2xK0',
      appId: '1:261059511428:android:e8c7acc426b58a0bb9eed1',
      messagingSenderId: '261059511428',
      projectId: 'saltik-198',
      storageBucket: 'saltik-198.firebasestorage.app',
    ),
  );

  initializeNotifications();
  startSensorLogging(); // Start the periodic sensor logging

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.workSansTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}
