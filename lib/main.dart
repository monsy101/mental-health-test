
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/dio/shopping_page.dart';
import 'package:monsy_weird_package/firebase_options.dart';
import 'package:monsy_weird_package/old/test.dart';
import 'package:monsy_weird_package/pages/mood_tracker_page.dart';
import 'package:monsy_weird_package/pages/profile_page.dart';
import 'package:monsy_weird_package/pages/yoga_page.dart';
import 'package:monsy_weird_package/pages/yoga_positions_screen.dart';
import 'package:monsy_weird_package/services/auth/auth_gate.dart';
import 'package:monsy_weird_package/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'ai widget test.dart';



main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (context)=> AuthService(),
    child: const MyApp(),)
  );

}

// main()async{
//   await WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: Scaffold(body: AIChatWidget(),),
      home: AuthGate(),
      // home: MoodTrackerPage(),
    );
  }
}
