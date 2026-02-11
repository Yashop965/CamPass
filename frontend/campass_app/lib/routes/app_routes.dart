// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/auth/role_select_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/warden_dashboard_screen.dart';
import '../screens/guard_dashboard_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/student/student_settings_screen.dart';
import '../screens/parent/parent_profile_screen.dart';
import '../screens/parent/parent_settings_screen.dart';
import '../screens/warden/warden_profile_screen.dart';
import '../screens/warden/warden_settings_screen.dart';
import '../screens/guard/guard_profile_screen.dart';
import '../screens/guard/guard_settings_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const RoleSelectScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/student': (context) => const StudentDashboardScreen(),
    '/parent': (context) => const ParentDashboardScreen(),
    '/warden': (context) => const WardenDashboardScreen(),
    '/guard': (context) => const GuardDashboardScreen(),
    '/admin': (context) => const AdminDashboardScreen(),
    // Student routes
    '/student/profile': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ProfileScreen(userId: args?['userId']);
    },
    '/student/settings': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return SettingsScreen(userId: args?['userId']);
    },
    // Parent routes
    '/parent/profile': (context) => const ParentProfileScreen(),
    '/parent/settings': (context) => const ParentSettingsScreen(),
    // Warden routes
    '/warden/profile': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return WardenProfileScreen(user: args ?? {});
    },
    '/warden/settings': (context) => const WardenSettingsScreen(),
    // Guard routes
    '/guard/profile': (context) => const GuardProfileScreen(),
    '/guard/settings': (context) => const GuardSettingsScreen(),
  };
}
