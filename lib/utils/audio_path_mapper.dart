class AudioPathMapper {
  static String getPath({
    required String instrument,
    required String note,
    required int octave,
  }) {
    // Map logical instrument names to folder names
    String folderName = instrument;
    if (instrument == 'guitar') {
      folderName = 'guitar-acoustic';
    }

    // IMPORTANT: File system uses 's' for sharp instead of '#'.
    // e.g. "F#" becomes "Fs"
    String safeNoteName = note.replaceAll('#', 's');

    final fileName = "$safeNoteName$octave.ogg";

    return "assets/$folderName/$fileName";
  }

  // Helper to standardise note names if inputs vary
  static String normalizeNoteName(String input) {
    return input.replaceAll('♭', 'b').replaceAll('♯', '#');
  }
}
