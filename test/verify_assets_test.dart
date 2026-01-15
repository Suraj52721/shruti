import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shruti/const/instrument_data.dart';
import 'package:shruti/utils/audio_path_mapper.dart';

void main() {
  test('Verify all InstrumentData assets exist on disk', () {
    final missingFiles = <String>[];
    int checkedCount = 0;

    // Iterate through every instrument config
    InstrumentData.availableNotes.forEach((instrument, notes) {
      for (var noteStr in notes) {
        checkedCount++;

        // Parse note and octave from string (e.g. "C#4")
        final match = RegExp(r'^([A-G][#bs]?)(-?\d+)$').firstMatch(noteStr);
        if (match == null) {
          missingFiles.add(
            "Invalid note format in InstrumentData: $instrument -> $noteStr",
          );
          continue;
        }

        String noteName = match.group(1)!;
        int octave = int.parse(match.group(2)!);

        // Use the mapper to get the expected asset path
        // Mapper returns "assets/folder/file.mp3"
        // We need to resolve this relative to project root.
        String relativePath = AudioPathMapper.getPath(
          instrument: instrument,
          note: noteName,
          octave: octave,
        );

        // On Windows/Local test execution, we can check File existence directly.
        // Paths from mapper use forward slashes. Windows handles them or we might need to fix.
        // Assuming running from project root 'd:/shruti/shruti/'
        final file = File(relativePath);
        if (!file.existsSync()) {
          // Try checking typical alternate extensions just in case logic is flawed
          final ogg = File(relativePath.replaceAll('.mp3', '.ogg'));
          final wav = File(relativePath.replaceAll('.mp3', '.wav'));

          if (!ogg.existsSync() && !wav.existsSync()) {
            missingFiles.add(
              "MISSING: $instrument -> $noteStr (Path: $relativePath)",
            );
          }
        }
      }
    });

    if (missingFiles.isNotEmpty) {
      print("\nFOUND ${missingFiles.length} MISSING ASSETS:");
      missingFiles.forEach(print);
      fail("Asset verification failed: ${missingFiles.length} files missing.");
    } else {
      print("\nSUCCESS: Verified $checkedCount assets. All exist.");
    }
  });
}
