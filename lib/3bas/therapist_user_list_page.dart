import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/3bas/therapist_user_profile_page.dart';
import 'package:provider/provider.dart';
import '../pages/chat_page.dart';
import '../services/auth/auth_service.dart';



// Define custom colors based on your specifications and image analysis
const Color primaryGreen = Color(0xFF91EEA5); // The main green color
const Color lightBackground =
Color(0xFFF1F4F8); // Background color for the page
const Color primaryText = Color(0xFF14181B); // Main dark text color
const Color secondaryText = Color(0xFF57636C); // Hint text, descriptive text
const Color cardBackground = Colors.white; // Background for cards
const Color accentGreen = Color(
    0xFFE0FFEA); // Lighter green for checkmark background (approximated from image)

class TherapistUserListPage extends StatefulWidget {
  const TherapistUserListPage({super.key});

  @override
  State<TherapistUserListPage> createState() => _TherapistUserListPageState();
}

class _TherapistUserListPageState extends State<TherapistUserListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text("Users"),
            centerTitle: true,
            backgroundColor: primaryGreen,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildUserList(),
      ),
    );
  }

  // ✅ Fetch all users from Firestore
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  // ✅ Build user list item with null safety
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    String userEmail = data['email'] ?? 'No Email Found';
    String userID = data['uid'] ?? ''; // ✅ Prevents null errors
    String userRole = data['role'] ?? 'User'; // ✅ Displays role

    if (_auth.currentUser!.email != userEmail) {
      return Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(userEmail,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          // ✅ Display role info
          trailing: Icon(Icons.chat, color: Colors.green),
          onTap: () {
            if (userID.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: userEmail,
                    receiverUserID: userID,
                  ),
                ),
              );
            } else {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text("Error: User ID is missing"),
              //     backgroundColor: Colors.red,
              //     duration: Duration(seconds: 2),
              //   ),
              // );
            }
          },
          leading: GestureDetector(
            child: CircleAvatar(child: Icon(Icons.person)),
            onTap: () {
              print("test");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          TherapistUserProfilePage(
                            userId: userID,
                          )));
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
