import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Colors
  static const Color background = Color(0xFF0A0E21);
  static const Color cardColor = Color(0xFF1D1E33);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonMagenta = Color(0xFFD500F9);

  // Light Colors (Zen Day)
  static const Color lightBackground = Color(0xFFF0F4F8);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF00BFA5); // Tealish
  static const Color lightSecondary = Color(0xFF7C4DFF); // Deep Purple

  static const Color errorRed = Color(0xFFFF1744);
  static const Color successGreen = Color(0xFF00E676);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: neonCyan,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: neonCyan,
        secondary: neonMagenta,
        surface: cardColor,
        error: errorRed,
      ),
      textTheme: GoogleFonts.exo2TextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      cardTheme: CardThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Colors.black54,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: neonCyan,
        inactiveTrackColor: Colors.white24,
        thumbColor: neonMagenta,
        overlayColor: neonMagenta.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: neonCyan.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: Colors.white),
        secondaryLabelStyle: TextStyle(color: neonCyan),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: neonCyan.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightCardColor,
        error: errorRed,
      ),
      textTheme: GoogleFonts.exo2TextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
      cardTheme: CardThemeData(
        color: lightCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.black12,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: lightPrimary,
        inactiveTrackColor: Colors.black12,
        thumbColor: lightSecondary,
        overlayColor: lightSecondary.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCardColor,
        selectedColor: lightPrimary.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: Colors.black87),
        secondaryLabelStyle: TextStyle(color: lightPrimary),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: lightPrimary.withValues(alpha: 0.5)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

// Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light); // Default to Light

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
