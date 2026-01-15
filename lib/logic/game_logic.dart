import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/audio_path_mapper.dart';
import '../const/instrument_data.dart';

// Game State
class GameState {
  final String currentNote; // e.g., "C"
  final int currentOctave; // e.g., 4
  final String correctNoteName; // "C"
  final List<String> options; // ["C", "D", "F#", "A"]
  final int streak;
  final int score;
  final int totalAttempts;
  final String? lastFeedback; // "Correct" or "Wrong"

  GameState({
    this.currentNote = "C",
    this.currentOctave = 4,
    this.correctNoteName = "C",
    this.options = const [],
    this.streak = 0,
    this.score = 0,
    this.totalAttempts = 0,
    this.lastFeedback,
  });

  GameState copyWith({
    String? currentNote,
    int? currentOctave,
    String? correctNoteName,
    List<String>? options,
    int? streak,
    int? score,
    int? totalAttempts,
    String? lastFeedback,
  }) {
    return GameState(
      currentNote: currentNote ?? this.currentNote,
      currentOctave: currentOctave ?? this.currentOctave,
      correctNoteName: correctNoteName ?? this.correctNoteName,
      options: options ?? this.options,
      streak: streak ?? this.streak,
      score: score ?? this.score,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastFeedback: lastFeedback ?? this.lastFeedback,
    );
  }
}

// Configuration State
class GameConfig {
  final String instrument;
  final List<int> octaves;
  final bool accidentals;
  final double intervalDifficulty; // 0.0 to 1.0 (Low to High)

  GameConfig({
    this.instrument = "piano",
    this.octaves = const [4],
    this.accidentals = false,
    this.intervalDifficulty = 0.5,
  });
}

// Logic
class GameLogic extends StateNotifier<GameState> {
  final GameConfig config;
  final Random _random = Random();

  GameLogic(this.config) : super(GameState()) {
    nextTurn();
  }

  void nextTurn() {
    // 1. Select Octave
    // Config octaves are already filtered by SetupScreen, so they are valid for the instrument.
    int octave = config.octaves[_random.nextInt(config.octaves.length)];

    // 2. Select Note valid for this octave
    final allAllowedNotes =
        InstrumentData.availableNotes[config.instrument] ?? [];

    // Extract notes that exist in this octave
    // e.g. "C4" matches if octave=4.
    final possibleNotes = allAllowedNotes
        .where((n) => n.endsWith(octave.toString()))
        .map((n) => n.substring(0, n.length - 1)) // Strip octave
        .toList();

    // Filter by accidentals config
    final validNotes = config.accidentals
        ? possibleNotes
        : possibleNotes
              .where((n) => !n.contains('#') && !n.contains('s'))
              .toList();

    // Safety check
    if (validNotes.isEmpty) {
      // Fallback (shouldn't happen with correct data)
      validNotes.add("C");
    }

    String note = validNotes[_random.nextInt(validNotes.length)];

    // 3. Generate Options
    // We want up to 4 options, but we can't exceed the number of available notes.
    List<String> newOptions = [note];
    List<String> remainingPool = List.from(validNotes)..remove(note);
    remainingPool.shuffle(_random);

    int slotsToFill = 3;
    // Take as many as possible up to 3
    newOptions.addAll(remainingPool.take(slotsToFill));

    newOptions.shuffle();

    // Append octave to options
    final displayOptions = newOptions.map((n) => "$n$octave").toList();

    state = state.copyWith(
      currentNote: note,
      currentOctave: octave,
      correctNoteName: "$note$octave",
      options: displayOptions,
      lastFeedback: null,
    );
  }

  void makeGuess(String noteName) {
    bool isCorrect = noteName == state.correctNoteName;

    if (isCorrect) {
      state = state.copyWith(
        streak: state.streak + 1,
        score: state.score + 1,
        totalAttempts: state.totalAttempts + 1,
        lastFeedback: "Correct",
      );
    } else {
      state = state.copyWith(
        streak: 0,
        totalAttempts: state.totalAttempts + 1,
        lastFeedback: "Wrong",
      );
    }

    // Auto-advance after a delay is handled by UI, but logic is ready.
  }

  String get currentAudioPath {
    return AudioPathMapper.getPath(
      instrument: config.instrument,
      note: state.currentNote,
      octave: state.currentOctave,
    );
  }
}

// Providers
final gameConfigProvider = StateProvider<GameConfig>((ref) => GameConfig());

final gameLogicProvider =
    StateNotifierProvider.autoDispose<GameLogic, GameState>((ref) {
      final config = ref.watch(gameConfigProvider);
      return GameLogic(config);
    });
