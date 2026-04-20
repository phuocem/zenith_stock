import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFD4AF37); // Gold Luxury
  static const accentColor = Color(0xFF00C8FF); // Blue Neon
  static const backgroundColor = Color(0xFF0A0C0E); // Deep Midnight
  static const cardColor = Color(0xFF161B1F);

  // Luxury Decorations
  static BoxDecoration glassDecoration({double opacity = 0.05, double blur = 15.0}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    );
  }

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
  );

  static List<BoxShadow> get luxuryShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: primaryColor.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 10,
        shadowColor: primaryColor.withOpacity(0.3),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
    ),
  );
}
