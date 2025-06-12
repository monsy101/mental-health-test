// File: lib/add_task_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user UID
import 'package:intl/intl.dart'; // For formatting date text

// Define custom colors (consistent with previous files)
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8); // Used for input field fill
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C); // Used for labels and hint text
const Color alternateColor =
    Color(0xFFE0E0E0); // A light grey for borders and inactive elements
const Color errorColor = Colors.red;
const Color cardBackground = Colors.white;

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleTextController;
  late TextEditingController detailsTextController;
  late FocusNode titleFocusNode;
  late FocusNode detailsFocusNode;

  DateTime? _selectedDate; // Stores the picked date for the initial task
  Set<int> _selectedRepeatDays =
      {}; // Stores selected weekdays for recurrence (1=Mon, ..., 7=Sun)

  // Map to display weekday names
  final Map<int, String> _weekdayNames = {
    DateTime.monday: 'M',
    DateTime.tuesday: 'T',
    DateTime.wednesday: 'W',
    DateTime.thursday: 'Th',
    DateTime.friday: 'F',
    DateTime.saturday: 'Sa',
    DateTime.sunday: 'Su',
  };

  @override
  void initState() {
    super.initState();
    titleTextController = TextEditingController();
    detailsTextController = TextEditingController();
    titleFocusNode = FocusNode();
    detailsFocusNode = FocusNode();

    _selectedDate = DateTime.now(); // Default to today's date
  }

  @override
  void dispose() {
    titleTextController.dispose();
    detailsTextController.dispose();
    titleFocusNode.dispose();
    detailsFocusNode.dispose();
    super.dispose();
  }

  // Validator for Title field
  String? _titleValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  // Function to show custom alert dialog for errors
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

  // Function to add task to Firestore
  Future<void> _addTaskToFirestore() async {
    // Get the current logged-in user's UID and reference
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showAlertDialog('Not Logged In', 'You must be logged in to add tasks.');
      return;
    }
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Ensure a date is selected
    if (_selectedDate == null) {
      _showAlertDialog('Date Missing', 'Please pick a date for the task.');
      return;
    }

    // Prepare task data for the initial task
    Map<String, dynamic> taskData = {
      'title': titleTextController.text.trim(),
      'details': detailsTextController.text.trim(),
      // Details can now be empty
      'taskDate': Timestamp.fromDate(DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day)),
      // Normalize date to start of day
      'isRecurring': _selectedRepeatDays.isNotEmpty,
      'repeatDays': _selectedRepeatDays.toList(),
      // Store the list of selected weekdays
      'completed': false,
      // New tasks are always incomplete
      'userRef': userRef,
      // Reference to the user who created the task
      'created_at': FieldValue.serverTimestamp(),
      // Server timestamp for creation
    };

    try {
      // Add the initial task to Firestore
      await FirebaseFirestore.instance.collection('tasks').add(taskData);

      Navigator.pop(context); // Dismiss the modal after adding task
      _showAlertDialog('Task Added', 'Your task has been added successfully!');
    } catch (e) {
      print('Error adding task: $e');
      _showAlertDialog('Error', 'Failed to add task. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Fixed height for consistency, allowing scroll if content overflows
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: cardBackground, // White background for the modal content
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        border: Border.all(
          color: alternateColor, // Light grey border
          width: 1.0,
        ),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // Validate as user types
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                // Make column only take necessary vertical space
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    // Align close button to top-right
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () => Navigator.pop(context), // Dismiss modal
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: alternateColor, width: 1.0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: secondaryText, // Darker text for close icon
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Add Task',
                      style: GoogleFonts.interTight(
                        fontSize: 25.0, // Match screenshot
                        fontWeight: FontWeight.bold, // Match screenshot
                        color: primaryText,
                      ),
                    ),
                  ),
                  // Title Text Field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextFormField(
                      controller: titleTextController,
                      focusNode: titleFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Title...',
                        labelStyle: GoogleFonts.inter(color: secondaryText),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: alternateColor, width: 1.0),
                          // Light grey border
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryGreen, width: 1.0),
                          // Green when focused
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: errorColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: errorColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: lightBackground,
                        // Light background fill
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 24.0),
                      ),
                      style: GoogleFonts.inter(color: primaryText),
                      validator: _titleValidator,
                    ),
                  ),
                  // Details Text Field (Now Optional)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextFormField(
                      controller: detailsTextController,
                      focusNode: detailsFocusNode,
                      maxLines: 3,
                      // Allow multiple lines
                      minLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Details (Optional)...',
                        // Changed label to indicate optional
                        labelStyle: GoogleFonts.inter(color: secondaryText),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: alternateColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryGreen, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          // Keep error styling for consistency, though no validator
                          borderSide: BorderSide(color: errorColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          // Keep error styling
                          borderSide: BorderSide(color: errorColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: lightBackground,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                      ),
                      style: GoogleFonts.inter(color: primaryText),
                      // validator: _detailsValidator, // Removed validator here
                    ),
                  ),
                  // Pick a Date Row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pick a Date: ${DateFormat('MMM d, yyyy').format(_selectedDate!)}', // Display selected date
                          style: GoogleFonts.interTight(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600, // Semi-bold
                            color: primaryText,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              // 1 year back
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 5)),
                              // 5 years future
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primaryGreen,
                                      // Header background color
                                      onPrimary: cardBackground,
                                      // Header text color
                                      surface: cardBackground,
                                      // Dialog background color
                                      onSurface: primaryText, // Body text color
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            primaryGreen, // Button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              // Green background for calendar icon
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: cardBackground, // White icon
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Repeat Weekly Label
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Repeat Weekly On:',
                      style: GoogleFonts.interTight(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                  ),
                  // Repeat Days Selection
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _weekdayNames.entries.map((entry) {
                        final weekday = entry.key;
                        final name = entry.value;
                        final isSelected =
                            _selectedRepeatDays.contains(weekday);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedRepeatDays.remove(weekday);
                              } else {
                                _selectedRepeatDays.add(weekday);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 35.0,
                            // Fixed width for each day button
                            height: 35.0,
                            // Fixed height for each day button
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? primaryGreen : lightBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color:
                                    isSelected ? primaryGreen : alternateColor,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                color:
                                    isSelected ? cardBackground : primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Add Task Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addTaskToFirestore();
                      } else {
                        _showAlertDialog('Validation Error',
                            'Please fill in all required fields (Title).');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50.0),
                      // Full width, fixed height
                      backgroundColor: primaryGreen,
                      // Green background
                      foregroundColor: cardBackground,
                      // White text/icon
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(24.0), // Rounded button
                      ),
                      elevation: 0.0,
                      // No elevation
                      side: BorderSide(color: alternateColor, width: 1.0),
                      // Light grey border
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0), // Padding around content
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 24.0),
                        // Add icon
                        const SizedBox(width: 8.0),
                        // Spacing between icon and text
                        Text(
                          'Add Task',
                          style: GoogleFonts.interTight(
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            color: cardBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
