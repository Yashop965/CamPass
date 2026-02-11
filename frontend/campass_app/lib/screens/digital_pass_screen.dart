import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitalPassScreen extends StatefulWidget {
  const DigitalPassScreen({super.key});

  @override
  State<DigitalPassScreen> createState() => _DigitalPassScreenState();
}

class _DigitalPassScreenState extends State<DigitalPassScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF1152D4);
  static const _backgroundDark = Color(0xFF101622);
  static const _success = Color(0xFF22C55E);

  late final AnimationController _pulseController;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 4, seconds: 59);
  int _navIndex = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
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
        backgroundColor: _primary,
        body: Stack(
          children: [
            const _BackgroundBlobs(),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  const _HeaderBar(),
                  // Main Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Column(
                          children: [
                            PassCardWidget(
                              isDark: isDark,
                              pulseController: _pulseController,
                              remaining: _remaining,
                            ),
                            const SizedBox(height: 16),
                            const PassActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  BottomNavigationBarWidget(
                    currentIndex: _navIndex,
                    onTap: (index) => setState(() => _navIndex = index),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Background blobs
class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -70,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF93C5FD).withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Header
class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

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
              const Icon(Icons.verified_user, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'CAMPASS',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class PassCardWidget extends StatelessWidget {
  final bool isDark;
  final AnimationController pulseController;
  final Duration remaining;

  const PassCardWidget({
    super.key,
    required this.isDark,
    required this.pulseController,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top gradient stripe
          Container(
            height: 12,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1152D4), Color(0xFF60A5FA)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                // Profile header
                const ProfileHeaderWidget(),
                const SizedBox(height: 16),
                const TicketSeparatorWidget(),
                const SizedBox(height: 16),
                const QrSectionWidget(),
                const SizedBox(height: 16),
                ApprovalStatusWidget(
                  pulseController: pulseController,
                  remaining: remaining,
                ),
              ],
            ),
          ),
          // Bottom texture strip
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              backgroundBlendMode: BlendMode.srcOver,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDe6L1IBPdw7cJDg5jn0homHto50Fc4fjQn-L4kZYjAaLAC63HNTd2Yey8lOxOU5d8flPSQRHil4yuNYKQm51JRAc8fm2ZDY9JLcmQkWMHhoOnWc446X6h2XqKNR6cQ5YazbmY3BdfLsb_HdTMQxvzRwds5NjGoyfhz1hmP4MFk5pLuw8QZDZqTiKEae0EhQf-aE5g-9v14uuxXwrcY6w2nDBXCIgK6BRzcvwLU3dfk4DvNTets29c2eSxFKipPgACW1hlCGD6LW02B',
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Alex Johnson',
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'ID: 2023-84921',
            style: textTheme.labelSmall?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class TicketSeparatorWidget extends StatelessWidget {
  const TicketSeparatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ),
        const Positioned(
          left: -28,
          top: -12,
          child: _CutoutCircle(color: Color(0xFF1152D4)),
        ),
        const Positioned(
          right: -28,
          top: -12,
          child: _CutoutCircle(color: Color(0xFF1152D4)),
        ),
      ],
    );
  }
}

class _CutoutCircle extends StatelessWidget {
  final Color color;
  const _CutoutCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class QrSectionWidget extends StatelessWidget {
  const QrSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAUq2VXgaM3l0-fopgn8b_f5R4IlrPQlLpThSSI3S6ZT2bTQD6vTXVZ6jQb7IFRxsP9_xGLOQ65j5rJP6oHIqgZ20zNMDXIJ6yZgy8sMEnv_Ht8MP42oXHBc8whhsq-PbG62fVAFxnroHd-0WwDkGuVq0bI53bhShVFrTaGh-2fFqATAI3v1RCyN5UOPlmkIRAjNQFU4RW3sbtkHZgWHaW9Y1xkT7NIQYXR6tlmO1WC3MqBT973E58ZEvdU4-_t5NmKAMJ5nw6dhEgl',
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Scan at Gate A',
          style: textTheme.labelSmall?.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class ApprovalStatusWidget extends StatelessWidget {
  final AnimationController pulseController;
  final Duration remaining;

  const ApprovalStatusWidget({
    super.key,
    required this.pulseController,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.7) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final scale = 0.95 + (pulseController.value * 0.05);
              final ringOpacity = (1 - pulseController.value).clamp(0.0, 1.0);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withOpacity(ringOpacity * 0.6),
                            blurRadius: 16,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'APPROVED',
                          style: textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Valid For',
            style: textTheme.labelSmall?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          CountdownTimerWidget(remaining: remaining),
        ],
      ),
    );
  }
}

class CountdownTimerWidget extends StatelessWidget {
  final Duration remaining;

  const CountdownTimerWidget({super.key, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: textTheme.displaySmall?.copyWith(
        fontFamily: 'Courier',
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }
}

class PassActionButtons extends StatelessWidget {
  const PassActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Refresh Pass',
            icon: Icons.refresh,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Report Issue',
            icon: Icons.report_problem,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;

  const _ActionButton({required this.label, required this.icon});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101622) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            label: 'Home',
            icon: Icons.home,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            textTheme: textTheme,
          ),
          _NavButton(
            label: 'Pass',
            icon: Icons.qr_code_scanner,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            textTheme: textTheme,
            raised: true,
          ),
          _NavButton(
            label: 'History',
            icon: Icons.history,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            textTheme: textTheme,
          ),
          _NavButton(
            label: 'Profile',
            icon: Icons.person,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool raised;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
    this.raised = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1152D4) : const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (raised)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1152D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Icon(icon, color: const Color(0xFF1152D4), size: 22),
              )
            else
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
