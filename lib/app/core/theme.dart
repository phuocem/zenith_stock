import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFD4AF37);
  static const accentColor = Color(0xFF00C8FF);
  static const successColor = Color(0xFF00E676);
  static const warningColor = Color(0xFFFFAB40);
  static const dangerColor = Color(0xFFFF5252);
  static const infoColor = Color(0xFF40C4FF);
  static const backgroundColor = Color(0xFF0A0C0E);
  static const surfaceColor = Color(0xFF111518);
  static const cardColor = Color(0xFF161B1F);
  static const elevatedColor = Color(0xFF1E262C);
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
  );
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C8FF), Color(0xFF0050FF)],
  );
  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E676), Color(0xFF00897B)],
  );
  static const dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
  );
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0C0E), Color(0xFF0D1117)],
  );
  static TextStyle get headlineStyle => GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  static TextStyle get titleStyle => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static TextStyle get labelStyle => GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: Colors.white38,
  );
  static TextStyle get captionStyle =>
      GoogleFonts.outfit(fontSize: 12, color: Colors.white54);
  static TextStyle get numberStyle => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  static BoxDecoration glassDecoration({
    double opacity = 0.05,
    double blur = 15.0,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    );
  }

  static BoxDecoration cardDecoration({
    Color? borderColor,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.06),
        width: 1,
      ),
    );
  }

  static BoxDecoration glowDecoration({
    required Color color,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.12),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static List<BoxShadow> get luxuryShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryColor.withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  static List<BoxShadow> colorShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 6),
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
      tertiary: successColor,
      error: dangerColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
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
        shadowColor: primaryColor.withOpacity(0.4),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.5,
        ),
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
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: dangerColor),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.white38,
      suffixIconColor: Colors.white38,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.06),
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
  );
}
