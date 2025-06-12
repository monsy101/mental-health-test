// lib/visual_memory_game_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

class VisualMemoryGameScreen extends StatefulWidget {
  const VisualMemoryGameScreen({super.key});

  @override
  State<VisualMemoryGameScreen> createState() => _VisualMemoryGameScreenState();
}

enum GameState {
  start,
  showingPattern, // Displaying the pattern to memorize
  inputtingPattern, // User is tapping cells to recall
  gameOver, // No more lives
}

class _VisualMemoryGameScreenState extends State<VisualMemoryGameScreen> {
  int _level = 1;
  int _gridSize = 3; // e.g., 3x3 grid
  List<int> _highlightedCells = []; // Indices of cells that should be highlighted in the pattern
  List<int> _selectedCells = []; // Indices of cells selected by the player
  GameState _gameState = GameState.start;

  // --- Lives and Chances System ---
  int _lives = 3; // Total lives for the game
  int _chancesInRound = 3; // Max mistakes allowed per pattern attempt
  int _chancesRemainingInRound = 3; // Current chances left for the current pattern

  // NEW: Stores all incorrect taps in the current round
  List<int> _incorrectlyTappedCells = [];

  @override
  void initState() {
    super.initState();
  }

  // --- Game Logic Methods ---

  void _startGame() {
    setState(() {
      _level = 1;
      _lives = 3; // Reset total lives for a new game
      _chancesRemainingInRound = _chancesInRound; // Reset chances for the first pattern
      _gridSize = _getGridSize(_level);
      _highlightedCells = _generatePattern(_level, _gridSize);
      _selectedCells.clear();
      _incorrectlyTappedCells.clear(); // Clear all incorrect taps for a new game
      _gameState = GameState.showingPattern;
    });
    _showPattern();
  }

  void _nextRound() {
    setState(() {
      _level++; // Increment level for next round
      _chancesRemainingInRound = _chancesInRound; // Reset chances for the new pattern/level
      _gridSize = _getGridSize(_level);
      _highlightedCells = _generatePattern(_level, _gridSize);
      _selectedCells.clear();
      _incorrectlyTappedCells.clear(); // Clear all incorrect taps for a new round
      _gameState = GameState.showingPattern;
    });
    _showPattern();
  }

  void _showPattern() async {
    int baseDuration = 800; // Base 0.8 seconds
    int cellsToHighlight = _getCellsToHighlightCount(_level);
    int extraDuration = cellsToHighlight * 250; // 0.25 seconds per highlighted cell
    int totalDuration = baseDuration + extraDuration;

    if (totalDuration < 1200) totalDuration = 1200; // Minimum 1.2 seconds
    if (totalDuration > 4500) totalDuration = 4500; // Maximum 4.5 seconds

    if (_level == 1 && _lives == 3 && _chancesRemainingInRound == _chancesInRound) {
      totalDuration += 500; // Small extra delay for the very first pattern display
    }

    await Future.delayed(Duration(milliseconds: totalDuration));
    if (mounted) {
      setState(() {
        _gameState = GameState.inputtingPattern;
      });
    }
  }

  int _getGridSize(int level) {
    if (level <= 2) return 3; // 3x3 for levels 1-2
    if (level <= 4) return 4; // 4x4 for levels 3-4
    if (level <= 6) return 5; // 5x5 for levels 5-6
    return 6; // 6x6 for higher levels
  }

  int _getCellsToHighlightCount(int level) {
    if (level == 1) return 2;
    if (level == 2) return 3;
    if (level == 3) return 4;
    if (level == 4) return 5;
    if (level == 5) return 6;
    if (level == 6) return 7;
    int maxCells = _gridSize * _gridSize;
    return min(level + 1, maxCells - 1); // Ensure at least one cell isn't highlighted
  }

  List<int> _generatePattern(int level, int gridSize) {
    final Random random = Random();
    final int totalCells = gridSize * gridSize;
    final int count = _getCellsToHighlightCount(level);
    final List<int> pattern = [];

    while (pattern.length < count) {
      int randomIndex = random.nextInt(totalCells);
      if (!pattern.contains(randomIndex)) {
        pattern.add(randomIndex);
      }
    }
    pattern.sort();
    return pattern;
  }

