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
import 'package:saltik/screens/home_page.dart';
import 'package:saltik/screens/reservoir.dart';
import 'screens/splashscreen.dart';
import 'authenticate/signin.dart';
import 'screens/sensor_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

/// Start Sensor Logging on App Startup
// Future<void> startSensorLoggerOnStartup() async {
//   List<String> speciesList = ['milkfish', 'shrimp (pacific white)', 'tilapia (nile)'];

//   String? latestPondId;
//   String? latestSpecies;
//   Timestamp? latestTimestamp;

//   // Fetch the latest pond from all species
//   for (String species in speciesList) {
//     QuerySnapshot pondsSnapshot = await FirebaseFirestore.instance
//         .collection('species')
//         .doc(species.toLowerCase())
//         .collection('ponds')
//         .orderBy('timestamp', descending: true)
//         .limit(1)
//         .get();

//     if (pondsSnapshot.docs.isNotEmpty) {
//       var doc = pondsSnapshot.docs.first;
//       Timestamp? ts = doc['timestamp'];

//       if (latestTimestamp == null || ts!.compareTo(latestTimestamp) > 0) {
//         latestTimestamp = ts;
//         latestPondId = doc.id;
//         latestSpecies = species;
//       }
//     }
//   }

//   if (latestPondId != null && latestSpecies != null) {
//     // Start logging to the latest pond
//     SensorLogger().startLogging(latestPondId, latestSpecies);
//     print("✅ Started logging to latest pond: $latestPondId ($latestSpecies)");
//   } else {
//     print("⚠️ No valid pond found for logging.");
//   }
// }

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

  // Start real-time pond monitoring for the species list
  SensorLogger().startRealtimePondTracking([
    'milkfish',
    'shrimp (pacific white)',
    'tilapia (nile)',
  ]);

  // Optionally initialize notifications
  initializeNotifications();

  // Optionally start the sensor logger on app startup
  //startSensorLoggerOnStartup();

  //runApp(MyApp());
  final user = FirebaseAuth.instance.currentUser;
  final prefs = await SharedPreferences.getInstance();
  final userRole = prefs.getString('userRole');

  runApp(MyApp(
    isLoggedIn: user != null && userRole != null,
    userRole: userRole,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userRole;

  const MyApp({required this.isLoggedIn, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.workSansTextTheme(),
      ),
      home: isLoggedIn
          ? MainScreen(userRole: userRole!)
          : SplashScreen(),
    );
  }
}