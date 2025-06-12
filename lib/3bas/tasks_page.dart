// File: lib/tasks_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user UID
import 'package:intl/intl.dart';
import 'package:monsy_weird_package/3bas/task_details_page.dart';

import 'add_task_dialog.dart'; // For date formatting

// Import the AddTaskDialog component
// Import your new TaskDetailsPage

// Define custom colors (consistent with previous files)
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color cardBackground = Colors.white;
const Color accentGreen =
    Color(0xFFE0FFEA); // For selected calendar day background
const Color alternateColor =
    Color(0xFFE0E0E0); // Light grey for borders and inactive elements

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  static String routeName = 'tasks';
  static String routePath = '/tasks';

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  DateTime _selectedDay =
      DateTime.now(); // Initially selected day in the calendar
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Get current user

  @override
  void initState() {
    super.initState();
    // Ensure _selectedDay is normalized to start of day for accurate filtering
    _selectedDay =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
  }

  // Helper to format month and year for calendar header
  String _getMonthYear(DateTime date) {
    return DateFormat('MMMM yd')
        .format(date); // Changed to 'yyyy' for consistency
  }

  // Helper to get day of week abbreviation (e.g., "Mon", "Tue")
  String _getDayOfWeekAbbr(int weekday) {
    // Dart's DateTime.weekday: Monday=1, Sunday=7
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  // Function to toggle task completion status
  Future<void> _toggleTaskCompletion(
      DocumentSnapshot taskDoc, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskDoc.id)
          .update({
        'completed': !currentStatus,
      });
      print(
          'Task ${taskDoc.id} completion status toggled to ${!currentStatus}');

      // Handle recurrence logic (create new task for next applicable day if it was just marked complete)
      if (taskDoc['isRecurring'] == true && !currentStatus) {
        // If it was recurring AND just marked marked complete
        final List<int> repeatDays =
            List<int>.from(taskDoc['repeatDays'] ?? []);
        // Sort repeatDays to ensure consistent order (important for finding next day)
        repeatDays.sort();

        final DateTime taskDate = (taskDoc['taskDate'] as Timestamp).toDate();
        final int currentWeekday = taskDate.weekday;

        DateTime? nextOccurrenceDate;
        bool foundNextDayInCurrentWeek = false;

        // 1. Find the next repeat day in the current or upcoming days of the current week
        for (int rDay in repeatDays) {
          if (rDay > currentWeekday) {
            final int daysToAdd = rDay - currentWeekday;
            nextOccurrenceDate = taskDate.add(Duration(days: daysToAdd));
            foundNextDayInCurrentWeek = true;
            break; // Found the next day, exit loop
          }
        }

        // 2. If no day was found after the current day in the current week,
        //    find the first repeat day in the next week.
        if (!foundNextDayInCurrentWeek && repeatDays.isNotEmpty) {
          final int firstRepeatDayOfNextWeek = repeatDays.first;
          // Calculate days to end of current week + days to reach the first repeat day of next week
          int daysToEndOfCurrentWeek = 7 - currentWeekday;
          if (currentWeekday == DateTime.sunday) {
            // If current day is Sunday (7), daysToEndOfCurrentWeek is 0 from Sunday to Saturday.
            daysToEndOfCurrentWeek = 0;
          }

          // Total days to add to get to the first repeat day of the next week
          final int daysToAdd =
              daysToEndOfCurrentWeek + firstRepeatDayOfNextWeek;
          nextOccurrenceDate = taskDate.add(Duration(days: daysToAdd));
        }

        // Only proceed if a next occurrence date was successfully determined
        if (nextOccurrenceDate != null) {
          final userRef = FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid);

          // Normalize the next occurrence date to start of day for accurate query
          final DateTime normalizedNextOccurrenceDate = DateTime(
              nextOccurrenceDate.year,
              nextOccurrenceDate.month,
              nextOccurrenceDate.day);

          // Check if a task with the same title and details already exists for the next occurrence date
          final existingTasks = await FirebaseFirestore.instance
              .collection('tasks')
              .where('userRef', isEqualTo: userRef)
              .where('title', isEqualTo: taskDoc['title'])
              .where('details', isEqualTo: taskDoc['details'])
              .where('taskDate',
                  isEqualTo: Timestamp.fromDate(normalizedNextOccurrenceDate))
              .limit(1)
              .get();

          if (existingTasks.docs.isEmpty) {
            // No duplicate found, create the new recurring task instance
            await FirebaseFirestore.instance.collection('tasks').add({
              'title': taskDoc['title'],
              'details': taskDoc['details'],
              'taskDate': Timestamp.fromDate(normalizedNextOccurrenceDate),
              // Save normalized date
              'isRecurring': true,
              'repeatDays': repeatDays,
              // Pass the same repeat days to the new instance
              'completed': false,
              // New recurring task starts incomplete
              'userRef': userRef,
              'created_at': FieldValue.serverTimestamp(),
            });
            print(
                'Created new recurring task for ${DateFormat('MMM d,EEEE').format(normalizedNextOccurrenceDate)}');
          } else {
            print(
                'Task for ${DateFormat('MMM d,EEEE').format(normalizedNextOccurrenceDate)} already exists.');
          }
        } else {
          print('Could not determine next occurrence date for recurring task.');
        }
      }
    } catch (e) {
      print('Error toggling task completion or adding recurring task: $e');
      _showAlertDialog('Error', 'Failed to update task. Please try again.');
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
    // If no user is logged in, show a message or redirect
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view tasks.'),
        ),
      );
    }

    // Get the start and end of the selected day for Firestore query
    final DateTime startOfDay =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final DateTime endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: lightBackground, // Page background color
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              // Allows content to be full height if needed by keyboard
              backgroundColor: Colors.transparent,
              // For rounded corners effect
              builder: (context) => Padding(
                padding:
                    MediaQuery.of(context).viewInsets, // Adjust for keyboard
                child: const AddTaskDialog(), // Show the AddTaskDialog
              ),
            );
            // After modal is dismissed, refresh the UI to show new tasks
            setState(() {
              // Re-setting _selectedDay forces the StreamBuilder to refresh if needed
              _selectedDay = _selectedDay;
            });
          },
          backgroundColor: primaryGreen, // Green FAB
          elevation: 8.0,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen, // Green background for the plus icon
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white, // White plus icon
              size: 30.0,
            ),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // App Bar Section
            Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height *
                  0.12, // Approximate height
              decoration: const BoxDecoration(
                color: primaryGreen, // Green app bar background
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10.0,
                    color: Color(0x33000000), // Soft shadow
                    offset: Offset(0.0, 2.0),
                  )
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 40.0, 0.0, 0.0), // Padding for status bar
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: InkWell(
                        // Custom back button
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () {
                          Navigator.pop(
                              context); // Go back to the previous page (e.g., HomePage)
                        },
                        child: Container(
                          width: 40.0,
                          // Size of the tappable area
                          height: 40.0,
                          margin: const EdgeInsets.only(left: 10.0),
                          // Spacing
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            // No specific color for the container as it's just a tappable area
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: primaryText, // White arrow icon
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.center,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 40.0, 0.0), // Push title slightly left
                          child: Text(
                            'Tasks',
                            style: GoogleFonts.interTight(
                              fontSize: 22.0, // Adjust size to fit
                              fontWeight: FontWeight.bold, // Match visual
                              color: primaryText, // White text
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Calendar Section (Custom Implementation)
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                children: [
                  // Month and Year with navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _getMonthYear(_selectedDay),
                          style: GoogleFonts.interTight(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today,
                                color: secondaryText, size: 20.0),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDay,
                                firstDate: DateTime(_selectedDay.year - 5),
                                lastDate: DateTime(_selectedDay.year + 5),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryGreen,
                                        // Header background color
                                        onPrimary: cardBackground,
                                        // Header text color
                                        surface: cardBackground,
                                        // Dialog background
                                        onSurface:
                                            primaryText, // Body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryGreen,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDay = DateTime(
                                      picked.year, picked.month, picked.day);
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: secondaryText, size: 24.0),
                            onPressed: () {
                              setState(() {
                                _selectedDay = _selectedDay.subtract(
                                    const Duration(days: 7)); // Go back a week
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: secondaryText, size: 24.0),
                            onPressed: () {
                              setState(() {
                                _selectedDay = _selectedDay.add(const Duration(
                                    days: 7)); // Go forward a week
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // Days of the week (Sun, Mon, Tue...) and dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      // Calculate the start of the week for the selected date (Monday as first day)
                      DateTime startOfWeek = _selectedDay
                          .subtract(Duration(days: _selectedDay.weekday - 1));
                      // Adjust if _selectedDay is Sunday (weekday 7), then startOfWeek should be previous Monday
                      if (_selectedDay.weekday == DateTime.sunday) {
                        startOfWeek =
                            _selectedDay.subtract(const Duration(days: 6));
                      }

                      final currentDay = startOfWeek.add(Duration(days: index));

                      final isSelected = currentDay.year == _selectedDay.year &&
                          currentDay.month == _selectedDay.month &&
                          currentDay.day == _selectedDay.day;

                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDay =
                                  currentDay; // Update selected day on tap
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryGreen
                                  : Colors
                                      .transparent, // Green background for selected
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getDayOfWeekAbbr(currentDay.weekday),
                                  style: GoogleFonts.inter(
                                    color:
                                        isSelected ? Colors.white : primaryText,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  currentDay.day.toString(),
                                  style: GoogleFonts.inter(
                                    color:
                                        isSelected ? Colors.white : primaryText,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Tasks List View
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('userRef',
                        isEqualTo: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser!.uid))
                    .where('taskDate',
                        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                    .where('taskDate',
                        isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
                    .orderBy('taskDate', descending: false)
                    .orderBy('completed',
                        descending: false) // Uncompleted tasks first
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks for this day!',
                        style: GoogleFonts.inter(color: secondaryText),
                      ),
                    );
                  }

                  final tasks = snapshot.data!.docs;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12.0),
                    itemBuilder: (context, index) {
                      final taskDoc = tasks[index];
                      final taskTitle =
                          taskDoc['title'] as String? ?? 'No Title';
                      final isCompleted =
                          taskDoc['completed'] as bool? ?? false;

                      return InkWell(
                        // Make the entire task item tappable
                        onTap: () {
                          // Navigate to TaskDetailsPage, passing the task document
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailsPage(taskDoc: taskDoc),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: cardBackground, // White background
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Checkbox Area
                              InkWell(
                                onTap: () =>
                                    _toggleTaskCompletion(taskDoc, isCompleted),
                                child: Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? primaryGreen
                                        : accentGreen,
                                    // Green if checked, light green if unchecked
                                    borderRadius: BorderRadius.circular(4.0),
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0), // Padding for the bottom
          ],
        ),
      ),
    );
  }
}
