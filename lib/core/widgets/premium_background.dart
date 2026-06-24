import 'dart:math' as math;

import 'package:eduvision_app/app/theme.dart';
import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [AppColors.midnight, AppColors.navy, Color(0xFF0D1D33)]
              : const [
                  AppColors.lightBackground,
                  Color(0xFFEAF7FF),
                  Color(0xFFFFFFFF),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PremiumBackgroundPainter(
                  primary: colorScheme.primary,
                  secondary: colorScheme.secondary,
                  outline: colorScheme.outline,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  const _PremiumBackgroundPainter({
    required this.primary,
    required this.secondary,
    required this.outline,
    required this.isDark,
  });

  final Color primary;
  final Color secondary;
  final Color outline;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowPanel(
      canvas,
      offset: Offset(size.width * 0.58, -size.height * 0.08),
      sizeFactor: Size(size.width * 0.62, size.height * 0.24),
      color: primary,
      angle: -0.16,
    );
    _drawGlowPanel(
      canvas,
      offset: Offset(-size.width * 0.18, size.height * 0.70),
      sizeFactor: Size(size.width * 0.72, size.height * 0.22),
      color: secondary,
      angle: 0.18,
    );

    final linePaint = Paint()
      ..color = outline.withValues(alpha: isDark ? 0.16 : 0.22)
      ..strokeWidth = 1;

    for (var index = -5; index < 14; index++) {
      final start = Offset(size.width * 0.10 * index, size.height);
      final end = Offset(size.width * 0.10 * (index + 5), 0);
      canvas.drawLine(start, end, linePaint);
    }

    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = secondary.withValues(alpha: isDark ? 0.12 : 0.18);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.07, size.height * 0.12, 128, 58),
        const Radius.circular(8),
      ),
      framePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 180, size.height * 0.78, 132, 58),
        const Radius.circular(8),
      ),
      framePaint,
    );
  }

  void _drawGlowPanel(
    Canvas canvas, {
    required Offset offset,
    required Size sizeFactor,
    required Color color,
    required double angle,
  }) {
    final rect = offset & sizeFactor;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: isDark ? 0.18 : 0.13),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(angle * math.pi);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PremiumBackgroundPainter oldDelegate) {
    return primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary ||
        outline != oldDelegate.outline ||
        isDark != oldDelegate.isDark;
  }
}
