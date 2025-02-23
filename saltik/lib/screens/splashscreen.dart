import 'package:flutter/material.dart';
//import 'home_page.dart';
import 'package:saltik/authenticate/signin.dart';
import 'package:saltik/screens/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/icon.jpg', // Ensure you have this image in assets folder
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_right, size: 50, color: Colors.white),
              onPressed: () {
                debugPrint("Button Pressed! Navigating to SignInPage...");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}