import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A3D62); // Deep Blue base
  static const Color primaryDark = Color(0xFF062339);
  static const Color primaryLight = Color(0xFF1E5F8A);

  // Semantic System
  static const Color systemRed = Color(0xFFFF3B30); // SOS, Violations
  static const Color systemGold = Color(0xFFFFCC00); // Pending, Warnings
  static const Color systemGreen = Color(0xFF34C759); // Approved, Active
  
  static const Color bg = Color(0xFFF5F6FA); // Light Background
  static const Color surface = Colors.white;
  
  // Glassmorphism
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color glassBackground = Colors.white.withOpacity(0.1);
}
