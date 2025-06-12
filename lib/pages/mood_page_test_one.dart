import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HappinessLevelPage extends StatefulWidget {
  @override
  _HappinessLevelPageState createState() => _HappinessLevelPageState();
}

class _HappinessLevelPageState extends State<HappinessLevelPage> {
  String selectedMood = "Select your happiness level";
  String currentSelection = "";
  final TextEditingController _noteController = TextEditingController(); // Controller for mood note
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseRadius = screenWidth / 5;

    return Scaffold(
      appBar: AppBar(title: const Text("Happiness Levels")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(selectedMood, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          // Row of mood icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodAvatar("😞", "Very Sad", Colors.red[300]!, baseRadius),
              _buildMoodAvatar("🙁", "Sad", Colors.orange[300]!, baseRadius),
              _buildMoodAvatar("😐", "Neutral", Colors.yellow[300]!, baseRadius),
              _buildMoodAvatar("🙂", "Happy", Colors.green[300]!, baseRadius),
              _buildMoodAvatar("😃", "Very Happy", Colors.blue[300]!, baseRadius),
            ],
          ),

          const SizedBox(height: 20),

          // Text field for user to add a note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "Add a note about your mood",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ),

          const SizedBox(height: 20),

          // Confirmation button
          ElevatedButton(
            onPressed: saveMoodRecord,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text("Confirm Mood"),
          ),
        ],
      ),
    );
  }

  // Function to store mood, timestamp, and user note in Firestore
  void saveMoodRecord() async {
    if (currentSelection.isEmpty) {
      _showSnackbar("⚠️ Please select a mood before confirming.");
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) {
      _showSnackbar("❌ No authenticated user.");
      return;
    }

    Map<String, dynamic> moodRecord = {
      "timestamp": DateTime.now().toIso8601String(),
      "mood": selectedMood,
      "note": _noteController.text.trim(), // Include user note
      "userId": user.uid,
    };

    try {
      await _firestore.collection("moodRecords").add(moodRecord);
      _showSnackbar("✅ Mood recorded successfully!");
      _noteController.clear(); // Clear note input after saving
    } catch (error) {
      _showSnackbar("❌ Error saving mood record. $error");
    }
  }

  // Helper function for showing Snackbar notifications
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontSize: 16))),
    );
  }

  // Helper function to create circular mood avatars
  Widget _buildMoodAvatar(String emoji, String moodText, Color bgColor, double baseRadius) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = "$emoji $moodText";
          currentSelection = moodText;
        });
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(
          begin: baseRadius * 0.4,
          end: currentSelection == moodText ? baseRadius * 0.55 : baseRadius * 0.4,
        ),
        builder: (context, radius, child) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: bgColor,
            child: Text(emoji, style: TextStyle(fontSize: radius * 0.6)),
          );
        },
      ),
    );
  }
}