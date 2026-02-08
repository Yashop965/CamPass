import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GlassyCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableBlur; // Optimization flag

  const GlassyCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.enableBlur = true, // Default to true
  }) : super(key: key);

  @override
  State<GlassyCard> createState() => _GlassyCardState();
}

class _GlassyCardState extends State<GlassyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
       CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24), 
          child: widget.enableBlur 
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
                child: _buildCardContent(),
              )
            : _buildCardContent(),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Use a slightly more opaque background if blur is disabled to maintain legibility
          color: widget.enableBlur 
              ? AppTheme.surface.withOpacity(0.1) // Glassy
              : AppTheme.surface.withOpacity(0.8), // Solid fallback
          gradient: widget.enableBlur ? AppTheme.glassGradient : null,
          border: Border.all(
            color: Colors.white.withOpacity(0.2), 
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: -5,
            )
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
