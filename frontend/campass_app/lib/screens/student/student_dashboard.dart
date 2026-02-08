import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../services/session_manager.dart';
import 'create_pass_screen.dart';
import 'barcode_display_screen.dart';
import 'sos_screen.dart';
import 'pass_history_screen.dart';
import 'student_profile_screen.dart';
import 'location_tracking_screen.dart';
import 'student_notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/firebase_service.dart';
import '../../providers/pass_provider.dart';

class StudentDashboard extends StatefulWidget {
  final String? userId;
  const StudentDashboard({Key? key, this.userId}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  String? _token;
  String _userName = 'Student';
  String? _userId;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    // config loaded

    _loadData();
    _setupNotifications();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _setupNotifications() {
     try {
        final firebaseService = FirebaseService();
        if (widget.userId != null) {
           firebaseService.subscribeToStudentAlerts(widget.userId!);
        }
        
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
           print("StudentDashboard received message: ${message.data}");
           if (mounted) {
              final type = message.data['type'];
              String msg = "";
              Color color = AppTheme.primary;
              
              if (type == 'pass_approved') {
                 final status = message.data['status'];
                 msg = status == 'approved_parent' 
                      ? "Parent Approved! Waiting for Warden." 
                      : "Pass Approved! Ready for outing.";
                 color = AppTheme.success;
                 
                 // Refresh passes
                 if (_token != null && _userId != null) {
                    Provider.of<PassProvider>(context, listen: false).loadPasses(_userId!, _token!);
                 }

              } else if (type == 'pass_rejected') {
                 msg = "Pass Rejected: ${message.data['reason'] ?? ''}";
                 color = AppTheme.error;
                  if (_token != null && _userId != null) {
                    Provider.of<PassProvider>(context, listen: false).loadPasses(_userId!, _token!);
                 }
              }

              if (msg.isNotEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                       content: Text(msg),
                       backgroundColor: color,
                       behavior: SnackBarBehavior.floating,
                    )
                 );
              }
           }
        });
     } catch (e) {
        print("Error setting up student notifications: $e");
     }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _token = await SessionManager.getToken();
    final user = await SessionManager.getUser();
    if (user != null) {
      setState(() {
        _userName = user.name ?? 'Student';
        _userId ??= user.id;
      });
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
           // Background Elements
           Positioned(
             top: -100,
             right: -50,
             child: Container(
               width: 300,
               height: 300,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: AppTheme.primary.withOpacity(0.1),
                 boxShadow: [
                   BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 100, spreadRadius: 20)
                 ]
               ),
             ),
           ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar / Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back,', style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
                          Text(_userName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                         onTap: () => _navigateTo(ProfileScreen(userId: widget.userId)),
                        child: Container(
                          decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(color: AppTheme.primary),
                             boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10)]
                          ),
                          child: const CircleAvatar(
                            backgroundColor: AppTheme.surface,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text("DASHBOARD", style: TextStyle(color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Staggered Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          title: 'New Pass',
                          icon: Icons.add_circle_outline,
                          color: AppTheme.primary,
                          delay: 0,
                          onTap: () => _navigateTo(CreatePassScreen(userId: _userId ?? '')),
                        ),
                        _buildMenuCard(
                          title: 'My Passes',
                          icon: Icons.history,
                          color: AppTheme.secondary,
                          delay: 100,
                          onTap: () => _navigateTo(PassHistoryScreen(userId: _userId ?? '', token: _token ?? '')),
                        ),
                        _buildMenuCard(
                          title: 'Notifications',
                          icon: Icons.notifications_none,
                          color: Colors.purpleAccent,
                          delay: 200,
                          onTap: () => _navigateTo(StudentNotificationsScreen(userId: _userId ?? '', token: _token ?? '')),
                        ),
                        _buildMenuCard(
                          title: 'Show QR',
                          icon: Icons.qr_code_2,
                          color: AppTheme.success,
                          delay: 300,
                          onTap: () => _navigateTo(const BarcodeDisplayScreen()),
                        ),
                        _buildMenuCard(
                          title: 'Location',
                          icon: Icons.location_on_outlined,
                          color: Colors.orangeAccent,
                          delay: 300,
                          onTap: () => _navigateTo(LocationTrackingScreen(userId: _userId, token: _token ?? '')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // SOS Button (Floating with Pulse)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.5 * _pulseController.value),
                          blurRadius: 20 + (20 * _pulseController.value),
                          spreadRadius: 5 * _pulseController.value,
                        )
                      ],
                    ),
                    child: child,
                  );
                },
                child: FloatingActionButton.large(
                  backgroundColor: AppTheme.accent,
                  onPressed: () => _navigateTo(SOSScreen(userId: _userId, token: _token ?? '')),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                        Icon(Icons.sos, size: 32, color: Colors.white),
                        Text("SOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white))
                     ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GlassyCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
               tag: 'menu_icon_$title',
               child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: color.withOpacity(0.2),
                    boxShadow: [
                       BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)
                    ]
                 ),
                 child: Icon(icon, color: Colors.white, size: 32),
               ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
