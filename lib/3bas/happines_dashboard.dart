import 'package:flutter/material.dart';

import '../mood/mood_history_graph_page.dart';
import '../mood/mood_history_page.dart';
import '../mood/mood_page_test_one.dart';

class HappinessDashboard extends StatelessWidget {
  const HappinessDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Happiness Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNavigationCard(context, "Track Happiness ", Colors.green, HappinessLevelPage()),
            _buildNavigationCard(context, "Mood History ", Colors.blueAccent, MoodHistoryPage() ),
            _buildNavigationCard(context, "Mood History Graph ", Colors.orange, MoodHistoryGraphPage()),
          ],
        ),
      ),
    );
  }

  // ✅ Helper function to create navigation cards
  Widget _buildNavigationCard(BuildContext context, String title, Color color, Widget page) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.8),
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
      ),
    );
  }
}