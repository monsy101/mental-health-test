// File: lib/task_details_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user UID

// Define custom colors (consistent with previous files)
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8); // Used for input field fill
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C); // Used for labels and hint text
const Color alternateColor =
    Color(0xFFE0E0E0); // A light grey for borders and inactive elements
const Color errorColor = Colors.red;
const Color cardBackground = Colors.white;

class TaskDetailsPage extends StatefulWidget {
  final DocumentSnapshot taskDoc; // Pass the DocumentSnapshot of the task

  const TaskDetailsPage({super.key, required this.taskDoc});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleTextController;
  late TextEditingController detailsTextController;
  late FocusNode titleFocusNode;
  late FocusNode detailsFocusNode;

  bool _isEditing = false; // Controls editability of fields
  bool _autovalidateMode = false; // Controls when validation errors appear

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current task data
    titleTextController =
        TextEditingController(text: widget.taskDoc['title'] as String? ?? '');
    detailsTextController =
        TextEditingController(text: widget.taskDoc['details'] as String? ?? '');

    titleFocusNode = FocusNode();
    detailsFocusNode = FocusNode();
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
      return 'Title cannot be empty';
    }
    return null;
  }

  // Validator for Details field
  String? _detailsValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Details cannot be empty';
    }
    return null;
  }

  // Function to show custom alert dialog for errors/success/confirmation
  void _showAlertDialog(String title, String message,
      {bool isConfirmation = false, VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            if (isConfirmation)
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Text(isConfirmation ? 'Confirm' : 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (isConfirmation && onConfirm != null) {
                  onConfirm();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update task in Firestore
  Future<void> _updateTask() async {
    setState(() {
      _autovalidateMode = true; // Enable validation on update attempt
    });

    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskDoc.id)
          .update({
        'title': titleTextController.text.trim(),
        'details': detailsTextController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(), // Update timestamp
      });
      _showAlertDialog('Success', 'Task updated successfully!');
      setState(() {
        _isEditing = false; // Turn off editing mode after update
      });
      if (mounted) {
        Navigator.pop(
            context); // Navigate back to TasksPage after successful update
      }
    } catch (e) {
      print('Error updating task: $e');
      _showAlertDialog('Error', 'Failed to update task. Please try again.');
    }
  }

  // Function to delete task from Firestore
  Future<void> _deleteTask() async {
    _showAlertDialog(
      'Confirm Delete',
      'Are you sure you want to delete this task? This action cannot be undone.',
      isConfirmation: true,
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(widget.taskDoc.id)
              .delete();
          _showAlertDialog('Success', 'Task deleted successfully!');
          if (mounted) {
            Navigator.pop(
                context); // Go back to the previous screen (TasksPage) after deletion
          }
        } catch (e) {
          print('Error deleting task: $e');
          _showAlertDialog('Error', 'Failed to delete task. Please try again.');
        }
        Navigator.pop(context); // Go back to the previous page
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: lightBackground, // Page background color
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Custom App Bar (to match the image)
            Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height *
                  0.12, // Approximate height
              decoration: const BoxDecoration(
                color: primaryGreen,
                // Changed app bar background to primaryGreen
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5.0,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () {
                          Navigator.pop(
                              context); // Go back to the previous page
                        },
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          margin: const EdgeInsets.only(left: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: primaryText,
                            // White arrow icon for green background
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          'Task Details',
                          style: GoogleFonts.interTight(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color:
                                primaryText, // White text for green background
                          ),
                        ),
                      ),
                    ),
                    // Edit and Delete Icons
                    Row(
                      children: [
                        // Edit Icon
                        InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () {
                            setState(() {
                              _isEditing = !_isEditing; // Toggle editing mode
                              _autovalidateMode =
                                  false; // Reset autovalidation on toggle
                            });
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              _isEditing ? Icons.edit_off : Icons.edit,
                              // Change icon based on editing mode
                              color: primaryText,
                              // White icon for green background
                              size: 24.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Delete Icon
                        InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: _deleteTask,
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            margin: const EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(
                              Icons.delete_forever,
                              color: primaryText,
                              // White icon for green background (image showed white icon)
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Main Content Area (White card-like container)
            Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 400.0, // Consistent with other pages
                ),
                decoration: BoxDecoration(
                  color: cardBackground, // White background
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Color(0x33000000),
                      offset: Offset(0.0, 2.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            'Title',
                            style: GoogleFonts.inter(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
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
                            enabled: _isEditing,
                            // Control editability
                            decoration: InputDecoration(
                              hintText: 'title',
                              // Placeholder text
                              hintStyle:
                                  GoogleFonts.inter(color: secondaryText),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: alternateColor, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: primaryGreen, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: errorColor, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: errorColor, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: lightBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 24.0),
                            ),
                            style: GoogleFonts.inter(color: primaryText),
                            validator: _titleValidator,
                          ),
                        ),
                        // Details Label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            'Details',
                            style: GoogleFonts.inter(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: primaryText,
                            ),
                          ),
                        ),
                        // Details Text Field
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: TextFormField(
                            controller: detailsTextController,
                            focusNode: detailsFocusNode,
                            enabled: _isEditing,
                            // Control editability
                            maxLines: 5,
                            // Allow multi-line input
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Details...',
                              // Placeholder text
                              hintStyle:
                                  GoogleFonts.inter(color: secondaryText),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: alternateColor, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: primaryGreen, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: errorColor, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: errorColor, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: lightBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12.0),
                            ),
                            style: GoogleFonts.inter(color: primaryText),
                            validator: _detailsValidator,
                          ),
                        ),
                        // Update Task Button (only visible if editing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isEditing ? primaryGreen : alternateColor,
                              // Green button
                              foregroundColor: cardBackground,
                              // White text
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              elevation: 2.0,
                            ),
                            child: Text(
                              'Update Task',
                              style: GoogleFonts.interTight(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
}
