import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);
    const backgroundLight = Color(0xFFF6F6F8);
    const backgroundDark = Color(0xFF101622);
    const surfaceLight = Color(0xFFFFFFFF);
    const surfaceDark = Color(0xFF1A2130);
    const danger = Color(0xFFD32F2F);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTheme = Theme.of(context);
    final textTheme = GoogleFonts.lexendTextTheme(baseTheme.textTheme);

    return Theme(
      data: baseTheme.copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: isDark ? backgroundDark : backgroundLight,
        body: Stack(
          children: [
            _AnimatedBackground(
              controller: _floatController,
              isDark: isDark,
              backgroundLight: backgroundLight,
              backgroundDark: backgroundDark,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 420,
                        minHeight: constraints.maxHeight,
                      ),
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            color: isDark
                                ? Colors.black.withOpacity(0.1)
                                : Colors.white.withOpacity(0.5),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        const SizedBox(height: 16),
                                        _HeaderSection(
                                          isDark: isDark,
                                          danger: danger,
                                        ),
                                        const SizedBox(height: 16),

                                        // Status Card
                                        StatusCard(
                                          isDark: isDark,
                                          primary: primary,
                                          surfaceDark: surfaceDark,
                                          controller: _floatController,
                                        ),
                                        const SizedBox(height: 24),

                                        // Quick Actions
                                        Text(
                                          'Quick Actions',
                                          style: textTheme.labelMedium?.copyWith(
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _QuickActionsGrid(
                                          primary: primary,
                                          isDark: isDark,
                                          surfaceLight: surfaceLight,
                                          surfaceDark: surfaceDark,
                                        ),
                                        const SizedBox(height: 24),

                                        // Recent Logs
                                        _RecentLogsSection(
                                          isDark: isDark,
                                          primary: primary,
                                          surfaceLight: surfaceLight,
                                          surfaceDark: surfaceDark,
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ),

                                // SOS Floating Button
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 80,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 420),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 24),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: SosFloatingButton(
                                            controller: _floatController,
                                            danger: danger,
                                            isDark: isDark,
                                            backgroundDark: backgroundDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Bottom Navigation
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: BottomNavBar(
                                    currentIndex: _currentIndex,
                                    onTap: (index) => setState(() => _currentIndex = index),
                                    primary: primary,
                                    isDark: isDark,
                                    surfaceLight: surfaceLight,
                                    surfaceDark: surfaceDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Background with animated blobs
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final Color backgroundLight;
  final Color backgroundDark;

  const _AnimatedBackground({
    required this.controller,
    required this.isDark,
    required this.backgroundLight,
    required this.backgroundDark,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [backgroundDark, const Color(0xFF0F172A)]
                    : [backgroundLight, const Color(0xFFDBEAFE)],
              ),
            ),
          ),
          _AnimatedBlob(
            controller: controller,
            baseOffset: const Offset(-80, -60),
            size: 320,
            color: primary.withOpacity(0.2),
            blur: 80,
            floatOffset: const Offset(30, 50),
            phase: 0.0,
          ),
          _AnimatedBlob(
            controller: controller,
            baseOffset: const Offset(-120, 160),
            size: 260,
            color: (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF93C5FD))
                .withOpacity(0.2),
            blur: 90,
            floatOffset: const Offset(40, -40),
            phase: 0.25,
          ),
        ],
      ),
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final AnimationController controller;
  final Offset baseOffset;
  final double size;
  final Color color;
  final double blur;
  final Offset floatOffset;
  final double phase;

  const _AnimatedBlob({
    required this.controller,
    required this.baseOffset,
    required this.size,
    required this.color,
    required this.blur,
    required this.floatOffset,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phase) * 2 * pi;
        final dx = sin(t) * floatOffset.dx;
        final dy = cos(t) * floatOffset.dy;
        final scale = 1 + (sin(t) * 0.08);
        return Positioned(
          left: baseOffset.dx + dx,
          top: baseOffset.dy + dy,
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Header section with avatar and notification
class _HeaderSection extends StatelessWidget {
  final bool isDark;
  final Color danger;

  const _HeaderSection({required this.isDark, required this.danger});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDqKIzXOtSweW9wuSc2MzGX8dNGDtEnP9Vji-lamYqQlE32PhhenX1RegWgbSIUBcq7SlWX-j0TQ3jTas_e7_EIOSKqD8Xyfjw-ENgWVzaPjw3qOHqjuacCMJwV9-KxdjrAehwTJ5GpFVFj4z4fpduGLtS88yitHvpDJYHuMnBggaRmL8s_2xEVVRUk29l2khKW9t1RgGjY8oDio_LoY2BzabNsL_opUKwCBTW_3hBAbATIL3_NFHAFTy3WDPV97-RqGVVMfCFQKDm7',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Sarah Chen',
                  style: textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: danger,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF101622) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color surfaceDark;
  final AnimationController controller;

  const StatusCard({
    super.key,
    required this.isDark,
    required this.primary,
    required this.surfaceDark,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF7C2D12).withOpacity(0.3)
                          : const Color(0xFFFDE68A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Processing',
                      style: textTheme.labelSmall?.copyWith(
                        color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFEA580C),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weekend Outing',
                    style: textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Request #8921 - Oct 24 - 26',
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.timelapse, color: primary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Step Progress
          StepProgressIndicator(
            controller: controller,
            isDark: isDark,
            primary: primary,
            surfaceDark: surfaceDark,
          ),
        ],
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final Color primary;
  final Color surfaceDark;

  const StepProgressIndicator({
    super.key,
    required this.controller,
    required this.isDark,
    required this.primary,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            Positioned(
              top: 14,
              left: 0,
              width: constraints.maxWidth * 0.5,
              child: Container(height: 2, color: primary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepItem(
                  title: 'Applied',
                  subtitle: '10:00 AM',
                  isCompleted: true,
                  isActive: false,
                  isDark: isDark,
                  primary: primary,
                  textTheme: textTheme,
                  controller: controller,
                  surfaceDark: surfaceDark,
                ),
                _StepItem(
                  title: 'Parent',
                  subtitle: 'Pending',
                  isCompleted: false,
                  isActive: true,
                  isDark: isDark,
                  primary: primary,
                  textTheme: textTheme,
                  controller: controller,
                  surfaceDark: surfaceDark,
                ),
                _StepItem(
                  title: 'Warden',
                  subtitle: '',
                  isCompleted: false,
                  isActive: false,
                  isDark: isDark,
                  primary: primary,
                  textTheme: textTheme,
                  controller: controller,
                  surfaceDark: surfaceDark,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StepItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isDark;
  final Color primary;
  final TextTheme textTheme;
  final AnimationController controller;
  final Color surfaceDark;

  const _StepItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.isDark,
    required this.primary,
    required this.textTheme,
    required this.controller,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    final baseTextColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937);
    final inactiveTextColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);

    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? primary : (isActive ? (isDark ? surfaceDark : Colors.white) : Colors.white),
              border: Border.all(color: isActive ? primary : borderColor, width: 2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : isActive
                      ? AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            final scale = 0.8 + (sin(controller.value * 2 * pi) * 0.2);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: isCompleted || isActive ? (isActive ? baseTextColor : primary) : inactiveTextColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: isActive
                    ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFF97316))
                    : inactiveTextColor,
              ),
            ),
        ],
      ),
    );
  }
}

