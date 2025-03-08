import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import 'package:saltik/authenticate/signin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = _auth.currentUser;
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Stay on page
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Proceed
              child: const Text("Yes"),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteAccount() async {
    bool confirmDelete = await _showConfirmationDialog(
      context,
      "Delete Account",
      "Are you sure you want to delete your account? This action cannot be undone.",
    );

    if (confirmDelete) {
      try {
        String userId = _user!.uid;

        // Delete user data from Firestore
        await _firestore.collection('users').doc(userId).delete();

        // Delete the user from Firebase Authentication
        await _user!.delete();

        // Navigate to SignInPage after deletion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } catch (e) {
        print("Error deleting account: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _userData == null
                ? const Text("No user data available")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Image.asset(
                          'lib/assets/saltik-logo-v2.png',
                          height: 50,
                        ),
                      ),

                      // Profile picture
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 15),
                      //   child: CircleAvatar(
                      //     radius: 60,
                      //     backgroundImage: _userData!['profileImageUrl'] != null
                      //         ? NetworkImage(_userData!['profileImageUrl'])
                      //         : const AssetImage('lib/assets/icon-camera.png') as ImageProvider,
                      //   ),
                      // ),

                      // Name
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          "${_userData!['firstName']} ${_userData!['lastName']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Job title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 39),
                        child: Text(
                          _userData!['role'] ?? 'Unknown Role',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      // Contact info
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: const Text(
                          "Email or Phone Number:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Text(
                          _userData!['email'] ?? 'No contact info',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                      ),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ElevatedButton(
                          //   onPressed: () async {
                          //     await Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => EditProfilePage(
                          //           userData: _userData!,
                          //           onProfileUpdated: _fetchUserData,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.blue,
                          //     foregroundColor: Colors.white,
                          //   ),
                          //   child: const Text("Edit Profile"),
                          // ),

                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              bool confirmLogout = await _showConfirmationDialog(
                                context,
                                "Log Out",
                                "Are you sure you want to log out?",
                              );

                              if (confirmLogout) {
                                await _auth.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignInPage()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Log out"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Delete Account"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
