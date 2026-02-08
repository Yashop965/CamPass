// lib/screens/guard/guard_profile_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glassy_card.dart';
import '../../services/session_manager.dart';
import '../../services/auth_service.dart';

class GuardProfileScreen extends StatefulWidget {
  const GuardProfileScreen({super.key});

  @override
  State<GuardProfileScreen> createState() => _GuardProfileScreenState();
}

class _GuardProfileScreenState extends State<GuardProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await SessionManager.getUser();
      if (user != null) {
        setState(() {
          _userData = user.toJson();
          // Add default guard-specific fields if missing
          if (!_userData!.containsKey('guardId')) {
             _userData!['guardId'] = user.id.substring(0, 8).toUpperCase();
          }
          if (!_userData!.containsKey('post')) {
             _userData!['post'] = 'Main Gate';
          }
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load profile data');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppTheme.surface.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.textGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textGrey,
              ),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.error, Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (mounted) {
         Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Guard Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: GradientBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
              child: Column(
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundColor: AppTheme.surface,
                            child: Icon(Icons.badge, size: 60, color: AppTheme.primary),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showSnackBar('Profile picture change coming soon');
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Information Card
                  GlassyCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData?['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (_userData?['role'] ?? 'N/A').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Email', _userData?['email']),
                          _buildInfoRow('Guard ID', _userData?['guardId']),
                          _buildInfoRow('Post', _userData?['post']),
                          _buildInfoRow('Phone', _userData?['phone']),
                          _buildInfoRow('Shift', _userData?['shift']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  GlassyCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock, color: AppTheme.primary),
                          title: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          subtitle: const Text('Update your account password', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
                          onTap: () => Navigator.pushNamed(context, '/guard/settings'),
                        ),
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings, color: AppTheme.primary),
                          title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          subtitle: const Text('App preferences and configuration', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
                          onTap: () => Navigator.pushNamed(context, '/guard/settings'),
                        ),
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: AppTheme.error),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text('Sign out of your account', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textGrey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}