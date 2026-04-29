import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF2E4857);
  static const Color secondary = Color(0xFFFFB29A);
  static const Color background = Color(0xFFF4F6F8);
  static const Color cardBg = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D1E);
  static const Color textSecondary = Color(0xFF7A8B94);
  
  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  static const Color border = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: const TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: const TextStyle(fontSize: 14, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
