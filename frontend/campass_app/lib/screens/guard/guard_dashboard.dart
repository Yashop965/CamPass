// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guard_provider.dart';
import '../../services/session_manager.dart';
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

  Future<void> _logout() async {
    await SessionManager.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard Dashboard'),
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
      body: Consumer<GuardProvider>(
        builder: (context, guardProvider, _) {
          final stats = guardProvider.getScanStats();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Last Scanned Pass
                if (guardProvider.lastScannedPass != null)
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Last Scanned Pass',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPassDetail('Type',
                              guardProvider.lastScannedPass!.type),
                          _buildPassDetail('Status',
                              guardProvider.lastScannedPass!.status),
                          _buildPassDetail(
                            'Valid Until',
                            guardProvider.lastScannedPass!.validTo
                                .toLocal()
                                .toString()
                                .split('.')[0],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '✓ Pass Verified',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
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
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Invalid',
                      stats['invalid'].toString(),
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Errors',
                      stats['errors'].toString(),
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scan Button
                ElevatedButton.icon(
                  onPressed: () => _openScanner(),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Pass'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Scan History
                const Text(
                  'Recent Scans',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (guardProvider.scannedHistory.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No scans yet',
                        style: TextStyle(color: Colors.grey[600]),
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

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: isValid ? Colors.green[50] : Colors.red[50],
                        child: ListTile(
                          leading: Icon(
                            isValid ? Icons.check_circle : Icons.cancel,
                            color: isValid ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            scan['passType'] ?? 'Unknown Pass',
                          ),
                          subtitle: Text(
                            scan['timestamp']
                                .toString()
                                .split('.')[0],
                          ),
                          trailing: Chip(
                            label: Text(
                              scan['status'].toUpperCase(),
                            ),
                            backgroundColor: isValid
                                ? Colors.green[100]
                                : Colors.red[100],
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
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      guardProvider.errorMessage!,
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPassDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
            style: const TextStyle(fontSize: 12, color: Colors.grey),
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
}
