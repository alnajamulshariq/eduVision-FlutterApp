import 'dart:async';
import 'dart:math' as math;

import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class StudentQrScreen extends StatefulWidget {
  const StudentQrScreen({super.key});

  @override
  State<StudentQrScreen> createState() => _StudentQrScreenState();
}

class _StudentQrScreenState extends State<StudentQrScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _countdownTimer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _secondsRemaining = _secondsRemaining == 0 ? 30 : _secondsRemaining - 1;
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'My Dynamic QR',
      subtitle: 'Secure student QR for attendance and gate access.',
      fallbackRoute: AppRoutes.student,
      children: [
        ModulePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _DynamicQrIdentityCard(
                pulseAnimation: _pulseController,
                secondsRemaining: _secondsRemaining,
              ),
              const SizedBox(height: 14),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ModuleBadge(
                    label: 'Attendance',
                    icon: Icons.fact_check_rounded,
                    color: AppColors.cyan,
                  ),
                  ModuleBadge(
                    label: 'Gate Entry/Exit',
                    icon: Icons.sensor_door_rounded,
                    color: AppColors.blue,
                  ),
                  ModuleBadge(
                    label: 'Dynamic',
                    icon: Icons.autorenew_rounded,
                    color: AppColors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
        const ModulePanel(
          padding: EdgeInsets.all(14),
          child: Column(
            children: [
              ModuleInfoTile(
                title: 'Ali Khan',
                subtitle: 'Name',
                icon: Icons.person_rounded,
                color: AppColors.cyan,
              ),
              SizedBox(height: 9),
              ModuleInfoTile(
                title: 'BSIT-2022-001',
                subtitle: 'Roll No',
                icon: Icons.badge_rounded,
                color: AppColors.blue,
              ),
              SizedBox(height: 9),
              ModuleInfoTile(
                title: 'BSIT',
                subtitle: 'Department',
                icon: Icons.account_tree_rounded,
                color: AppColors.amber,
              ),
              SizedBox(height: 9),
              ModuleInfoTile(
                title: '8th Semester',
                subtitle: 'Semester',
                icon: Icons.school_rounded,
                color: Color(0xFFB48CFF),
              ),
            ],
          ),
        ),
        const ModulePanel(
          padding: EdgeInsets.all(14),
          child: ModuleInfoTile(
            title: 'Security Note',
            subtitle: 'This QR refreshes automatically to prevent misuse.',
            icon: Icons.shield_rounded,
            color: AppColors.cyan,
          ),
        ),
      ],
    );
  }
}

class _DynamicQrIdentityCard extends StatelessWidget {
  const _DynamicQrIdentityCard({
    required this.pulseAnimation,
    required this.secondsRemaining,
  });

  final Animation<double> pulseAnimation;
  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = secondsRemaining / 30;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(pulseAnimation.value);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.secondary.withValues(
                alpha: 0.24 + pulse * 0.26,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withValues(
                  alpha: 0.14 + pulse * 0.10,
                ),
                blurRadius: 20 + pulse * 16,
                offset: const Offset(0, 12),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.10),
                colorScheme.surface.withValues(alpha: 0.26),
                colorScheme.secondary.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ali Khan',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'BSIT-2022-001',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ModuleBadge(
                    label: 'Live',
                    icon: Icons.bolt_rounded,
                    color: AppColors.cyan,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  width: 218,
                  height: 218,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.38),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _QrPreviewPainter(
                      foreground: colorScheme.primary,
                      accent: colorScheme.secondary,
                      background: colorScheme.surface.withValues(alpha: 0.86),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Refreshes in ${secondsRemaining}s',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.autorenew_rounded,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: colorScheme.secondary,
                  backgroundColor: colorScheme.secondary.withValues(
                    alpha: 0.13,
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

class _QrPreviewPainter extends CustomPainter {
  const _QrPreviewPainter({
    required this.foreground,
    required this.accent,
    required this.background,
  });

  final Color foreground;
  final Color accent;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = background;
    final fgPaint = Paint()..color = foreground;
    final accentPaint = Paint()..color = accent;
    final cell = size.width / 15;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      bgPaint,
    );

    void finder(int x, int y) {
      final rect = Rect.fromLTWH(x * cell, y * cell, cell * 4, cell * 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        fgPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(cell * 0.78),
          const Radius.circular(5),
        ),
        bgPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(cell * 1.42),
          const Radius.circular(3),
        ),
        fgPaint,
      );
    }

    finder(1, 1);
    finder(10, 1);
    finder(1, 10);

    for (var row = 0; row < 15; row++) {
      for (var column = 0; column < 15; column++) {
        final inFinder =
            (column <= 4 && row <= 4) ||
            (column >= 10 && row <= 4) ||
            (column <= 4 && row >= 10);
        if (inFinder) {
          continue;
        }
        final seed = (row * 9 + column * 13 + row * column) % 7;
        if (seed == 0 || seed == 2 || seed == 5) {
          final inset = cell * (seed == 5 ? 0.25 : 0.18);
          final rect = Rect.fromLTWH(
            column * cell + inset,
            row * cell + inset,
            cell - inset * 2,
            cell - inset * 2,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect,
              Radius.circular(math.max(2, cell * 0.16)),
            ),
            seed == 2 ? accentPaint : fgPaint,
          );
        }
      }
    }

    final centerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.52);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: size.center(Offset.zero),
          width: size.width * 0.32,
          height: size.height * 0.32,
        ),
        const Radius.circular(8),
      ),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPreviewPainter oldDelegate) {
    return foreground != oldDelegate.foreground ||
        accent != oldDelegate.accent ||
        background != oldDelegate.background;
  }
}
