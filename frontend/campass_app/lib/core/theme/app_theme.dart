import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Futuristic Color Palette
  static const Color background = Color(0xFF0F172A); // Deep Navy/Black
  static const Color surface = Color(0xFF1E293B); // Slightly lighter for cards
  static const Color primary = Color(0xFF00F0FF); // Neon Cyan
  static const Color secondary = Color(0xFF7000FF); // Neon Purple
  static const Color accent = Color(0xFFFF0055); // Neon Pink/Red (Alerts)
  static const Color error = Color(0xFFFF0000); // Standard Red
  static const Color success = Color(0xFF00FF9D); // Neon Green

  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF94A3B8);

  // 2. Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x26FFFFFF), // White with 15% opacity
      Color(0x0DFFFFFF), // White with 5% opacity
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 3. Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textWhite,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textGrey,
        ),
      ),

      // Input Decoration (Glassy fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary),
        ),
        prefixIconColor: textGrey,
        hintStyle: const TextStyle(color: textGrey),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
      ),

      // Global Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
