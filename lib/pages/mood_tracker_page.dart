import 'package:flutter/material.dart';
import 'package:monsy_weird_package/components/mood_component.dart';
import 'package:monsy_weird_package/components/my_colors.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors[1],
      appBar: AppBar(
        backgroundColor: MyColors[1],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: MyColors[3],
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // title
            Text(
              'Track Your Daily Mood',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: MyColors[0],
                  shadows: [
                    Shadow(color: Colors.grey.shade800, blurRadius: 30)
                  ]),
            ),
            SizedBox(
              height: 30,
            ),

            // text
            Text(
              "How Do You Feel Right Now?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 30,
            ),

            // moods

          ],
        ),
      ),
    );
  }
}
