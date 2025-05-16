import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/tamatem.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              // profile picture
              CircleAvatar(
                radius: 100,
              ),
      
              // display name
              GetUsername()
      
              // change name
      
              // todo: add more settings
            ],
          ),
        ),
      ),
    );
  }
}
