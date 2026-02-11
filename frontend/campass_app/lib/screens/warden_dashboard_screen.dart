import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WardenDashboardScreen extends StatefulWidget {
  const WardenDashboardScreen({super.key});

  @override
  State<WardenDashboardScreen> createState() => _WardenDashboardScreenState();
}

class _WardenDashboardScreenState extends State<WardenDashboardScreen> {
  static const _primary = Color(0xFF1152D4);
  static const _backgroundLight = Color(0xFFF6F6F8);
  static const _backgroundDark = Color(0xFF101622);

  int _selectedTab = 0;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTheme = Theme.of(context);
    final textTheme = GoogleFonts.lexendTextTheme(baseTheme.textTheme);

    return Theme(
      data: baseTheme.copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: isDark ? _backgroundDark : _backgroundLight,
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      WardenHeaderWidget(isDark: isDark),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          children: [
                            Text(
                              'Good Morning, Mr. Warden',
                              style: textTheme.titleLarge?.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Here\'s the campus occupancy overview for today.',
                              style: textTheme.bodySmall?.copyWith(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: KpiCardWidget(
                                    title: 'Active Outings',
                                    value: '142',
                                    suffix: 'students',
                                    icon: Icons.directions_walk,
                                    accentColor: Color(0xFF1152D4),
                                    progress: 0.7,
                                    showAction: false,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: KpiCardWidget(
                                    title: 'Pending Approvals',
                                    value: '12',
                                    suffix: 'requests',
                                    icon: Icons.assignment_late,
                                    accentColor: Color(0xFFF59E0B),
                                    progress: 0,
                                    showAction: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SegmentedTabControl(
                              selectedIndex: _selectedTab,
                              onChanged: (index) => setState(() => _selectedTab = index),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Student List',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '142',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.filter_list, size: 16, color: _primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Filter: Overdue',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: _primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const StudentListItemWidget(
                              name: 'Jane Smith',
                              room: 'Rm 105',
                              studentId: '#8821',
                              avatarUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCMR8XToq0XtzUee2BkAPZAFaxW0a4ZCEFnfGKBxjzrnWmaofvUDamp4bp6q82--pVen7LhD7skfZK_XBm71sfuYVcHAzJ2KxcA3i6KbH0JrjClXCMFJPhQfjH94TKrx3HFt6C7CnftyWgduDKDxkDSoDm14xmNkjVeQ5HB0hfTkOnrUStVrCtxQHC5WQ-zwgDpsQ2tgXbhA1AfePvmnzRoBXV92zmgOgBE2q5G4kXiDVcvSa5c3elsiUL5m86y9jSqGwTr7iz1A3k2',
                              status: StatusType.overdue,
                              exp: '14:30',
                              remaining: '+45m',
                            ),
                            const SizedBox(height: 10),
                            const StudentListItemWidget(
                              name: 'John Doe',
                              room: 'Rm 302',
                              studentId: '#9942',
                              avatarUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBnMF2ClGEMHfTT1kol8daUJ3uFyI8Jnr1sKEcQtsPXJcLikfdExRiYWIf9X4nFMuT9xHNgUphEdeSkqb2tyekRIwGlUZaggtE6CcX3cwHWP8_xGDdAkZ2zlMSqROnzk_zp5TZ71OGZxlzEkNRlFVYWUW5FFxydvuFRRHDsEtpNmnoq_ZDeo9C0YcPQdYBpu1iIwz-suqQE8Kw6CSzClFf3-TqBwwovIBoSX8Kq94f79ZG3Jt--E_dDmz2EU04t_z0-Exo098aPa47g',
                              status: StatusType.onTime,
                              exp: '18:00',
                              remaining: '~2h left',
                            ),
                            const SizedBox(height: 10),
                            const StudentListItemWidget(
                              name: 'Sarah Connor',
                              room: 'Rm 212',
                              studentId: '#1024',
                              avatarUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCXgXWE0G0mJ2XTTed5sJ-NI15vngROtBgWX1uih1fyx_XvghlrE6NmNo3rVTJinzYvnxOxNO4bcJE7z3IFGdj3NrxcmoTX_Ixemn7FzeY7mXrveEjQy28AdF8XgjRrnlMWVlwK4wQKWCjfOYF5RG9WfBVCcvKyIiaOoC9sumZ3nPpuaJjQyROj4pAGvm5Wx9yx_22c4HXkkoWeTYEwLtKc-gJAOQtfbKmY8lxUpr2-OHKx9h1QgC8PSzgLQZj3brlbvw4c8ZqF7nh7',
                              status: StatusType.onTime,
                              exp: '19:30',
                              remaining: '~3.5h left',
                            ),
                            const SizedBox(height: 10),
                            const StudentListItemWidget(
                              name: 'Michael Key',
                              room: 'Rm 401',
                              studentId: '#7712',
                              initials: 'MK',
                              status: StatusType.endingSoon,
                              exp: '16:45',
                              remaining: '15m left',
                            ),
                            const SizedBox(height: 10),
                            const StudentListItemWidget(
                              name: 'Alex Chen',
                              room: 'Rm 118',
                              studentId: '#5521',
                              avatarUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCmJDLVxTJ9qxF2H6akk44U0jcCJWtqNSLGJL-kPSvk6ZszOj4xOwjvG9ZZPJT8Gh_581SBII7SS1u4LQh3_ioK7RDOdpwEVib7GWzwcyaXYcQwZp9uzSEWTEd5Zddx1rPfRMdzRDgQ-7MgI9HKv7EYdw3OBTmY4WOjJH3oDcyMAIhmf4hzrt8P8y7MoN5Z08LGedu12B-h27U7wkypLGNCBROHfGcN9z04EP5qvDGUM86Tfsm-3OZx2eSadNzpwxZ4F2p9lFVRYz0h',
                              status: StatusType.onTime,
                              exp: '20:00',
                              remaining: '~4h left',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const ScanFloatingButton(),
          ],
        ),
        bottomNavigationBar: WardenBottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (index) => setState(() => _navIndex = index),
        ),
      ),
    );
  }
}

class WardenHeaderWidget extends StatelessWidget {
  final bool isDark;

  const WardenHeaderWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1152D4),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1152D4).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.security, color: Colors.white),
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
                    'WARDEN ADMIN',
                    style: textTheme.labelSmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDhAuhfyrXv1_ctZpvHC7JUgJlTbPiLtoRCkWWUmSsvURWT3a85jePsyp8tky7KAbwColg6MR5wcxoeCgJI5Booj5Dfdqb7V9zzB_pPJaaOidrPgl5MAYHfIOxkJHFR9iU7eWZRBdb0emTp5eIaLtlSs7u7xtDdDGaGwGjqlWEtSwrC3-3IusRuqy-bD-StOKiyg2Q2PfCU6Z43Ocs7RTpWsxotxYxMxbPjzpkiIZbv2amxOHnkUcT7ABEgg5pEx0NYzulRK6oHHt-A',
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                    width: 2,
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

class KpiCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color accentColor;
  final double progress;
  final bool showAction;

  const KpiCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.accentColor,
    required this.progress,
    required this.showAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -4,
            child: Icon(icon, size: 64, color: accentColor.withOpacity(0.15)),
          ),
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
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    suffix,
                    style: textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (progress > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: const Color(0xFF1152D4),
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF1152D4)),
                    label: Text(
                      'Review Now',
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF1152D4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SegmentedTabControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.6) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Currently Outside',
            isActive: selectedIndex == 0,
            onTap: () => onChanged(0),
            textTheme: textTheme,
            isDark: isDark,
          ),
          _TabButton(
            label: 'Approval Queue',
            isActive: selectedIndex == 1,
            onTap: () => onChanged(1),
            textTheme: textTheme,
            isDark: isDark,
          ),
          _TabButton(
            label: 'Log History',
            isActive: selectedIndex == 2,
            onTap: () => onChanged(2),
            textTheme: textTheme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final bool isDark;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isActive
        ? (isDark ? Colors.white : const Color(0xFF1152D4))
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum StatusType { overdue, onTime, endingSoon }

class StudentListItemWidget extends StatelessWidget {
  final String name;
  final String room;
  final String studentId;
  final String? avatarUrl;
  final String? initials;
  final StatusType status;
  final String exp;
  final String remaining;

  const StudentListItemWidget({
    super.key,
    required this.name,
    required this.room,
    required this.studentId,
    required this.status,
    required this.exp,
    required this.remaining,
    this.avatarUrl,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    Color? leadingStripe;
    StatusBadgeWidget badge;
    Color remainingColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    switch (status) {
      case StatusType.overdue:
        leadingStripe = const Color(0xFFEF4444);
        badge = const StatusBadgeWidget(
          label: 'Overdue',
          color: Color(0xFFEF4444),
          icon: Icons.warning,
        );
        remainingColor = const Color(0xFFEF4444);
        break;
      case StatusType.endingSoon:
        leadingStripe = const Color(0xFFF59E0B);
        badge = const StatusBadgeWidget(
          label: 'Ending Soon',
          color: Color(0xFFF59E0B),
          icon: Icons.warning,
        );
        remainingColor = const Color(0xFFF59E0B);
        break;
      case StatusType.onTime:
        badge = const StatusBadgeWidget(
          label: 'On Time',
          color: Color(0xFF22C55E),
        );
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (leadingStripe != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: leadingStripe,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _Avatar(
                      url: avatarUrl,
                      initials: initials,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room,
                              size: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room,
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '*',
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ID: $studentId',
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    badge,
                    const SizedBox(height: 4),
                    Text(
                      'Exp: $exp',
                      style: textTheme.labelSmall?.copyWith(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      remaining,
                      style: textTheme.labelSmall?.copyWith(
                        color: remainingColor,
                        fontWeight: FontWeight.w700,
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

class _Avatar extends StatelessWidget {
  final String? url;
  final String? initials;

  const _Avatar({this.url, this.initials});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: url == null
          ? Center(
              child: Text(
                initials ?? '',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            )
          : null,
    );
  }
}

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
          ),
        ],
      ),
    );
  }
}

class ScanFloatingButton extends StatefulWidget {
  const ScanFloatingButton({super.key});

  @override
  State<ScanFloatingButton> createState() => _ScanFloatingButtonState();
}

class _ScanFloatingButtonState extends State<ScanFloatingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 90,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1152D4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1152D4).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class WardenBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WardenBottomNavigationBar({
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
            label: 'Dashboard',
            icon: Icons.dashboard,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            textTheme: textTheme,
          ),
          _BottomNavItem(
            label: 'Requests',
            icon: Icons.assignment_ind,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            textTheme: textTheme,
            showDot: true,
          ),
          const Spacer(),
          _BottomNavItem(
            label: 'Students',
            icon: Icons.people,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            textTheme: textTheme,
          ),
          _BottomNavItem(
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

class _BottomNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool showDot;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
    this.showDot = false,
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
            Stack(
              children: [
                Icon(icon, color: color),
                if (showDot)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
