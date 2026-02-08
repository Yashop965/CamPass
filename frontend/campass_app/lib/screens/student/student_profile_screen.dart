// lib/screens/student/student_profile_screen.dart
// ignore_for_file: unused_element, unused_field, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../widgets/gradient_background.dart';
import '../../models/user_model.dart';
import '../../utils/error_handler.dart';
import '../../utils/validators.dart';
import '../../services/session_manager.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = true;
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await SessionManager.getUser();
      if (user != null) {
        setState(() {
          _userData = user.toJson();
          _nameController.text = user.name;
          _emailController.text = user.email;
          // Load settings
          final settings = user.settings ?? {};
          _notificationsEnabled = settings['notifications'] ?? true;
          _locationTrackingEnabled = settings['locationTracking'] ?? true;
          _selectedTheme = settings['theme'] ?? 'system';
        });
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getErrorMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ErrorHandler.showErrorSnackBar(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SessionManager.getToken();
      if (token == null) throw Exception('No token found');

      await UserService().changePassword({
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _isChangingPassword = false);
      ErrorHandler.showSuccessSnackBar(context, 'Password changed successfully');
    } catch (e) {
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getErrorMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final token = await SessionManager.getToken();
      if (token == null) throw Exception('No token found');

      final settings = {
        'notifications': _notificationsEnabled,
        'locationTracking': _locationTrackingEnabled,
        'theme': _selectedTheme,
      };

      await UserService().updateSettings(settings);

      // Update local storage
      final user = await SessionManager.getUser();
      if (user != null) {
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          settings: settings,
        );
        await SessionManager.saveUser(updatedUser);
      }

      ErrorHandler.showSuccessSnackBar(context, 'Settings saved successfully');
    } catch (e) {
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getErrorMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Widget _buildPasswordChangeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isChangingPassword ? Icons.close : Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _isChangingPassword = !_isChangingPassword),
                  ),
                ],
              ),
              if (_isChangingPassword) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Change Password'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      await SessionManager.logout(); // Ensure both are cleared
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), // Adjust padding for AppBar
              child: Column(
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person, size: 60),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                // TODO: Implement profile picture change
                                _showSnackBar('Profile picture change coming soon');
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData?['name'] ?? 'N/A',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userData?['role'] ?? 'N/A',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Email', _userData?['email']),
                          _buildInfoRow('Student ID', _userData?['studentId']),
                          _buildInfoRow('Department', _userData?['department']),
                          _buildInfoRow('Year', _userData?['year']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Change Password'),
                          subtitle: const Text('Update your account password'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.pushNamed(context, '/student/settings'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                          subtitle: const Text('App preferences and configuration'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.pushNamed(context, '/student/settings'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          subtitle: const Text('Sign out of your account'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
