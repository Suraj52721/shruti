import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_logic.dart';
import '../models/session_result.dart';
import '../theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/audio_path_mapper.dart';

class ArenaScreen extends ConsumerStatefulWidget {
  const ArenaScreen({super.key});

  @override
  ConsumerState<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends ConsumerState<ArenaScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _continuousMode = false;

  // For validation animation
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    // Play sound initially after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound() async {
    // We access the helper getter from the NOTIFIER, not the state.
    final logicNotifier = ref.read(gameLogicProvider.notifier);
    String fullPath = logicNotifier.currentAudioPath;
    // Remove "assets/" prefix for AssetSource
    String assetPath = fullPath.replaceFirst("assets/", "");

    try {
      await _audioPlayer.stop(); // Stop previous
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error playing: $assetPath")));
      }
    }
  }

  final _random = Random();
  final List<String> _praisePhrases = [
    "Awesome!",
    "Spot On!",
    "Great Ear!",
    "Keep it Up!",
    "Perfect!",
    "Sensational!",
  ];

  bool _isProcessing = false;

  Future<void> _handleGuess(String note) async {
    if (_isProcessing) {
      debugPrint("Ignoring guess: Processing already in progress.");
      return;
    }
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Play the selected note
      await _playSelectedOption(note);

      // 2. Wait 1.5 seconds
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      final logicNotifier = ref.read(gameLogicProvider.notifier);
      final previousCorrect = ref.read(gameLogicProvider).correctNoteName;

      logicNotifier.makeGuess(note);

      // Check result
      final currentState = ref.read(gameLogicProvider);
      final isCorrect = currentState.lastFeedback == "Correct";

      setState(() {
        _feedbackColor = isCorrect ? AppTheme.successGreen : AppTheme.errorRed;
      });

      if (_continuousMode) {
        // Continuous Mode: Flash feedback and auto-advance
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _feedbackColor = null;
            _isProcessing = false;
          });
          logicNotifier.nextTurn();
          _playSound();
        });
      } else {
        // Manual Mode: Show Dialog
        _showFeedbackDialog(isCorrect, isCorrect ? null : previousCorrect);
        // _isProcessing remains true until dialog is closed
      }
    } catch (e, stack) {
      debugPrint("Error in _handleGuess: $e\n$stack");
      // Recovery: Reset processing if something crashed
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _playSelectedOption(String noteDisplay) async {
    // Parse "C4", "F#4" etc.
    final match = RegExp(r'^(.+?)(\d+)$').firstMatch(noteDisplay);
    if (match == null) return;

    final noteName = match.group(1)!;
    final octave = int.parse(match.group(2)!);

    final config = ref.read(gameConfigProvider);

    String fullPath = AudioPathMapper.getPath(
      instrument: config.instrument,
      note: noteName,
      octave: octave,
    );

    String assetPath = fullPath.replaceFirst("assets/", "");

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing selection: $e");
    }
  }

  void _showFeedbackDialog(bool isCorrect, String? correctNote) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final phrase = _praisePhrases[_random.nextInt(_praisePhrases.length)];
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                size: 60,
                color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
              ),
              SizedBox(height: 16),
              Text(
                isCorrect ? phrase : "Oops!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isCorrect) ...[
                SizedBox(height: 16),
                Text(
                  "It was",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  correctNote ?? "",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            if (!isCorrect)
              TextButton.icon(
                icon: Icon(Icons.refresh),
                label: Text("Replay"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: _playSound,
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                setState(() {
                  _feedbackColor = null;
                  _isProcessing = false;
                });
                ref.read(gameLogicProvider.notifier).nextTurn();
                _playSound();
              },
              child: Text("Next"),
            ),
          ],
        );
      },
    );
  }

  void _endSession() {
    final state = ref.read(gameLogicProvider);
    final config = ref.read(gameConfigProvider);

    // Save to Hive
    final box = Hive.box<SessionResult>('history');
    final result = SessionResult(
      date: DateTime.now(),
      instrument: config.instrument,
      score: state.score,
      totalNotes: state.totalAttempts,
    );
    box.add(result);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameLogicProvider);

    return Scaffold(
      backgroundColor:
          _feedbackColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close), onPressed: _endSession),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "STREAK: ${state.streak}  |  ${state.totalAttempts > 0 ? ((state.score / state.totalAttempts) * 100).toStringAsFixed(0) : 0}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Visualizer / Replay Area
          Expanded(
            flex: 4,
            child: Center(
              child: GestureDetector(
                onTap: _playSound,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardTheme.color,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 60,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Continuous Mode: ${_continuousMode ? 'ON' : 'OFF'}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _continuousMode,
                onChanged: (val) {
                  setState(() {
                    _continuousMode = val;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),

          // Options Grid
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use Grid or Row/Column based on available space
                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    physics: NeverScrollableScrollPhysics(),
                    children: state.options.map((note) {
                      return _buildOptionBtn(note);
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(String note) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleGuess(note),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Text(
              note,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
