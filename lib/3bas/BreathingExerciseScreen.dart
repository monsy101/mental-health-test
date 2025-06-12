import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

// Enum to manage the state of the breathing animation
enum BreathingPhase {
  inhale,
  exhale,
  initial, // For the very beginning before any cycle starts
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  // Animation properties
  BreathingPhase _currentPhase = BreathingPhase.initial;
  double _circleDiameter = 200.0; // Initial size of the inner circle
  final double _minCircleDiameter = 200.0; // Smallest size for exhale
  final double _maxCircleDiameter = 250.0; // Largest size for inhale
  String _displayText = "Start Breathing";

  // Durations for each phase
  final Duration _inhaleDuration = const Duration(seconds: 5);
  final Duration _exhaleDuration = const Duration(seconds: 6);

  // Counter properties
  int _currentBreathCount = 0;
  final int _totalBreaths = 30; // Target breaths for the session

  // Session control
  Timer? _breathingTimer; // Keeping this for potential future complex timing, though Future.delayed is used for phases
  bool _isSessionComplete = false;
  bool _isBreathingActive = false; // To control starting/pausing the animation

  @override
  void initState() {
    super.initState();
    // Start breathing automatically after a brief delay if desired,
    // or wait for a "Start" button press. For this example, let's auto-start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBreathingSession();
    });
  }

  @override
  void dispose() {
    _breathingTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _startBreathingSession() {
    if (_isBreathingActive && !_isSessionComplete) return; // Prevent starting if already active and not complete

    setState(() {
      _isBreathingActive = true;
      _isSessionComplete = false;
      _currentBreathCount = 0; // Reset for a new session
      _currentPhase = BreathingPhase.initial; // Reset phase
      _displayText = "Start Breathing";
      _circleDiameter = _minCircleDiameter; // Start at min size
    });
    _runBreathingCycle(); // Begin the breathing animation cycle
  }

  void _runBreathingCycle() async {
    if (!_isBreathingActive || _isSessionComplete || !mounted) {
      return; // Stop if session is complete, paused, or widget is disposed
    }

    // Inhale Phase
    setState(() {
      _currentPhase = BreathingPhase.inhale;
      _displayText = "Breathe in";
      _circleDiameter = _maxCircleDiameter; // Bigger size for inhale
    });
    await Future.delayed(_inhaleDuration);

    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Exhale Phase
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _displayText = "Breathe out";
      _circleDiameter = _minCircleDiameter; // Smaller size for exhale (back to initial)
    });
    await Future.delayed(_exhaleDuration);

    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // End of one breath cycle
    setState(() {
      _currentBreathCount++;
    });

    if (_currentBreathCount >= _totalBreaths) {
      // Session complete
      _endSession(complete: true);
    } else {
      // Continue to the next cycle
      _runBreathingCycle();
    }
  }

  void _endSession({bool complete = false}) {
    _breathingTimer?.cancel(); // Ensure timer is stopped
    setState(() {
      _isBreathingActive = false;
      _isSessionComplete = true;
      if (!complete) {
        _displayText = "Session Ended"; // Custom message if ended early
      } else {
        _displayText = "Complete!"; // Message if all breaths are done
      }
    });
  }

  void _resetAndStartNewRound() {
    _startBreathingSession(); // Simply restart the session
  }

  void _goBack() {
    Navigator.pop(context); // Navigate back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Breathing',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color(0xFF91EEA5), // Light green App bar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: _goBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Take A Few Deep Breaths.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // NEW: Stack to layer the static shadow and animating circle
              Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Static Outer Container for the Shadow
                  Container(
                    width: _maxCircleDiameter, // Fixed size to define the shadow area
                    height: _maxCircleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent, // Keep this transparent
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.7),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 5), // Slight offset for depth
                        ),
                      ],
                    ),
                  ),
                  // 2. Animating Inner Circle
                  AnimatedContainer(
                    duration: _currentPhase == BreathingPhase.inhale ? _inhaleDuration : _exhaleDuration,
                    curve: Curves.easeInOut, // Smooth animation curve
                    width: _circleDiameter, // This property animates
                    height: _circleDiameter, // This property animates
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF4DB6AC), // Inner light teal
                          Color(0xFF339989), // Mid teal
                          Color(0xFF206A5D), // Outer dark teal
                        ],
                        stops: [0.0, 0.5, 1.0], // Transition points for colors
                      ),
                      // boxShadow property is REMOVED from here, as it's now on the outer Container
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _displayText,
                      style: const TextStyle(
                        color: Colors.white, // White text
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Breath Counter
              Text(
                '$_currentBreathCount/$_totalBreaths',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),
              // Session Control Buttons
              if (!_isSessionComplete)
                ElevatedButton(
                  onPressed: _endSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'End Session',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _resetAndStartNewRound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF91EEA5), // Light green
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Another Round',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _goBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400], // Grey
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Go back',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}