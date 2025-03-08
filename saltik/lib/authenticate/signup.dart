import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:saltik/screens/home_page.dart';
import 'package:uuid/uuid.dart';

Future<void> requestPermissions() async {
  await Permission.camera.request();
  await Permission.photos.request();
  await Permission.storage.request();
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _selectedRole = "Laborer";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    await requestPermissions();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _takePhoto() async {
    await requestPermissions();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = const Uuid().v4();
      Reference ref = FirebaseStorage.instance.ref().child('profileImage/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': _selectedRole,
        'profileImage': imageUrl ?? "",
      });

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      }
    } catch (e) {
      print("Error saving user data: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text(
        //   'Sign Up',
        //   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        // ),
        // centerTitle: true,
        // backgroundColor: Colors.white,
        // elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image Selection
                // _image != null
                //     ? CircleAvatar(radius: 50, backgroundImage: FileImage(_image!))
                //     : const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                // const SizedBox(height: 10),
                // const Text("Profile Photo", style: TextStyle(fontWeight: FontWeight.bold)),
                // const SizedBox(height: 5),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Column(
                //       children: [
                //         IconButton(icon: const Icon(Icons.photo, size: 40), onPressed: _pickImageFromGallery),
                //         const Text("Open Gallery"),
                //       ],
                //     ),
                //     const SizedBox(width: 20),
                //     Column(
                //       children: [
                //         IconButton(icon: const Icon(Icons.camera_alt, size: 40), onPressed: _takePhoto),
                //         const Text("Take Photo"),
                //       ],
                //     ),
                //   ],
                // ),
                Transform.translate(
                    offset: const Offset(0, -20),
                    child: Image.asset(
                      'lib/assets/saltik-logo-v2.png',
                      height: 100,
                    ),
                  ),
                const Text(
                    'SIGN UP',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),

                const SizedBox(height: 20),

                // Input Fields
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone Number',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter email or phone' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.length < 6 ? 'Password must be 6+ characters' : null,
                ),
                const SizedBox(height: 10),

                // Role Selection
                const Text("Select Role", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _selectedRole = "Laborer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == "Laborer" ? Color.fromARGB(255, 101, 186, 255) : Colors.grey[300],
                      ),
                      child: const Text("Laborer", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => setState(() => _selectedRole = "Researcher"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == "Researcher" ? Color.fromARGB(255, 101, 186, 255) : Colors.grey[300],
                      ),
                      child: const Text("Researcher", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
