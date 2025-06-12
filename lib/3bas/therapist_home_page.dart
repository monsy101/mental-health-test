// File: lib/therapist_home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/login_page.dart';

// Define custom colors (consistent with other pages)
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color cardBackground = Colors.white;

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({super.key});

  static String routeName = 'TherapistHomePage';
  static String routePath = '/therapistHome';

  @override
  State<TherapistHomePage> createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  User? currentUser;
  String? _firstName;
  String? _lastName;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchTherapistInfo();
  }

  Future<void> _fetchTherapistInfo() async {
    if (currentUser == null) {
      // Handle case where user is not logged in (though they should be to reach this page)
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot therapistDoc = await FirebaseFirestore.instance
          .collection('therapists')
          .doc(currentUser!.uid)
          .get();

      if (therapistDoc.exists) {
        setState(() {
          _firstName = therapistDoc['firstName'] as String?;
          _lastName = therapistDoc['lastName'] as String?;
          _email = therapistDoc['email'] as String?;
          _isLoading = false;
        });
      } else {
        // Therapist document not found, possibly an inconsistency
        print('Therapist document not found for UID: ${currentUser!.uid}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching therapist info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: lightBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
        ),
      );
    }

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: lightBackground,
        body: Center(
          child: Text('Please log in to view therapist home.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightBackground,
      body: Column(
        children: [
          // Custom App Bar
          Container(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height * 0.12,
            decoration: const BoxDecoration(
              color: primaryGreen,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, 2.0),
                )
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Optional: Back button if needed, but usually not for home
                  const SizedBox(width: 50.0), // Spacer for alignment
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'Therapist Home',
                        style: GoogleFonts.interTight(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Logout Button
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage(
                                    onTap: () {},
                                  )),
                          // Assuming LoginPage is your entry point
                          (Route<dynamic> route) =>
                              false, // Remove all routes below
                        );
                      }
                    },
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      margin: const EdgeInsets.only(right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Therapist Information Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_firstName ?? 'Therapist'}!',
                    style: GoogleFonts.interTight(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Name: ${_firstName ?? ''} ${_lastName ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Email: ${_email ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: secondaryText,
                    ),
                  ),
                  // Add more therapist-specific information here
                  const SizedBox(height: 24.0),
                  Text(
                    'This is your dedicated therapist dashboard. You can add features here specific to managing your patients, appointments, etc.',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
