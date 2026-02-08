import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../providers/warden_provider.dart';
import '../common/review_request_screen.dart';
import 'package:intl/intl.dart';
import '../../services/session_manager.dart';
import 'warden_profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/firebase_service.dart';

class WardenDashboard extends StatefulWidget {
  final String wardenId;
  final String token;
  const WardenDashboard({
    super.key,
    required this.wardenId,
    required this.token,
  });

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  int _selectedIndex = 0;
  String? _wardenId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _wardenId = widget.wardenId.isNotEmpty ? widget.wardenId : null;
    _token = widget.token.isNotEmpty ? widget.token : null;
    
    _loadData();
    _setupNotifications();
  }

  void _setupNotifications() {
     try {
       final firebaseService = FirebaseService();
       firebaseService.subscribeToAdminAlerts(); // Wardens subscribe to admin alerts (SOS/Geofence)
       firebaseService.subscribeToTopic('warden_alerts'); // Specific warden alerts

       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
         print("WardenDashboard received message: ${message.data}");
         
         if (mounted) {
            final type = message.data['type'];
            final wardenProvider = Provider.of<WardenProvider>(context, listen: false);
            bool shouldRefresh = false;
            String snackBarMsg = "";

            if (type == 'pass_request') {
               wardenProvider.loadPendingApprovals(_token!);
               snackBarMsg = "New Pass Request: ${message.notification?.body ?? ''}";
               shouldRefresh = true;
            } else if (type == 'sos_alert' || type == 'manual_sos') {
               wardenProvider.loadAllSOSAlerts(_token!);
               snackBarMsg = "SOS ALERT! ${message.notification?.body ?? ''}";
               shouldRefresh = true;
            } else if (type == 'geofence_violation') {
               wardenProvider.loadGeofenceViolations(_token!);
               snackBarMsg = "Violation Detected: ${message.notification?.body ?? ''}";
               shouldRefresh = true;
            }

            if (shouldRefresh) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text(snackBarMsg),
                   backgroundColor: type == 'pass_request' ? AppTheme.primary : AppTheme.accent,
                   duration: const Duration(seconds: 4),
                   action: SnackBarAction(label: 'VIEW', onPressed: () {
                      // Logic to switch tab could go here if needed
                   }),
                 ),
               );
            }
         }
       });
     } catch (e) {
       print("Error setting up notifications in WardenDashboard: $e");
     }
  }

  Future<void> _loadData() async {
    if (_wardenId == null || _token == null) {
      final user = await SessionManager.getUser();
      final token = await SessionManager.getToken();
      if (mounted && user != null && token != null) {
        setState(() {
          _wardenId = user.id;
          _token = token;
        });
      }
    }
    
    if (mounted && _token != null) {
      final wardenProvider = Provider.of<WardenProvider>(context, listen: false);
      wardenProvider.loadPendingApprovals(_token!);
      wardenProvider.loadHistory(_token!);
      wardenProvider.loadAllSOSAlerts(_token!);
      wardenProvider.loadGeofenceViolations(_token!);
    }
  }

  Future<void> _logout() async {
    await SessionManager.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
         children: [
             // Futuristic Grid Background
             Positioned.fill(
                child: CustomPaint(
                   painter: GridPainter(),
                ),
             ),
             
             SafeArea(
                child: Column(
                   children: [
                      Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                         child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text("CAMPASS SYSTEM", style: TextStyle(color: AppTheme.primary.withOpacity(0.7), fontSize: 12, letterSpacing: 3)),
                                     const SizedBox(height: 4),
                                     Text("Warden Control", style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                               ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
                                  child: IconButton(
                                    icon: const Icon(Icons.person, color: AppTheme.primary),
                                    onPressed: () {
                                       Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                             builder: (_) => const WardenProfileScreen()
                                          )
                                       );
                                    },
                                    tooltip: 'Profile',
                                  ),
                               )
                            ],
                         ),
                      ),
                      
                      Expanded(
                         child: IndexedStack(
                            index: _selectedIndex,
                            children: [
                               _buildOverviewTab(),
                               _buildApprovalsTab(),
                               _buildHistoryTab(),
                               _buildSOSAlertsTab(),
                               _buildViolationsTab(),
                            ],
                         ),
                      )
                   ],
                ),
             )
         ],
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildGlassBottomNav() {
     return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
           child: Container(
              color: AppTheme.surface.withOpacity(0.7),
              child: BottomNavigationBar(
                 currentIndex: _selectedIndex,
                 onTap: (index) => setState(() => _selectedIndex = index),
                 backgroundColor: Colors.transparent,
                 elevation: 0,
                 type: BottomNavigationBarType.fixed,
                 selectedItemColor: AppTheme.primary,
                 unselectedItemColor: AppTheme.textGrey,
                 items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
                    BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Approvals'),
                    BottomNavigationBarItem(icon: Icon(Icons.emergency_outlined), label: 'SOS'),
                    BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Violations'),
                 ],
              ),
           ),
        ),
     );
  }

  Widget _buildOverviewTab() {
    return Consumer<WardenProvider>(
      builder: (context, provider, _) {
         final stats = provider.getDashboardStats();
         return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                     children: [
                        Expanded(child: _buildStatCard("PENDING", stats['pendingApprovals'].toString(), AppTheme.primary, Icons.timer)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard("ACTIVE SOS", stats['activeSOSAlerts'].toString(), AppTheme.accent, Icons.warning)),
                     ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                     children: [
                        Expanded(child: _buildStatCard("VIOLATIONS", stats['geofenceViolations'].toString(), Colors.orange, Icons.not_listed_location)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard("ON CAMPUS", "1.2k", AppTheme.success, Icons.people)), // Mock data for demo
                     ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text("SYSTEM STATUS", style: TextStyle(color: AppTheme.textGrey, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GlassyCard(
                     child: Column(
                        children: [
                           _buildSystemRow("Gate Sensors", "Online", AppTheme.success),
                           const Divider(color: Colors.white12),
                           _buildSystemRow("Database Sync", "Active", AppTheme.success),
                           const Divider(color: Colors.white12),
                           _buildSystemRow("Notifications Service", "Running", AppTheme.success),
                        ],
                     ),
                  )
               ],
            ),
         );
      }
    );
  }
  
  Widget _buildSystemRow(String label, String status, Color color) {
     return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              Row(
                 children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                 ],
              )
           ],
        ),
     );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
     return GlassyCard(
        padding: const EdgeInsets.all(16),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 16),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10, letterSpacing: 1)),
           ],
        ),
     );
  }

  Widget _buildApprovalsTab() {
     return Consumer<WardenProvider>(builder: (context, provider, _) { 
        if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        if (provider.pendingApprovals.isEmpty) return _buildEmptyState("No Pending Approvals");
        
        return ListView.builder(
           padding: const EdgeInsets.all(24),
           itemCount: provider.pendingApprovals.length,
           itemBuilder: (context, index) {
              final p = provider.pendingApprovals[index];
              return Padding(
                 padding: const EdgeInsets.only(bottom: 16),
                 child: GlassyCard(
                    onTap: () async {
                       final result = await Navigator.push(
                          context, 
                          MaterialPageRoute(
                             builder: (_) => ReviewRequestScreen(
                                pass: p, 
                                reviewerId: _wardenId ?? '', 
                                token: _token ?? '',
                                isWarden: true,
                              )
                          )
                       );
                       if (result == true) {
                          provider.loadPendingApprovals(widget.token);
                       }
                    },
                    child: Row(
                       children: [
                          CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.2), child: Text(p.type[0].toUpperCase(), style: const TextStyle(color: AppTheme.primary))),
                          const SizedBox(width: 16),
                          Expanded(
                             child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(p.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                   Text(DateFormat('MMM dd, HH:mm').format(p.validFrom.toLocal()), style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                ],
                             ),
                          ),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                             child: const Text("REVIEW", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                       ],
                    ),
                 ),
              );
           },
        );
     });
  }

  Widget _buildHistoryTab() {
    return Consumer<WardenProvider>(builder: (context, provider, _) {
       final history = provider.passHistory;
       if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
       if (history.isEmpty) {
          return Center(
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history, size: 60, color: AppTheme.textGrey.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   const Text("No History", style: TextStyle(color: Colors.white, fontSize: 18)),
                   TextButton(
                      onPressed: () => provider.loadHistory(_token!),
                      child: const Text("Refresh")
                   )
                ],
             ),
          );
       }

       return RefreshIndicator(
          onRefresh: () async => await provider.loadHistory(_token!),
          child: ListView.builder(
             padding: const EdgeInsets.all(24),
             itemCount: history.length,
             itemBuilder: (context, index) {
                final p = history[index];
                Color statusColor;
                switch (p.status) {
                   case 'approved': case 'approved_warden': case 'approved_parent': statusColor = AppTheme.success; break;
                   case 'rejected': statusColor = AppTheme.error; break;
                   case 'expired': statusColor = Colors.grey; break;
                   default: statusColor = AppTheme.textGrey;
                }
                
                return Padding(
                   padding: const EdgeInsets.only(bottom: 16),
                   child: GlassyCard(
                      child: ListTile(
                         leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.2),
                            child: Icon(
                               p.status.contains('approved') ? Icons.check : Icons.close,
                               color: statusColor,
                               size: 20
                            )
                         ),
                         title: Text(p.studentName ?? 'Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                         subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text("${p.type.toUpperCase()} • ${p.status.toUpperCase()}", style: TextStyle(color: statusColor, fontSize: 12)),
                               Text(DateFormat('MMM dd, HH:mm').format(p.validFrom.toLocal()), style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                            ],
                         ),
                         trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                         onTap: () {
                             // Show details if needed
                         },
                      ),
                   ),
                );
             },
          ),
       );
    });
  }

  Widget _buildSOSAlertsTab() {
     return Consumer<WardenProvider>(builder: (context, provider, _) {
        if (provider.allSOSAlerts.isEmpty) return _buildEmptyState("No Active Alerts");
        return ListView.builder(
           padding: const EdgeInsets.all(24),
           itemCount: provider.allSOSAlerts.length,
           itemBuilder: (context, index) {
              final alert = provider.allSOSAlerts[index];
              return Padding(
                 padding: const EdgeInsets.only(bottom: 16),
                 child: GlassyCard(
                    child: ListTile(
                       leading: const Icon(Icons.emergency, color: AppTheme.accent, size: 32),
                       title: const Text("SOS ALERT", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                       subtitle: Text(alert['alertType'] ?? 'Emergency', style: const TextStyle(color: Colors.white)),
                       trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                           onPressed: () {
                              if (_token != null) {
                                provider.resolveSOSAlert(alert['id'], _token!);
                              }
                           },
                       ),
                    ),
                 ),
              );
           },
        );
     });
  }
  
  Widget _buildViolationsTab() {
     return Consumer<WardenProvider>(builder: (context, provider, _) {
         if (provider.geofenceViolations.isEmpty) return _buildEmptyState("No Violations");
         return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.geofenceViolations.length,
            itemBuilder: (context, index) {
               final v = provider.geofenceViolations[index];
               return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassyCard(
                     child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                        title: Text(v['studentName'] ?? 'Unknown Student', style: const TextStyle(color: Colors.white)),
                        subtitle: const Text("Outside Campus Boundary", style: TextStyle(color: AppTheme.textGrey)),
                     ),
                  ),
               );
            }
         );
     });
  }

  Widget _buildEmptyState(String msg) {
     return Center(child: Text(msg, style: TextStyle(color: AppTheme.textGrey.withOpacity(0.5), fontSize: 18)));
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
      
    double space = 40;
    
    for (double i = 0; i < size.width; i += space) {
       canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += space) {
       canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
