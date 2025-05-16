import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'components/chat_bubble.dart';

// A StatefulWidget that handles user input and communicates with an AI model
class AIChatWidget extends StatefulWidget {
  @override
  _AIChatWidgetState createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends State<AIChatWidget> {
  // Controller for handling user text input
  TextEditingController _controller = TextEditingController();

  // Default response text before user interaction
  String responseText = "Enter a prompt and get AI-generated text!";

  // Function to send a prompt to the AI API and update response
  Future<void> fetchAIResponse(String prompt) async {
    print("Sending request to API...");

    final uri = Uri.parse('http://10.0.2.2:5000/v1/completions'); // Ensure correct API URL
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "stablelm-zephyr-3b", // Specify model being used
        "prompt": "User: $prompt \n Assistant:", // Prompt format to guide AI response
        "max_tokens": 256, // Limit response length
        "temperature": 0.5, // Adjust randomness of responses
        "top_p": 0.9 // Control diversity in token selection
      }),
    );

    print("Response received: ${response.statusCode}");

    // Check if the request was successful
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Generated response: ${data['choices'][0]['text']}"); // Debug print

      // Update UI with the received response
      setState(() {
        responseText = data['choices'][0]['text'];
      });
    } else {
      print("Error: ${response.statusCode} - ${response.body}"); // Handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Prevents overflow by allowing scrolling
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Text field for user input
            TextField(
              controller: _controller, // Bind text controller
              decoration: InputDecoration(labelText: "Enter prompt"), // Input label
            ),
            SizedBox(height: 10),

            // Button to send user input to AI model
            ElevatedButton(
              onPressed: () {
                try {
                  fetchAIResponse(_controller.text); // Send prompt to API
                } catch (error) {
                  print(error.toString()); // Debugging any errors
                }
              },
              child: Text("Generate"), // Button label
            ),
            SizedBox(height: 20),

            // Container to display AI-generated response
            ChatBubble(message: responseText,),


          ],
        ),
      ),
    );
  }
}