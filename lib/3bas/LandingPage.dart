import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Required for RichText tap gesture
import 'package:google_fonts/google_fonts.dart';

import '../3bas/login_page.dart';
import '../3bas/register_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Define custom colors based on your specifications
  static const Color primaryGreen = Color(0xFF91EEA5);
  static const Color lightBackground = Color(0xFFF1F4F8);
  static const Color primaryText =
      Color(0xFF14181B); // Assuming a dark text for primary
  static const Color secondaryText = Color(0xFF57636C); // For the body text
  static const Color alternateColor =
      Color(0xFF000000); // Used where FlutterFlowTheme.alternate was

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: lightBackground, // Set the background color
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Stack for the background image and gradient overlay
            Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      // No border radius as per original
                      child: Image.asset(
                        'assets/images/therapygirl.png',
                        // Use the provided image asset
                        width: double.infinity, // Occupy full width
                        height: 400.0, // Fixed height for the image
                        fit: BoxFit.cover, // Cover the entire space
                        alignment:
                            const Alignment(0.0, -1.0), // Align to top center
                      ),
                    ),
                  ),
                ),
                Opacity(
                    opacity: 0.1,
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      color: Colors.white,
                    )),
                Container(
                  width: double.infinity,
                  // Occupy full width
                  height: 450.0,
                  // Height slightly more than image for gradient effect
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [Colors.transparent, lightBackground],
                      // Transparent to background color
                      stops: const [0.0, 0.73],
                      // Gradient starts from transparent at 0% and transitions to background color at 80%
                      begin: const AlignmentDirectional(0.0, -1.0),
                      // Top to bottom
                      end: const AlignmentDirectional(0, 1.0),
                    ),
                    borderRadius:
                        BorderRadius.circular(0.0), // No border radius
                  ),
                  child: Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    // Align content to the bottom of this container
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Center the icon and texts
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(0.0, -1.0),
                            child: Icon(
                              Icons.flutter_dash_outlined, // Flutter Dash icon
                              color: primaryGreen, // Primary green color
                              size: 60.0,
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(0.0, -1.0),
                            child: Text(
                              'Theraputic',
                              style: GoogleFonts.playfairDisplay(
                                // Custom font
                                color: primaryGreen, // Primary green color
                                fontSize: 35.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight
                                    .bold, // Adjusted for visual match
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              'Amplify your Mental Well Being ',
                              style: GoogleFonts.inter(
                                // Custom font
                                color: alternateColor,
                                // White color for this text
                                fontSize: 20.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Divider below the image/gradient section
            Divider(
              thickness: 1.0,
              indent: 30.0,
              endIndent: 30.0,
              color: alternateColor, // White color for the divider
            ),
            // Flexible section for the main body text
            Flexible(
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                // Center alignment
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      30.0, 20.0, 30.0, 0.0),
                  child: Text(
                    'Your mental health and overall well-being should always be a top priority, as they are essential to living a balanced, fulfilling, and healthy life.',
                    textAlign: TextAlign.center, // Center align the text
                    style: GoogleFonts.inter(
                      // Custom font
                      color: secondaryText, // Dark grey for secondary text
                      fontSize: 17,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            // Flexible section for the "Start With Us" button
            Flexible(
              child: Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                // Align to the bottom
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 12.0, 16.0, 12.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    label: Text(
                      'Start With Us',
                      style: GoogleFonts.interTight(
                        // Custom font
                        color: alternateColor, // White text color
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0, // Adjusted font size for better fit
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 24.0,
                      color: alternateColor, // White icon color
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60.0),
                      // Occupy full width, fixed height
                      backgroundColor: primaryGreen,
                      // Primary green background
                      foregroundColor: alternateColor,
                      // Icon and ripple color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        // Rounded corners
                        side: const BorderSide(
                          color: Colors.transparent,
                          // No border color as per original
                          width: 2.0,
                        ),
                      ),
                      elevation: 0.0,
                      // No elevation
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      // No horizontal padding
                      alignment: Alignment
                          .center, // Center align content inside button
                    ),
                  ),
                ),
              ),
            ),
            // Section for the "Already have an account? Log In!" text
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 64.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account?',
                      style: GoogleFonts.inter(
                        // Custom font
                        color: secondaryText, // Dark grey color
                        fontSize: 16.0, // Adjusted font size
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: ' Log In!',
                      style: GoogleFonts.inter(
                        // Custom font
                        color: primaryText,
                        // Using a darker primary text color for contrast
                        fontSize: 16.0,
                        // Adjusted font size
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                    )
                  ],
                  // Base style for RichText (if needed, otherwise individual spans carry their own)
                  style: GoogleFonts.inter(
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
