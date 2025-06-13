import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/chat_page.dart';

class AdminChatRoomsPage extends StatefulWidget {
  const AdminChatRoomsPage({super.key});

  @override
  State<AdminChatRoomsPage> createState() => _AdminChatRoomsPageState();
}

class _AdminChatRoomsPageState extends State<AdminChatRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Rooms")),
      body: _buildChatRoomList(),
    );
  }

  // ✅ Fetch all chat rooms from Firestore
  Widget _buildChatRoomList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chat_rooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chat rooms.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildChatRoomItem(doc)).toList(),
        );
      },
    );
  }

  // ✅ Build chat room list item with navigation
  Widget _buildChatRoomItem(DocumentSnapshot document) {
    String chatRoomId = document.id;
    List<String> participants = chatRoomId.split("_"); // ✅ Extract participants

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("Chat Room: $chatRoomId", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text("Participants: ${participants.join(' & ')}"),
        trailing: Icon(Icons.chat, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                 receiverUserEmail: '', receiverUserID: '', // ✅ Pass correct chat room ID
              ),
            ),
          );
        },
      ),
    );
  }
}