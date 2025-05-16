import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = []; // Stores conversation history

  // Function to send prompt to AI and update chat history
  Future<void> sendMessage() async {
    String userMessage = _messageController.text.trim();

    if (userMessage.isNotEmpty) {
      // Add user message to chat history
      setState(() {
        _messages.add({"role": "user", "text": userMessage});
      });

      _messageController.clear(); // Clear input field

      // Fetch AI-generated response
      String aiResponse = await fetchAIResponse(userMessage);

      // Add AI response to chat history
      setState(() {
        _messages.add({"role": "assistant", "text": aiResponse});
      });
    }
  }

  // Function to fetch AI response from API
  Future<String> fetchAIResponse(String prompt) async {
    try {
      final uri = Uri.parse('http://10.0.2.2:5000/v1/completions'); // Adjust if needed
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "stablelm-zephyr-3b",
          "prompt": "User: $prompt \n Assistant:",
          "max_tokens": 256,
          "temperature": 0.7,
          "top_p": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['text']; // Extract AI-generated response
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (error) {
      return "AI response failed: ${error.toString()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("AI Chat"),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()), // Display chat history
          _buildMessageInput(), // User input field
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