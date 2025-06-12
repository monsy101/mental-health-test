// File: lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer in RichText
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monsy_weird_package/3bas/therapist_account_setup_page.dart';
import 'package:monsy_weird_package/3bas/therapist_home_page.dart';

import '../3bas/home_page.dart';
import '../3bas/register_page.dart'; // For Firestore operations

// Define custom colors based on your specifications and image analysis
const Color primaryGreen =
    Color(0xFF91EEA5); // The darker green in the gradient and button
const Color lighterGreen =
    Color(0xFFC0F7C9); // The lighter green at the top of the gradient
const Color lightBackground =
    Color(0xFFF1F4F8); // Background color for input fields
const Color primaryText = Color(0xFF14181B); // Main dark text color
const Color secondaryText = Color(0xFF57636C); // Hint text, descriptive text
const Color errorColor = Colors.red; // Standard error color
const Color yellowishColor = Color(0xFFEEE691); // Defined in previous responses

// Regex for email validation
const String kTextValidatorEmailRegex =
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

// Enum to define user types for clarity
enum UserType { patient, therapist }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String routeName = 'LoginPage';
  static String routePath = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  late TextEditingController emailAddressTextController;
  late TextEditingController passwordTextController;

  late FocusNode emailAddressFocusNode;
  late FocusNode passwordFocusNode;

  bool passwordVisibility = false;
  UserType _selectedLoginType = UserType.patient; // Default login type

  @override
  void initState() {
    super.initState();
    emailAddressTextController = TextEditingController();
    passwordTextController = TextEditingController();

    emailAddressFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    emailAddressTextController.dispose();
    passwordTextController.dispose();

    emailAddressFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
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
              colors: [yellowishColor, primaryGreen],
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
                                'Welcome Back',
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
                                  'Fill out the information below in order to access your account.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                    fontSize: 14.0,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                              // Email Address Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
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
                                  child: TextFormField(
                                    controller: passwordTextController,
                                    focusNode: passwordFocusNode,
                                    autofocus: false,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    textInputAction: TextInputAction.done,
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
                              // User Type Selection
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
                                            _selectedLoginType =
                                                UserType.patient;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _selectedLoginType ==
                                                  UserType.patient
                                              ? primaryGreen
                                              : lightBackground,
                                          foregroundColor: _selectedLoginType ==
                                                  UserType.patient
                                              ? Colors.white
                                              : primaryText,
                                          side: BorderSide(
                                            color: _selectedLoginType ==
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
                                            _selectedLoginType =
                                                UserType.therapist;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _selectedLoginType ==
                                                  UserType.therapist
                                              ? primaryGreen
                                              : lightBackground,
                                          foregroundColor: _selectedLoginType ==
                                                  UserType.therapist
                                              ? Colors.white
                                              : primaryText,
                                          side: BorderSide(
                                            color: _selectedLoginType ==
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
                              // Sign In Button
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _autovalidateMode =
                                          AutovalidateMode.always;
                                    });

                                    if (_formKey.currentState == null ||
                                        !_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    try {
                                      UserCredential userCredential =
                                          await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                        email: emailAddressTextController.text,
                                        password: passwordTextController.text,
                                      );

                                      String targetCollection =
                                          _selectedLoginType == UserType.patient
                                              ? 'users'
                                              : 'therapists';
                                      DocumentSnapshot userDoc =
                                          await FirebaseFirestore.instance
                                              .collection(targetCollection)
                                              .doc(userCredential.user!.uid)
                                              .get();

                                      if (userDoc.exists) {
                                        if (mounted) {
                                          if (_selectedLoginType ==
                                              UserType.patient) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomePage()),
                                            );
                                          } else {
                                            // UserType.therapist
                                            // Check if therapist setup is complete
                                            bool isSetupComplete =
                                                userDoc['isSetupComplete']
                                                        as bool? ??
                                                    false;
                                            if (isSetupComplete) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TherapistHomePage()), // Navigate to TherapistHomePage
                                              );
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TherapistAccountSetupPage()), // Navigate to TherapistAccountSetupPage
                                              );
                                            }
                                          }
                                        }
                                      } else {
                                        await FirebaseAuth.instance.signOut();
                                        _showAlertDialog(
                                          'Login Failed',
                                          'Account found, but not registered as a ${_selectedLoginType == UserType.patient ? 'Patient' : 'Therapist'}. Please try the other option or register.',
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      print(
                                          'Firebase Auth Error: ${e.code} - ${e.message}');
                                      String errorMessage =
                                          'An error occurred. Please try again.';
                                      if (e.code == 'user-not-found') {
                                        errorMessage =
                                            'No user found for that email. Please check your email or register.';
                                      } else if (e.code == 'wrong-password') {
                                        errorMessage =
                                            'Wrong password provided. Please try again.';
                                      } else if (e.code == 'invalid-email') {
                                        errorMessage =
                                            'The email address is not valid.';
                                      } else if (e.code == 'user-disabled') {
                                        errorMessage =
                                            'This account has been disabled.';
                                      }
                                      _showAlertDialog(
                                          'Login Failed', errorMessage);
                                    } catch (e) {
                                      print('General Error: $e');
                                      _showAlertDialog('Error',
                                          'Something went wrong. Please try again.');
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
                                    'Sign In',
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // "Don't have an account? Sign Up here" text
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 40.0),
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Don\'t have an account?  ',
                                        style: GoogleFonts.inter(
                                          color: primaryText,
                                          letterSpacing: 0.0,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sign Up here',
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
                                                      RegisterPage()),
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
