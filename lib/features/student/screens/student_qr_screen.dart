import 'dart:async';

import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/dynamic_qr_model.dart';
import 'package:eduvision_app/features/auth/providers/auth_provider.dart';
import 'package:eduvision_app/features/student/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentQrScreen extends ConsumerStatefulWidget {
  const StudentQrScreen({super.key});

  @override
  ConsumerState<StudentQrScreen> createState() => _StudentQrScreenState();
}

class _StudentQrScreenState extends ConsumerState<StudentQrScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _countdownTimer;
  StudentQrIdentityModel? _activeIdentity;
  String? _qrPayload;
  String? _qrError;
  bool _isGenerating = false;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted || _activeIdentity == null) {
      return;
    }

    if (_secondsRemaining <= 1) {
      unawaited(_regeneratePayload(_activeIdentity!));
      return;
    }

    setState(() {
      _secondsRemaining -= 1;
    });
  }

  Future<void> _regeneratePayload(StudentQrIdentityModel identity) async {
    if (_isGenerating || !mounted) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _qrError = null;
    });

    final result = await ref
        .read(qrTokenServiceProvider)
        .generateStudentToken(
          studentUserId: identity.studentUserId,
          studentId: identity.studentId,
        );

    if (!mounted) {
      return;
    }

    if (result case Success<String>(:final data)) {
      setState(() {
        _qrPayload = data;
        _secondsRemaining = 30;
        _isGenerating = false;
      });
      return;
    }

    if (result case Failure<String>(:final exception)) {
      setState(() {
        _qrError = exception.message;
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final identityAsync = ref.watch(studentQrIdentityProvider);

    return ModuleScreenShell(
      title: 'My Dynamic QR',
      subtitle: 'Secure student QR for attendance and gate access.',
      fallbackRoute: AppRoutes.student,
      children: [
        identityAsync.when(
          loading: () => const _QrStatePanel(
            icon: Icons.qr_code_2_rounded,
            title: 'Loading student QR',
            subtitle: 'Preparing your live attendance code.',
          ),
          error: (error, _) => _QrStatePanel(
            icon: Icons.error_rounded,
            title: 'QR unavailable',
            subtitle: error.toString().replaceFirst('Exception: ', ''),
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(studentQrIdentityProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ),
          data: (identity) {
            _activeIdentity = identity;

            if (_qrPayload == null && !_isGenerating) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  unawaited(_regeneratePayload(identity));
                }
              });
            }

            return ModulePanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _DynamicQrIdentityCard(
                    identity: identity,
                    pulseAnimation: _pulseController,
                    secondsRemaining: _secondsRemaining,
                    payload: _qrPayload,
                    errorMessage: _qrError,
                    isGenerating: _isGenerating,
                    onRefresh: () => _regeneratePayload(identity),
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
            );
          },
        ),
        identityAsync.maybeWhen(
          data: (identity) => _StudentDetailsPanel(identity: identity),
          orElse: () => const SizedBox.shrink(),
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
    required this.identity,
    required this.pulseAnimation,
    required this.secondsRemaining,
    required this.payload,
    required this.errorMessage,
    required this.isGenerating,
    required this.onRefresh,
  });

  final StudentQrIdentityModel identity;
  final Animation<double> pulseAnimation;
  final int secondsRemaining;
  final String? payload;
  final String? errorMessage;
  final bool isGenerating;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = secondsRemaining / 30;
    final qrBackground = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.surface;
    final qrForeground = colorScheme.brightness == Brightness.dark
        ? colorScheme.surface
        : colorScheme.onSurface;

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
                          identity.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          identity.rollNo,
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
                  width: 226,
                  height: 226,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: qrBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.38),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: payload == null || isGenerating
                        ? _QrLoadingBox(
                            key: const ValueKey('qr-loading'),
                            foreground: qrForeground,
                            background: qrBackground,
                          )
                        : QrImageView(
                            key: ValueKey(payload),
                            data: payload!,
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                            padding: EdgeInsets.zero,
                            backgroundColor: qrBackground,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: qrForeground,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: qrForeground,
                            ),
                          ),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                ModuleInfoTile(
                  title: 'QR refresh failed',
                  subtitle: errorMessage!,
                  icon: Icons.error_rounded,
                  color: colorScheme.error,
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isGenerating
                          ? 'Refreshing QR...'
                          : 'Refreshes in ${secondsRemaining}s',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Refresh QR',
                    onPressed: isGenerating ? null : onRefresh,
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.autorenew_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: isGenerating ? null : progress,
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

class _QrLoadingBox extends StatelessWidget {
  const _QrLoadingBox({
    super.key,
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
      ),
    );
  }
}

class _StudentDetailsPanel extends StatelessWidget {
  const _StudentDetailsPanel({required this.identity});

  final StudentQrIdentityModel identity;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ModuleInfoTile(
            title: identity.name,
            subtitle: 'Name',
            icon: Icons.person_rounded,
            color: AppColors.cyan,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: identity.rollNo,
            subtitle: 'Roll No',
            icon: Icons.badge_rounded,
            color: AppColors.blue,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: identity.departmentName ?? 'Not linked',
            subtitle: 'Department',
            icon: Icons.account_tree_rounded,
            color: AppColors.amber,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: identity.semesterName ?? 'Not linked',
            subtitle: 'Semester',
            icon: Icons.school_rounded,
            color: const Color(0xFFB48CFF),
          ),
        ],
      ),
    );
  }
}

class _QrStatePanel extends StatelessWidget {
  const _QrStatePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ModuleInfoTile(
            title: title,
            subtitle: subtitle,
            icon: icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
