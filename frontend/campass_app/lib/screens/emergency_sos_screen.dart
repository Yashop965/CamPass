import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF1152D4);
  static const _danger = Color(0xFFEF4444);
  static const _success = Color(0xFF22C55E);
  static const _backgroundLight = Color(0xFFF6F6F8);
  static const _backgroundDark = Color(0xFF101622);

  late final AnimationController _bgPulseController;
  late final AnimationController _ringController;
  late final AnimationController _mapPulseController;
  late final AnimationController _holdController;

  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _mapPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    _ringController.dispose();
    _mapPulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() => _holding = true);
    _holdController.forward(from: 0);
  }

  void _endHold() {
    if (_holdController.isCompleted) {
      // Trigger cancel callback (stub)
    }
    setState(() => _holding = false);
    _holdController.reset();
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
        body: AnimatedBuilder(
          animation: _bgPulseController,
          builder: (context, child) {
            final t = _bgPulseController.value;
            final bg = Color.lerp(
              isDark ? _backgroundDark : _backgroundLight,
              const Color(0xFFFEE2E2),
              t <= 0.5 ? t * 0.25 : (1 - t) * 0.25,
            );
            return Container(
              color: bg,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _danger.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SosHeaderWidget(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                SosCentralAnimation(
                                  ringController: _ringController,
                                  danger: _danger,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Help is on the way',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Emergency alerts have been successfully sent to your designated contacts.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const NotificationStatusChips(),
                                const SizedBox(height: 16),
                                LiveLocationCard(
                                  isDark: isDark,
                                  primary: _primary,
                                  mapPulseController: _mapPulseController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        LongPressCancelButton(
                          isDark: isDark,
                          holdController: _holdController,
                          holding: _holding,
                          onHoldStart: _startHold,
                          onHoldEnd: _endHold,
                        ),
                        const SosFooterWidget(),
                      ],
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
}

class SosHeaderWidget extends StatelessWidget {
  const SosHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'SOS Active',
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            '10:42 AM',
            style: textTheme.labelSmall?.copyWith(
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SosCentralAnimation extends StatelessWidget {
  final AnimationController ringController;
  final Color danger;

  const SosCentralAnimation({
    super.key,
    required this.ringController,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: ringController,
            builder: (context, child) {
              final scale = 1 + (ringController.value * 0.4);
              final opacity = (1 - ringController.value).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: danger.withOpacity(0.08 * opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: danger.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: danger.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.notification_important, color: Color(0xFFEF4444), size: 60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationStatusChips extends StatelessWidget {
  const NotificationStatusChips({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _Chip(textTheme: textTheme, label: 'Warden'),
        _Chip(textTheme: textTheme, label: 'Parent'),
        _Chip(textTheme: textTheme, label: 'Security'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final TextTheme textTheme;
  final String label;

  const _Chip({required this.textTheme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveLocationCard extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final AnimationController mapPulseController;

  const LiveLocationCard({
    super.key,
    required this.isDark,
    required this.primary,
    required this.mapPulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBKiqhqikmXZCJNZ9XybzBi7eGZIpwMqTtx2qc_HEMdqiWhbEHH6ITOuF-JqGNn3YcH7mtJS0pFCECRslUXKA7M_JXNeiEBLYDojtM-bYwtD8V239vl3c6ygGEm3RFRp5dfeXz-Anj_p8E39cSiUFJN6673EBBh61Uc8zYHDCrgOLG5JEYKOlCMtsXb0SGMfhEmwiju4OhW4ptgCGVnz6PPyuPtPtRp9nukp0SVCRtkgAVzTtpqHc0x3dtwrk0BB6bzM8Z3y9Ue7V77',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: AnimatedBuilder(
                    animation: mapPulseController,
                    builder: (context, child) {
                      final scale = 1 + (mapPulseController.value * 0.4);
                      final opacity = (1 - mapPulseController.value).clamp(0.0, 1.0);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.25 * opacity),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '34.0522 N, 118.2437 W',
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.my_location, size: 14, color: Color(0xFF1152D4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Near Student Center, Block B',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.near_me, size: 16, color: Color(0xFF1152D4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LongPressCancelButton extends StatelessWidget {
  final bool isDark;
  final AnimationController holdController;
  final bool holding;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  const LongPressCancelButton({
    super.key,
    required this.isDark,
    required this.holdController,
    required this.holding,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: AnimatedBuilder(
                  animation: holdController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: holding ? holdController.value : 0,
                      strokeWidth: 4,
                      color: const Color(0xFF94A3B8),
                      backgroundColor: const Color(0xFFE2E8F0),
                    );
                  },
                ),
              ),
              GestureDetector(
                onLongPressStart: (_) => onHoldStart(),
                onLongPressEnd: (_) => onHoldEnd(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'False Alarm?',
                        style: textTheme.labelMedium?.copyWith(
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Long press to cancel SOS',
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
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

class SosFooterWidget extends StatelessWidget {
  const SosFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        'Emergency ID: #SOS-8921-XJ',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF94A3B8),
            ),
      ),
    );
  }
}
