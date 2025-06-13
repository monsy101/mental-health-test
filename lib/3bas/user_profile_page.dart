import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/3bas/LandingPage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ✅ Load user data when page opens
  }

  // ✅ Fetch user data from Firestore
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
        _isLoading = false;
      });
    }
  }

  // ✅ Update user info in Firestore
  Future<void> _updateUserData() async {
    try {
      await _firestore.collection("users").doc(userId).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error updating profile: $error"),
            backgroundColor: Colors.red),
      );
    }
  }

  // ✅ Sign out function
  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                const LandingPage())); // ✅ Redirect user after sign-out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // ✅ Show loader while fetching data
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: "First Name")),
                  TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: "Last Name")),
                  TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email")),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserData,
                    child: const Text("Update Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Spacer(), // ✅ Pushes sign-out button to the bottom
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text("Sign Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
