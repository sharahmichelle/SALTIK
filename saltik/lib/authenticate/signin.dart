import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Show loading state

  Future<void> _signIn() async {
    setState(() => _isLoading = true); // Show loading indicator

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to the next screen on success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );

      // TODO: Navigate to Home Page or Dashboard
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";

      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password. Try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, -20),
                child: Image.asset(
                  'lib/assets/saltik-logo-v2.png', 
                  height: 250,
                ),
              ),
              const Text(
                'SIGN IN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Email Input
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email or Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              // Password Input
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),

              // Sign In Button
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 30),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Show loader
                      : const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              // Sign Up Link
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No account? '),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