  void _handleCellTap(int index) async {
    // Prevent re-tapping already selected (correct) or already tapped incorrectly cells
    if (_gameState != GameState.inputtingPattern ||
        _selectedCells.contains(index) ||
        _incorrectlyTappedCells.contains(index)) // Updated: Disable re-tapping any previously incorrect square
        {
      return;
    }

    if (_highlightedCells.contains(index)) {
      // Correct tap
      setState(() {
        _selectedCells.add(index);
      });

      // Check if all correct cells have been tapped
      if (_selectedCells.length == _highlightedCells.length) {
        await Future.delayed(const Duration(milliseconds: 600)); // Brief pause on complete correct selection
        if (mounted) _nextRound();
      }
    } else {
      // Incorrect tap
      setState(() {
        _chancesRemainingInRound--; // Deduct a chance for this pattern attempt
        _incorrectlyTappedCells.add(index); // NEW: Add to the list of incorrect taps
      });

      await Future.delayed(const Duration(milliseconds: 400)); // Show red cell briefly

      if (mounted) {
        // We no longer clear _incorrectlyTappedCells here.
        // They will remain set, keeping the squares red until a new pattern starts.

        if (_chancesRemainingInRound > 0) {
          // Still have chances left in this round, user continues on the same pattern
          // The red squares will now stay highlighted.
        } else {
          // No more chances left for this pattern, lose a life
          setState(() {
            _lives--; // Deduct a total life
            _selectedCells.clear(); // Clear selections for the new pattern (or game over)
            _incorrectlyTappedCells.clear(); // NEW: Clear all incorrect taps when a life is lost / new pattern
          });

          if (_lives > 0) {
            // Generate a NEW pattern for the SAME level
            setState(() {
              _chancesRemainingInRound = _chancesInRound; // Reset chances for the new pattern
              _highlightedCells = _generatePattern(_level, _gridSize); // Generate a NEW pattern
              _gameState = GameState.showingPattern; // Transition to showing the new pattern
            });
            _showPattern(); // Start showing the new pattern
          } else {
            // No more total lives, game over
            setState(() {
              _gameState = GameState.gameOver;
            });
          }
        }
      }
    }
  }

  void _resetGame() {
    setState(() {
      _gameState = GameState.start;
      _level = 1;
      _lives = 3; // Reset total lives
      _chancesRemainingInRound = _chancesInRound; // Reset chances
      _gridSize = _getGridSize(1); // Reset grid size for level 1
      _highlightedCells.clear();
      _selectedCells.clear();
      _incorrectlyTappedCells.clear(); // Clear all incorrect taps on full reset
    });
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light off-white
      appBar: AppBar(
        title: const Text(
          'Visual Memory',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color(0xFF91EEA5), // Light green
        elevation: 0,
        centerTitle: true,
        // Removed actions here as lives count is moved to the main content
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
      case GameState.showingPattern:
      case GameState.inputtingPattern:
        return _buildGameActiveScreen(key: const ValueKey<int>(1));
      case GameState.gameOver:
        return _buildGameOverScreen(key: const ValueKey<int>(2));
    }
  }

  Widget _buildStartScreen({Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Visual Memory Game',
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

  Widget _buildGameActiveScreen({Key? key}) {
    String instructionText = '';
    Color instructionTextColor = Colors.black87;
    double instructionTextSize = 24;

    if (_gameState == GameState.showingPattern) {
      instructionText = 'Memorize the pattern!';
    } else if (_gameState == GameState.inputtingPattern) {
      instructionText = 'Tap the highlighted squares!';
      instructionTextSize = 24; // Smaller to fit two lines
      instructionTextColor = (_chancesRemainingInRound < _chancesInRound) ? Colors.red : Colors.black87;
    }

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row( // Row to display Level and Lives side-by-side
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
                  const SizedBox(width: 20), // Space between Level and Lives
                  Text(
                    'Lives: $_lives',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Reduced gap for tighter fit
              Text(
                instructionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: instructionTextSize,
                  fontWeight: FontWeight.bold,
                  color: instructionTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Reduced spacing before the grid
          _buildGrid(), // The Grid itself
        ],
      ),
    );
  }

  Widget _buildGameOverScreen({Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'GAME OVER!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'You reached Level $_level',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _resetGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
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
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final double cellSize = min(
      (MediaQuery.of(context).size.width - (32 * 2 + 20 * 2 + 8)) / _gridSize,
      70.0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: _gridSize * cellSize,
      height: _gridSize * cellSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridSize,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _gridSize * _gridSize,
        itemBuilder: (context, index) {
          Color cellColor = Colors.grey[300]!;
          bool isTappable = (_gameState == GameState.inputtingPattern);
          bool isHighlightedForDisplay = _highlightedCells.contains(index);
          bool isSelectedByUser = _selectedCells.contains(index);

          // Determine cell color based on current game state and cell properties
          if (_gameState == GameState.showingPattern && isHighlightedForDisplay) {
            cellColor = const Color(0xFF91EEA5); // Light green highlight for pattern
          } else if (_gameState == GameState.inputtingPattern) {
            if (isSelectedByUser) {
              cellColor = const Color(0xFF91EEA5); // Green for correctly selected by user
            }
            if (_incorrectlyTappedCells.contains(index)) { // NEW: If this cell was incorrectly tapped
              cellColor = Colors.red; // Mark it red
            }
          }

          return GestureDetector(
            onTap: isTappable ? () => _handleCellTap(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_gameState == GameState.showingPattern && isHighlightedForDisplay) ||
                      (_gameState == GameState.inputtingPattern && (isSelectedByUser || _incorrectlyTappedCells.contains(index))) // NEW: Border for all incorrect taps
                      ? Colors.black54 : Colors.transparent, // Border for relevant cells
                  width: 2,
                ),
              ),
              child: (_gameState == GameState.showingPattern && isHighlightedForDisplay)
                  ? const Center(
                child: Icon(Icons.star, color: Colors.white, size: 30),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}