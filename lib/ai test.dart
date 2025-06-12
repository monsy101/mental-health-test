import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendPrompt(String prompt) async {
  final uri = Uri.parse("http://127.0.0.1:5000/v1/chat/completions");

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "model": "stablelm-zephyr-3b",
      "messages": [ // ✅ Correct format for chat-based models
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 256,
      "temperature": 0.7,
      "top_p": 0.9
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content']; // ✅ Updated response parsing
  } else {
    return "Error: ${response.statusCode} - ${response.body}";
  }
}

void main() async {
  String aiResponse = await sendPrompt("I am feeling kinda down lately");
  print("Processed Response: $aiResponse");
}