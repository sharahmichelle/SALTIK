import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onProfileUpdated; // Add callback

  const EditProfilePage({Key? key, required this.userData, required this.onProfileUpdated}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}


class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userData['firstName'] ?? '';
    _lastNameController.text = widget.userData['lastName'] ?? '';
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = const Uuid().v4();
      Reference ref = FirebaseStorage.instance.ref().child('profileImages/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _updateProfile() async {
  setState(() => _isLoading = true);

  String firstName = _firstNameController.text.trim();
  String lastName = _lastNameController.text.trim();
  String? imageUrl = widget.userData['profileImageUrl'];

  if (_image != null) {
    imageUrl = await _uploadImage(_image!);
  }

  try {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': imageUrl,
    });

    widget.onProfileUpdated(); // Refresh ProfilePage after saving

    if (mounted) Navigator.pop(context);
  } catch (e) {
    print("Error updating profile: $e");
  }

  setState(() => _isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // GestureDetector(
              //   onTap: _showImageSourceDialog,
              //   child: CircleAvatar(
              //     radius: 60,
              //     backgroundImage: _image != null
              //         ? FileImage(_image!)
              //         : widget.userData['profileImageUrl'] != null
              //             ? NetworkImage(widget.userData['profileImageUrl'])
              //             : const AssetImage('lib/assets/icon-camera.png') as ImageProvider,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // TextButton(
              //   onPressed: _showImageSourceDialog,
              //   child: const Text(
              //     "Click here to change Profile Picture",
              //     style: TextStyle(color: Colors.black, ),
              //   ),
              // ),
              const SizedBox(height: 20),

              // First Name Input Field
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Last Name Input Field
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4, // 70% of screen width
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue button color
                    foregroundColor: Colors.white, // White font color
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes", style: TextStyle(fontSize: 15, )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
