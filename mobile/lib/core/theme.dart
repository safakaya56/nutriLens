import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutriLensTheme {
  // Renk Paleti (Color Tokens)
  static const Color primaryEmerald = Color(0xFF006948);
  static const Color primaryMint = Color(0xFF10B981);
  static const Color primaryLightMint = Color(0xFFE6F7F0);
  
  static const Color background = Color(0xFFF9F9FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE9ECEF);

  // Makro Besin Renkleri
  static const Color proteinCoral = Color(0xFFFF6B6B);
  static const Color carbAmber = Color(0xFFF59E0B);
  static const Color fatIndigo = Color(0xFF6366F1);

  // Metin Tonları
  static const Color textDark = Color(0xFF111C2D);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) => isDark(context) ? const Color(0xFF0F172A) : background;
  static Color cardBg(BuildContext context) => isDark(context) ? const Color(0xFF1E293B) : surfaceCard;
  static Color cardBorderColor(BuildContext context) => isDark(context) ? const Color(0xFF334155) : cardBorder;
  static Color textPrimary(BuildContext context) => isDark(context) ? Colors.white : textDark;
  static Color textSec(BuildContext context) => isDark(context) ? const Color(0xFF94A3B8) : textSecondary;
  static Color textMut(BuildContext context) => isDark(context) ? const Color(0xFF64748B) : textMuted;
  static Color accentColor(BuildContext context) => isDark(context) ? primaryMint : primaryEmerald;
  static Color chipBg(BuildContext context) => isDark(context) ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  static Color iconCircleBg(BuildContext context) => isDark(context) ? const Color(0xFF334155) : Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryEmerald,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        surface: surfaceCard,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: const TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: const TextStyle(color: textDark, fontSize: 14),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 13),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      primaryColor: primaryEmerald,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        brightness: Brightness.dark,
        primary: primaryMint,
        surface: const Color(0xFF1E293B),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: const TextStyle(color: Colors.white, fontSize: 14),
        bodyMedium: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
    );
  }
}
