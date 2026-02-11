import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF1152D4);
  static const _success = Color(0xFF22C55E);
  static const _danger = Color(0xFFEF4444);
  static const _backgroundLight = Color(0xFFF6F6F8);
  static const _backgroundDark = Color(0xFF101622);

  late final AnimationController _pulseController;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTheme = Theme.of(context);
    final textTheme = GoogleFonts.lexendTextTheme(baseTheme.textTheme);

    return Theme(
      data: baseTheme.copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: isDark ? _backgroundDark : _backgroundLight,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  ParentHeaderWidget(
                    isDark: isDark,
                    danger: _danger,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pending Requests Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending Requests',
                                style: textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '2 New',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: _primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const PendingRequestCard(),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 16,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F2937).withOpacity(0.6)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Live Location Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Live Location',
                                style: textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'View Full Map',
                                style: textTheme.labelSmall?.copyWith(
                                  color: _primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LiveLocationCard(
                            isDark: isDark,
                            primary: _primary,
                            success: _success,
                            pulseController: _pulseController,
                          ),
                          const SizedBox(height: 24),

                          // Recent Activity Section
                          Text(
                            'Recent Activity',
                            style: textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const ActivityTimelineWidget(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: ParentBottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (index) => setState(() => _navIndex = index),
        ),
      ),
    );
  }
}

class ParentHeaderWidget extends StatelessWidget {
  final bool isDark;
  final Color danger;

  const ParentHeaderWidget({
    super.key,
    required this.isDark,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: textTheme.bodySmall?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Alex Johnson',
                style: textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                  ),
                  onPressed: () {},
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PendingRequestCard extends StatelessWidget {
  const PendingRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF1152D4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : Colors.white,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAcjZkGrXC5OGPOovoBssqxGQMe9n6hD5bO_avxtdm06M9NYifKwgOTCOnUJtDKMgr8YJ0EwU-bbHvs97kn1WgLd9YyyLONXZHVXhAV4flPixdssYxVO1xih_NfLHpacAPaYYdooPFQ2C3YLBl5sVtS4Cu_CRAjnJZNYMFSf0kjlNVfakvhAQEaDIJCcq4GjHdl0mCsVgPU4KR4MUtJmvZphMMnSiE4rn9KGHvu2fXmyrcQxVSIUQKpIQlfBv-XpR3-mvg7xuWXnUj4',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sarah Johnson',
                              style: textTheme.titleSmall?.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Requesting outing',
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '2m ago',
                        style: textTheme.labelSmall?.copyWith(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _InfoRow(
                  icon: Icons.place,
                  title: 'Central Library',
                  subtitle: 'Study Group',
                ),
                const SizedBox(height: 12),
                const _InfoRow(
                  icon: Icons.schedule,
                  title: '4:00 PM - 6:00 PM',
                  subtitle: 'Today',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1152D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0xFF1152D4).withOpacity(0.25),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1152D4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1152D4), size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LiveLocationCard extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color success;
  final AnimationController pulseController;

  const LiveLocationCard({
    super.key,
    required this.isDark,
    required this.primary,
    required this.success,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Map
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDtja0VcSeN1JWYxR5tW6lPSxII4pvTX99_Z3NbZMOyRS1HMKGbuYhNtd_Qi3oAjTCxqwzm9Jkz_l97knmQJZ8yGPSWSDNkm41dBHbeYiNw_bnLR_FAFXZXGcWnL2il-9PNUyfhyhcFlpXTnaTAHXti78N_1082t0cvT50H8KdUuIyq4g6mblr3EilqiHCT_9T0C8KJkeoq0l0Xi7cJfp5pt8yB3jRPGRLbMR7sq5QuOVSiazKa5bUe33gXaB2NI46HYlTBWQkyX62k',
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      final scale = 1 + (pulseController.value * 0.4);
                      final opacity = (1 - pulseController.value).clamp(0.0, 1.0);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.2 * opacity),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F2937) : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuALtI7b22qg6RBJUBtNEl9zVBWvj2_Z0Qcya_JoCRK3d-0n9DqDG32e94KaHK3Uvfn3tcBaTRkOoNZ261SaQS7lq_rECr_mFLWciH29MESGRycgP-238nd9Ya8xyNN-e_Ul47l9BvuJyVs5drzkeZEc5pCzGhO3EcAOdU1H4O84P85u5CjIUfwT_CwAyx7WLvZTB0-ihJ-K4IhmFZ3csmrkegzAidpjSuhaZjMIF8JqbJ-GXITd5G9KaNwWWbNYWoZ5BYTWpR9v1qt2',
                                    width: 34,
                                    height: 34,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Liam is at Soccer Practice',
                        style: textTheme.labelSmall?.copyWith(
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Info Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoPill(
                  icon: Icons.update,
                  title: 'Last Updated',
                  value: 'Just now',
                  isDark: isDark,
                  iconColor: const Color(0xFF64748B),
                  iconBackground: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
                _InfoPill(
                  icon: Icons.battery_full,
                  title: 'Battery',
                  value: '84%',
                  isDark: isDark,
                  iconColor: success,
                  iconBackground: isDark ? success.withOpacity(0.2) : const Color(0xFFDCFCE7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;
  final Color iconColor;
  final Color iconBackground;

  const _InfoPill({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActivityTimelineWidget extends StatelessWidget {
  const ActivityTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ActivityTimelineItem(
          icon: Icons.school,
          title: 'School Arrival',
          subtitle: 'Liam arrived safely at 8:15 AM',
          color: Color(0xFF1152D4),
          showLine: true,
        ),
        ActivityTimelineItem(
          icon: Icons.check_circle,
          title: 'Outing Completed',
          subtitle: 'Sarah returned home yesterday at 5:30 PM',
          color: Color(0xFF22C55E),
          showLine: true,
        ),
        ActivityTimelineItem(
          icon: Icons.verified_user,
          title: 'Request Approved',
          subtitle: 'You approved Sarah\'s request to Mall',
          color: Color(0xFF94A3B8),
          showLine: false,
        ),
      ],
    );
  }
}

class ActivityTimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool showLine;

  const ActivityTimelineItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.only(top: 4),
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ParentBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ParentBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            label: 'Home',
            icon: Icons.dashboard,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            textTheme: textTheme,
          ),
          _NavItem(
            label: 'Family',
            icon: Icons.people,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            textTheme: textTheme,
          ),
          _NavItem(
            label: 'History',
            icon: Icons.history,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            textTheme: textTheme,
          ),
          _NavItem(
            label: 'Settings',
            icon: Icons.settings,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1152D4) : const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
