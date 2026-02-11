import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<_RoleOption> _roles = const [
    _RoleOption(label: 'Student', icon: Icons.school),
    _RoleOption(label: 'Parent', icon: Icons.family_restroom),
    _RoleOption(label: 'Warden', icon: Icons.admin_panel_settings),
    _RoleOption(label: 'Guard', icon: Icons.security),
    _RoleOption(label: 'Admin', icon: Icons.settings),
  ];

  int _selectedRoleIndex = 0;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);
    const backgroundLight = Color(0xFFF6F6F8);

    final baseTheme = Theme.of(context);
    final textTheme = GoogleFonts.lexendTextTheme(baseTheme.textTheme);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: textTheme,
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primary;
            }
            return Colors.transparent;
          }),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
      ),
      child: Scaffold(
        backgroundColor: backgroundLight,
        body: Stack(
          children: [
            const _GradientMeshBackground(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 12),
                          // Top Branding
                          Column(
                            children: [
                              Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [primary, Color(0xFF4F46E5)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.local_police, color: Colors.white, size: 36),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'CAMPASS',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Smart Campus Access',
                                style: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Middle Glass Card
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Your Role',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 86,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _roles.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final role = _roles[index];
                                      return _RoleButton(
                                        label: role.label,
                                        icon: role.icon,
                                        isSelected: _selectedRoleIndex == index,
                                        onTap: () => setState(() => _selectedRoleIndex = index),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Login Form
                                const _GlassTextField(
                                  label: 'Campus ID / Username',
                                  hintText: 'Ex: S12345678',
                                  icon: Icons.badge,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                _GlassTextField(
                                  label: 'Password',
                                  hintText: '********',
                                  icon: Icons.lock,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() => _rememberMe = value ?? false);
                                          },
                                        ),
                                        Text(
                                          'Remember me',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Forgot Password?',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _PressableLoginButton(
                                  onPressed: () {},
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login, color: Color(0xFFC7D2FE), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Secure Login',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Column(
                                    children: [
                                      IconButton(
                                        iconSize: 32,
                                        color: primary,
                                        onPressed: () {},
                                        icon: const Icon(Icons.face),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap for Face ID',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              Text.rich(
                                TextSpan(
                                  text: 'Need help? ',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Contact Support',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Copyright (c) 2024 Campus Administration',
                                style: textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom gradient fade
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientMeshBackground extends StatelessWidget {
  const _GradientMeshBackground();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);
    const backgroundLight = Color(0xFFF6F6F8);

    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [backgroundLight, Color(0xFFDBEAFE)],
              ),
            ),
          ),
          Positioned(
            top: -160,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 420,
                height: 320,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(260),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 380,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF818CF8).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(220),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(
                dotColor: primary.withOpacity(0.08),
                spacing: 24,
                radius: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  const _DotPatternPainter({
    required this.dotColor,
    required this.spacing,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor ||
        oldDelegate.spacing != spacing ||
        oldDelegate.radius != radius;
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.08) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primary : const Color(0xFF64748B)),
            const SizedBox(height: 6),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: isSelected ? primary : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction textInputAction;

  const _GlassTextField({
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<_GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<_GlassTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _hasFocus
                    ? Colors.white.withOpacity(0.95)
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasFocus ? primary : primary.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: _hasFocus
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                textInputAction: widget.textInputAction,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(widget.icon, color: const Color(0xFF94A3B8)),
                  suffixIcon: widget.suffix,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PressableLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PressableLoginButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_PressableLoginButton> createState() => _PressableLoginButtonState();
}

class _PressableLoginButtonState extends State<_PressableLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1152D4);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: primary,
          borderRadius: BorderRadius.circular(16),
          elevation: 12,
          shadowColor: primary.withOpacity(0.4),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption {
  final String label;
  final IconData icon;

  const _RoleOption({required this.label, required this.icon});
}
