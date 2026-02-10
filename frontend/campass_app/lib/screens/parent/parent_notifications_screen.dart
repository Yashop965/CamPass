import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parent_provider.dart';
// Ensure you have this model
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import 'package:intl/intl.dart';

class ParentNotificationsScreen extends StatefulWidget {
  final String parentId;
  final String childId;
  final String token;

  const ParentNotificationsScreen({
    super.key,
    required this.parentId,
    required this.childId,
    required this.token,
  });

  @override
  State<ParentNotificationsScreen> createState() => _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState extends State<ParentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ParentProvider>(context, listen: false);
    // Ensure we have latest data
    await provider.loadPendingApprovals(widget.token);
    if (provider.children.isNotEmpty) {
       // Load history for the first child (or all if we iterate)
       // For this simple implementation, we just use what's available or load the first one
       await provider.loadChildPasses(provider.children.first['id'], widget.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Allow parent gradient to show
      child: Consumer<ParentProvider>(
        builder: (context, provider, _) {
          // Derive notifications
          List<Map<String, dynamic>> notifications = [];

          // 1. Pending Approvals
          for (var p in provider.pendingApprovals) {
             notifications.add({
                'title': 'Approval Request',
                'body': 'New ${p.type} pass request from ${p.studentName ?? "your child"}.',
                'timestamp': p.updatedAt ?? p.validFrom,
                'type': 'request',
                'isRead': false,
             });
          }

          // 2. Child History (Activity)
          for (var p in provider.childPasses) {
             // Skip pending as they are covered above
             if (p.status == 'pending') continue;

             String title = "Pass Update";
             String body = "Pass is ${p.status}.";
             String type = "info";

             if (p.status.contains('approved')) {
                title = "Pass Approved";
                body = "Outing to ${p.purpose ?? 'destination'} approved.";
                type = "success";
             } else if (p.status == 'rejected') {
                title = "Pass Rejected";
                body = "Request to ${p.purpose ?? 'destination'} rejected.";
                type = "error";
             } else if (p.status == 'active') {
                title = "Child Active";
                body = "Child has left the campus.";
                type = "warning";
             } else if (p.status == 'entered') {
                bool isLate = p.entryTime != null && p.entryTime!.isAfter(p.validTo);
                title = isLate ? "LATE ENTRY" : "Child Returned";
                body = isLate 
                  ? "Child entered campus late after pass expiry."
                  : "Child has safely returned to campus.";
                type = isLate ? "error" : "success";
             } else if (p.status == 'expired' || p.status == 'completed') {
                title = "Pass Ended";
                body = "The outing pass has expired or was completed.";
                type = "info";
             }

             notifications.add({
                'title': title,
                'body': body,
                'timestamp': p.updatedAt ?? p.validFrom,
                'type': type,
                'isRead': true,
             });
          }

          // Sort by timestamp
          notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          return Column(
             children: [
                // Custom Header
                Padding(
                   padding: const EdgeInsets.all(24),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Text("NOTIFICATIONS", style: TextStyle(color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.bold)),
                          TextButton(
                             onPressed: () {
                                // Mark all read logic would go here
                             }, 
                             child: const Text("Refresh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))
                          )
                      ],
                   ),
                ),
                
                Expanded(
                   child: provider.isLoading 
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : notifications.isEmpty
                         ? const Center(child: Text("No notifications", style: TextStyle(color: AppTheme.textGrey)))
                         : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                               final notif = notifications[index];
                               final type = notif['type'];
                               Color iconColor;
                               IconData icon;

                               switch(type) {
                                  case 'request': iconColor = Colors.orange; icon = Icons.question_mark; break;
                                  case 'success': iconColor = AppTheme.success; icon = Icons.check_circle_outline; break;
                                  case 'error': iconColor = AppTheme.error; icon = Icons.cancel_outlined; break;
                                  case 'warning': iconColor = AppTheme.accent; icon = Icons.warning_amber_rounded; break;
                                  default: iconColor = AppTheme.primary; icon = Icons.notifications_none;
                               }
                               
                               return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GlassyCard(
                                     padding: const EdgeInsets.all(16),
                                     child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                           Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                 shape: BoxShape.circle,
                                                 color: iconColor.withOpacity(0.1),
                                              ),
                                              child: Icon(
                                                 icon,
                                                 color: iconColor,
                                                 size: 20,
                                              ),
                                           ),
                                           const SizedBox(width: 16),
                                           Expanded(
                                              child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                    Row(
                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                       children: [
                                                          Text(
                                                             notif['title'],
                                                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                                          ),
                                                          if (notif['isRead'] == false)
                                                             Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle))
                                                       ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                       notif['body'],
                                                       style: const TextStyle(color: AppTheme.textGrey, height: 1.4),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                       DateFormat('MMM dd, hh:mm a').format(notif['timestamp'].toLocal()),
                                                       style: TextStyle(color: AppTheme.textGrey.withOpacity(0.5), fontSize: 11),
                                                    ),
                                                 ],
                                              ),
                                           )
                                        ],
                                     ),
                                  ),
                               );
                            },
                         ),
                )
             ],
          );
        },
      ),
    );
  }
}
