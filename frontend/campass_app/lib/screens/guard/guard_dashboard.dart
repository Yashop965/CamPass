// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glassy_card.dart';
import '../../providers/guard_provider.dart';
import 'barcode_scanner_screen.dart';
import 'guard_profile_screen.dart';

class GuardDashboard extends StatefulWidget {
  final String guardId;
  final String token;
  const GuardDashboard({
    super.key,
    required this.guardId,
    required this.token,
  });

  @override
  State<GuardDashboard> createState() => _GuardDashboardState();
}

class _GuardDashboardState extends State<GuardDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final guardProvider =
          Provider.of<GuardProvider>(context, listen: false);
      guardProvider.loadScanHistory(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Guard Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuardProfileScreen()),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: GradientBackground(
        child: Consumer<GuardProvider>(
          builder: (context, guardProvider, _) {
            final stats = guardProvider.getScanStats();
  
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 120, 16, 16), // Top padding for AppBar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Last Scanned Pass
                  if (guardProvider.lastScannedPass != null)
                    GlassyCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Last Scanned Pass',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.success,
                                  size: 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildPassDetail('Student',
                                guardProvider.lastScannedPass!.studentName ?? 'Unknown'),
                            _buildPassDetail('Type',
                                guardProvider.lastScannedPass!.type),
                            _buildPassDetail('Status',
                                guardProvider.lastScannedPass!.status.toUpperCase()),
                            if (guardProvider.lastScannedPass!.exitTime != null)
                              _buildPassDetail('Exited At',
                                DateFormat('hh:mm a').format(guardProvider.lastScannedPass!.exitTime!.toLocal())),
                            if (guardProvider.lastScannedPass!.entryTime != null)
                              _buildPassDetail('Entered At',
                                DateFormat('hh:mm a').format(guardProvider.lastScannedPass!.entryTime!.toLocal())),
                            _buildPassDetail(
                              'Valid Until',
                              DateFormat('MMM dd, hh:mm a').format(guardProvider.lastScannedPass!.validTo.toLocal()),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: _getStatusColor(guardProvider.lastScannedPass!),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusText(guardProvider.lastScannedPass!),
                                  style: TextStyle(
                                    color: _getStatusColor(guardProvider.lastScannedPass!),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
  
                  // Scan Statistics
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                        'Total Scans',
                        stats['totalScans'].toString(),
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Verified',
                        stats['verified'].toString(),
                        AppTheme.success,
                      ),
                      _buildStatCard(
                        'Invalid',
                        stats['invalid'].toString(),
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Errors',
                        stats['errors'].toString(),
                        AppTheme.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
  
                  // Scan Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                         BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
                      ]
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _openScanner(),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Pass'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
  
                  // Scan History
                  const Text(
                    'Recent Scans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  if (guardProvider.scannedHistory.isEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No scans yet',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: guardProvider.scannedHistory.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        final scan = guardProvider.scannedHistory[index];
                        final isValid = scan['status'] == 'verified';
  
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GlassyCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                isValid ? Icons.check_circle : Icons.cancel,
                                color: isValid ? AppTheme.success : AppTheme.error,
                              ),
                              title: Text(
                                '${scan['studentName'] ?? 'Student'} - ${scan['passType'] ?? 'Pass'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${scan['scanType']?.toString().toUpperCase() ?? 'SCAN'} • ${DateFormat('MMM dd, hh:mm a').format(DateTime.parse(scan['timestamp'].toString()))}',
                                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isValid ? AppTheme.success : AppTheme.error).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: (isValid ? AppTheme.success : AppTheme.error).withOpacity(0.5))
                                ),
                                child: Text(
                                  scan['status'].toUpperCase(),
                                  style: TextStyle(color: isValid ? AppTheme.success : AppTheme.error, fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
  
                  // Error Message
                  if (guardProvider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error)
                      ),
                      child: Text(
                        guardProvider.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildPassDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
          Text(value, style: const TextStyle(color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return GlassyCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Future<void> _openScanner() async {
    final guardProvider =
        Provider.of<GuardProvider>(context, listen: false);

    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode != null && barcode.isNotEmpty) {
      final success =
          await guardProvider.scanPass(barcode, widget.token);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Pass verified'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Invalid pass'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(dynamic pass) {
    if (pass.status == 'entered') {
      if (pass.entryTime != null && pass.entryTime!.isAfter(pass.validTo)) {
        return AppTheme.error; // Late entry
      }
      return AppTheme.success; // Returned on time
    }
    if (pass.status == 'exited') return Colors.orange; // Student is outside
    return AppTheme.primary; // Active/Approved but not yet used
  }

  String _getStatusText(dynamic pass) {
    if (pass.status == 'entered') {
      if (pass.entryTime != null && pass.entryTime!.isAfter(pass.validTo)) {
        return 'LATE ENTRY';
      }
      return 'RETURNED';
    }
    if (pass.status == 'exited') return 'OUTSIDE';
    return 'VERIFIED';
  }
}
