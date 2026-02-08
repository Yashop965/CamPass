// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'manage_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String adminId;
  final String token;
  const AdminDashboard({
    super.key,
    required this.adminId,
    required this.token,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider =
          Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllUsers(widget.token);
      adminProvider.loadSystemLogs(widget.token);
      adminProvider.loadAllSOSAlerts(widget.token);
      adminProvider.loadGeofenceViolations(widget.token);
      adminProvider.calculateStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Violations',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        switch (_selectedIndex) {
          case 0:
            return _buildOverviewTab(adminProvider);
          case 1:
            return _buildUsersTab(adminProvider);
          case 2:
            return _buildSOSAlertsTab(adminProvider);
          case 3:
            return _buildViolationsTab(adminProvider);
          default:
            return _buildOverviewTab(adminProvider);
        }
      },
    );
  }

  Widget _buildOverviewTab(AdminProvider adminProvider) {
    final stats = adminProvider.systemStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // System Health
          Card(
            elevation: 2,
            color: Colors.green[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Status',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'All Systems Operational',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatTile(
                'Total Users',
                stats['totalUsers']?.toString() ?? '0',
                Colors.blue,
                Icons.people,
              ),
              _buildStatTile(
                'Students',
                stats['students']?.toString() ?? '0',
                Colors.cyan,
                Icons.school,
              ),
              _buildStatTile(
                'Parents',
                stats['parents']?.toString() ?? '0',
                Colors.purple,
                Icons.family_restroom,
              ),
              _buildStatTile(
                'Staff',
                stats['staff']?.toString() ?? '0',
                Colors.orange,
                Icons.badge,
              ),
              _buildStatTile(
                'Active SOS',
                stats['activeSOSAlerts']?.toString() ?? '0',
                Colors.red,
                Icons.emergency,
              ),
              _buildStatTile(
                'Violations',
                stats['geofenceViolations']?.toString() ?? '0',
                Colors.amber,
                Icons.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedIndex = 1),
            icon: const Icon(Icons.person_add),
            label: const Text('Manage Users'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedIndex = 2),
            icon: const Icon(Icons.emergency),
            label: const Text('Monitor Alerts'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.red,
            ),
          ),

          // Error Message
          if (adminProvider.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                adminProvider.errorMessage!,
                style: TextStyle(color: Colors.red[900]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminProvider adminProvider) {
    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ManageUsersScreen(
      token: widget.token,
      adminId: widget.adminId,
    );
  }

  Widget _buildSOSAlertsTab(AdminProvider adminProvider) {
    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final alerts = adminProvider.allSOSAlerts;

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            const Text('No active SOS alerts'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final sos = alerts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.red[50],
          child: ListTile(
            leading: Icon(Icons.emergency, color: Colors.red[700]),
            title: const Text('🚨 SOS Alert'),
            subtitle: Text(
              'Student: ${sos['studentName'] ?? 'Unknown'}\n${sos['createdAt']?.toString().split('.')[0] ?? 'Unknown time'}',
            ),
            trailing: Chip(
              label: Text(sos['status'] ?? 'Active'),
              backgroundColor: sos['status'] == 'resolved'
                  ? Colors.green[100]
                  : Colors.red[100],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViolationsTab(AdminProvider adminProvider) {
    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final violations = adminProvider.geofenceViolations;

    if (violations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            const Text('No geofence violations'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: violations.length,
      itemBuilder: (context, index) {
        final violation = violations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.orange[50],
          child: ListTile(
            leading: Icon(Icons.warning, color: Colors.orange[700]),
            title: Text(
              violation['studentName'] ?? 'Unknown Student',
            ),
            subtitle: Text(
              'Outside campus since ${violation['timestamp']?.toString().split('.')[0] ?? 'Unknown'}',
            ),
          ),
        );
      },
    );
  }
}
