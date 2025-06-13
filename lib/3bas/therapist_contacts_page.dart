import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/chat_page.dart';
import '../services/auth/auth_service.dart';


class TherapistContactsPage extends StatefulWidget {
  const TherapistContactsPage({super.key});

  @override
  State<TherapistContactsPage> createState() => _TherapistContactsPageState();
}

class _TherapistContactsPageState extends State<TherapistContactsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a Therapist"),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _buildTherapistList(), // ✅ Display verified therapists
    );
  }

  // ✅ Fetch therapists from Firestore
  Widget _buildTherapistList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('therapists')
          .where('isSetupComplete', isEqualTo: true) // ✅ Show only verified therapists
          .snapshots(),
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

  // ✅ Build therapist list item
  Widget _buildTherapistListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("${data['firstName']} ${data['lastName']}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📧 Email: ${data['email']}"),
            Text("📞 Phone: ${data['phoneNumber'] ?? 'N/A'}"),
            Text("🏥 Clinic: ${data['clinicAddress'] ?? 'Not provided'}"),
            Text("🎓 Education: ${data['education'] ?? 'Not listed'}"),
            Text("🧑‍⚕️ Specialties: ${data['specialties']?.join(', ') ?? 'Not listed'}"),
          ],
        ),
        isThreeLine: true,
        trailing: Icon(Icons.chat, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'],
                receiverUserID: document.id, // Use document ID as user identifier
              ),
            ),
          );
        },
      ),
    );
  }
}