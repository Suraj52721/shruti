import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_logic.dart';
import '../theme.dart';
import '../widgets/neon_glow_button.dart';
import '../const/instrument_data.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  String selectedInstrument = 'piano';
  List<int> selectedOctaves = [4];
  bool useAccidentals = false;
  double difficultyDetails = 0.5; // "Max Interval Jump"

  final List<String> instruments = InstrumentData.instrumentNames.keys.toList();

  List<int> get _currentAvailableOctaves {
    final notes = InstrumentData.availableNotes[selectedInstrument];
    if (notes == null || notes.isEmpty) return [4];

    final octaveSet = <int>{};
    for (var n in notes) {
      final match = RegExp(r'(\d+)$').firstMatch(n);
      if (match != null) {
        octaveSet.add(int.parse(match.group(1)!));
      }
    }
    final sorted = octaveSet.toList()..sort();
    return sorted.isNotEmpty ? sorted : [4];
  }

  void _onInstrumentChanged(String newInstrument) {
    setState(() {
      selectedInstrument = newInstrument;

      final validOctaves = _getValidOctavesFor(newInstrument);

      selectedOctaves.removeWhere((oct) => !validOctaves.contains(oct));

      if (selectedOctaves.isEmpty) {
        if (validOctaves.contains(4)) {
          selectedOctaves.add(4);
        } else if (validOctaves.isNotEmpty) {
          selectedOctaves.add(validOctaves.first);
        } else {
          selectedOctaves.add(4);
        }
      }
      selectedOctaves.sort();
    });
  }

  List<int> _getValidOctavesFor(String instrument) {
    final notes = InstrumentData.availableNotes[instrument];
    if (notes == null) return [4];
    final octaveSet = <int>{};
    for (var n in notes) {
      final match = RegExp(r'(\d+)$').firstMatch(n);
      if (match != null) octaveSet.add(int.parse(match.group(1)!));
    }
    return octaveSet.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SHRUTI SETUP",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader("INSTRUMENT"),
            SizedBox(height: 16),
            NeonGlowButton(
              text:
                  InstrumentData.instrumentNames[selectedInstrument]
                      ?.toUpperCase() ??
                  selectedInstrument.toUpperCase(),
              onPressed: _showInstrumentSelectionDialog,
              glowColor: Theme.of(context).colorScheme.secondary,
              width: double.infinity,
              height: 60,
            ),
            SizedBox(height: 32),
            _buildSectionHeader("OCTAVES"),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: _currentAvailableOctaves.map((oct) {
                final isSelected = selectedOctaves.contains(oct);
                return FilterChip(
                  label: Text("C$oct"),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedOctaves.add(oct);
                      } else {
                        if (selectedOctaves.length > 1) {
                          selectedOctaves.remove(oct);
                        }
                      }
                      selectedOctaves.sort();
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            _buildSectionHeader("ACCIDENTALS (Sharps/Flats)"),
            SizedBox(height: 8),
            Center(
              child: Switch(
                value: useAccidentals,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) => setState(() => useAccidentals = val),
              ),
            ),
            SizedBox(height: 32),
            _buildSectionHeader("MAX INTERVAL JUMP"),
            SizedBox(height: 8),
            Slider(
              value: difficultyDetails,
              onChanged: (val) => setState(() => difficultyDetails = val),
              divisions: 2, // Low, Med, High
              label: difficultyDetails < 0.33
                  ? "Low"
                  : (difficultyDetails < 0.66 ? "Medium" : "High"),
            ),
            Center(
              child: Text(
                difficultyDetails < 0.33
                    ? "Low (Close Notes)"
                    : (difficultyDetails < 0.66 ? "Medium" : "High (Any Jump)"),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(height: 48),
            Center(
              child: NeonGlowButton(
                text: "START TRAINING",
                glowColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  // Update Config
                  ref.read(gameConfigProvider.notifier).state = GameConfig(
                    instrument: selectedInstrument,
                    octaves: selectedOctaves,
                    accidentals: useAccidentals,
                    intervalDifficulty: difficultyDetails,
                  );

                  // Reset Game Logic state with new config (auto-dispose handles reset on re-entry,
                  // but explicit refresh ensures clean state if pushing)
                  final _ = ref.refresh(gameLogicProvider);

                  Navigator.pushNamed(context, '/arena');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstrumentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            "SELECT INSTRUMENT",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: instruments.map((inst) {
                final isSelected = selectedInstrument == inst;
                final colorScheme = Theme.of(context).colorScheme;

                return GestureDetector(
                  onTap: () {
                    _onInstrumentChanged(inst);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          inst == 'piano'
                              ? Icons.piano
                              : (inst.contains('guitar')
                                    ? Icons.music_note
                                    : Icons.graphic_eq),
                          color: isSelected
                              ? colorScheme.primary
                              : Theme.of(context).disabledColor,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          InstrumentData.instrumentNames[inst]?.toUpperCase() ??
                              inst.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.onSurface
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
