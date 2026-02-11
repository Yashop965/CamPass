
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primary = Color(0xFF1152D4);
const Color _success = Color(0xFF22C55E);
const Color _danger = Color(0xFFEF4444);
const Color _backgroundLight = Color(0xFFF6F6F8);
const Color _backgroundDark = Color(0xFF101622);

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen>
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
          child: Column(
            children: [
              GuardHeaderWidget(isDark: isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      SystemStatusCard(
                        isDark: isDark,
                        success: _success,
                        pulseController: _pulseController,
                      ),
                      const SizedBox(height: 24),
                      // Primary Scan Area
                      Column(
                        children: [
                          Text(
                            'Ready to Scan',
                            style: textTheme.headlineSmall?.copyWith(
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hold device steady near pass',
                            style: textTheme.bodySmall?.copyWith(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ScanActionButton(
                            primary: _primary,
                            pulseController: _pulseController,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      RecentActivitySection(
                        isDark: isDark,
                        success: _success,
                        danger: _danger,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: GuardBottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (index) => setState(() => _navIndex = index),
        ),
      ),
    );
  }
}

class GuardHeaderWidget extends StatelessWidget {
  final bool isDark;

  const GuardHeaderWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1152D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.security, color: Color(0xFF1152D4)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAMPASS',
                    style: textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Guard Station - North Gate',
                    style: textTheme.labelSmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC2MXp8ghXyPCH1jkFnxPckzljd2sbMpxrvLxW7hgjBlvnNCvc8tz4WO7eYlOtVhZW-PLQqy270GAeoaZ9YX7BCPn1egqI9nTlUkddsc-LuRtrcC2tLbFmAJ6stU9SlOHmG4nLiCmmrn-HgJzFBx7TvlILx9Js2WYPqPok8hExfDByFyKrZGGdhFREL_LwxfezrfjjY0o-BuBovek6kTincbyCPDXoMiciamTho2PxbqsA4__dCFqMsyNhujlj2rxq1fnXQenEO0CQv',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF101622) : _backgroundLight,
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

class SystemStatusCard extends StatelessWidget {
  final bool isDark;
  final Color success;
  final AnimationController pulseController;

  const SystemStatusCard({
    super.key,
    required this.isDark,
    required this.success,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  final scale = 1 + (pulseController.value * 0.6);
                  final opacity = (1 - pulseController.value).clamp(0.0, 1.0);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: success.withOpacity(0.2 * opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                'System Active',
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'v2.4.1',
            style: textTheme.labelSmall?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ScanActionButton extends StatefulWidget {
  final Color primary;
  final AnimationController pulseController;

  const ScanActionButton({
    super.key,
    required this.primary,
    required this.pulseController,
  });

  @override
  State<ScanActionButton> createState() => _ScanActionButtonState();
}

class _ScanActionButtonState extends State<ScanActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: widget.pulseController,
                builder: (context, child) {
                  final scale = 1 + (widget.pulseController.value * 0.4);
                  final opacity = (1 - widget.pulseController.value).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: widget.primary.withOpacity(0.15 * opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: widget.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1152D4), Color(0xFF2563EB)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.white, size: 44),
                    const SizedBox(height: 6),
                    Text(
                      'SCAN',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentActivitySection extends StatelessWidget {
  final bool isDark;
  final Color success;
  final Color danger;

  const RecentActivitySection({
    super.key,
    required this.isDark,
    required this.success,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'View All',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF1152D4),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ScanActivityItem(
              name: 'Sarah Jenkins',
              detail: 'ID #8842 - Just now',
              time: '10:42 AM',
              status: ScanStatus.entry,
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA5NrirNtJb5CP-BBELN4sSftfbSA18x6HSweMKNihLtgyEGQCN9JwZUFgZbiz6kdOtuvlMoTMYBlDU8fupyafupXF7SmIvvPpsfCDYc5VpxjAm6oNJhD8U71gsKSA5ZU4CHOoMoD-Swn8wlpR6CF9DLcGsmC_Js6JvGfuM7tHxxzjA3T1FDUR0E3LVs0H8BMu9mADE8yCClfzekMX6-uwbrrmnnCJxW1y8Y3y6aSzZal77lLvoJ0R4CCFuH4GsZzwBT5sbT6mGRUv6',
            ),
            const SizedBox(height: 10),
            const ScanActivityItem(
              name: 'Marcus Chen',
              detail: 'ID #9021 - 2m ago',
              time: '10:40 AM',
              status: ScanStatus.exit,
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC8_bwQ1TwGd9us8r9KMILE74g3y973sGo5PUKn-PalmaGY8pgmk2zncKdvzmVpxM-btZevTnjnQa6YqLZMIAE96tCu9gJjAyirpwDxu7EofenM6cvsYSlFkcDRhXwa7Mo-l0s79WXgVp-9pHI1gdiMsUodqGgVCbp_R32RV4oopfh4mwFoIm9hKcRnHYDzxDOjzzIlxQtg4JlsDLmfVeevVnWMXMXd6WC4qeyODiLMrwv9_5fVqnWNTBOJ758ABjtlGA3_LhFE73oi',
            ),
            const SizedBox(height: 10),
            const ScanActivityItem(
              name: 'Unknown ID',
              detail: 'Scan Error - 5m ago',
              time: '10:37 AM',
              status: ScanStatus.denied,
            ),
          ],
        ),
      ),
    );
  }
}

enum ScanStatus { entry, exit, denied }

class ScanActivityItem extends StatelessWidget {
  final String name;
  final String detail;
  final String time;
  final ScanStatus status;
  final String? avatarUrl;

  const ScanActivityItem({
    super.key,
    required this.name,
    required this.detail,
    required this.time,
    required this.status,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    Color badgeColor;
    Color badgeBg;
    IconData overlayIcon;
    switch (status) {
      case ScanStatus.entry:
        badgeColor = const Color(0xFF15803D);
        badgeBg = const Color(0xFFDCFCE7);
        overlayIcon = Icons.check;
        break;
      case ScanStatus.exit:
        badgeColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
        badgeBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        overlayIcon = Icons.check;
        break;
      case ScanStatus.denied:
        badgeColor = const Color(0xFFEF4444);
        badgeBg = const Color(0xFFFEE2E2);
        overlayIcon = Icons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status == ScanStatus.denied
            ? (isDark ? const Color(0xFF7F1D1D).withOpacity(0.15) : const Color(0xFFFEE2E2))
            : (isDark ? const Color(0xFF1F2937).withOpacity(0.6) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: status == ScanStatus.denied
              ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA))
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              if (avatarUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    avatarUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_off,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                  ),
                ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: status == ScanStatus.denied ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(overlayIcon, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: textTheme.labelSmall?.copyWith(
                    color: status == ScanStatus.denied
                        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444))
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status == ScanStatus.entry
                      ? 'ENTRY'
                      : status == ScanStatus.exit
                          ? 'EXIT'
                          : 'DENIED',
                  style: textTheme.labelSmall?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: textTheme.labelSmall?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GuardBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GuardBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          _BottomNavItem(
            label: 'Scan',
            icon: Icons.dashboard,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            textTheme: textTheme,
          ),
          _BottomNavItem(
            label: 'Logs',
            icon: Icons.history,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            textTheme: textTheme,
          ),
          _BottomNavItem(
            label: 'Settings',
            icon: Icons.settings,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1152D4) : const Color(0xFF94A3B8);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
