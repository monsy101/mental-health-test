import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = []; // Local chat history

  @override
  void initState() {
    super.initState();
    _loadChatHistory(); // Load past messages from Firestore
  }

  // Function to send user message & get AI response
  Future<void> sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    // Store user message locally & in Firestore
    setState(() {
      _messages.add({"role": "user", "text": userMessage});
    });
    _messageController.clear();
    saveChatMessage(userMessage, "User");

    // Fetch AI response
    String aiResponse = await fetchAIResponse(userMessage);

    // Store AI response locally & in Firestore
    setState(() {
      _messages.add({"role": "assistant", "text": aiResponse});
    });
    saveChatMessage(aiResponse, "AI");
  }

  // Function to fetch AI response from API
  Future<String> fetchAIResponse(String prompt) async {
    try {
      final uri = Uri.parse("http://10.0.2.2:5000/v1/chat/completions");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "stablelm-zephyr-3b",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 256,
          "temperature": 0.7,
          "top_p": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
        return "Error: ${response.statusCode}";
      }
    } catch (error) {
      print("❌ AI response failed: $error");
      return "Error fetching AI response.";
    }
  }

  // Save chat message to Firestore
  void saveChatMessage(String message, String sender) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection("chatMessages").add({
        "userId": user.uid,
        "message": message,
        "sender": sender,
        "timestamp": FieldValue.serverTimestamp(),
      });
      print("✅ Chat message saved in Firestore!");
    } catch (error) {
      print("❌ Error saving message: $error");
    }
  }

  // Load past chat messages from Firestore
  void _loadChatHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection("chatMessages")
        .where("userId", isEqualTo: user.uid)
        .orderBy("timestamp", descending: false)
        .get();

    setState(() {
      _messages = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return {
          "role": data["sender"] == "User" ? "user" : "assistant",
          "text": data["message"].toString(), // ✅ Ensure text is a String
        } as Map<String, String>; // ✅ Explicitly cast to `Map<String, String>`
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text("AI Chat")),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Build message list dynamically
  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        bool isUserMessage = message["role"] == "user";

        return Container(
          alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(isUserMessage ? "You" : "AI Bot"),
              const SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUserMessage ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(message["text"]!, style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build message input section
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Enter your message'),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, size: 40),
          ),
        ],
      ),
    );
  }
}