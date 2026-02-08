import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/parent_provider.dart';
import '../../models/pass_model.dart';
import '../../services/pass_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_error_dialog.dart';

class ReviewRequestScreen extends StatefulWidget {
  final PassModel pass;
  final String reviewerId;
  final String token;
  final bool isWarden;

  const ReviewRequestScreen({
    super.key,
    required this.pass,
    required this.reviewerId,
    required this.token,
    this.isWarden = false,
  });

  @override
  State<ReviewRequestScreen> createState() => _ReviewRequestScreenState();
}

class _ReviewRequestScreenState extends State<ReviewRequestScreen> {
  final PassService _passService = PassService();
  bool _isLoading = false;

  Future<void> _processRequest(bool approve) async {
    setState(() => _isLoading = true);
    try {
      if (approve) {
        if (widget.isWarden) {
           await _passService.approveByWarden(widget.pass.id, widget.token);
        } else {
           // Use ParentProvider which handles token automatically via ApiClient
           final parentProvider = Provider.of<ParentProvider>(context, listen: false);
           final success = await parentProvider.approvePass(widget.pass.id, widget.token);
           
           if (!success) {
             throw Exception(parentProvider.errorMessage ?? "Approval failed");
           }
        }
      } else {
         // Rejection logic with Reason Dialog
         if (!mounted) return;
         
         final reasonController = TextEditingController();
         final reason = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
               backgroundColor: AppTheme.surface,
               title: const Text("Refuse Request", style: TextStyle(color: Colors.white)),
               content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     const Text("Please provide a reason for rejection:", style: TextStyle(color: AppTheme.textGrey)),
                     const SizedBox(height: 16),
                     TextField(
                        controller: reasonController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                           hintText: "Reason (e.g., Late return time)",
                           hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                           filled: true,
                           fillColor: Colors.white.withOpacity(0.05),
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                     ),
                  ],
               ),
               actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context), 
                     child: const Text("CANCEL", style: TextStyle(color: AppTheme.textGrey))
                  ),
                  TextButton(
                     onPressed: () => Navigator.pop(context, reasonController.text.trim()), 
                     child: const Text("REJECT", style: TextStyle(color: AppTheme.accent))
                  ),
               ],
            ),
         );

         if (reason == null || reason.isEmpty) {
            setState(() => _isLoading = false);
            return; // User cancelled or didn't provide reason
         }

         if (widget.isWarden) {
            await _passService.rejectPass(widget.pass.id, reason, widget.token);
         } else {
            final parentProvider = Provider.of<ParentProvider>(context, listen: false);
            final success = await parentProvider.rejectPass(widget.pass.id, reason, widget.token);
            if (!success) {
               throw Exception(parentProvider.errorMessage ?? "Rejection failed");
            }
         }
      }
      
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to refresh
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(approve ? 'Request Approved' : 'Request Rejected'),
        backgroundColor: approve ? AppTheme.success : AppTheme.accent,
      ));
    } catch (e) {
      if (!mounted) return;
      CustomErrorDialog.show(context, message: 'Process failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.isWarden ? 'Warden Review' : 'Parent Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GlassyCard(
              child: Column(
                children: [
                   Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: AppTheme.primary.withOpacity(0.1),
                         border: Border.all(color: AppTheme.primary.withOpacity(0.5))
                      ),
                      child: const Icon(Icons.assignment_ind_outlined, size: 48, color: AppTheme.primary),
                   ),
                   const SizedBox(height: 16),
                   Text(
                      widget.pass.studentName ?? 'Student',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Text(
                      "Requesting ${widget.pass.type.toUpperCase()}",
                      style: const TextStyle(color: AppTheme.textGrey, letterSpacing: 1),
                   ),
                   const Divider(color: Colors.white12, height: 48),
                   
                   _buildInfoRow(Icons.calendar_today, "Date", dateFormat.format(widget.pass.validFrom.toLocal())),
                   const SizedBox(height: 16),
                   _buildInfoRow(Icons.access_time, "Time", "${timeFormat.format(widget.pass.validFrom.toLocal())} - ${timeFormat.format(widget.pass.validTo.toLocal())}"),
                   const SizedBox(height: 16),
                   _buildInfoRow(Icons.description_outlined, "Purpose", widget.pass.purpose ?? 'N/A'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("IGNORE", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _processRequest(false),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.red.withOpacity(0.8),
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("DECLINE", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: "APPROVE",
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: () => _processRequest(true),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
     return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Icon(icon, color: AppTheme.textGrey, size: 20),
           const SizedBox(width: 16),
           Expanded(
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
                 ],
              ),
           )
        ],
     );
  }
}
