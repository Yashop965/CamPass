import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../widgets/gradient_background.dart';
import '../../providers/parent_provider.dart';
import '../common/review_request_screen.dart';
import 'parent_tracking_screen.dart';
import 'parent_notifications_screen.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/firebase_service.dart';

class ParentDashboard extends StatefulWidget {
  final String parentId;
  final String token;
  const ParentDashboard({
    super.key,
    required this.parentId,
    required this.token,
  });

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  String? _selectedChildId; // For Tracking & History tabs
  String? _approvalFilterId; // For Approvals tab filtering
  Timer? _pollTimer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initial Load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _loadChildren();
    });

    // Start Polling (every 15 seconds)
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        _refreshData();
      }
    });

    // Subscribe to parent alerts and listen for messages
    _setupNotifications();
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
      print("App resumed - refreshing parent dashboard");
      _refreshData();
    }
  }

  void _refreshData() {
     try {
        final parentProvider = Provider.of<ParentProvider>(context, listen: false);
        parentProvider.loadPendingApprovals(widget.token);
        // We could also reload children if linking status changed externally
        // parentProvider.loadChildren(widget.token); 
     } catch (e) {
        print("Error refreshing parent data: $e");
     }
  }

  void _loadChildren() {
      try {
        final parentProvider = Provider.of<ParentProvider>(context, listen: false);
        parentProvider.loadChildren(widget.token).then((_) {
            // If children exist, load passes for the first one by default
            if (parentProvider.children.isNotEmpty) {
               parentProvider.loadChildPasses(parentProvider.children.first['id'], widget.token);
            }
        });
      } catch (e) {
         print("Error loading children: $e");
      }
  }

  void _setupNotifications() {
     try {
       final firebaseService = FirebaseService();
       firebaseService.subscribeToParentAlerts(widget.parentId);

       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
         print("ParentDashboard received message: ${message.data}");
         if (message.data['type'] == 'pass_request') {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text("New Pass Request: ${message.notification?.body ?? ''}"),
                 backgroundColor: AppTheme.primary,
                 action: SnackBarAction(label: 'REFRESH', onPressed: () => _refreshData()),
               ),
             );
             _refreshData();
           }
          } else if (message.data['type'] == 'late_entry') {
             if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                      content: Text("LATE ENTRY! ${message.notification?.body ?? ''}"),
                      backgroundColor: AppTheme.error,
                      duration: const Duration(seconds: 10),
                   )
                );
             }
          } else if (message.data['type'] == 'sos_alert') {
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                     content: Text("SOS ALERT! ${message.notification?.body ?? ''}"),
                     backgroundColor: AppTheme.error,
                     duration: const Duration(seconds: 10),
                     action: SnackBarAction(
                        label: 'TRACK', 
                        textColor: Colors.white,
                        onPressed: () {
                           setState(() {
                              _selectedChildId = message.data['studentId'];
                              _selectedIndex = 2; // Switch to Tracking Tab
                           });
                        }
                     ),
                  )
               );
            }
         }
       });
     } catch (e) {
       print("Error setting up notifications in ParentDashboard: $e");
     }
  }

  void _showLinkStudentDialog() {
    final emailController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.only(
             bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
             top: 24, left: 24, right: 24
          ),
          decoration: BoxDecoration(
             color: const Color(0xFF1E1E1E).withOpacity(0.9),
             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
             border: Border.all(color: Colors.white10)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
               const SizedBox(height: 24),
               const Text("Link Student Account", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               const Text("Enter your child's student email to link their account to your dashboard.", style: TextStyle(color: Colors.white54)),
               const SizedBox(height: 24),
               
               // Email Input
               Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.white10)
                  ),
                  child: TextField(
                     controller: emailController,
                     style: const TextStyle(color: Colors.white),
                     decoration: const InputDecoration(
                        icon: Icon(Icons.email_outlined, color: AppTheme.primary),
                        hintText: "student@university.edu",
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                     ),
                  ),
               ),
               const SizedBox(height: 32),
               
               // Action Buttons
               Row(
                 children: [
                    Expanded(
                       child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                       ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                       child: ElevatedButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            if (email.isEmpty) return;
                            
                            Navigator.pop(ctx); 
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Linking account..."), duration: Duration(seconds: 1)),
                            );
                            
                            try {
                              final authService = AuthService();
                              await authService.linkStudent(email, widget.token); 
                              
                              if (mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Success! Student linked."), backgroundColor: AppTheme.success),
                                 );
                                 _refreshData();
                                 _loadChildren();
                              }
                            } catch (e) {
                              if (mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.error),
                                 );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                             backgroundColor: AppTheme.primary,
                             foregroundColor: Colors.black,
                             padding: const EdgeInsets.symmetric(vertical: 16),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                          ),
                          child: const Text("Link Account", style: TextStyle(fontWeight: FontWeight.bold)),
                       ),
                    ),
                 ],
               )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: Stack(
          children: [
              // Keep Orbs if they look good, or remove / update them
              // Updated Orb
             Positioned(
               top: -100,
               right: -50,
               child: Container(
                 width: 300,
                 height: 300,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.white.withOpacity(0.05), // Subtle white instead of primary
                   boxShadow: [
                     BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 100, spreadRadius: 20)
                   ]
                 ),
               ),
             ),
           
           SafeArea(
             bottom: false,
             child: Column(
                children: [
                   // AppBar Custom
                   Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  const Text("Campass", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                  const SizedBox(height: 4),
                                  Text("Parent Portal", style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                               ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                                  onPressed: _showLinkStudentDialog,
                                  tooltip: "Link Student",
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                   onTap: () => Navigator.pushNamed(context, '/parent/profile'),
                                   child: const CircleAvatar(
                                      backgroundColor: AppTheme.surface,
                                      child: Icon(Icons.person, color: Colors.white),
                                   ),
                                ),
                              ],
                            )
                         ],
                      ),
                   ),
                   
                   Expanded(
                      child: IndexedStack(
                         index: _selectedIndex,
                         children: [
                            _buildApprovalsTab(),
                            _buildReviewTab(), 
                            Consumer<ParentProvider>(
                                builder: (context, provider, _) { 
                                   String targetChildId = "";
                                   if (provider.children.isNotEmpty) {
                                      if (_selectedChildId != null && provider.children.any((c) => c['id'] == _selectedChildId)) {
                                          targetChildId = _selectedChildId!;
                                      } else {
                                          targetChildId = provider.children.first['id'];
                                      }
                                   } else {
                                      targetChildId = widget.parentId;
                                   }
                                   
                                   return ParentTrackingScreen(
                                      parentId: widget.parentId, 
                                      childId: targetChildId, 
                                      token: widget.token
                                   );
                                }
                            ),
                            ParentNotificationsScreen(parentId: widget.parentId, childId: widget.parentId, token: widget.token),
                         ],
                      ),
                   ),
                ],
             ),
           ),
        ],
        ),
      ),
      extendBody: true,
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                   currentIndex: _selectedIndex,
                   onTap: (index) => setState(() => _selectedIndex = index),
                   backgroundColor: Colors.transparent,
                   elevation: 0,
                   selectedItemColor: AppTheme.primary,
                   unselectedItemColor: AppTheme.textGrey,
                   type: BottomNavigationBarType.fixed,
                   items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: 'Approvals'),
                      BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
                      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Track'),
                      BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
                   ],
                ),
              ),
           ),
        ),
     );
  }

  Widget _buildReviewTab() {
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        final history = parentProvider.childPasses;
        final children = parentProvider.children;

        // If no children linked, show empty state
        if (children.isEmpty) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.person_off_outlined, size: 60, color: AppTheme.textGrey.withOpacity(0.5)),
                 const SizedBox(height: 16),
                 const Text("No Children Linked", style: TextStyle(color: Colors.white, fontSize: 18)),
                 TextButton(
                    onPressed: _showLinkStudentDialog,
                    child: const Text("Link Student Now")
                 )
               ],
             )
           );
        }

        return Column(
          children: [
             // Child Selector (Only if multiple children)
             if (children.isNotEmpty) 
               Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                     decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05), // Glassy
                        borderRadius: BorderRadius.circular(20), // More rounded
                        border: Border.all(color: Colors.white.withOpacity(0.1))
                     ),
                     child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                           value: children.any((c) => c['id'] == parentProvider.childPasses.firstOrNull?.userId) 
                                   ? parentProvider.childPasses.firstOrNull?.userId 
                                   : children.first['id'], // Default to first child
                           dropdownColor: const Color(0xFF2A2A2A).withOpacity(0.95), // Lighter translucent dropdown
                           borderRadius: BorderRadius.circular(16), // Rounded dropdown corners
                           icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
                           isExpanded: true,
                           style: const TextStyle(color: Colors.white, fontSize: 16),
                           items: children.map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['name'] ?? 'Student', style: const TextStyle(color: Colors.white)),
                           )).toList(),
                           onChanged: (val) {
                              if (val != null) {
                                 parentProvider.loadChildPasses(val, widget.token);
                              }
                           },
                        )
                     ),
                  ),
               ),

             Expanded(
               child: history.isEmpty
                 ? Center(
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          Icon(Icons.history_toggle_off, size: 80, color: AppTheme.textGrey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text("No History Yet", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text("Past passes will appear here.", style: TextStyle(color: AppTheme.textGrey)),
                       ],
                    ),
                 )
                 : RefreshIndicator(
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    onRefresh: () async {
                      // Refresh currently selected child's passes
                      // We can infer current child from the list or default to first
                      String targetId = children.first['id'];
                      if (history.isNotEmpty) targetId = history.first.userId;
                      await parentProvider.loadChildPasses(targetId, widget.token);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final p = history[index];
                        Color statusColor;
                        switch (p.status) {
                           case 'active': statusColor = AppTheme.success; break;
                           case 'pending': statusColor = Colors.orange; break;
                           case 'rejected': statusColor = AppTheme.error; break;
                           default: statusColor = AppTheme.textGrey;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassyCard(
                             child: Row(
                                children: [
                                   Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                         color: statusColor.withOpacity(0.1),
                                         borderRadius: BorderRadius.circular(12),
                                         border: Border.all(color: statusColor.withOpacity(0.3))
                                      ),
                                      child: Icon(
                                         p.type == 'outing' ? Icons.directions_walk : Icons.home,
                                         color: statusColor,
                                      ),
                                   ),
                                   const SizedBox(width: 16),
                                   Expanded(
                                      child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                            Text(
                                               p.purpose ?? "Outing",
                                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                               "Valid: ${DateFormat('MMM dd, hh:mm a').format(p.validFrom)}",
                                               style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                                            ),
                                            Text(
                                               "Status: ${p.status.toUpperCase()}",
                                               style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                         ],
                                      ),
                                   ),
                                ],
                             ),
                          ),
                        );
                      },
                    ),
                 ),
             ),
          ],
        );
      },
    );
  }

  Widget _buildApprovalsTab() {
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        final pending = parentProvider.pendingApprovals;

        // Filter Logic
        final filteredPending = _approvalFilterId == null 
             ? pending 
             : pending.where((p) => p.userId == _approvalFilterId).toList();
        
        final children = parentProvider.children;

        return Column(
          children: [
             // APPROVAL FILTER (Only show if there are children linked)
             if (children.isNotEmpty)
               Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                        children: [
                           // "All" Chip
                           ChoiceChip(
                              label: const Text("All Students"),
                              selected: _approvalFilterId == null,
                              onSelected: (bool selected) {
                                 if (selected) setState(() => _approvalFilterId = null);
                              },
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(color: _approvalFilterId == null ? Colors.black : Colors.white),
                              backgroundColor: AppTheme.surface,
                              side: BorderSide.none,
                           ),
                           const SizedBox(width: 8),
                           // Child Chips
                           ...children.map((child) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                 label: Text(child['name'] ?? 'Student'),
                                 selected: _approvalFilterId == child['id'],
                                 onSelected: (bool selected) {
                                    setState(() => _approvalFilterId = selected ? child['id'] : null);
                                 },
                                 selectedColor: AppTheme.primary,
                                 labelStyle: TextStyle(color: _approvalFilterId == child['id'] ? Colors.black : Colors.white),
                                 backgroundColor: AppTheme.surface,
                                 side: BorderSide.none,
                              ),
                           )),
                        ],
                     ),
                  ),
               ),

             if (filteredPending.isEmpty)
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    onRefresh: () async => _refreshData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                              Icon(Icons.check_circle_outline, size: 80, color: AppTheme.success.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                 _approvalFilterId == null ? "All Caught Up!" : "No requests for this student",
                                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 8),
                              const Text("No pending approval requests.", style: TextStyle(color: AppTheme.textGrey)),
                           ],
                        ),
                      ),
                    ),
                  ),
                )
             else 
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    onRefresh: () async => _refreshData(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: filteredPending.length,
                      itemBuilder: (context, index) {
                        final p = filteredPending[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassyCard(
                             // ... rest of card code ...
                             child: InkWell( // Wrap content in InkWell for tap effect if needed or just keep GlassyCard tap
                               onTap: () {
                                  Navigator.push(
                                     context, 
                                     MaterialPageRoute(
                                        builder: (_) => ReviewRequestScreen(
                                            pass: p, 
                                            reviewerId: widget.parentId, 
                                            token: widget.token,
                                            isWarden: false,
                                         )
                                     )
                                  ).then((_) => _refreshData());
                               },
                               child: Padding( // Add padding inside card
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                       Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                             color: AppTheme.primary.withOpacity(0.1),
                                             borderRadius: BorderRadius.circular(12),
                                             border: Border.all(color: AppTheme.primary.withOpacity(0.3))
                                          ),
                                          child: Icon(
                                             p.type == 'outing' ? Icons.directions_walk : Icons.home,
                                             color: AppTheme.primary,
                                          ),
                                       ),
                                       const SizedBox(width: 16),
                                       Expanded(
                                          child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                                Text(
                                                   p.type.toUpperCase(),
                                                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                   "Requested: ${DateFormat('MMM dd, hh:mm a').format(p.validFrom)}",
                                                   style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                                                ),
                                                if (p.studentName != null) ...[
                                                   const SizedBox(height: 4),
                                                   Text(
                                                      "By: ${p.studentName}",
                                                      style: const TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                                                   ),
                                                ]
                                             ],
                                          ),
                                       ),
                                       const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGrey)
                                    ],
                                 ),
                               ),
                             ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
