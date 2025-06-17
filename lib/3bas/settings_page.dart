import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsy_weird_package/3bas/LandingPage.dart';

import '../services/permissons/permissions.dart';
import 'package:about/about.dart';

// Define custom colors
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color cardBackground = Colors.white;
const Color accentGreen = Color(0xFFE0FFEA);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;
  String userId = "";
  String profilePicUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      userId = user.uid;
    });

    DocumentSnapshot doc =
        await _firestore.collection("users").doc(user.uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
        profilePicUrl = data['profilePicUrl'] ?? "";
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    try {
      await _firestore.collection("users").doc(userId).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text("Profile updated successfully!"),
      //       backgroundColor: Colors.green),
      // );
    } catch (error) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text("Error updating profile: $error"),
      //       backgroundColor: Colors.red),
      // );
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text("User Profile"),
            centerTitle: true,
            backgroundColor: primaryGreen,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Material(
                        elevation: 4, // Adjust elevation as needed
                        shape: CircleBorder(),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl)
                              : null,
                          backgroundColor: cardBackground,
                          child: profilePicUrl.isEmpty
                              ? Icon(Icons.person,
                                  size: 50, color: primaryGreen)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 30),
                      _buildEditableProfileCard(
                        "User Name",
                        '${_firstNameController.text} ${_lastNameController.text}',
                      ),
                      _buildEditableProfileCard(
                        "Email",
                        _emailController.text,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: const Text("Edit Profile info"),
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                        onPressed: () {
                          showAboutPage(
                            context: context,
                            values: {
                              'version': '1.016',
                              'year': DateTime.now().year.toString(),
                            },
                            applicationLegalese:
                                'Copyright © TherapuTech team SAMS, {{ year }}',
                            applicationDescription: const Text(
                                'Displays an About dialog, which describes the application.'),
                            children: const <Widget>[
                              MarkdownPageListTile(
                                icon: Icon(Icons.list),
                                title: Text('Changelog'),
                                filename: 'CHANGELOG.md',
                              ),
                              LicensesPageListTile(
                                icon: Icon(Icons.favorite),
                              ),
                            ],
                            applicationIcon: const SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: AssetImage('assets/icon/app_logo.jpg'),

                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Show App Info",
                          style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 6,
                          backgroundColor: primaryGreen,
                          foregroundColor: cardBackground,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      // Sign out button
                      ElevatedButton(
                        onPressed: _signOut,
                        child: const Text("Sign Out"),
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEditableProfileCard(String label, String controller) {
    return SizedBox(
      width: double.infinity, // Makes it take full screen width
      child: Card(
        elevation: 4,
        color: cardBackground,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText)),
              Text(controller,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText)),
            ],
          ),
        ),
      ),
    );
  }
}
