import 'package:flutter/material.dart';
import 'package:monsy_weird_package/pages/yoga_positions_screen.dart';

import '../yoga/yoga_poses_dashboard.dart';

class YogaPage extends StatelessWidget {
  const YogaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
            backgroundColor: Color(0xff91EEA5),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.keyboard_return,
                    size: 40,
                    color: Colors.white,
                  ))
            ],
          ),
          body: Stack(
            children: [
              // yoga information
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      // yoga image
                      const Image(
                        image: AssetImage('assets/images/yoga_image.png'),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // title for the page
                      const Text(
                        'Yoga meditation guide',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // description
                      Text(
                        "Yoga meditation blends physical poses, controlled breathing, and focused attention to significantly boost mental well-being. Physical postures release tension that often contributes to mental stress. Mindful movement during asanas anchors you in the present, reducing worries about the past or future. Pranayama, or breath control, activates the \"rest and digest\" system, lowering stress hormones and building resilience. The meditative aspect cultivates mindfulness, allowing you to observe thoughts without getting caught up in them, fostering emotional regulation and calm. Regular practice can improve mood, lessen anxiety and depression, sharpen focus, and enhance overall well-being, making it a powerful tool for mental health.",
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),

                      const SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),

              // send to yoga position screen button

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Color(0xff91EEA5),
                              minimumSize: const Size(250, 50)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const YogaPosesDashboard()));
                          },
                          child: const Text(
                            "go to yoga positions",
                            style: TextStyle(fontSize: 24, color: Colors.black),
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