// Quick actions grid
class _QuickActionsGrid extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final Color surfaceLight;
  final Color surfaceDark;

  const _QuickActionsGrid({
    required this.primary,
    required this.isDark,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuickActionButton(
          title: 'New Outing Request',
          subtitle: 'Apply for day pass or overnight leave',
          icon: Icons.add,
          isPrimary: true,
          primary: primary,
          isDark: isDark,
          surfaceLight: surfaceLight,
          surfaceDark: surfaceDark,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                title: 'Digital Pass',
                icon: Icons.qr_code_2,
                isPrimary: false,
                primary: primary,
                isDark: isDark,
                surfaceLight: surfaceLight,
                surfaceDark: surfaceDark,
                iconColor: primary,
                iconBackground:
                    isDark ? const Color(0xFF1E3A8A).withOpacity(0.2) : const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionButton(
                title: 'History Log',
                icon: Icons.history,
                isPrimary: false,
                primary: primary,
                isDark: isDark,
                surfaceLight: surfaceLight,
                surfaceDark: surfaceDark,
                iconColor: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF7C3AED),
                iconBackground:
                    isDark ? const Color(0xFF4C1D95).withOpacity(0.2) : const Color(0xFFEDE9FE),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuickActionButton extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isPrimary;
  final Color primary;
  final bool isDark;
  final Color surfaceLight;
  final Color surfaceDark;
  final Color? iconColor;
  final Color? iconBackground;

  const QuickActionButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.primary,
    required this.isDark,
    required this.surfaceLight,
    required this.surfaceDark,
    this.iconColor,
    this.iconBackground,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: widget.isPrimary
              ? widget.primary
              : (widget.isDark ? widget.surfaceDark : widget.surfaceLight),
          borderRadius: BorderRadius.circular(widget.isPrimary ? 16 : 14),
          elevation: widget.isPrimary ? 6 : 2,
          shadowColor: widget.isPrimary ? widget.primary.withOpacity(0.3) : Colors.black.withOpacity(0.08),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(widget.isPrimary ? 16 : 14),
            child: Padding(
              padding: widget.isPrimary
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: widget.isPrimary
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle ?? '',
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFDBEAFE),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.iconBackground ?? Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor ?? widget.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: widget.isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Recent logs section
class _RecentLogsSection extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color surfaceLight;
  final Color surfaceDark;

  const _RecentLogsSection({
    required this.isDark,
    required this.primary,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Logs',
              style: textTheme.labelMedium?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LogListItem(
          isDark: isDark,
          surfaceLight: surfaceLight,
          surfaceDark: surfaceDark,
          title: 'Returned to Campus',
          subtitle: 'Oct 20, 8:45 PM',
          passId: '#8892',
          icon: Icons.check_circle,
          iconBackground: isDark ? const Color(0xFF14532D).withOpacity(0.2) : const Color(0xFFDCFCE7),
          iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
        ),
        const SizedBox(height: 12),
        LogListItem(
          isDark: isDark,
          surfaceLight: surfaceLight,
          surfaceDark: surfaceDark,
          title: 'Left Campus',
          subtitle: 'Oct 20, 10:15 AM',
          passId: '#8892',
          icon: Icons.logout,
          iconBackground: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          iconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ],
    );
  }
}

class LogListItem extends StatelessWidget {
  final bool isDark;
  final Color surfaceLight;
  final Color surfaceDark;
  final String title;
  final String subtitle;
  final String passId;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const LogListItem({
    super.key,
    required this.isDark,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.title,
    required this.subtitle,
    required this.passId,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? surfaceDark : surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              passId,
              style: textTheme.labelSmall?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                fontFamily: 'Courier',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Glassmorphism container
class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GlassContainer({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2130).withOpacity(0.75) : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// Floating SOS button
class SosFloatingButton extends StatelessWidget {
  final AnimationController controller;
  final Color danger;
  final bool isDark;
  final Color backgroundDark;

  const SosFloatingButton({
    super.key,
    required this.controller,
    required this.danger,
    required this.isDark,
    required this.backgroundDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value * 2 * pi;
        final dy = sin(t) * 3;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: danger,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: danger.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? backgroundDark : Colors.white,
                    width: 4,
                  ),
                ),
                child: const Icon(Icons.local_police, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SOS',
                  style: textTheme.labelSmall?.copyWith(
                    color: danger,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Bottom navigation bar
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color primary;
  final bool isDark;
  final Color surfaceLight;
  final Color surfaceDark;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.primary,
    required this.isDark,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? surfaceDark : surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              label: 'Home',
              icon: Icons.home,
              isActive: currentIndex == 0,
              primary: primary,
              onTap: () => onTap(0),
            ),
            _NavItem(
              label: 'Requests',
              icon: Icons.description,
              isActive: currentIndex == 1,
              primary: primary,
              onTap: () => onTap(1),
            ),
            _NavItem(
              label: 'Profile',
              icon: Icons.person,
              isActive: currentIndex == 2,
              primary: primary,
              onTap: () => onTap(2),
            ),
            _NavItem(
              label: 'Settings',
              icon: Icons.settings,
              isActive: currentIndex == 3,
              primary: primary,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color primary;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = isActive ? primary : const Color(0xFF94A3B8);
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
