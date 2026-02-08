// lib/screens/student/settings_screen.dart
import 'package:flutter/material.dart';
import '../shared/base_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String? userId;
  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseSettingsScreen(
      userRole: 'student',
      userId: userId ?? '',
    );
  }
}
