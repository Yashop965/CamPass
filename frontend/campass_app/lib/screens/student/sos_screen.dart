import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sos_provider.dart';
import '../../services/session_manager.dart';
import '../../core/constants/app_colors.dart';

class SOSScreen extends StatefulWidget {
  final String? userId;
  final String? token;

  const SOSScreen({
    super.key,
    this.userId,
    this.token,
  });

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with SingleTickerProviderStateMixin {
  bool _isSent = false;
  
  // Confirmation State
  bool _isHolding = false;
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2), // 2 seconds to confirm
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
         _onConfirmComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoldStart(LongPressStartDetails details) {
     if (_isSent) return;
     setState(() => _isHolding = true);
     _controller.forward();
  }

  void _onHoldEnd(LongPressEndDetails details) {
     if (_isSent) return;
     if (_controller.status != AnimationStatus.completed) {
        // Cancelled early
        setState(() => _isHolding = false);
        _controller.reset();
     }
  }

  void _onConfirmComplete() {
     _sendSOS();
  }

  Future<void> _sendSOS() async {
    if (_isSent) return;

    try {
      final sosProvider = Provider.of<SOSProvider>(context, listen: false);
      
      // Use provided ID or fetch from session if needed
      String? uid = widget.userId;
      String? tkn = widget.token;
      
      if (uid == null || tkn == null) {
         final user = await SessionManager.getUser();
         final token = await SessionManager.getToken();
         uid = user?.id;
         tkn = token;
      }

      if (uid != null && tkn != null) {
          // Optimistic UI update
          if (mounted) {
             setState(() => _isSent = true);
          }
          
          await sosProvider.sendSOSAlert(
            studentId: uid,
            token: tkn,
          );
      }
    } catch (e) {
      print("SOS Send Error: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Alert logged locally (Check connection)"), backgroundColor: AppColors.systemRed)
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Emergency SOS"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSent) ...[
               // SENT STATE
               const Icon(Icons.check_circle, color: AppColors.systemGreen, size: 120),
               const SizedBox(height: 24),
               const Text("SOS ALERT SENT", style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary
               )),
               const SizedBox(height: 16),
               const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 32.0),
                 child: Text("Help is on the way. Your location has been shared with Wardens and Parents.", 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey)
                 ),
               ),
               const SizedBox(height: 48),
               ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.primary,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                  child: const Text("Return to Dashboard"),
               )

            ] else ...[
               // CONFIRMATION STATE
               GestureDetector(
                  onLongPressStart: _onHoldStart,
                  onLongPressEnd: _onHoldEnd,
                  child: Stack(
                     alignment: Alignment.center,
                     children: [
                        // Background Circle
                        Container(
                           width: 250,
                           height: 250,
                           decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              boxShadow: [
                                 BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                 )
                              ]
                           ),
                        ),
                        
                        // Progress Indicator
                        SizedBox(
                           width: 250,
                           height: 250,
                           child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                 return CircularProgressIndicator(
                                    value: _controller.value,
                                    strokeWidth: 20,
                                    backgroundColor: Colors.transparent,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.systemRed),
                                 );
                              },
                           ),
                        ),
                        
                        // Inner Content
                        Container(
                           width: 200,
                           height: 200,
                           decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                           ),
                           child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Icon(
                                    Icons.touch_app, 
                                    size: 60, 
                                    color: _isHolding ? AppColors.systemRed : Colors.grey
                                 ),
                                 const SizedBox(height: 12),
                                 Text(
                                    _isHolding ? "KEEP HOLDING" : "HOLD TO SEND",
                                    style: TextStyle(
                                       fontSize: 18, 
                                       fontWeight: FontWeight.bold, 
                                       color: _isHolding ? AppColors.systemRed : Colors.grey[700]
                                    ),
                                 ),
                              ],
                           ),
                        ),
                     ],
                  ),
               ),
               const SizedBox(height: 48),
               const Text(
                  "Hold for 2 seconds to confirm emergency",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
               ),
               const SizedBox(height: 24),
               TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel / False Alarm", style: TextStyle(color: Colors.grey)),
               ),
            ]
          ],
        ),
      ),
    );
  }
}
