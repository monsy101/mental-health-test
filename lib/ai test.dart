import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendPrompt(String prompt) async {
  // api
  final uri = Uri.parse('http://192.168.1.5:5000/v1/completions');


  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "model": "stablelm-zephyr-3b",
      "prompt": "User: $prompt \n Assistant:",
      "max_tokens": 256,
      "temperature": 0.7,
      "top_p": 0.9
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['text']; // Return the AI-generated response
  } else {
    return "Error: ${response.statusCode} - ${response.body}";
  }
}
void main() async {
  String aiResponse = await sendPrompt("i am feeling kinda down lately");
  print("Processed Response: $aiResponse");
}