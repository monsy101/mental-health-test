import 'package:flutter/material.dart';
import 'big_toe_pose_widget.dart';
import 'bridge_pose_widget.dart';
import 'hare_pose_widget.dart';
import 'supported_side_plank_pose_widget.dart';
import 'wind_relieving_pose_widget.dart';

class YogaPosesDashboard extends StatelessWidget {
  const YogaPosesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yoga Poses Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildYogaPoseCard(context, "Big Toe Pose", BigToePoseWidget(), Colors.green),
            _buildYogaPoseCard(context, "Bridge Pose", BridgePoseWidget(), Colors.blue),
            _buildYogaPoseCard(context, "Hare Pose", HarePoseWidget(), Colors.orange),
            _buildYogaPoseCard(context, "Supported Side Plank", SupportedSidePlankPoseWidget(), Colors.purple),
            _buildYogaPoseCard(context, "Wind Relieving Pose", WindRelievingPoseWidget(), Colors.red),
          ],
        ),
      ),
    );
  }

  // ✅ Helper function to create navigation cards
  Widget _buildYogaPoseCard(BuildContext context, String title, Widget page, Color color) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: Center(
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}