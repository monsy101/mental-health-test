import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetUsername extends StatelessWidget {
  const GetUsername({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // The display name might be directly available if set during sign-up
      if (user.displayName != null) {
        return Text('Username: ${user.displayName}');
      } else {
        // If the username is stored in Firestore with the user's UID as the document ID
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return const Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                  "Username: ${data['username'] ?? 'No Username'}"); // Assuming 'username' is the field name
            }

            return const CircularProgressIndicator();
          },
        );
      }
    } else {
      return const Text('User not logged in.');
    }
  }
}
