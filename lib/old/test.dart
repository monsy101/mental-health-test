import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [senderContainer(myMessage: "3a33a3")],
      ),
    );
  }
}

class senderContainer extends StatelessWidget {
  const senderContainer({super.key, required String myMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.shade700,
                      blurRadius: 16,
                      blurStyle: BlurStyle.outer)
                ]),
            child: Test(),
          ),
        ),
      ],
    );
  }
}
