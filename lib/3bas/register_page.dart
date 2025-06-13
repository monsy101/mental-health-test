// File: lib/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer in RichText
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monsy_weird_package/3bas/therapist_account_setup_page.dart';
import '../3bas/login_page.dart';
import 'main_screen.dart'; // For Firebase Firestore

// Import your LoginPage here
// Import your HomePage here
// Import your new TherapistAccountSetupPage

// Define custom colors based on your specifications
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color yellowishColor = Color(0xFFEEE691);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color errorColor = Colors.red;

// Regex patterns for validation
const String kTextValidatorEmailRegex =
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

// Enum to define user types for clarity (same as in login_page.dart)
enum UserType { patient, therapist }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static String routeName = 'RegisterPage';
  static String routePath = '/registerPage';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  late TextEditingController firstNameTextController;
  late TextEditingController lastNameTextController;
  late TextEditingController emailAddressTextController;
  late TextEditingController passwordTextController;
  late TextEditingController confirmpasswordTextController;

  late FocusNode firstNameFocusNode;
  late FocusNode lastNameFocusNode;
  late FocusNode emailAddressFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmpasswordFocusNode;

  bool passwordVisibility = false;
  bool confirmpasswordVisibility = false;
  UserType _selectedRegisterType =
      UserType.patient; // Default registration type

  @override
  void initState() {
    super.initState();
    firstNameTextController = TextEditingController();
    lastNameTextController = TextEditingController();
    emailAddressTextController = TextEditingController();
    passwordTextController = TextEditingController();
    confirmpasswordTextController = TextEditingController();

    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    emailAddressFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmpasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    emailAddressTextController.dispose();
    passwordTextController.dispose();
    confirmpasswordTextController.dispose();

    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailAddressFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmpasswordFocusNode.dispose();

    super.dispose();
  }

  // Validator for First Name field
  String? _firstNameValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'First Name is required';
    }
    return null;
  }

  // Validator for Last Name field
  String? _lastNameValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Last Name is required';
    }
    return null;
  }

  // Validator for email field
  String? _emailAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // Validator for password field
  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    return null;
  }

  // Validator for confirm password field
  String? _confirmpasswordTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Confirm Password is required';
    }
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    if (val != passwordTextController.text) {
      return 'Passwords do not match!';
    }
    return null;
  }

  // Function to show custom alert dialog for errors/success
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, yellowishColor],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.87, -1.0),
              end: AlignmentDirectional(-0.87, 1.0),
            ),
          ),
          alignment: AlignmentDirectional.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 70.0, 0.0, 20.0),
                  child: Container(
                    width: 200.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: AlignmentDirectional.center,
                    child: Icon(
                      Icons.flutter_dash,
                      color: primaryText,
                      size: 70.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 400.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autovalidateMode,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Create an account',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.interTight(
                                  fontSize: 34.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 24.0),
                                child: Text(
                                  'Let\'s get started by filling out the form below.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                    fontSize: 14.0,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                              // First Name Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: firstNameTextController,
                                    focusNode: firstNameFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      labelStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      hintStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 24.0, 20.0, 24.0),
                                    ),
                                    style:
                                        GoogleFonts.inter(color: primaryText),
                                    validator: (value) =>
                                        _firstNameValidator(context, value),
                                  ),
                                ),
                              ),
                              // Last Name Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: lastNameTextController,
                                    focusNode: lastNameFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      labelStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      hintStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 24.0, 20.0, 24.0),
                                    ),
                                    style:
                                        GoogleFonts.inter(color: primaryText),
                                    validator: (value) =>
                                        _lastNameValidator(context, value),
                                  ),
                                ),
                              ),
                              // Email Address Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: emailAddressTextController,
                                    focusNode: emailAddressFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      hintStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                    ),
                                    style:
                                        GoogleFonts.inter(color: primaryText),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) =>
                                        _emailAddressTextControllerValidator(
                                            context, value),
                                  ),
                                ),
                              ),
                              // Password Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: passwordTextController,
                                    focusNode: passwordFocusNode,
                                    autofocus: false,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    textInputAction: TextInputAction.next,
                                    obscureText: !passwordVisibility,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      hintStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      suffixIcon: InkWell(
                                        onTap: () => setState(
                                          () => passwordVisibility =
                                              !passwordVisibility,
                                        ),
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          passwordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: secondaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    style:
                                        GoogleFonts.inter(color: primaryText),
                                    validator: (value) =>
                                        _passwordTextControllerValidator(
                                            context, value),
                                  ),
                                ),
                              ),
                              // Confirm Password Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: confirmpasswordTextController,
                                    focusNode: confirmpasswordFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    obscureText: !confirmpasswordVisibility,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      hintStyle: GoogleFonts.inter(
                                          color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      suffixIcon: InkWell(
                                        onTap: () => setState(
                                          () => confirmpasswordVisibility =
                                              !confirmpasswordVisibility,
                                        ),
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          confirmpasswordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: secondaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    style:
                                        GoogleFonts.inter(color: primaryText),
                                    validator: (value) =>
                                        _confirmpasswordTextControllerValidator(
                                            context, value),
                                  ),
                                ),
                              ),
                              // User Type Selection for Register
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedRegisterType =
                                                UserType.patient;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _selectedRegisterType ==
                                                      UserType.patient
                                                  ? primaryGreen
                                                  : lightBackground,
                                          foregroundColor:
                                              _selectedRegisterType ==
                                                      UserType.patient
                                                  ? Colors.white
                                                  : primaryText,
                                          side: BorderSide(
                                            color: _selectedRegisterType ==
                                                    UserType.patient
                                                ? primaryGreen
                                                : secondaryText,
                                            width: 1.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                        child: Text(
                                          'Patient',
                                          style: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedRegisterType =
                                                UserType.therapist;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _selectedRegisterType ==
                                                      UserType.therapist
                                                  ? primaryGreen
                                                  : lightBackground,
                                          foregroundColor:
                                              _selectedRegisterType ==
                                                      UserType.therapist
                                                  ? Colors.white
                                                  : primaryText,
                                          side: BorderSide(
                                            color: _selectedRegisterType ==
                                                    UserType.therapist
                                                ? primaryGreen
                                                : secondaryText,
                                            width: 1.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                        child: Text(
                                          'Therapist',
                                          style: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Create Account Button
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _autovalidateMode = AutovalidateMode.always;
                                      });

                                      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      try {
                                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                          email: emailAddressTextController.text,
                                          password: passwordTextController.text,
                                        );

                                        if (userCredential.user != null) {
                                          await userCredential.user!.updateDisplayName(
                                            '${firstNameTextController.text} ${lastNameTextController.text}',
                                          );

                                          String collectionName = _selectedRegisterType == UserType.patient ? 'users' : 'therapists';
                                          CollectionReference targetCollection = FirebaseFirestore.instance.collection(collectionName);

                                          // ✅ Include the user ID when saving to Firestore
                                          Map<String, dynamic> userData = {
                                            'uid': userCredential.user!.uid, // ✅ Adds userID
                                            'firstName': firstNameTextController.text.trim(),
                                            'lastName': lastNameTextController.text.trim(),
                                            'email': emailAddressTextController.text,
                                            'created_at': FieldValue.serverTimestamp(),
                                          };

                                          // ✅ If it's a therapist, add setup completion flag
                                          if (_selectedRegisterType == UserType.therapist) {
                                            userData['isSetupComplete'] = false;
                                          }

                                          await targetCollection.doc(userCredential.user!.uid).set(userData); // ✅ Store userID as document ID

                                          if (mounted) {
                                            if (_selectedRegisterType == UserType.patient) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const MainScreen()),
                                              );
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const TherapistAccountSetupPage()),
                                              );
                                            }
                                          }
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        print('Firebase Auth Error: ${e.code} - ${e.message}');
                                        String errorMessage = 'An error occurred. Please try again.';
                                        if (e.code == 'weak-password') {
                                          errorMessage = 'The password provided is too weak.';
                                        } else if (e.code == 'email-already-in-use') {
                                          errorMessage = 'An account already exists for that email.';
                                        } else if (e.code == 'invalid-email') {
                                          errorMessage = 'The email address is not valid.';
                                        }
                                        _showAlertDialog('Registration Failed', errorMessage);
                                      } catch (e) {
                                        print('General Error: $e');
                                        _showAlertDialog('Error', 'Something went wrong during registration or data saving. Please try again.');
                                      }
                                    },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 44.0),
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 3.0,
                                    side: const BorderSide(
                                        color: Colors.transparent, width: 1.0),
                                  ),
                                  child: Text(
                                    'Create Account',
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // "Already have an account? Sign in here" text
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 40.0),
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Already have an account?',
                                        style: GoogleFonts.inter(
                                          color: primaryText,
                                          letterSpacing: 0.0,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Sign in here',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: primaryGreen,
                                          letterSpacing: 0.0,
                                          decoration: TextDecoration.underline,
                                          fontSize: 14.0,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage()),
                                            );
                                          },
                                      )
                                    ],
                                    style:
                                        GoogleFonts.inter(letterSpacing: 0.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
