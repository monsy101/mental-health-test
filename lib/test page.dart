import 'package:flutter/material.dart';
import 'package:monsy_weird_package/ai%20widget%20test.dart';

import 'ai test.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}
   Future<String> aiResponse () async { // todo:test this
  return await sendPrompt("i am feeling kinda down lately");
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(aiResponse().toString()),),
    );
  }
}
