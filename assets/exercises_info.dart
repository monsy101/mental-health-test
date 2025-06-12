import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monsy_weird_package/3bas/BreathingExerciseScreen.dart';
import 'package:monsy_weird_package/3bas/game_screen.dart';
import 'package:monsy_weird_package/3bas/visual_memory_game_screen.dart';
import 'package:monsy_weird_package/pages/yoga_page.dart';

List<Map<String, dynamic>> exercisePages = [
  {
    "pageTitle": "Number Memory Game",
    "description": "Improve your short term memory for numbers.",
    "navigation": GameScreen(),
    "icon": Icon(CupertinoIcons.number_square_fill,size: 20,)
  },
  {
    "pageTitle": "Visual Memory Game",
    "description": "boost cognitive function by sharpening the ability to recall and process visual information.",
    "navigation": VisualMemoryGameScreen(),
    "icon": Icon(CupertinoIcons.eye)
  },
  {
    "pageTitle": "Breathing Exercise",
    "description": "Help regulate the nervous system, reducing stress and promoting a sense of calm which positively impacts mental well-being.",
    "navigation": BreathingExerciseScreen(),
    "icon": Icon(Icons.air)
  },
  {
    "pageTitle": "Yoga",
    "description": "Improves mental health by integrating movement, breath, and meditation to reduce stress and anxiety.",
    "navigation": YogaPage(),
    "icon": Icon(Icons.self_improvement)
  },
];