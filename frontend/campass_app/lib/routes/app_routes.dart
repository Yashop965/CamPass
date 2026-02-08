// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_select_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/warden/warden_dashboard.dart';
import '../screens/guard/guard_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
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
    '/student': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? userId;
      if (args is Map && args['userId'] is String) {
        userId = args['userId'] as String;
      }
      return StudentDashboard(userId: userId);
    },
    '/parent': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final parentId = args?['parentId'] as String? ?? '';
      final token = args?['token'] as String? ?? '';
      return ParentDashboard(parentId: parentId, token: token);
    },
    '/warden': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final wardenId = args?['wardenId'] as String? ?? '';
      final token = args?['token'] as String? ?? '';
      return WardenDashboard(wardenId: wardenId, token: token);
    },
    '/guard': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final guardId = args?['guardId'] as String? ?? '';
      final token = args?['token'] as String? ?? '';
      return GuardDashboard(guardId: guardId, token: token);
    },
    '/admin': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final adminId = args?['adminId'] as String? ?? '';
      final token = args?['token'] as String? ?? '';
      return AdminDashboard(adminId: adminId, token: token);
    },
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
