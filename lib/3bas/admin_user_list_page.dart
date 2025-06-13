import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'therapist_user_profile_page.dart'; // ✅ Ensure this exists for viewing user details

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Users")),
      body: _buildUserList(),
    );
  }

  // ✅ Fetch all users from Firestore
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildUserListItem(doc)).toList(),
        );
      },
    );
  }

  // ✅ Build user list item with navigation to profile
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("${data['firstName']} ${data['lastName']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text("📧 Email: ${data['email']}\n🧑‍⚕️ Role: ${data['role'] ?? 'User'}"),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TherapistUserProfilePage(userId: document.id), // ✅ View user details
            ),
          );
        },
      ),
    );
  }
}