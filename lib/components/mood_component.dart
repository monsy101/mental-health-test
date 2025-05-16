import 'package:flutter/material.dart';

import 'my_colors.dart';

class MoodComponent extends StatefulWidget {
  final String moodImage;

  const MoodComponent({super.key, required this.moodImage});

  @override
  State<MoodComponent> createState() => _MoodComponentState();
}

class _MoodComponentState extends State<MoodComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("this works");
      },
      child: CircleAvatar(
        radius: 64,

        backgroundColor: MyColors[0], // todo remove
      ),
    );
  }
}
