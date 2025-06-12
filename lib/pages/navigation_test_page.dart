import 'package:flutter/material.dart';

import 'mood_history_graph_page.dart';
import 'mood_history_page.dart';
import 'mood_page_test_one.dart';

class NavigationTestPage extends StatelessWidget {
  const NavigationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            HappinessLevelPage()));
              },
              child: Text('to HappinessLevelPage')),
          ElevatedButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        MoodHistoryPage()));
          }, child: Text('to MoodHistoryPage')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            MoodHistoryGraphPage()));
              }, child: Text('to MoodHistoryGraphPage')),
          ElevatedButton(onPressed: () {}, child: Text('to ')),
        ],
      ),
    );
  }
}
