// lib/screens/parent/parent_settings_screen.dart
import 'package:flutter/material.dart';
import '../shared/base_settings_screen.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseSettingsScreen(
      userRole: 'parent',
      userId: '',
    );
  }
}