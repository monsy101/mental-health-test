import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monsy_weird_package/yoga/wind_relieving_pose_widget.dart';

import '../3bas/home_page.dart';
import '3bas/LandingPage.dart';
import '3bas/main_screen.dart';

void main() async {
  // Ensure Flutter widgets binding is initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the platform-specific options.
  await Firebase.initializeApp();

  // Run the Flutter application.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the base widget for a Material Design app.
    return MaterialApp(
      title: 'Theraputech',
      // App title
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define your primary color theme
        visualDensity: VisualDensity
            .adaptivePlatformDensity, // Adapts UI to platform specifics
      ),
      // Use a StreamBuilder to listen for Firebase authentication state changes.
      // This determines whether to show the LandingPage or HomePage.
      // home: StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     // While waiting for the authentication state, show a loading indicator.
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(
      //           child: CircularProgressIndicator(), // Simple loading indicator
      //         ),
      //       );
      //     }
      //     // If there is a user logged in (snapshot.hasData is true), navigate to HomePage.
      //     if (snapshot.hasData) {
      //       return const MainScreen();
      //     }
      //     // If no user is logged in, navigate to LandingPage.
      //     return const LandingPage();
      //   },
      // ),
      home: WindRelievingPoseWidget(),
    );
  }
}
