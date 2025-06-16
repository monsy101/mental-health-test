import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/3bas/add_task_dialog.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_service.dart';
import 'chat_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
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
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text("Contacts"),
            centerTitle: true,
            backgroundColor: primaryGreen,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildUserList(),
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
          padding: EdgeInsets.symmetric(vertical: 16),
          children: snapshot.data!.docs.map<Widget>((doc) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6), // Adds spacing between tiles
            child: _buildUserListItem(doc),
          )).toList(),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        tileColor: cardBackground,
        trailing: const Icon(
          Icons.chat,
          color: primaryGreen,
        ),
        title: data['firstName'] != Null
            ? Text("${data['firstName']} ${data['lastName']}")
            : Text(data['email']),
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
