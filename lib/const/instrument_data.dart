// Defines the available audio assets for every instrument to prevent playback errors.
// This file is manually currated based on the 'assets/' directory content.

class InstrumentData {
  static const List<String> _notes = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ];

  // Helper to generate a full chromatic scale for a range of octaves
  static List<String> _chromaticRange(int startOctave, int endOctave) {
    List<String> range = [];
    for (int o = startOctave; o <= endOctave; o++) {
      for (var n in _notes) {
        range.add("$n$o");
      }
    }
    return range;
  }

  // Instrument-specific configurations
  // Key: Instrument ID (folder name)
  // Value: List of available Note+Octave strings (e.g. "C4", "F#3")
  static final Map<String, List<String>> availableNotes = {
    // -------------------------------------------------------------------------
    // FULL RANGE INSTRUMENTS (Generators)
    // -------------------------------------------------------------------------
    'piano': _chromaticRange(1, 7), // Piano covers 1-7 largely
    // -------------------------------------------------------------------------
    // SPARSE / SPECIFIC INSTRUMENTS (Explicit Lists)
    // -------------------------------------------------------------------------
    // Note: '#' is used here. AudioPathMapper handles the '#' -> 's' conversion.

    // GUITARS (Verified: Many notes missing, generators unsafe)
    'guitar-acoustic': [
      "A2",
      "A#2",
      "B2",
      // "C2", // MISSING
      "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2",
      "A3",
      "A#3",
      "C3",
      "C#3",
      "D3",
      "D#3",
      "E3",
      "F3",
      "F#3",
      "G3",
      "G#3", // MISSING B3
      "A4",
      "A#4",
      "B4",
      "C4",
      "C#4",
      "D4",
      "D#4",
      "E4",
      "F4",
      "F#4",
      "G4",
      "G#4",
      "C5", "C#5", "D5",
    ],

    'guitar-electric': [
      "A2",
      // "C2", // MISSING
      "C#2",
      // "D#2", // MISSING
      "E2",
      "F#2",
      "A3",
      "C3",
      "D#3",
      "F#3",
      "A4",
      "C4",
      // "C#4", // MISSING
      "D#4",
      "F#4",
      "A5",
      "C5",
      // "C#5", // MISSING
      "D#5",
      "F#5",
      "C6",
    ],

    'guitar-nylon': [
      "A2", "B2", "D2", "E2", "F#2", "G#2",
      "A3",
      "B3",
      "C#3",
      "D3",
      "E3",
      "F#3",
      "G3",
      "A3",
      "B3",
      "C#3",
      "D3",
      "E3",
      "F#3",
      "G3", // Duplicates in orig list? Cleaning up.
      "A4", "B4", "C#4", "D#4", "E4", "F#4",
      // "G4", // MISSING
      "G#4",
      "A5", "A#5", "C#5", "D5", "E5", "F#5", "G5", "G#5",
    ],

    'flute': ["C4", "E4", "A4", "C5", "E5", "A5", "C6", "E6", "A6", "C7"],

    'bassoon': ["A2", "G2", "A3", "C3", "G3", "A4", "C4", "E4", "G4", "C5"],

    'clarinet': [
      "D3", "F3", "A#3",
      "D4", "F4", "A#4",
      "D5", "F5", "A#5",
      "D6", "F#6", // Odd ones
    ],

    'contrabass': [
      "F#1",
      "G1",
      "A#1",
      "C2",
      "D2",
      "E2",
      "F#2",
      "G#2",
      "A2",
      "C#3",
      "E3",
      "G#3",
      "B3",
    ],

    'cello': [
      "C2",
      "D2",
      "E2",
      "F2",
      "G2",
      "A2",
      "A#2",
      "B2",
      "C3",
      "C#3",
      "D3",
      "D#3",
      "E3",
      "F3",
      "F#3",
      "G3",
      "G#3",
      "A3",
      "A#3",
      "B3",
      "C4",
      "C#4",
      "D4",
      "E4",
      "F4",
      "Fs4",
      "G4",
      "A4",
      "B4",
      "C5",
    ],

    'saxophone': [
      "A#3", "B3", // removed A3, C3 as missing
      "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3",
      "A4",
      "A#4",
      "B4",
      "C4",
      "C#4",
      "D4",
      "D#4",
      "E4",
      "F4",
      "F#4",
      "G4",
      "G#4",
      "A5", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5",
    ],

    'violin': [
      "G3",
      "A3",
      "C4",
      "E4",
      "G4",
      "A4",
      "C5",
      "E5",
      "G5",
      "A5",
      "C6",
      "G6",
      "A6",
      "C7",
    ],

    'bass-electric': [
      "A#1",
      "C#1",
      "E1",
      "G1",
      "A#2",
      "C#2",
      "E2",
      "G2",
      "A#3",
      "C#3",
      "E3",
      "G3",
      "A#4",
      "C#4",
      "E4",
      "G4",
      "C#5",
    ],

    'french-horn': [
      "A1",
      "C2",
      "D#2",
      "G2",
      "A3",
      "C4",
      "D3",
      "F3",
      "D5",
      "F5",
    ],
    'trombone': [
      "A#1",
      "A#2",
      "A#3",
      "C3",
      "C4",
      "C#2",
      "C#4",
      "D3",
      "D4",
      "D#2",
      "D#3",
      "D#4",
      "F2",
      "F3",
      "F4",
      "G#2",
      "G#3",
    ],
    'trumpet': [
      "F3", "A3", "C4",
      // "C#4", // MISSING
      "D#4", "F4", "G4", "A#4",
      "D5", "F5", "A5", "C6",
    ],
    'tuba': [
      "F1", "A#1",
      // "C#2", "D2", // MISSING
      "D#2", "F2", "A#2",
      // "C#3", // MISSING
      "D3", "F3", "A#3", "D4",
    ],

    // OTHER
    'harmonium': [
      // Computed from _chromaticRange(2, 4) minus F#4
      "C2",
      "C#2",
      "D2",
      "D#2",
      "E2",
      "F2",
      "F#2",
      "G2",
      "G#2",
      "A2",
      "A#2",
      "B2",
      "C3",
      "C#3",
      "D3",
      "D#3",
      "E3",
      "F3",
      "F#3",
      "G3",
      "G#3",
      "A3",
      "A#3",
      "B3",
      "C4", "C#4", "D4", "D#4", "E4", "F4",
      // "F#4", // MISSING
      "G4", "G#4", "A4", "A#4", "B4",
    ],

    'harp': [
      "A2",
      // "B2", // MISSING
      "D2", "F2",
      "A4",
      // "B4", // MISSING
      "D4", "F4",
      "A6", "B6", "D6", "F6",
      "C3", "E3", "G3",
      "C5", "E5", "G5",
      "D7", "F7",
    ],

    'organ': [
      "A1",
      "C1",
      "D#1",
      "F#1",
      "A2",
      "C2",
      "D#2",
      "F#2",
      "A3",
      "C3",
      "D#3",
      "F#3",
      "A4",
      "C4",
      "D#4",
      "F#4",
      "A5",
      "C5",
      "D#5",
      "F#5",
      "C6",
    ],

    'xylophone': ["G4", "C5", "G5", "C6", "G6", "C7", "G7", "C8"],
  };

  // Logical Instrument Names to Display Name
  static const Map<String, String> instrumentNames = {
    'piano': 'Piano',
    'guitar-acoustic': 'Acoustic Guitar',
    'guitar-electric': 'Electric Guitar',
    'guitar-nylon': 'Nylon Guitar',
    'bass-electric': 'Electric Bass',
    'flute': 'Flute',
    'clarinet': 'Clarinet',
    'saxophone': 'Saxophone',
    'trumpet': 'Trumpet',
    'trombone': 'Trombone',
    'tuba': 'Tuba',
    'french-horn': 'French Horn',
    'violin': 'Violin',
    'cello': 'Cello',
    'contrabass': 'Contrabass',
    'harp': 'Harp',
    'harmonium': 'Harmonium',
    'organ': 'Organ',
    'bassoon': 'Bassoon',
    'xylophone': 'Xylophone',
  };
}
