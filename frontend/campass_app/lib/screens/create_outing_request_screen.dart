import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateOutingRequestScreen extends StatefulWidget {
  const CreateOutingRequestScreen({super.key});

  @override
  State<CreateOutingRequestScreen> createState() => _CreateOutingRequestScreenState();
}

class _CreateOutingRequestScreenState extends State<CreateOutingRequestScreen> {
  static const _primary = Color(0xFF1152D4);
  static const _primary600 = Color(0xFF0D40A5);
  static const _backgroundLight = Color(0xFFF6F6F8);
  static const _backgroundDark = Color(0xFF101622);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _surfaceDark = Color(0xFF1A2233);

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _reason = 'Personal Errand';
  DateTime _departure = DateTime.now().add(const Duration(hours: 4));
  DateTime _returnTime = DateTime.now().add(const Duration(hours: 8));

  @override
  void dispose() {
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isDeparture}) async {
    // Stub logic for date/time pickers
    final initialDate = isDeparture ? _departure : _returnTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;
    final updated = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isDeparture) {
        _departure = updated;
      } else {
        _returnTime = updated;
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${_weekday(dateTime.weekday)}, $hour:$minute $suffix';
  }

  String _weekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
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
        body: Stack(
          children: [
            Column(
              children: [
                // Header
                SafeArea(
                  bottom: false,
                  child: _HeaderBar(
                    isDark: isDark,
                    backgroundLight: _backgroundLight,
                    backgroundDark: _backgroundDark,
                    primary: _primary,
                  ),
                ),
                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Destination & Reason
                        IosCardContainer(
                          isDark: isDark,
                          surfaceLight: _surfaceLight,
                          surfaceDark: _surfaceDark,
                          child: Column(
                            children: [
                              IosInputField(
                                isDark: isDark,
                                label: 'Where are you going?',
                                hint: 'City Center Mall, Library...',
                                icon: Icons.place,
                                controller: _destinationController,
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _IconCircle(
                                    icon: Icons.help_outline,
                                    color: _primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reason for Outing',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _reason,
                                          items: const [
                                            DropdownMenuItem(value: 'Personal Errand', child: Text('Personal Errand')),
                                            DropdownMenuItem(
                                              value: 'Medical Appointment',
                                              child: Text('Medical Appointment'),
                                            ),
                                            DropdownMenuItem(value: 'Family Visit', child: Text('Family Visit')),
                                            DropdownMenuItem(
                                              value: 'Academic Project',
                                              child: Text('Academic Project'),
                                            ),
                                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                                          ],
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() => _reason = value);
                                          },
                                          icon: Icon(
                                            Icons.expand_more,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Timing
                        Text(
                          'Timing',
                          style: textTheme.labelMedium?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IosCardContainer(
                          isDark: isDark,
                          surfaceLight: _surfaceLight,
                          surfaceDark: _surfaceDark,
                          child: Column(
                            children: [
                              TimingRowWidget(
                                isDark: isDark,
                                icon: Icons.flight_takeoff,
                                iconBackground: isDark
                                    ? const Color(0xFF14532D).withOpacity(0.2)
                                    : const Color(0xFFDCFCE7),
                                iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
                                label: 'Departure',
                                value: _formatDateTime(_departure),
                                isPrimary: true,
                                onTap: () => _pickDateTime(isDeparture: true),
                              ),
                              const Divider(height: 1),
                              TimingRowWidget(
                                isDark: isDark,
                                icon: Icons.flight_land,
                                iconBackground: isDark
                                    ? const Color(0xFF7C2D12).withOpacity(0.3)
                                    : const Color(0xFFFDE68A),
                                iconColor: isDark ? const Color(0xFFF59E0B) : const Color(0xFFF97316),
                                label: 'Expected Return',
                                value: _formatDateTime(_returnTime),
                                isPrimary: false,
                                onTap: () => _pickDateTime(isDeparture: false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Approval Chain
                        Text(
                          'Approval Chain',
                          style: textTheme.labelMedium?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ApprovalChainWidget(
                          isDark: isDark,
                          primary: _primary,
                          surfaceLight: _surfaceLight,
                          surfaceDark: _surfaceDark,
                        ),
                        const SizedBox(height: 20),

                        // Notes
                        IosCardContainer(
                          isDark: isDark,
                          surfaceLight: _surfaceLight,
                          surfaceDark: _surfaceDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Additional Notes (Optional)',
                                style: textTheme.labelSmall?.copyWith(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'I will be going with my roommate...',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Footer
            StickySubmitFooter(
              isDark: isDark,
              backgroundLight: _backgroundLight,
              backgroundDark: _backgroundDark,
              primary: _primary,
              primary600: _primary600,
            ),
          ],
        ),
      ),
    );
  }
}

// Header bar with blur
class _HeaderBar extends StatelessWidget {
  final bool isDark;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color primary;

  const _HeaderBar({
    required this.isDark,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: (isDark ? backgroundDark : backgroundLight).withOpacity(0.9),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Cancel',
                  style: textTheme.bodyMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'New Request',
                style: textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 64),
            ],
          ),
        ),
      ),
    );
  }
}

class IosCardContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color surfaceLight;
  final Color surfaceDark;

  const IosCardContainer({
    super.key,
    required this.child,
    required this.isDark,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? surfaceDark : surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class IosInputField extends StatelessWidget {
  final bool isDark;
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  const IosInputField({
    super.key,
    required this.isDark,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconCircle(icon: icon, color: _CreateOutingRequestScreenState._primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimingRowWidget extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final bool isPrimary;
  final VoidCallback onTap;

  const TimingRowWidget({
    super.key,
    required this.isDark,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isPrimary ? _CreateOutingRequestScreenState._primary : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class ApprovalChainWidget extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color surfaceLight;
  final Color surfaceDark;

  const ApprovalChainWidget({
    super.key,
    required this.isDark,
    required this.primary,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return IosCardContainer(
      isDark: isDark,
      surfaceLight: surfaceLight,
      surfaceDark: surfaceDark,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(isDark ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primary.withOpacity(isDark ? 0.2 : 0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              'This request will be sent to:',
              style: textTheme.labelSmall?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ApproverAvatarWidget(
                  name: 'Dad',
                  role: 'Parent',
                  isApproved: true,
                  isDark: isDark,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDJjSSIjgqxJRT_RBP24JPxEkwcImyn_8l6j2wQ8VAGs1CB4isogYNJ4Og6jiK8PcDKnBPt8oKAnVv68GNsFUlJeCa6aX56BM2hwd2vrNXai1Q1X1ck0hx8NkTnZdIk5D_UUV6S80N-ID7zYYx5vN0M8acbgoSsAXsaNHsnZYIzPTZuZp7lq86qsmtGTTEE2_bpOoFNyL2c9dTIOovBX9LMM8EsvRdhGvD8JF1oK1V4QOSqW8dycZQjJNpLRa2eKszmmBELBZvU4bzN',
                ),
                Container(
                  width: 32,
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 28),
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                ),
                ApproverAvatarWidget(
                  name: 'Mrs. Davis',
                  role: 'Warden',
                  isApproved: false,
                  isDark: isDark,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAGlN10Y_w4NhVXlrCpekBuxy6vZxp75fgH1Xx4aJrZ-uO2dvRb0zMexy40k0jZdCqKydG3NlNdF8H6E_pHJUznzTUXSe5msu7zo0iw-eQRVzw3FmMpqG68hMAappazo_ryAGgpyELv_grqjp5J2WEQeOw_bwRoDpwvNZI4i9l4WMTt3Eb5cQhSYHKh7UJnwCNZiqdnOs8EPkmgRnMVPDbrPHqARpKEMAUbFSoy6jaRVb0L7TyBAcQBwvPJDmGMI_8HYA688oW_tAPw',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApproverAvatarWidget extends StatelessWidget {
  final String name;
  final String role;
  final bool isApproved;
  final bool isDark;
  final String imageUrl;

  const ApproverAvatarWidget({
    super.key,
    required this.name,
    required this.role,
    required this.isApproved,
    required this.isDark,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                border: Border.all(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isApproved ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isApproved ? Icons.check : Icons.schedule,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: textTheme.labelMedium?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          role.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class StickySubmitFooter extends StatefulWidget {
  final bool isDark;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color primary;
  final Color primary600;

  const StickySubmitFooter({
    super.key,
    required this.isDark,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.primary,
    required this.primary600,
  });

  @override
  State<StickySubmitFooter> createState() => _StickySubmitFooterState();
}

class _StickySubmitFooterState extends State<StickySubmitFooter> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  (widget.isDark ? widget.backgroundDark : widget.backgroundLight),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: widget.isDark ? widget.backgroundDark : widget.backgroundLight,
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedScale(
                    scale: _pressed ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: widget.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit for Approval',
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'By submitting, you agree to return by the specified time.',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
