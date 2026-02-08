// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../services/session_manager.dart';
import '../../app.dart';
import '../../models/user_model.dart';

class BaseSettingsScreen extends StatefulWidget {
  final String userRole;
  final String userId;

  const BaseSettingsScreen({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<BaseSettingsScreen> createState() => _BaseSettingsScreenState();
}

class _BaseSettingsScreenState extends State<BaseSettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _notifications = true;
  bool _biometric = false;
  bool _locationTracking = true;
  bool _emergencyAlerts = true;
  bool _passNotifications = true;
  bool _autoLogout = false;
  String _theme = 'light';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getSettings();
      if (settings != null) {
        setState(() {
          _notifications = settings['notifications'] ?? true;
          _biometric = settings['biometric'] ?? false;
          _locationTracking = settings['locationTracking'] ?? true;
          _emergencyAlerts = settings['emergencyAlerts'] ?? true;
          _passNotifications = settings['passNotifications'] ?? true;
          _autoLogout = settings['autoLogout'] ?? false;
          _theme = settings['theme'] ?? 'light';
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load settings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final success = await _settingsService.updateSettings({
        'notifications': _notifications,
        'biometric': _biometric,
        'locationTracking': _locationTracking,
        'emergencyAlerts': _emergencyAlerts,
        'passNotifications': _passNotifications,
        'autoLogout': _autoLogout,
        'theme': _theme,
      });

      if (success) {
        _showSnackBar('Settings saved successfully');
        // Update user settings in session
        final user = await SessionManager.getUser();
        if (user != null) {
          final updatedUser = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            settings: {
              'notifications': _notifications,
              'biometric': _biometric,
              'locationTracking': _locationTracking,
              'emergencyAlerts': _emergencyAlerts,
              'passNotifications': _passNotifications,
              'autoLogout': _autoLogout,
              'theme': _theme,
            },
          );
          await SessionManager.saveSession(
            token: await _settingsService.api.getToken() ?? '',
            role: user.role,
            user: updatedUser,
          );
        }
        // Update theme if changed
        final themeProvider = ThemeProvider.of(context);
        if (themeProvider != null) {
          themeProvider.onThemeChanged(
            _theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
          );
        }
      } else {
        _showSnackBar('Failed to save settings');
      }
    } catch (e) {
      _showSnackBar('Failed to save settings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildRoleSpecificSettings() {
    switch (widget.userRole) {
      case 'student':
        return Column(
          children: [
            _buildSwitchTile(
              'Location Tracking',
              'Allow campus to track your location for safety',
              _locationTracking,
              (value) => setState(() => _locationTracking = value),
            ),
            _buildSwitchTile(
              'Emergency Alerts',
              'Receive emergency notifications',
              _emergencyAlerts,
              (value) => setState(() => _emergencyAlerts = value),
            ),
            _buildSwitchTile(
              'Pass Notifications',
              'Get notified about pass status updates',
              _passNotifications,
              (value) => setState(() => _passNotifications = value),
            ),
          ],
        );
      case 'parent':
        return Column(
          children: [
            _buildSwitchTile(
              'Child Location Tracking',
              'Monitor your child\'s location',
              _locationTracking,
              (value) => setState(() => _locationTracking = value),
            ),
            _buildSwitchTile(
              'Emergency Alerts',
              'Receive emergency notifications',
              _emergencyAlerts,
              (value) => setState(() => _emergencyAlerts = value),
            ),
            _buildSwitchTile(
              'Pass Notifications',
              'Get notified about pass activities',
              _passNotifications,
              (value) => setState(() => _passNotifications = value),
            ),
          ],
        );
      case 'warden':
        return Column(
          children: [
            _buildSwitchTile(
              'Location Tracking',
              'Track warden location for coordination',
              _locationTracking,
              (value) => setState(() => _locationTracking = value),
            ),
            _buildSwitchTile(
              'Emergency Alerts',
              'Receive emergency notifications',
              _emergencyAlerts,
              (value) => setState(() => _emergencyAlerts = value),
            ),
            _buildSwitchTile(
              'Pass Notifications',
              'Get notified about pass validations',
              _passNotifications,
              (value) => setState(() => _passNotifications = value),
            ),
          ],
        );
      case 'guard':
        return Column(
          children: [
            _buildSwitchTile(
              'Location Tracking',
              'Track guard location for coordination',
              _locationTracking,
              (value) => setState(() => _locationTracking = value),
            ),
            _buildSwitchTile(
              'Emergency Alerts',
              'Receive emergency notifications',
              _emergencyAlerts,
              (value) => setState(() => _emergencyAlerts = value),
            ),
            _buildSwitchTile(
              'Pass Notifications',
              'Get notified about pass validations',
              _passNotifications,
              (value) => setState(() => _passNotifications = value),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Theme Settings
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Light Theme'),
                        value: 'light',
                        groupValue: _theme,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _theme = value);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Dark Theme'),
                        value: 'dark',
                        groupValue: _theme,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _theme = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // General Settings
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        'Push Notifications',
                        'Receive push notifications',
                        _notifications,
                        (value) => setState(() => _notifications = value),
                      ),
                      _buildSwitchTile(
                        'Biometric Login',
                        'Use fingerprint/face unlock',
                        _biometric,
                        (value) => setState(() => _biometric = value),
                      ),
                      _buildSwitchTile(
                        'Auto Logout',
                        'Automatically logout after period of inactivity',
                        _autoLogout,
                        (value) => setState(() => _autoLogout = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Role-specific Settings
                Text(
                  '${widget.userRole.toUpperCase()} Settings',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: _buildRoleSpecificSettings(),
                ),
                const SizedBox(height: 24),

                // Account Settings
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showChangePasswordDialog(),
                  ),
                ),
              ],
            ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validatePassword(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await _settingsService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );

                Navigator.of(context).pop();

                if (success) {
                  _showSnackBar('Password changed successfully');
                } else {
                  _showSnackBar('Failed to change password');
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final specialCharRegex = RegExp(r'[!@#$%^&*()_+\-=\[\]{};:''"\\|,.<>/?]');
    if (!specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    final numberRegex = RegExp(r'\d');
    if (!numberRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }
}