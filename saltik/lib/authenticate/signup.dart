import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.camera.request();
  await Permission.photos.request();
  await Permission.storage.request(); // Required for older Android versions
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  File? _image; // Store selected/taken image
  final ImagePicker _picker = ImagePicker();
  String _selectedRole = "Laborer"; // Default role is "Laborer"

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    await requestPermissions();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  // Function to take a photo using the camera
  Future<void> _takePhoto() async {
    await requestPermissions();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Preview
              _image != null
                  ? CircleAvatar(radius: 50, backgroundImage: FileImage(_image!))
                  : const Icon(Icons.account_circle, size: 80, color: Colors.grey),

              const SizedBox(height: 10),
              const Text("Profile Photo", style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(icon: const Icon(Icons.photo, size: 40), onPressed: _pickImageFromGallery),
                      const Text("Open Gallery"),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      IconButton(icon: const Icon(Icons.camera_alt, size: 40), onPressed: _takePhoto),
                      const Text("Take Photo"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // First Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              // Last Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              // Email or Phone
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email or Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              // Password
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),

              // Role Selection
              const Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _selectedRole = "Laborer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == "Laborer" ? Colors.blue : Colors.grey[300], // Highlight selected role
                      foregroundColor: _selectedRole == "Laborer" ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Laborer"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => _selectedRole = "Researcher"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == "Researcher" ? Colors.blue : Colors.grey[300],
                      foregroundColor: _selectedRole == "Researcher" ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Researcher"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Create Account Button
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () => print("Selected Role: $_selectedRole"), // For testing
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(double.infinity, 30),
                  ),
                  child: const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
