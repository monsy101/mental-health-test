import 'package:flutter/material.dart';

class YogaPositionsScreen extends StatelessWidget {
  const YogaPositionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // background color

      Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xff91EEA5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
      ),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Yoga Poses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(32),
                    bottomLeft: Radius.circular(32))),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
                itemCount: 11,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: .80),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // image
                      Image.asset('images/$index.png'),
                      // title
                      Text(
                        'Pose $index',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  );
                }),
          )),
    ]);
  }
}
