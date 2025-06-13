import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/3bas/admin_chat_rooms_page.dart';

import 'admin_therapist_list_page.dart';
import 'admin_user_list_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalUsers = 0;
  int totalTherapists = 0;
  int pendingApprovals = 0;
  int chatRooms = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // ✅ Fetch admin dashboard stats from Firestore
  Future<void> _fetchDashboardData() async {
    QuerySnapshot chatRoomsSnapshot = await _firestore.collection("chat_rooms").get();
    QuerySnapshot usersSnapshot = await _firestore.collection("users").get();
    QuerySnapshot therapistsSnapshot =
        await _firestore.collection("therapists").get();
    QuerySnapshot pendingSnapshot = await _firestore
        .collection("therapists")
        .where("isSetupComplete", isEqualTo: false)
        .get();

    setState(() {
      totalUsers = usersSnapshot.docs.length;
      totalTherapists = therapistsSnapshot.docs.length;
      pendingApprovals = pendingSnapshot.docs.length;
      chatRooms = chatRoomsSnapshot.docs.length;
    });
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pop(context); // ✅ Redirect after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AdminUserListPage()));
                },
                child: _buildStatCard("Total Users", totalUsers, Icons.people)),
            GestureDetector(onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AdminTherapistListPage()));
            },
              child: _buildStatCard(
                  "Total Therapists", totalTherapists, Icons.medical_services),
            ),
            _buildStatCard(
                "Pending Approvals", pendingApprovals, Icons.hourglass_empty),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AdminChatRoomsPage()));
                },
                child: _buildStatCard("Chat Rooms", chatRooms, Icons.chat)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper function to display stats
  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blueAccent),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text("$count",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
