import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TherapistUserProfilePage extends StatefulWidget {
  final String userId; // ✅ Receives user ID from navigation

  const TherapistUserProfilePage({super.key, required this.userId});

  @override
  State<TherapistUserProfilePage> createState() => _TherapistUserProfilePageState();
}

class _TherapistUserProfilePageState extends State<TherapistUserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ✅ Load user data when page opens
  }

  // ✅ Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(widget.userId).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data() as Map<String, dynamic>;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: User profile not found"), backgroundColor: Colors.red),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // ✅ Show loader while fetching data
          : userData == null
          ? Center(child: Text("User data not available"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReadOnlyField("First Name", userData!['firstName']),
            _buildReadOnlyField("Last Name", userData!['lastName']),
            _buildReadOnlyField("Email", userData!['email']),
            _buildReadOnlyField("Role", userData!['role'] ?? "User"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper function for read-only fields
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}