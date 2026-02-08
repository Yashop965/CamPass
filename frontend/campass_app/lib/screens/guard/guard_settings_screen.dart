// lib/screens/guard/guard_settings_screen.dart
import 'package:flutter/material.dart';
import '../shared/base_settings_screen.dart';

class GuardSettingsScreen extends StatelessWidget {
  const GuardSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseSettingsScreen(
      userRole: 'guard',
      userId: '',
    );
  }
}