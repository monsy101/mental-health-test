import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import Intl package for date formatting

class MoodHistoryPage extends StatefulWidget {
  @override
  _MoodHistoryPageState createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood History")),
      body: _buildMoodList(),
    );
  }

  // Fetch and display mood history ONLY for the logged-in user
  Widget _buildMoodList() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text("No authenticated user!", style: TextStyle(fontSize: 18)));
    }

    return StreamBuilder(
      stream: _firestore.collection("moodRecords").where("userId", isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        var moodList = snapshot.data?.docs ?? [];

        if (moodList.isEmpty) {
          return Center(child: Text("No mood records found.", style: TextStyle(fontSize: 18)));
        }

        // Sort moods locally by timestamp (oldest to newest)
        moodList.sort((a, b) => DateTime.parse(a["timestamp"]).compareTo(DateTime.parse(b["timestamp"])));

        return ListView.builder(
          itemCount: moodList.length,
          itemBuilder: (context, index) {
            var moodData = moodList[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: CircleAvatar(child: Text(moodData["mood"][0])), // Display first emoji from mood
              title: Text(moodData["mood"], style: TextStyle(fontSize: 18)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(moodData["timestamp"]), style: TextStyle(fontSize: 14, color: Colors.grey)), // Date format
                  if (moodData["note"] != null && moodData["note"].isNotEmpty) // Show note only if it exists
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text("📌 Note: ${_sanitizeText(moodData["note"])}", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Formats Firestore timestamp into a readable date format (DD/MM/YYYY)
  String _formatDate(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  // Cleans text to avoid invalid UTF-16 characters
  String _sanitizeText(String text) {
    return text.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), ''); // Remove non-UTF-16 characters
  }
}