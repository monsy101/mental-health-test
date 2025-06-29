import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/components/my_button.dart';
import 'package:monsy_weird_package/pages/ai_chat_page.dart';
import 'package:monsy_weird_package/pages/contacts_page.dart';
import 'package:monsy_weird_package/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign user out
  void signOut() {
    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("HomePage"),
    //     actions: [
    //       // sign out button
    //       IconButton(onPressed: signOut, icon: const Icon(Icons.logout))
    //     ],
    //   ),
    //   body: _buildUserList(),
    // );
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            MyButton(onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ContactsPage()));
            }, text: "contacts"),
            SizedBox(
              height: 20,
            ),
            MyButton(onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> AIChatPage()));

            }, text: "aichat"),
          ],
        ),
      ),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        // if there is an error output it
        if (snapshot.hasError) {
          return const Text('error');
        }
        // say that it's loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }

        // show users in a list format by using a snapshot
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    //display all users except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          // pass the clicked user's UID to the chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'],
                receiverUserID: data['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
