import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';

class WardenSettingsScreen extends StatefulWidget {
  const WardenSettingsScreen({super.key});

  @override
  State<WardenSettingsScreen> createState() => _WardenSettingsScreenState();
}

class _WardenSettingsScreenState extends State<WardenSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildSectionHeader("APP PREFERENCES"),
               GlassyCard(
                  child: Column(
                     children: [
                        _buildSwitchTile("Dark Mode", "Use system dark theme", _darkMode, (v) => setState(() => _darkMode = v)),
                        const Divider(color: Colors.white12),
                        _buildSwitchTile("Notifications", "Enable push alerts", _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
                     ],
                  ),
               ),
               
               const SizedBox(height: 32),
               _buildSectionHeader("SECURITY"),
               GlassyCard(
                  child: Column(
                     children: [
                        _buildSwitchTile("Biometric Login", "FaceID / Fingerprint", _biometricEnabled, (v) => setState(() => _biometricEnabled = v)),
                        const Divider(color: Colors.white12),
                        ListTile(
                           title: const Text("Change Password", style: TextStyle(color: Colors.white)),
                           trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
                           onTap: () {},
                        )
                     ],
                  ),
               ),

               const SizedBox(height: 32),
               _buildSectionHeader("ABOUT"),
               const GlassyCard(
                  child: ListTile(
                     title: Text("Version", style: TextStyle(color: Colors.white)),
                     trailing: Text("1.0.0 (Beta)", style: TextStyle(color: AppTheme.textGrey)),
                  ),
               ),
            ],
         ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
     return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 8),
        child: Text(
           title, 
           style: const TextStyle(color: AppTheme.primary, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)
        ),
     );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
     return SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        inactiveTrackColor: Colors.white10,
     );
  }
}