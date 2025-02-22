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

import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/ponds.dart';

void main() {
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
