import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_background.dart';
import '../../services/auth_service.dart';
import '../../services/session_manager.dart';

class WardenProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const WardenProfileScreen({super.key, this.user});

  @override
  State<WardenProfileScreen> createState() => _WardenProfileScreenState();
}

class _WardenProfileScreenState extends State<WardenProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.user != null) {
      setState(() {
        _userData = widget.user;
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await SessionManager.getUser();
      if (user != null) {
        setState(() {
          _userData = user.toJson();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                         shape: BoxShape.circle,
                         gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                         boxShadow: [BoxShadow(color: AppTheme.primary, blurRadius: 20, spreadRadius: -5)]
                      ),
                   ),
                   const CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, size: 64, color: Colors.white),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
               _userData?['name'] ?? 'Warden User',
               style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
               _userData?['email'] ?? 'warden@example.com',
               style: const TextStyle(color: AppTheme.textGrey),
            ),
            
            const SizedBox(height: 48),
            
            GlassyCard(
               child: Column(
                  children: [
                     _buildListTile(Icons.perm_identity, "Warden ID: ${_userData?['id'] ?? 'N/A'}", () {}),
                     const Divider(color: Colors.white12),
                     _buildListTile(Icons.settings, "Settings", () {}),
                     const Divider(color: Colors.white12),
                     _buildListTile(Icons.notifications_none, "Notifications", () {}),
                  ],
               ),
            ),
            
            const SizedBox(height: 24),
            
            GradientButton(
               text: "LOGOUT",
               icon: Icons.logout,
               onPressed: () async {
                  await _authService.logout();
                  if (context.mounted) {
                     Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
               },
            )
          ],
        ),
      ),
        ),
      ),
    );
  }
  
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
     return ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
        onTap: onTap,
     );
  }
}