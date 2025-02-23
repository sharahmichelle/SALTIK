// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'screens/splashscreen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: 
//       SplashScreen(),
//     );
//   }
// }

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splashscreen.dart';
//import 'firebase_options.dart'; // Ensure this file exists
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: 'AIzaSyACbx9uRQf_gW85TYH09SRio8ra7dm2xK0',
    appId: '1:261059511428:android:e8c7acc426b58a0bb9eed1',
    messagingSenderId: '261059511428',
    projectId: 'saltik-198',
    storageBucket: 'saltik-198.firebasestorage.app',
  )
);

  runApp(MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   //FirebaseDatabase.instance.setPersistenceEnabled(true);
//   await Firebase.initializeApp();  // No FirebaseOptions needed
//   runApp(MyApp());
// }

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