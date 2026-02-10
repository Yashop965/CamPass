import 'dart:async';
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

class _WardenDashboardState extends State<WardenDashboard> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  String? _wardenId;
  String? _token;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _wardenId = widget.wardenId.isNotEmpty ? widget.wardenId : null;
    _token = widget.token.isNotEmpty ? widget.token : null;
    
    _loadData();
    _setupNotifications();

    // Start Polling (every 15 seconds)
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && _token != null) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
       print("App resumed - refreshing warden dashboard");
       if (_token != null) {
          _refreshData();
       }
    }
  }

  void _refreshData() {
      if (!mounted || _token == null) return;
      try {
        final wardenProvider = Provider.of<WardenProvider>(context, listen: false);
        wardenProvider.loadPendingApprovals(_token!);
        wardenProvider.loadAllSOSAlerts(_token!);
        wardenProvider.loadGeofenceViolations(_token!);
      } catch (e) {
         print("Error refreshing warden data: $e");
      }
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
            bool shouldRefresh = false;
            String snackBarMsg = "";

            if (type == 'pass_request') {
               snackBarMsg = "New Pass Request: ${message.notification?.body ?? ''}";
               shouldRefresh = true;
            } else if (type == 'sos_alert' || type == 'manual_sos') {
               snackBarMsg = "SOS ALERT! ${message.notification?.body ?? ''}";
               shouldRefresh = true;
            } else if (type == 'geofence_violation') {
               snackBarMsg = "Violation Detected: ${message.notification?.body ?? ''}";
               shouldRefresh = true;
            } else if (type == 'late_entry') {
               snackBarMsg = "LATE ENTRY: ${message.notification?.body ?? ''}";
               final wardenProvider = Provider.of<WardenProvider>(context, listen: false);
               wardenProvider.addLateEntryAlert(message.data);
               shouldRefresh = true;
            }

            if (shouldRefresh) {
               _refreshData();
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text(snackBarMsg),
                   backgroundColor: type == 'pass_request' ? AppTheme.primary : AppTheme.accent,
                   duration: const Duration(seconds: 4),
                   action: SnackBarAction(label: 'REFRESH', onPressed: () => _refreshData()),
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
      _refreshData();
      final wardenProvider = Provider.of<WardenProvider>(context, listen: false);
      wardenProvider.loadHistory(_token!);
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
                               _buildAlertsTab(),
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
                     BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),

                    BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Alerts'),
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
         return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            child: SingleChildScrollView(
               physics: const AlwaysScrollableScrollPhysics(),
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
        final pending = provider.pendingApprovals;
        
        if (pending.isEmpty) {
           return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: SingleChildScrollView(
                 physics: const AlwaysScrollableScrollPhysics(),
                 child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    alignment: Alignment.center,
                    child: Text("No Pending Approvals", style: TextStyle(color: AppTheme.textGrey.withOpacity(0.5), fontSize: 18))
                 ),
              ),
           );
        }
        
        return RefreshIndicator(
           onRefresh: () async => _refreshData(),
           color: AppTheme.primary,
           backgroundColor: AppTheme.surface,
           child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                 final p = pending[index];
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
                             _refreshData();
                          }
                       },
                       child: Row(
                          children: [
                             CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.2), child: Text((p.studentName?.isNotEmpty == true ? p.studentName![0] : p.type[0]).toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
                             const SizedBox(width: 16),
                             Expanded(
                                child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                       Text(p.studentName ?? 'Unknown Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),

                                       const SizedBox(height: 4),

                                       Text('${p.type.toUpperCase()}${p.purpose != null ? " • ${p.purpose}" : ""}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 13), overflow: TextOverflow.ellipsis),

                                       const SizedBox(height: 2),

                                       Text(DateFormat('MMM dd, hh:mm a').format(p.validFrom.toLocal()), style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),

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
           ),
        );
     });
  }

  Widget _buildHistoryTab() {
    return Consumer<WardenProvider>(builder: (context, provider, _) {
       final history = provider.passHistory;
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
                               Text(DateFormat('MMM dd, hh:mm a').format(p.validFrom.toLocal()), style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                if (p.rejectionReason != null && p.rejectionReason!.isNotEmpty) ...[


                                   const SizedBox(height: 4),


                                   Text("Reason: ${p.rejectionReason}", style: const TextStyle(color: AppTheme.error, fontSize: 12, fontStyle: FontStyle.italic)),


                                ],


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

  Widget _buildAlertsTab() {
    return Consumer<WardenProvider>(builder: (context, provider, _) {
      final sosAlerts = provider.allSOSAlerts;
      final violations = provider.geofenceViolations;
      final lateEntries = provider.lateEntryAlerts;
      final hasAlerts = sosAlerts.isNotEmpty || violations.isNotEmpty || lateEntries.isNotEmpty;

      if (!hasAlerts) return _buildEmptyState("No Active Alerts");

      return Column(
        children: [
          if (sosAlerts.isNotEmpty || lateEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("ACTIVE ALERTS", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  TextButton.icon(
                    onPressed: () {
                      if (_token != null) {
                        provider.resolveAllSOS(_token!);
                        // Also clear late entries if desired, or just refresh
                        _refreshData();
                      }
                    },
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    label: const Text("RESOLVE ALL", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1))
                  )
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: AppTheme.accent,
              backgroundColor: AppTheme.surface,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: sosAlerts.length + violations.length + lateEntries.length,
                itemBuilder: (context, index) {
                  if (index < sosAlerts.length) {
                    final alert = sosAlerts[index];
                    return _buildSOSAlertCard(alert, provider);
                  } else if (index < sosAlerts.length + lateEntries.length) {
                    final lateEntry = lateEntries[index - sosAlerts.length];
                    return _buildLateEntryCard(lateEntry);
                  } else {
                    final v = violations[index - sosAlerts.length - lateEntries.length];
                    return _buildViolationCard(v);
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSOSAlertCard(dynamic alert, WardenProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassyCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency, color: AppTheme.accent, size: 32),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12)),
                    child: const Text("SOS", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                    onPressed: () {
                      if (_token != null) {
                        provider.resolveSOSAlert(alert['id'], _token!);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(alert['studentName'] ?? 'Unknown Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(alert['alertType'] ?? 'Emergency Alert', style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViolationCard(dynamic v) {
    final timestamp = v['timestamp'] != null ? DateTime.parse(v['timestamp']) : null;
    final latestPass = v['latestPass'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassyCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                    child: const Text("VIOLATION", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(v['studentName'] ?? 'Unknown Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text("Outside Campus Boundary", style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              if (timestamp != null) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.textGrey, size: 16),
                    const SizedBox(width: 8),
                    Text("Detected: ${DateFormat('MMM dd, hh:mm a').format(timestamp.toLocal())}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
              if (latestPass != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("Active Pass: ${latestPass['type']?.toUpperCase() ?? 'N/A'} • ${latestPass['purpose'] ?? 'No purpose'}", style: const TextStyle(color: AppTheme.primary, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.block, color: AppTheme.error, size: 16),
                    SizedBox(width: 8),
                    Text("No Active Pass", style: TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLateEntryCard(dynamic data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassyCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_off_outlined, color: AppTheme.error, size: 32),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(12)),
                    child: const Text("LATE ENTRY", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(data['studentName'] ?? 'Unknown Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.login, color: AppTheme.textGrey, size: 16),
                  const SizedBox(width: 8),
                  Text("Entered: ${DateFormat('hh:mm a').format(DateTime.parse(data['entryTime']).toLocal())}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.event_available, color: AppTheme.textGrey, size: 16),
                  const SizedBox(width: 8),
                  Text("Expired: ${DateFormat('hh:mm a').format(DateTime.parse(data['validUntil']).toLocal())}", style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildViolationsTab() {
     return Consumer<WardenProvider>(builder: (context, provider, _) {
         if (provider.geofenceViolations.isEmpty) return _buildEmptyState("No Violations");
         return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            color: Colors.orange,
            backgroundColor: AppTheme.surface,
            child: ListView.builder(
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
            ),
         );
     });
  }

  Widget _buildEmptyState(String msg) {
     return RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: Text(msg, style: TextStyle(color: AppTheme.textGrey.withOpacity(0.5), fontSize: 18)),
          ),
        ),
     );
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
