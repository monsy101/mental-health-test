// File: lib/therapist_account_setup_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monsy_weird_package/3bas/therapist_home_page.dart';

// Import your TherapistHomePage for navigation after setup

// Define custom colors (consistent with other pages)
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color alternateColor = Color(0xFFE0E0E0);
const Color errorColor = Colors.red;
const Color cardBackground = Colors.white;

class TherapistAccountSetupPage extends StatefulWidget {
  const TherapistAccountSetupPage({super.key});

  static String routeName = 'TherapistAccountSetupPage';
  static String routePath = '/therapistSetup';

  @override
  State<TherapistAccountSetupPage> createState() =>
      _TherapistAccountSetupPageState();
}

class _TherapistAccountSetupPageState extends State<TherapistAccountSetupPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  late TextEditingController educationTextController;
  late TextEditingController phoneNumberTextController;
  late TextEditingController clinicAddressTextController;
  late TextEditingController subscriptionPriceTextController;

  late FocusNode educationFocusNode;
  late FocusNode phoneNumberFocusNode;
  late FocusNode clinicAddressFocusNode;
  late FocusNode subscriptionPriceFocusNode;

  List<String> _selectedSpecialties = [];
  final List<String> _allSpecialties = [
    'Stress Management',
    'Anxiety Disorders',
    'ADHD',
    'PTSD',
    'Depression',
    'Bipolar Disorder',
    'Eating Disorders',
    'OCD',
    'Trauma',
    'Grief & Loss',
    'Relationship Issues',
    'Self-Esteem',
    'Substance Abuse',
    'Sleep Disorders',
    'Panic Attacks',
    'Social Anxiety',
    'Parenting Issues',
  ];

  User? currentUser; // To get the current therapist's UID

  @override
  void initState() {
    super.initState();
    educationTextController = TextEditingController();
    phoneNumberTextController = TextEditingController();
    clinicAddressTextController = TextEditingController();
    subscriptionPriceTextController = TextEditingController();

    educationFocusNode = FocusNode();
    phoneNumberFocusNode = FocusNode();
    clinicAddressFocusNode = FocusNode();
    subscriptionPriceFocusNode = FocusNode();

    currentUser = FirebaseAuth.instance.currentUser;
    _loadExistingTherapistData(); // Load any previously saved data
  }

  @override
  void dispose() {
    educationTextController.dispose();
    phoneNumberTextController.dispose();
    clinicAddressTextController.dispose();
    subscriptionPriceTextController.dispose();

    educationFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    clinicAddressFocusNode.dispose();
    subscriptionPriceFocusNode.dispose();
    super.dispose();
  }

  // Function to load existing data if the therapist has partially filled before
  Future<void> _loadExistingTherapistData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('therapists')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          educationTextController.text = doc['education'] as String? ?? '';
          phoneNumberTextController.text = doc['phoneNumber'] as String? ?? '';
          clinicAddressTextController.text =
              doc['clinicAddress'] as String? ?? '';
          subscriptionPriceTextController.text =
              (doc['subscriptionPrice'] as num?)?.toString() ?? '';
          _selectedSpecialties = List<String>.from(doc['specialties'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading existing therapist data: $e");
    }
  }

  // Validator for text fields (can be made optional or required)
  String? _textFieldValidator(String? val, String fieldName,
      {bool isRequired = true}) {
    if (isRequired && (val == null || val.isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validator for phone number
  String? _phoneNumberValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Phone Number is required';
    }
    // Basic phone number validation: checks if it contains only digits and is at least 7 characters
    if (!RegExp(r'^[0-9]{7,}$').hasMatch(val)) {
      return 'Please enter a valid phone number (digits only, min 7)';
    }
    return null;
  }

  // Validator for subscription price
  String? _subscriptionPriceValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Subscription Price is required';
    }
    if (double.tryParse(val) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(val) <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
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

  Future<void> _saveTherapistDetails() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) {
      _showAlertDialog(
          'Validation Error', 'Please correct the errors before saving.');
      return;
    }

    if (_selectedSpecialties.isEmpty) {
      _showAlertDialog(
          'Validation Error', 'Please select at least one specialty.');
      return;
    }

    if (currentUser == null) {
      _showAlertDialog(
          'Error', 'No authenticated user found. Please log in again.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(currentUser!.uid)
          .update({
        'education': educationTextController.text.trim(),
        'phoneNumber': phoneNumberTextController.text.trim(),
        'clinicAddress': clinicAddressTextController.text.trim(),
        'specialties': _selectedSpecialties,
        // Save list of specialties
        'subscriptionPrice':
            double.parse(subscriptionPriceTextController.text.trim()),
        // Save as number
        'isSetupComplete': true,
        // Mark setup as complete
        'lastUpdated': FieldValue.serverTimestamp(),
        // Optional: add a timestamp
      });

      _showAlertDialog('Success', 'Therapist details saved successfully!');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TherapistHomePage()),
        );
      }
    } catch (e) {
      print('Error saving therapist details: $e');
      _showAlertDialog('Error', 'Failed to save details. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: primaryGreen,
          automaticallyImplyLeading: false,
          // Hide default back button
          title: Text(
            'Setup Therapist Account',
            style: GoogleFonts.interTight(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 4.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us more about your practice.',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Education Field
                  TextFormField(
                    controller: educationTextController,
                    focusNode: educationFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Education/Degrees',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: alternateColor, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryGreen, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: cardBackground,
                    ),
                    style: GoogleFonts.inter(color: primaryText),
                    validator: (value) =>
                        _textFieldValidator(value, 'Education'),
                  ),
                  const SizedBox(height: 16.0),

                  // Phone Number Field
                  TextFormField(
                    controller: phoneNumberTextController,
                    focusNode: phoneNumberFocusNode,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: alternateColor, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryGreen, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: cardBackground,
                    ),
                    style: GoogleFonts.inter(color: primaryText),
                    validator: _phoneNumberValidator,
                  ),
                  const SizedBox(height: 16.0),

                  // Clinic Address Field
                  TextFormField(
                    controller: clinicAddressTextController,
                    focusNode: clinicAddressFocusNode,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Clinic Address',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: alternateColor, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryGreen, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: cardBackground,
                    ),
                    style: GoogleFonts.inter(color: primaryText),
                    validator: (value) =>
                        _textFieldValidator(value, 'Clinic Address'),
                  ),
                  const SizedBox(height: 16.0),

                  // Specialties Selection using FilterChip
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Specialties (Select at least one)',
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: primaryText,
                          ),
                        ),
                      ),
                      // Use Wrap to display chips, allowing them to flow to the next line
                      Wrap(
                        spacing: 8.0,
                        // horizontal spacing between chips
                        runSpacing: 8.0,
                        // vertical spacing between rows of chips
                        children: _allSpecialties.map((specialty) {
                          final isSelected =
                              _selectedSpecialties.contains(specialty);
                          return FilterChip(
                            label: Text(
                              specialty,
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.white : primaryText,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSpecialties.add(specialty);
                                } else {
                                  _selectedSpecialties.remove(specialty);
                                }
                              });
                            },
                            // Visuals for selected/unselected chips
                            selectedColor: primaryGreen,
                            checkmarkColor: Colors.white,
                            backgroundColor: lightBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                color:
                                    isSelected ? primaryGreen : alternateColor,
                                width: 1.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Display validation error if no specialty is selected and form is auto-validating
                      if (_autovalidateMode == AutovalidateMode.always &&
                          _selectedSpecialties.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            'Please select at least one specialty.',
                            style: GoogleFonts.inter(
                              color: errorColor,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Subscription Price Field
                  TextFormField(
                    controller: subscriptionPriceTextController,
                    focusNode: subscriptionPriceFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Subscription Price (per session)',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: alternateColor, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryGreen, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: cardBackground,
                    ),
                    style: GoogleFonts.inter(color: primaryText),
                    validator: _subscriptionPriceValidator,
                  ),
                  const SizedBox(height: 32.0),

                  // Save Details Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveTherapistDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        elevation: 2.0,
                      ),
                      child: Text(
                        'Save Details',
                        style: GoogleFonts.interTight(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
