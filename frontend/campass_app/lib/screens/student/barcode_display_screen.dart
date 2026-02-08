// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/pass_model.dart';
import '../../services/pass_service.dart';
import '../../services/session_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import 'package:intl/intl.dart';

class BarcodeDisplayScreen extends StatefulWidget {
  final PassModel? pass; // Optional initial pass (deprecated focus)
  final String? userId;
  const BarcodeDisplayScreen({super.key, this.pass, this.userId});

  @override
  State<BarcodeDisplayScreen> createState() => _BarcodeDisplayScreenState();
}

class _BarcodeDisplayScreenState extends State<BarcodeDisplayScreen> {
  List<PassModel> passes = [];
  bool loading = true;
  final PassService _passService = PassService();
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await SessionManager.getToken();
    final userId = widget.userId ?? (await SessionManager.getUser())?.id;
    
    if (token != null && userId != null) {
      try {
        final list = await _passService.getPassesForUser(userId, token);
        if (list.isNotEmpty) {
           // Sort by date descending
           list.sort((a, b) => b.validFrom.compareTo(a.validFrom));
           
           if(mounted) {
             setState(() {
               passes = list;
               loading = false;
             });
           }
        } else {
           if(mounted) setState(() => loading = false);
        }
      } catch (e) {
         print("Error loading passes: $e");
         if(mounted) setState(() => loading = false);
      }
    } else {
       if(mounted) setState(() => loading = false);
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
       return const Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
       );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
         title: const Text('My Digital Passes'),
         backgroundColor: Colors.transparent,
         elevation: 0,
         centerTitle: true,
      ),
      body: Column(
        children: [
           const SizedBox(height: 20),
           const Hero(
             tag: 'menu_icon_Show QR',
             child: Icon(Icons.qr_code_2, size: 40, color: AppTheme.success),
           ),
           const SizedBox(height: 20),
           
           Expanded(
             child: passes.isEmpty 
               ? Center(child: _buildEmptyState()) 
               : PageView.builder(
                   controller: _pageController,
                   itemCount: passes.length,
                   onPageChanged: (index) => setState(() => _currentPage = index),
                   itemBuilder: (context, index) {
                     return _buildPassCard(passes[index]);
                   },
                 ),
           ),
           
           if (passes.isNotEmpty) ...[
             const SizedBox(height: 20),
             _buildPageIndicator(),
             const SizedBox(height: 40),
           ]
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return const Padding(
       padding: EdgeInsets.all(32.0),
       child: GlassyCard(
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.textGrey),
                SizedBox(height: 16),
                Text("No active passes found.", style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 8),
                Text("Generate a new pass to see it here.", style: TextStyle(color: AppTheme.textGrey), textAlign: TextAlign.center),
             ],
          ),
       ),
     );
  }
  
  Widget _buildPageIndicator() {
     return Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: List.generate(passes.length.clamp(0, 10), (index) {
          bool isActive = _currentPage == index;
          return AnimatedContainer(
             duration: const Duration(milliseconds: 300),
             margin: const EdgeInsets.symmetric(horizontal: 4),
             width: isActive ? 12 : 8,
             height: 8,
             decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.white24,
                borderRadius: BorderRadius.circular(4)
             ),
          );
       }),
     );
  }

  Widget _buildPassCard(PassModel pass) {
     return AnimatedBuilder(
       animation: _pageController,
       builder: (context, child) {
          return Center(child: child);
       },
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 8),
         child: GlassyCard(
           padding: const EdgeInsets.all(0),
           child: SingleChildScrollView(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 // Header Strip
                 Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        gradient: _getStatusGradient(pass.status ?? 'pending'),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Text(
                       (pass.type ?? 'OUTING').toUpperCase(),
                       textAlign: TextAlign.center,
                       style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontSize: 18
                       ),
                    ),
                 ),
                 
                 Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                       children: [
                          // Barcode visualization
                          Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)
                             ),
                             child: QrImageView(
                                data: pass.barcode,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                             ),
                          ),
                          const SizedBox(height: 8),
                          Text(pass.barcode, style: const TextStyle(color: AppTheme.textGrey, letterSpacing: 2)),
                          
                          const Divider(color: Colors.white24, height: 32),
                          
                          _buildInfoRow("PURPOSE", pass.purpose ?? 'N/A'),
                          const SizedBox(height: 12),
                          _buildInfoRow("VALID FROM", DateFormat('MMM dd, hh:mm a').format(pass.validFrom.toLocal())),
                          const SizedBox(height: 12),
                          _buildInfoRow("VALID TO", DateFormat('MMM dd, hh:mm a').format(pass.validTo.toLocal())),
                          
                          const SizedBox(height: 24),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             decoration: BoxDecoration(
                                color: _getStatusColor(pass.status ?? 'pending').withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: _getStatusColor(pass.status ?? 'pending')),
                             ),
                             child: Text(
                                (pass.status ?? 'PENDING').toUpperCase(),
                                style: TextStyle(
                                   color: _getStatusColor(pass.status ?? 'pending'),
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: 2
                                ),
                             ),
                          )
                       ],
                    ),
                 )
               ],
             ),
           ),
         ),
       ),
     );
  }
  
  Color _getStatusColor(String status) {
     switch(status.toLowerCase().trim()) {
        case 'active': return AppTheme.success;
        case 'approved': return AppTheme.success;
        case 'approved_parent': return Colors.yellow;
        case 'approved_warden': return AppTheme.success;
        case 'rejected': return AppTheme.accent;
        case 'completed': return AppTheme.textGrey;
        default: return Colors.orange;
     }
  }

  LinearGradient _getStatusGradient(String status) {
     switch(status.toLowerCase().trim()) {
        case 'active': 
        case 'approved': 
        case 'approved_warden': 
           return AppTheme.primaryGradient;
        case 'rejected': 
           return const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFFFF0000)]);
        default: 
           return const LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
     } 
  }
  
  Widget _buildInfoRow(String label, String value) {
     return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
           Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        ],
     );
  }
}
