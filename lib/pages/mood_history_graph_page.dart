import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodHistoryGraphPage extends StatefulWidget {
  @override
  _MoodHistoryGraphPageState createState() => _MoodHistoryGraphPageState();
}

class _MoodHistoryGraphPageState extends State<MoodHistoryGraphPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BarChartGroupData> moodDataBars = [];
  List<String> moodDates = [];

  @override
  void initState() {
    super.initState();
    _fetchMoodRecords();
  }

  void _fetchMoodRecords() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    var snapshot = await _firestore
        .collection("moodRecords")
        .where("userId", isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> moodEntries = [];

    for (var doc in snapshot.docs) {
      var moodText = doc["mood"];
      var timestamp = doc["timestamp"];
      var score = _convertMoodToScore(moodText);

      moodEntries.add({"score": score, "timestamp": timestamp});
    }

    // **Sort moods locally by timestamp (ascending)**
    moodEntries.sort((a, b) => DateTime.parse(a["timestamp"])
        .compareTo(DateTime.parse(b["timestamp"])));

    List<BarChartGroupData> bars = [];
    List<String> dates = [];
    int index = 0;

    for (var entry in moodEntries) {
      bars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry["score"].toDouble(),
              color: _getMoodColor(entry["score"]),
              width: 15,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      );
      dates.add(_formatDate(entry["timestamp"]));

      index++;
    }

    setState(() {
      moodDataBars = bars;
      moodDates = dates;
    });
  }

  int _convertMoodToScore(String mood) {
    if (mood.contains("Very Sad")) return 1;
    if (mood.contains("Sad")) return 2;
    if (mood.contains("Neutral")) return 3;
    if (mood.contains("Happy")) return 4;
    if (mood.contains("Very Happy")) return 5;
    return 3;
  }

  String _formatDate(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}";
  }

  Color _getMoodColor(int score) {
    return [
      Colors.red, // Very Sad
      Colors.orange, // Sad
      Colors.yellow, // Neutral
      Colors.green, // Happy
      Colors.blue // Very Happy
    ][score - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood History Graph")),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Mood Trends Over Time",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // Graph with controlled size
            SizedBox(
              height: 250,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Enables horizontal scrolling
                child: SizedBox(
                  width: moodDataBars.length * 40,
                  // Adjust width dynamically based on data
                  child: BarChart(
                    BarChartData(
                      barGroups: moodDataBars,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value < moodDates.length) {
                                return Text(moodDates[value.toInt()],
                                    style: TextStyle(fontSize: 12));
                              }
                              return Text("");
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Mood Improvement Percentage Display
            Text(
              _calculateMoodImprovement(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),
            Text(
              _predictNextMood(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // Placeholder for extra content
            ElevatedButton(
              onPressed: () {},
              child: Text("nseet akon family frindly"),
            ),
          ],
        ),
      ),
    );
  }

// Function to calculate mood improvement percentage
  String _calculateMoodImprovement() {
    if (moodDataBars.length < 7)
      return "Not enough data to calculate improvement.";

    // Get last 7 mood scores
    List<double> last7Moods = moodDataBars
        .sublist(moodDataBars.length - 7)
        .map((bar) => bar.barRods[0].toY)
        .toList();

    // Split into two groups: Last 3 moods vs Previous 4 moods
    double recentAverage = last7Moods.sublist(4).reduce((a, b) => a + b) / 3;
    double previousAverage =
        last7Moods.sublist(0, 4).reduce((a, b) => a + b) / 4;

    // Calculate percentage improvement
    double improvement = ((recentAverage - previousAverage) / 5) * 100;

    return improvement >= 0
        ? "Mood has improved by ${improvement.toStringAsFixed(1)}% over the last 7 records 🎉"
        : "Mood has dropped by ${improvement.abs().toStringAsFixed(1)}% over the last 7 records 😔";
  }

  String _predictNextMood() {
    if (moodDataBars.length < 7) return "Not enough data to predict mood.";

    // Get last 7 mood scores
    List<double> last7Moods = moodDataBars
        .sublist(moodDataBars.length - 7)
        .map((bar) => bar.barRods[0].toY)
        .toList();

    // Calculate the trend slope (rate of mood change)
    double trendSlope = (last7Moods.last - last7Moods.first) /
        6; // Approximate trend over 7 entries

    // Predict next mood based on trend
    double predictedMood = last7Moods.last + trendSlope;

    // Ensure prediction stays within valid range (1-5)
    predictedMood = predictedMood.clamp(1, 5);

    // Convert score back to mood description
    String moodText = _convertScoreToMood(predictedMood);

    return "📈 Predicted Mood in a Week: $moodText";
  }

  String _convertScoreToMood(double score) {
    if (score <= 1.5) return "😞 Very Sad";
    if (score <= 2.5) return "🙁 Sad";
    if (score <= 3.5) return "😐 Neutral";
    if (score <= 4.5) return "🙂 Happy";
    return "😃 Very Happy";
  }
}
