import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glassy_card.dart';
import 'package:intl/intl.dart';
import '../../utils/api_client.dart';
import 'dart:convert';
import '../../models/pass_model.dart';

class StudentNotificationsScreen extends StatefulWidget {
  final String userId;
  final String token;

  const StudentNotificationsScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      // For now, we derive notifications from Pass History
      // A better approach would be a dedicated notifications endpoint
      final response = await _apiClient.get('/api/passes/user/${widget.userId}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final passes = data.map((json) => PassModel.fromJson(json)).toList();
        
        List<Map<String, dynamic>> derivedNotifications = [];

        for (var pass in passes) {
           // Create a notification for pass status changes
           String title = "Pass Update";
           String body = "Your pass request is ${pass.status}.";
           String type = "info";
           
           if (pass.status == 'approved' || pass.status == 'approved_parent' || pass.status == 'approved_warden') {
              title = "Pass Approved";
              body = "Your ${pass.type} pass to ${pass.purpose ?? 'destination'} has been approved.";
              type = "success";
           } else if (pass.status == 'rejected') {
              title = "Pass Rejected";
              body = "Your ${pass.type} pass request was rejected.";
              type = "error";
           } else if (pass.status == 'active') {
              title = "Pass Active";
              body = "Your pass is now active.";
              type = "success";
           } else if (pass.status == 'pending') {
               // Maybe skip pending for notifications unless it was just created
               continue;
           }
           
           derivedNotifications.add({
              'title': title,
              'body': body,
              'timestamp': pass.updatedAt ?? pass.validFrom,
              'type': type,
              'isRead': true, // Mock read status
           });
        }
        
        // Sort by timestamp desc
        derivedNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        
        if (mounted) {
           setState(() {
              _notifications = derivedNotifications;
           });
        }
      }
    } catch (e) {
      print("Error loading student notifications: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("NOTIFICATIONS", style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _notifications.isEmpty
             ? const Center(child: Text("No notifications", style: TextStyle(color: AppTheme.textGrey)))
             : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 16), // Adjust padding for AppBar
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                   final notif = _notifications[index];
                   Color iconColor;
                   IconData icon;
                   
                   switch(notif['type']) {
                      case 'success':
                         iconColor = AppTheme.success;
                         icon = Icons.check_circle_outline;
                         break;
                      case 'error':
                         iconColor = AppTheme.error;
                         icon = Icons.cancel_outlined;
                         break;
                      default:
                         iconColor = AppTheme.primary;
                         icon = Icons.info_outline;
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
                                        Text(
                                           notif['title'],
                                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
      ),
    );
  }
}
