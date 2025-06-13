import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'therapist_user_profile_page.dart'; // ✅ Ensure this exists for viewing therapist details

class AdminTherapistListPage extends StatefulWidget {
  const AdminTherapistListPage({super.key});

  @override
  State<AdminTherapistListPage> createState() => _AdminTherapistListPageState();
}

class _AdminTherapistListPageState extends State<AdminTherapistListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Therapists")),
      body: _buildTherapistList(),
    );
  }

  // ✅ Fetch all therapists from Firestore
  Widget _buildTherapistList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('therapists').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading therapists.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildTherapistListItem(doc)).toList(),
        );
      },
    );
  }

  // ✅ Build therapist list item with navigation to profile
  Widget _buildTherapistListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("${data['firstName']} ${data['lastName']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text("📧 Email: ${data['email']}\n✅ Setup Complete: ${data['isSetupComplete'] == true ? "Yes" : "No"}"),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TherapistUserProfilePage(userId: document.id), // ✅ View therapist details
            ),
          );
        },
      ),
    );
  }
}