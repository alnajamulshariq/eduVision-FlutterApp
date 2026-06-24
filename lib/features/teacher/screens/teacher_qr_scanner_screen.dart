import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeacherQrScannerScreen extends StatefulWidget {
  const TeacherQrScannerScreen({super.key});

  @override
  State<TeacherQrScannerScreen> createState() => _TeacherQrScannerScreenState();
}

class _TeacherQrScannerScreenState extends State<TeacherQrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  _ScanResult? _scanResult;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _simulateScan() async {
    setState(() {
      _isVerifying = true;
      _scanResult = null;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    setState(() {
      _isVerifying = false;
      _scanResult = _ScanResult(
        student: 'Ali Khan',
        rollNo: 'BSIT-2022-001',
        method: 'Dynamic QR',
        status: 'Attendance marked',
        time: DateFormat('hh:mm a').format(DateTime.now()),
      );
    });
  }

  void _resetScan() {
    setState(() {
      _isVerifying = false;
      _scanResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'QR Scanner',
      subtitle: 'Scan student dynamic QR preview.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        ModulePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _ScannerFrame(animation: _scanController),
              const SizedBox(height: 12),
              Text(
                _isVerifying
                    ? 'Verifying dynamic QR...'
                    : 'Align student QR inside the frame',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: _isVerifying
                    ? 'Verifying dynamic QR...'
                    : 'Simulate QR Scan',
                icon: Icons.center_focus_strong_rounded,
                minHeight: 50,
                isLoading: _isVerifying,
                onPressed: _simulateScan,
              ),
              if (_scanResult != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _resetScan,
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Reset Scan'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_scanResult != null) ...[
          _ScanResultCard(result: _scanResult!),
          const _ValidationChecklist(),
        ],
      ],
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.34),
          width: 1.4,
        ),
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.qr_code_scanner_rounded, size: 76)),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.56),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final top = (constraints.maxHeight - 4) * animation.value;
                      return Stack(
                        children: [
                          Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.secondary.withValues(alpha: 0),
                                    colorScheme.secondary,
                                    colorScheme.secondary.withValues(alpha: 0),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.secondary.withValues(
                                      alpha: 0.36,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 26,
            child: _CornerMark(color: colorScheme.primary),
          ),
          Positioned(
            right: 26,
            top: 26,
            child: Transform.rotate(
              angle: 1.5708,
              child: _CornerMark(color: colorScheme.primary),
            ),
          ),
          Positioned(
            left: 26,
            bottom: 26,
            child: Transform.rotate(
              angle: -1.5708,
              child: _CornerMark(color: colorScheme.primary),
            ),
          ),
          Positioned(
            right: 26,
            bottom: 26,
            child: Transform.rotate(
              angle: 3.1416,
              child: _CornerMark(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  const _CornerMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 3),
            top: BorderSide(color: color, width: 3),
          ),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
        ),
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.result});

  final _ScanResult result;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.70, end: 1),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: const ModuleBadge(
              label: 'Verified',
              icon: Icons.check_circle_rounded,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: result.student,
            subtitle: 'Student',
            icon: Icons.person_rounded,
            color: AppColors.cyan,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.rollNo,
            subtitle: 'Roll No',
            icon: Icons.badge_rounded,
            color: AppColors.blue,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.method,
            subtitle: 'Method',
            icon: Icons.qr_code_2_rounded,
            color: AppColors.amber,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.status,
            subtitle: 'Status',
            icon: Icons.verified_rounded,
            color: const Color(0xFFB48CFF),
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.time,
            subtitle: 'Time',
            icon: Icons.access_time_filled_rounded,
            color: const Color(0xFFFF8A7A),
          ),
        ],
      ),
    );
  }
}

class _ValidationChecklist extends StatelessWidget {
  const _ValidationChecklist();

  @override
  Widget build(BuildContext context) {
    return const ModulePanel(
      padding: EdgeInsets.all(14),
      child: Column(
        children: [
          _ValidationRow(label: 'QR token verified'),
          SizedBox(height: 8),
          _ValidationRow(label: 'Student enrollment checked'),
          SizedBox(height: 8),
          _ValidationRow(label: 'Attendance method confirmed'),
          SizedBox(height: 8),
          _ValidationRow(label: 'Record ready for saving'),
        ],
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  const _ValidationRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanResult {
  const _ScanResult({
    required this.student,
    required this.rollNo,
    required this.method,
    required this.status,
    required this.time,
  });

  final String student;
  final String rollNo;
  final String method;
  final String status;
  final String time;
}
