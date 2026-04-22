import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── ZENITH STOCK — PREMIUM DARK THEME (Material 3 + Custom) ───────────────

class AppTheme {
  AppTheme._();

  // ── Core Palette ────────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF00E5C3); // Cyan-mint
  static const Color accentColor    = Color(0xFF7C6FFF); // Soft indigo
  static const Color successColor   = Color(0xFF22D67A);
  static const Color dangerColor    = Color(0xFFFF4B6E);
  static const Color warningColor   = Color(0xFFFFB547);
  static const Color infoColor      = Color(0xFF38BEFF);

  // ── Surface Layers ──────────────────────────────────────────────────────
  static const Color bgColor        = Color(0xFF090D12);
  static const Color surfaceColor   = Color(0xFF0E1420);
  static const Color cardColor      = Color(0xFF131A25);
  static const Color elevatedColor  = Color(0xFF1A2333);
  static const Color borderColor    = Color(0xFF1E2C3D);

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5C3), Color(0xFF0099FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C6FFF), Color(0xFFCC5AFF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22D67A), Color(0xFF00B4A6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF4B6E), Color(0xFFFF2D78)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB547), Color(0xFFFF7B00)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ── Typography ──────────────────────────────────────────────────────────
  static TextStyle get displayStyle => const TextStyle(
    fontFamily: 'Sora', fontSize: 28, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -0.5, height: 1.2,
  );
  static TextStyle get headlineStyle => const TextStyle(
    fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: -0.3,
  );
  static TextStyle get titleStyle => const TextStyle(
    fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static TextStyle get bodyStyle => const TextStyle(
    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400,
    color: Color(0xFFB0BEC5),
  );
  static TextStyle get captionStyle => const TextStyle(
    fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400,
    color: Color(0xFF607D8B),
  );
  static TextStyle get labelStyle => const TextStyle(
    fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
    color: Color(0xFF546E7A), letterSpacing: 1.2,
  );
  static TextStyle get numberStyle => const TextStyle(
    fontFamily: 'JetBrains Mono', fontSize: 24, fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle get monoStyle => const TextStyle(
    fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.w400,
    color: Color(0xFF78909C),
  );

  // ── Decorations ─────────────────────────────────────────────────────────
  static BoxDecoration cardDecoration({Color? borderColor, double radius = 16}) =>
    BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppTheme.borderColor, width: 1),
    );

  static BoxDecoration glowDecoration({required Color color, double radius = 24}) =>
    BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.08),
      border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      boxShadow: [
        BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
      ],
    );

  static BoxDecoration surfaceDecoration({double radius = 20}) =>
    BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
    );

  // ── Material 3 Theme ────────────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: successColor,
        error: dangerColor,
        surface: surfaceColor,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        outline: borderColor,
      ),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700,
          color: Colors.white, letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF607D8B), size: 22),
        actionsIconTheme: const IconThemeData(color: Color(0xFF607D8B), size: 22),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF546E7A), fontFamily: 'Inter'),
        hintStyle: const TextStyle(color: Color(0xFF37474F), fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Sora', fontWeight: FontWeight.w700, letterSpacing: 1.5,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: elevatedColor,
        side: const BorderSide(color: borderColor),
        labelStyle: const TextStyle(color: Color(0xFF90A4AE), fontFamily: 'Inter', fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: const Color(0xFF546E7A),
        textColor: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: elevatedColor,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
