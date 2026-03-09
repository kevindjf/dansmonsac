import 'package:flutter/material.dart';

/// Animated flame widget with realistic flickering effect
///
/// Creates a flame animation using Flutter's CustomPainter with:
/// - Color transitions (orange → red → yellow)
/// - Flickering effect
/// - Scale pulsing
/// - Smooth animation loop
///
/// Usage:
/// ```dart
/// AnimatedFlame(
///   size: 64,
///   color: Theme.of(context).colorScheme.secondary,
/// )
/// ```
class AnimatedFlame extends StatefulWidget {
  final double size;
  final Color? color;

  const AnimatedFlame({
    super.key,
    this.size = 64,
    this.color,
  });

  @override
  State<AnimatedFlame> createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<AnimatedFlame>
    with TickerProviderStateMixin {
  late AnimationController _flickerController;
  late AnimationController _pulseController;
  late Animation<double> _flickerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Flicker animation (fast, random-like)
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);

    _flickerAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _flickerController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation (slow, breathing effect)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: Listenable.merge([_flickerController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Opacity(
            opacity: _flickerAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size * 1.2),
              painter: _FlamePainter(
                flickerValue: _flickerAnimation.value,
                pulseValue: _pulseAnimation.value,
                baseColor: themeColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double flickerValue;
  final double pulseValue;
  final Color baseColor;

  _FlamePainter({
    required this.flickerValue,
    required this.pulseValue,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final flameHeight = size.height * 0.8;
    final flameWidth = size.width * 0.6;

    // Create flame gradient (orange → yellow → red)
    final gradient = RadialGradient(
      center: Alignment.bottomCenter,
      radius: 1.2,
      colors: [
        const Color(0xFFFFF176), // Yellow core
        const Color(0xFFFFB74D), // Orange
        const Color(0xFFFF7043), // Red-orange
        baseColor.withValues(alpha: 0.3), // Theme color edge
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    // Draw main flame body
    final flamePath = Path();
    flamePath.moveTo(center.dx, size.height);

    // Left curve
    flamePath.quadraticBezierTo(
      center.dx - flameWidth / 2,
      size.height - flameHeight * 0.3,
      center.dx - flameWidth / 3,
      size.height - flameHeight * 0.6,
    );

    // Left top
    flamePath.quadraticBezierTo(
      center.dx - flameWidth / 4,
      size.height - flameHeight * 0.85 * flickerValue,
      center.dx,
      size.height - flameHeight * pulseValue,
    );

    // Right top
    flamePath.quadraticBezierTo(
      center.dx + flameWidth / 4,
      size.height - flameHeight * 0.85 * flickerValue,
      center.dx + flameWidth / 3,
      size.height - flameHeight * 0.6,
    );

    // Right curve
    flamePath.quadraticBezierTo(
      center.dx + flameWidth / 2,
      size.height - flameHeight * 0.3,
      center.dx,
      size.height,
    );

    flamePath.close();

    // Draw flame with gradient
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: center,
          width: size.width,
          height: size.height,
        ),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(flamePath, paint);

    // Add inner glow (brighter core)
    final glowPath = Path();
    glowPath.moveTo(center.dx, size.height - flameHeight * 0.2);
    glowPath.quadraticBezierTo(
      center.dx - flameWidth / 6,
      size.height - flameHeight * 0.4,
      center.dx,
      size.height - flameHeight * 0.6 * flickerValue,
    );
    glowPath.quadraticBezierTo(
      center.dx + flameWidth / 6,
      size.height - flameHeight * 0.4,
      center.dx,
      size.height - flameHeight * 0.2,
    );
    glowPath.close();

    final glowPaint = Paint()
      ..color = const Color(0xFFFFF176).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawPath(glowPath, glowPaint);

    // Add sparkle effect at tip
    if (flickerValue > 0.95) {
      final sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: flickerValue - 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx, size.height - flameHeight * pulseValue),
        3,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) {
    return oldDelegate.flickerValue != flickerValue ||
        oldDelegate.pulseValue != pulseValue;
  }
}
