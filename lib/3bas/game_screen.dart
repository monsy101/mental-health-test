// lib/game_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum GameState {
  showingNumber,
  inputtingNumber,
  correct,
  incorrect,
  start,
}

class _GameScreenState extends State<GameScreen> {
  String _currentNumber = '';
  int _level = 1;
  GameState _gameState = GameState.start;
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // --- Game Logic Methods ---

  void _startGame() async {
    setState(() {
      _level = 1; // Reset level on new game start
      _currentNumber = _generateNumber(_level);
      _inputController.clear();
      _gameState = GameState.showingNumber; // Immediately show number
    });

    // Wait for a duration based on number length, then transition to input state
    int showDuration = _currentNumber.length * 700;
    if (showDuration < 750) showDuration = 750;
    if (showDuration > 4000) showDuration = 4000;

    // Add a small delay for Level 1 only
    if (_level == 1) {
      showDuration += 500; // Add an extra 0.5 seconds for the first level
    }

    await Future.delayed(Duration(milliseconds: showDuration));
    if (mounted) {
      setState(() {
        _gameState = GameState.inputtingNumber;
      });
    }
  }

  void _nextRound() async {
    setState(() {
      _level++; // Increment level for next round
      _currentNumber = _generateNumber(_level);
      _inputController.clear();
      _gameState = GameState.showingNumber;
    });

    int showDuration = _currentNumber.length * 500;
    if (showDuration < 750) showDuration = 750;
    if (showDuration > 4000) showDuration = 4000;

    await Future.delayed(Duration(milliseconds: showDuration));
    if (mounted) {
      setState(() {
        _gameState = GameState.inputtingNumber;
      });
    }
  }

  String _generateNumber(int level) {
    String number = '';
    Random random = Random();
    int digits = level;

    if (digits < 1) digits = 1;

    for (int i = 0; i < digits; i++) {
      if (i == 0 && digits > 1) {
        number += (random.nextInt(9) + 1).toString(); // 1-9
      } else {
        number += random.nextInt(10).toString(); // 0-9
      }
    }
    return number;
  }

  void _checkAnswer() {
    if (_formKey.currentState!.validate()) {
      if (_inputController.text == _currentNumber) {
        setState(() {
          _gameState = GameState.correct;
        });
        // **Removed the Future.delayed to automatically go to the next round.**
        // The "NEXT" button will now trigger _nextRound().
      } else {
        setState(() {
          _gameState = GameState.incorrect;
        });
      }
    }
  }

  void _resetGame() {
    setState(() {
      _gameState = GameState.start;
      _currentNumber = '';
      _level = 1;
      _inputController.clear();
    });
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        title: const Text(
          'Number Memory',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color(0xFF91EEA5),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_gameState) {
      case GameState.start:
        return _buildStartScreen(key: const ValueKey<int>(0));
      case GameState.showingNumber:
        return _buildShowingNumberScreen(key: const ValueKey<int>(1));
      case GameState.inputtingNumber:
        return _buildInputtingNumberScreen(key: const ValueKey<int>(2));
      case GameState.correct:
        return _buildFeedbackScreen('CORRECT!\n$_currentNumber', Colors.green, key: const ValueKey<int>(3));
      case GameState.incorrect:
        return _buildFeedbackScreen('INCORRECT!\n$_currentNumber', Colors.red, key: const ValueKey<int>(4));
      default:
        return const Center(child: Text('Unknown State', key: ValueKey<int>(5)));
    }
  }

  Widget _buildStartScreen({Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Number Memory Game',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF91EEA5),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'START GAME',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Level: $_level',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildShowingNumberScreen({Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Level: $_level',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedOpacity(
          opacity: _gameState == GameState.showingNumber ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (BuildContext context, double scale, Widget? child) {
              return Transform.scale(
                scale: scale,
                child: Text(
                  _currentNumber,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            },
            curve: Curves.easeOutBack,
          ),
        ),
      ],
    );
  }

  Widget _buildInputtingNumberScreen({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Level: $_level',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'What was the number?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Enter number',
                hintStyle: const TextStyle(color: Colors.black45, fontSize: 30),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF91EEA5), width: 3),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number!';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'CHECK',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackScreen(String message, Color color, {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 60),
        // **NEW: Conditional buttons based on game state**
        if (_gameState == GameState.correct)
          ElevatedButton(
            onPressed: _nextRound, // This button moves to the next round
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91EEA5), // Green for NEXT
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'NEXT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on green button
              ),
            ),
          )
        else if (_gameState == GameState.incorrect)
          ElevatedButton(
            onPressed: _resetGame, // This button resets the game
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // Orange for Play Again
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on orange button
              ),
            ),
          ),
      ],
    );
  }
}