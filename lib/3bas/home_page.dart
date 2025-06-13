// File: lib/home_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user info
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations
import 'package:monsy_weird_package/3bas/tasks_page.dart';
import 'package:monsy_weird_package/3bas/user_profile_page.dart';
import 'package:monsy_weird_package/3bas/visual_memory_game_screen.dart';
import 'package:monsy_weird_package/pages/ai_chat_page.dart';
import '../pages/contacts_page.dart';
import '../pages/mood_page_test_one.dart';
import '../pages/yoga_page.dart';
import 'BreathingExerciseScreen.dart';
import 'LandingPage.dart';
import 'game_screen.dart'; // For random data generation

// Import your TasksPage here
// Adjust path if needed

// Define custom colors based on your specifications and image analysis
const Color primaryGreen = Color(0xFF91EEA5); // The main green color
const Color lightBackground =
    Color(0xFFF1F4F8); // Background color for the page
const Color primaryText = Color(0xFF14181B); // Main dark text color
const Color secondaryText = Color(0xFF57636C); // Hint text, descriptive text
const Color cardBackground = Colors.white; // Background for cards
const Color accentGreen = Color(
    0xFFE0FFEA); // Lighter green for checkmark background (approximated from image)


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Text editing controller for the "Talk to us..." field
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;
  List<Map<String, dynamic>> exercisePages = [
    {
      "pageTitle": "Number Memory Game",
      "description": "Improve your short term memory for numbers.",
      "navigation": const GameScreen(),
      "icon": const Icon(CupertinoIcons.number_square_fill,size: 100,color: primaryGreen,)
    },
    {
      "pageTitle": "Visual Memory Game",
      "description": "boost cognitive function by sharpening the ability to recall and process visual information.",
      "navigation": const VisualMemoryGameScreen(),
      "icon": const Icon(CupertinoIcons.eye,size: 100,color: primaryGreen,)
    },
    {
      "pageTitle": "Breathing Exercise",
      "description": "Help regulate the nervous system, reducing stress and promoting a sense of calm which positively impacts mental well-being.",
      "navigation": const BreathingExerciseScreen(),
      "icon": const Icon(Icons.air,size: 100,color: primaryGreen,)
    },
    {
      "pageTitle": "Yoga",
      "description": "Improves mental health by integrating movement, breath, and meditation to reduce stress and anxiety.",
      "navigation": const YogaPage(),
      "icon": const Icon(Icons.self_improvement,size: 100,color: primaryGreen,)
    },
  ];


  // For the bottom navigation bar
  int _selectedIndex = 0;
  final List<Widget> _screens = [HomePage(), Placeholder(), ContactsPage()];// Current selected tab index

  // Current authenticated user
  User? currentUser;
  String? _firstName; // New: State variable to store the first name

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();

    // Initialize current user
    currentUser = FirebaseAuth.instance.currentUser;

    // Fetch user's first name from FireStore
    _fetchUserName();

    // Generate random data for recommended exercises
    // Example: 5 exercises
  }

  // New function to fetch user's first name
  Future<void> _fetchUserName() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['firstName'] as String? ??
                currentUser?.displayName?.split(' ').first ??
                'Guest';
          });
        } else {
          setState(() {
            _firstName = currentUser?.displayName?.split(' ').first ?? 'Guest';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User document does not exist for UID: ${currentUser!.uid}'),
              backgroundColor: Colors.red, // Highlight error in red
              duration: const Duration(seconds: 3), // Visible for 3 seconds
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _firstName = currentUser?.displayName?.split(' ').first ??
              'Guest'; // Fallback to display name or 'Guest'
        });
      }
    } else {
      setState(() {
        _firstName = 'Guest'; // Set to 'Guest' if no user is logged in
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  // Function to toggle task completion status in Firestore
  Future<void> _toggleTaskCompletion(String taskId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'completed': !currentStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task $taskId completion status toggled to ${!currentStatus}'),
          backgroundColor: Colors.green, // ✅ Use green for success feedback
          duration: const Duration(seconds: 2), // ✅ Keep it short for quick updates
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling task completion: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      // Optionally show an alert to the user
      _showAlertDialog(
          'Error', 'Failed to update task completion. Please try again.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseRadius = screenWidth / 10;
    // If no user is logged in, show a message or redirect
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view this page.'),
        ),
      );
    }

    // Get the start and end of the current day for Firestore query
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = startOfToday
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard on tap outside of input fields
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: lightBackground, // Set main background color
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Section
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 44.0, 16.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Profile Picture (Card with rounded image)
                    // Added InkWell to make the profile picture tappable
                    InkWell(
                      onTap: () async {
                        // Log out the user from Firebase
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserProfilePage()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User signed out successfully'),
                            backgroundColor: Colors.blue, // ✅ Use blue for neutral feedback
                            duration: Duration(seconds: 2), // ✅ Short duration for quick confirmation
                          ),
                        );
                        // The StreamBuilder in main.dart will automatically handle navigation to LandingPage
                      },
                      borderRadius: BorderRadius.circular(40.0),
                      // Match the card's border radius
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: primaryGreen,
                        // Card background color (border-like)
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(40.0), // Fully rounded
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          // Padding inside the card for the image
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40.0),
                            // Image rounded
                            child: Image.network(
                              'https://placehold.co/80x80/91EEA5/FFFFFF/png?text=P',
                              // Placeholder image URL
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                      'assets/images/default_avatar.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit
                                          .cover), // Fallback image if network fails
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Display First Name and Greeting
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 0.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Displaying the fetched first name or a loading indicator
                          _firstName == null
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryGreen),
                                  strokeWidth: 2.0,
                                )
                              : Text(
                                  _firstName!, // Use the fetched first name
                                  style: GoogleFonts.interTight(
                                    color: primaryText,
                                    fontSize: 22.0, // Match visual
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 4.0, 0.0, 0.0),
                            child: Text(
                              'Good morning!',
                              style: GoogleFonts.inter(
                                color: secondaryText,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // "How are you Feeling Today?" Section
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 10.0),
                child: Text(
                  'How are you Feeling Today?',
                  style: GoogleFonts.inter(
                    color: primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600, // Semi-bold
                  ),
                ),
              ),
              //log your mood
              SingleChildScrollView( scrollDirection: Axis.horizontal,
                child: Container(child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMoodAvatar("😞", "Very Sad", Colors.red[300]!, baseRadius),
                    _buildMoodAvatar("🙁", "Sad", Colors.orange[300]!, baseRadius),
                    _buildMoodAvatar("😐", "Neutral", Colors.yellow[300]!, baseRadius),
                    _buildMoodAvatar("🙂", "Happy", Colors.green[300]!, baseRadius),
                    _buildMoodAvatar("😃", "Very Happy", Colors.blue[300]!, baseRadius),
                  ],
                ),),
              ),

              SizedBox(height: 20,),



              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBackground, // White background
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Color(0x162D3A21), // Soft shadow
                        offset: Offset(0.0, 10.0),
                        spreadRadius: 2.0,
                      )
                    ],
                    borderRadius:
                        BorderRadius.circular(18.0), // Rounded corners
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 12.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: textController,
                                focusNode: textFieldFocusNode,
                                autofocus: false,
                                // Prevents immediate focus on load
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: 'Talk to us...',
                                  hintStyle: GoogleFonts.inter(
                                    color: secondaryText,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      // No visible border
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius
                                        .zero, // No rounded corners for underline
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      // No visible border
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  focusedErrorBorder:
                                      const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 4.0, 8.0, 12.0),
                                ),
                                style: GoogleFonts.inter(
                                  color: primaryText,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 8,
                                minLines: 3,
                                // No validator for this text field in the original FlutterFlow code, assuming it's free text.
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            12.0, 4.0, 12.0, 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          // Align button to end
                          children: [
                            Flexible(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                // Align button to the end
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                const AIChatPage()));
                                    print('Talk to us button pressed!');
                                    // Handle text submission here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(90.0, 40.0),
                                    // Fixed size for button
                                    backgroundColor: primaryGreen,
                                    // Green background
                                    foregroundColor: Colors.white,
                                    // White icon color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12.0), // Rounded corners
                                    ),
                                    elevation: 2.0,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward, // Arrow icon
                                    size: 25.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "Tasks for Today" Section
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        30.0, 0.0, 0.0, 10.0),
                    child: Text(
                      'Tasks for Today',
                      style: GoogleFonts.inter(
                        color: primaryText,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd, // Align to end
                    child: InkWell(
                      // Custom button for Add Task, navigates to TasksPage
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () async {
                        print(
                            'Add Task button pressed! Navigating to Tasks Page');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TasksPage()), // Navigate to TasksPage
                        );
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: secondaryText,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                child: Container(
                  width: double.infinity,
                  height: 200.0, // Fixed height for the task list container
                  decoration: BoxDecoration(
                    color: cardBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Color(0x33000000),
                        offset: Offset(0.0, 2.0),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        5.0, 0.0, 5.0, 0.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: (currentUser != null)
                          ? FirebaseFirestore.instance
                              .collection('tasks')
                              .where('userRef',
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUser!.uid))
                              .where('taskDate',
                                  isGreaterThanOrEqualTo:
                                      Timestamp.fromDate(startOfToday))
                              .where('taskDate',
                                  isLessThanOrEqualTo:
                                      Timestamp.fromDate(endOfToday))
                              .orderBy('taskDate', descending: false)
                              .orderBy('completed',
                                  descending: false) // Uncompleted tasks first
                              .snapshots()
                          : const Stream.empty(), // Return empty stream if no user
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryGreen),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No tasks for today!',
                              style: GoogleFonts.inter(color: secondaryText),
                            ),
                          );
                        }

                        final tasks = snapshot.data!.docs;

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                          // Padding inside listview
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5.0),
                          itemBuilder: (context, index) {
                            final taskDoc = tasks[index];
                            final taskTitle =
                                taskDoc['title'] as String? ?? 'No Title';
                            final isCompleted =
                                taskDoc['completed'] as bool? ?? false;

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: cardBackground, // White background
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Checkbox Area
                                  InkWell(
                                    onTap: () async {
                                      // Toggle completion status in Firestore
                                      await FirebaseFirestore.instance
                                          .collection('tasks')
                                          .doc(taskDoc.id)
                                          .update({
                                        'completed': !isCompleted,
                                      });
                                      print(
                                          'Task ${taskDoc.id} completion status toggled to ${!isCompleted}');
                                    },
                                    child: Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? primaryGreen
                                            : accentGreen,
                                        // Green if checked, light green if unchecked
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: isCompleted
                                          ? const Icon(
                                              Icons.check,
                                              size: 16.0,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  // Task Title
                                  Expanded(
                                    child: Text(
                                      taskTitle,
                                      style: GoogleFonts.inter(
                                        color: primaryText,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // "Recommended Exercise" Section
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 10.0),
                child: Text(
                  'Recommended Exercise ',
                  style: GoogleFonts.inter(
                    color: primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                height: 325, // Fixed height for horizontal list
                decoration: const BoxDecoration(), // No specific decoration
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      15.0, 0.0, 15.0, 0.0),
                  child: SizedBox(
                    height: 225, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // ✅ Enables horizontal scrolling
                      itemCount: exercisePages.length,
                      itemBuilder: (context, index) {
                        var pageData = exercisePages[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: cardBackground,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              width: 250, // Set a fixed width for each card
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child:pageData["icon"]), // Display the icon
                                  const SizedBox(height: 10),
                                  Text(pageData["pageTitle"]!,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(pageData["description"]!,
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => pageData["navigation"]),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Add padding for bottom navigation bar
            ],
          ),
        ),


      ),
    );
  }

  Widget _buildMoodAvatar(String emoji, String moodText, Color bgColor, double baseRadius) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HappinessLevelPage()));
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          radius: baseRadius,
          backgroundColor: bgColor,
          child: Text(emoji, style: TextStyle(fontSize: baseRadius * 0.6)),
        ),
      ),
    );
  }

}
