import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primary = Color(0xFF1152D4);
const Color _backgroundLight = Color(0xFFF6F6F8);
const Color _backgroundDark = Color(0xFF101622);
const Color _cardDark = Color(0xFF151B2B);
const Color _borderLight = Color(0xFFE2E8F0);
const Color _borderDark = Color(0xFF1F2937);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barController;
  late final Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );
    _barController.forward();
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.lexendTextTheme(theme.textTheme),
      ),
      child: Scaffold(
        backgroundColor: isDark ? _backgroundDark : _backgroundLight,
        bottomNavigationBar: AdminBottomNavigation(isDark: isDark),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: 72,
              titleSpacing: 20,
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: SizedBox(
                width: double.infinity,
                child: AdminHeader(isDark: isDark),
              ),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? _cardDark : Colors.white).withOpacity(0.9),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? _borderDark : _borderLight,
                        ),
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Text(
                      'Good Morning, Admin',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Here is what is happening in your system today.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metrics horizontal scroll
                    MetricsHorizontalSection(
                      isDark: isDark,
                      metrics: const [
                        MetricCardData(
                          icon: Icons.group,
                          value: '1,248',
                          label: 'Active Users',
                          iconColor: _primary,
                          iconBackground: Color(0xFFEFF6FF),
                          growth: '12%',
                        ),
                        MetricCardData(
                          icon: Icons.pending_actions,
                          value: '24',
                          label: 'Pending Approvals',
                          iconColor: Color(0xFFF97316),
                          iconBackground: Color(0xFFFFEDD5),
                        ),
                        MetricCardData(
                          icon: Icons.directions_walk,
                          value: '342',
                          label: 'Total Outings',
                          iconColor: Color(0xFFA855F7),
                          iconBackground: Color(0xFFF3E8FF),
                          growth: '5%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Outing activity chart
                    OutingActivityChart(
                      isDark: isDark,
                      animation: _barAnimation,
                    ),
                    const SizedBox(height: 24),

                    // User demographics chart
                    UserDemographicsChart(isDark: isDark),
                    const SizedBox(height: 24),

                    // Quick actions
                    QuickActionsSection(isDark: isDark),
                    const SizedBox(height: 24),

                    // Recent users list
                    RecentUsersList(isDark: isDark),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  final bool isDark;

  const AdminHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CAMPASS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: titleColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'System Administration',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _NotificationButton(isDark: isDark),
            const SizedBox(width: 12),
            _AdminAvatar(isDark: isDark),
          ],
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool isDark;

  const _NotificationButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark ? _cardDark : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  final bool isDark;

  const _AdminAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuApmw-L78XILSY3WTBAyR_xi5dO-XV1qRSrlo7QIw8sPYUmWz-JjAExJl2K2yCMSgbO4EYDoXVIoAfesffOAcd-qAFI6FYa6NbfAHQPR-LF15tDYtM6i654fWtVenjsNegzcUAr3lXHIW92ikVmwpcaFHk2zaZDA3RZCyZ5Yh7dw7_1h_EDp-xs9eAjzpPNopAPnF5y9u0HgtjVNxmk4KWQce_ki4H0yYdXnE4XHBHqoH9hD2NMm-ioJ-90ci6deKOUdWMoBQ-s1Ogw',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MetricsHorizontalSection extends StatelessWidget {
  final List<MetricCardData> metrics;
  final bool isDark;

  const MetricsHorizontalSection({
    super.key,
    required this.metrics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return MetricCard(
            data: metrics[index],
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final MetricCardData data;
  final bool isDark;

  const MetricCard({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? _cardDark : Colors.white;
    final borderColor = isDark ? _borderDark : _borderLight;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final iconBg = isDark ? data.iconBackground.withOpacity(0.2) : data.iconBackground;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  data.icon,
                  color: data.iconColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (data.growth != null)
                _GrowthBadge(
                  value: data.growth!,
                  isDark: isDark,
                ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  final String value;
  final bool isDark;

  const _GrowthBadge({
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF14532D).withOpacity(0.35) : const Color(0xFFDCFCE7);
    final fg = isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_upward,
            size: 10,
            color: fg,
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class OutingActivityChart extends StatelessWidget {
  final bool isDark;
  final Animation<double> animation;

  const OutingActivityChart({
    super.key,
    required this.isDark,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? _cardDark : Colors.white;
    final borderColor = isDark ? _borderDark : _borderLight;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outing Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Past 7 Days',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              _ChartToggle(isDark: isDark),
            ],
          ),
          const SizedBox(height: 16),
          // Bar chart
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return _BarChart(
                  animationValue: animation.value,
                  isDark: isDark,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisLabel('Mon'),
              _AxisLabel('Tue'),
              _AxisLabel('Wed'),
              _AxisLabel('Thu'),
              _AxisLabel('Fri'),
              _AxisLabel('Sat'),
              _AxisLabel('Sun'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartToggle extends StatelessWidget {
  final bool isDark;

  const _ChartToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0F172A).withOpacity(0.5) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              'Week',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Month',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;

  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF94A3B8);

    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final double animationValue;
  final bool isDark;

  const _BarChart({
    required this.animationValue,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const baseHeights = [0.40, 0.65, 0.50, 0.80, 0.60, 0.90, 0.75];
    const innerHeights = [0.60, 0.70, 0.40, 0.90, 0.50, 0.85, 0.65];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(baseHeights.length, (index) {
            final base = baseHeights[index];
            final inner = innerHeights[index];

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: constraints.maxHeight * base,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(isDark ? 0.20 : 0.12),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      Container(
                        height: constraints.maxHeight * base * inner * animationValue,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.9),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class UserDemographicsChart extends StatelessWidget {
  final bool isDark;

  const UserDemographicsChart({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? _cardDark : Colors.white;
    final borderColor = isDark ? _borderDark : _borderLight;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final segments = [
      const DonutSegment(0.60, _primary),
      const DonutSegment(0.30, Color(0xFF60A5FA)),
      DonutSegment(0.10, isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Demographics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: DonutChartPainter(
                        segments: segments,
                        backgroundColor:
                            isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '1.2k',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Users',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _LegendRow(
                      color: _primary,
                      label: 'Students',
                      value: '60%',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: const Color(0xFF60A5FA),
                      label: 'Parents',
                      value: '30%',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      label: 'Staff',
                      value: '10%',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isDark;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final valueColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  final bool isDark;

  const QuickActionsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Student',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text(
                  'Add Parent',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(
                    color: _primary.withOpacity(isDark ? 0.4 : 0.2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isDark ? _cardDark : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RecentUsersList extends StatelessWidget {
  final bool isDark;

  const RecentUsersList({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? _cardDark : Colors.white;
    final borderColor = isDark ? _borderDark : _borderLight;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    const users = [
      RecentUser(
        initials: 'JS',
        name: 'James Smith',
        roleLine: 'Student | ID: 2024001',
        status: 'Active',
        avatarBackground: Color(0xFFDBEAFE),
        avatarText: _primary,
        statusBackground: Color(0xFFDCFCE7),
        statusText: Color(0xFF15803D),
      ),
      RecentUser(
        initials: 'ML',
        name: 'Mary Lane',
        roleLine: 'Parent | ID: P-8821',
        status: 'Pending',
        avatarBackground: Color(0xFFF3E8FF),
        avatarText: Color(0xFF7C3AED),
        statusBackground: Color(0xFFFEF9C3),
        statusText: Color(0xFFA16207),
      ),
      RecentUser(
        initials: 'RK',
        name: 'Robert King',
        roleLine: 'Student | ID: 2024045',
        status: 'Active',
        avatarBackground: Color(0xFFDBEAFE),
        avatarText: _primary,
        statusBackground: Color(0xFFDCFCE7),
        statusText: Color(0xFF15803D),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Users',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
            itemBuilder: (context, index) {
              return RecentUserItem(
                user: users[index],
                isDark: isDark,
              );
            },
          ),
        ],
      ),
    );
  }
}

class RecentUserItem extends StatelessWidget {
  final RecentUser user;
  final bool isDark;

  const RecentUserItem({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final avatarBg = isDark ? user.avatarBackground.withOpacity(0.25) : user.avatarBackground;
    final statusBg = isDark ? user.statusBackground.withOpacity(0.25) : user.statusBackground;
    final statusText = isDark ? user.statusText.withOpacity(0.9) : user.statusText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: user.avatarText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.roleLine,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBottomNavigation extends StatelessWidget {
  final bool isDark;

  const AdminBottomNavigation({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final navColor = isDark ? _cardDark : Colors.white;
    final borderColor = isDark ? _borderDark : _borderLight;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        decoration: BoxDecoration(
          color: navColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.dashboard,
                      label: 'Home',
                      active: true,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.people,
                      label: 'Users',
                      active: false,
                    ),
                  ),
                  SizedBox(width: 56),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.verified,
                      label: 'Approve',
                      active: false,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      active: false,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -18,
                child: Material(
                  color: _primary,
                  shape: const CircleBorder(),
                  elevation: 6,
                  child: InkWell(
                    onTap: () {},
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _primary : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCardData {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final String? growth;

  const MetricCardData({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    this.growth,
  });
}

class RecentUser {
  final String initials;
  final String name;
  final String roleLine;
  final String status;
  final Color avatarBackground;
  final Color avatarText;
  final Color statusBackground;
  final Color statusText;

  const RecentUser({
    required this.initials,
    required this.name,
    required this.roleLine,
    required this.status,
    required this.avatarBackground,
    required this.avatarText,
    required this.statusBackground,
    required this.statusText,
  });
}

class DonutSegment {
  final double value;
  final Color color;

  const DonutSegment(this.value, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final Color backgroundColor;

  DonutChartPainter({
    required this.segments,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor;

    canvas.drawCircle(center, radius, backgroundPaint);

    double startAngle = -pi / 2;
    for (final segment in segments) {
      final sweepAngle = 2 * pi * segment.value;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segment.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return true;
  }
}
