import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/permissons/permissions.dart';
import 'LandingPage.dart';

// Define custom colors
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color cardBackground = Colors.white;
const Color accentGreen = Color(0xFFE0FFEA);

class TherapistProfilePage extends StatefulWidget {
  const TherapistProfilePage({super.key});

  @override
  State<TherapistProfilePage> createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();

  bool _isLoading = true;
  String userId = "";
  String profilePicUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchTherapistData();
  }

  Future<void> _fetchTherapistData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      userId = user.uid;
    });

    DocumentSnapshot doc = await _firestore.collection("therapists").doc(user.uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _qualificationController.text = data['subscriptionPrice'] ?? '';
        profilePicUrl = data['profilePicUrl'] ?? "";
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTherapistData() async {
    try {
      await _firestore.collection("therapists").doc(userId).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'subscriptionPrice': _qualificationController,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $error"), backgroundColor: Colors.red),
      );
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const LandingPage()),
    );
  }

  Future<void> _uploadProfilePicture() async {
    await requestStoragePermission(context);

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected"), backgroundColor: Colors.orange),
      );
      return;
    }

    File file = File(image.path);

    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Selected file does not exist"), backgroundColor: Colors.red),
      );
      return;
    }

    String fileName = "therapist_pictures/$userId.jpg";

    try {
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection("therapists").doc(userId).update({'profilePicUrl': downloadUrl});

      setState(() {
        profilePicUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading picture: $error"), backgroundColor: Colors.red),
      );
    }
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
            title: const Text("Therapist Profile"),
            centerTitle: true,
            backgroundColor: primaryGreen,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _uploadProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                  backgroundColor: Colors.grey[300],
                  child: profilePicUrl.isEmpty ? Icon(Icons.person, size: 50, color: Colors.white) : null,
                ),
              ),
              const SizedBox(height: 10),
              Text("Tap to change profile picture", style: TextStyle(color: secondaryText, fontSize: 14)),
              const SizedBox(height: 20),
              _buildEditableProfileCard("First Name", _firstNameController),
              _buildEditableProfileCard("Last Name", _lastNameController),
              _buildEditableProfileCard("Email", _emailController),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTherapistData,
                child: const Text("Update Profile"),
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  backgroundColor: primaryGreen,
                  foregroundColor: lightBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signOut,
                child: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableProfileCard(String label, TextEditingController controller) {
    return Card(
      elevation: 4,
      color: cardBackground,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText)),
            TextField(
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none),
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}