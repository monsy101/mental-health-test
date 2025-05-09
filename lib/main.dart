
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/firebase_options.dart';
import 'package:monsy_weird_package/pages/yoga_page.dart';
import 'package:monsy_weird_package/pages/yoga_positions_screen.dart';
import 'package:monsy_weird_package/services/auth/auth_gate.dart';
import 'package:monsy_weird_package/services/auth/auth_service.dart';
import 'package:provider/provider.dart';



main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (context)=> AuthService(),
    child: const MyApp(),)
  );

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: YogaPage(),
    );
  }
}
