import 'dart:async';

import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/data/models/dynamic_qr_model.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:eduvision_app/features/teacher/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TeacherQrScannerScreen extends ConsumerStatefulWidget {
  const TeacherQrScannerScreen({super.key});

  @override
  ConsumerState<TeacherQrScannerScreen> createState() =>
      _TeacherQrScannerScreenState();
}

class _TeacherQrScannerScreenState extends ConsumerState<TeacherQrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final MobileScannerController _scannerController;
  final TextEditingController _manualPayloadController =
      TextEditingController();
  QrAttendanceMarkResult? _scanResult;
  String? _statusMessage;
  bool _isVerifying = false;
  bool _scannerPaused = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _manualPayloadController.dispose();
    _scanController.dispose();
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_isVerifying) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final payload = barcode.rawValue?.trim();

      if (payload != null && payload.isNotEmpty) {
        unawaited(_processPayload(payload));
        return;
      }
    }
  }

  Future<void> _processPayload(String payload) async {
    final trimmedPayload = payload.trim();

    if (trimmedPayload.isEmpty) {
      showModuleSnackBar(context, 'Paste or scan a valid QR payload.');
      return;
    }

    if (_isVerifying) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _scanResult = null;
      _statusMessage = null;
    });

    await _pauseScanner();

    final currentUser = ref.read(authControllerProvider).user;

    if (currentUser == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
        _statusMessage = 'Please log in as a teacher before scanning QR.';
      });
      showModuleSnackBar(context, _statusMessage!);
      return;
    }

    final result = await ref
        .read(teacherAttendanceRepositoryProvider)
        .markDynamicQrAttendanceFromPayload(
          teacherUserId: currentUser.id,
          payload: trimmedPayload,
        );

    if (!mounted) {
      return;
    }

    if (result case Success<QrAttendanceMarkResult>(:final data)) {
      setState(() {
        _isVerifying = false;
        _scanResult = data;
        _statusMessage = data.message;
      });
      showModuleSnackBar(context, data.message);
      return;
    }

    if (result case Failure<QrAttendanceMarkResult>(:final exception)) {
      setState(() {
        _isVerifying = false;
        _statusMessage = exception.message;
      });
      showModuleSnackBar(context, exception.message);
    }
  }

  Future<void> _pauseScanner() async {
    try {
      await _scannerController.stop();
    } catch (_) {
      // The camera may still be starting up; the next manual resume will start it.
    }

    if (mounted) {
      setState(() {
        _scannerPaused = true;
      });
    }
  }

  Future<void> _resumeScanner() async {
    setState(() {
      _isVerifying = false;
      _scanResult = null;
      _statusMessage = null;
      _scannerPaused = false;
    });

    try {
      await _scannerController.start();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _scannerPaused = true;
        _statusMessage = 'Unable to restart the camera scanner.';
      });
      showModuleSnackBar(context, _statusMessage!);
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (_) {
      if (mounted) {
        showModuleSnackBar(context, 'Unable to switch camera.');
      }
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
    } catch (_) {
      if (mounted) {
        showModuleSnackBar(context, 'Torch is not available on this device.');
      }
    }
  }

  Future<void> _pastePayloadFromClipboard() async {
    if (_isVerifying) {
      return;
    }

    final data = await Clipboard.getData('text/plain');

    if (!mounted) {
      return;
    }

    final payload = data?.text?.trim();

    if (payload == null || payload.isEmpty) {
      showModuleSnackBar(context, 'Clipboard does not contain a QR payload.');
      return;
    }

    _manualPayloadController.text = payload;
    _manualPayloadController.selection = TextSelection.collapsed(
      offset: payload.length,
    );
    showModuleSnackBar(context, 'QR payload pasted from clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'QR Scanner',
      subtitle: 'Scan student dynamic QR for active attendance sessions.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        ModulePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _ScannerFrame(
                animation: _scanController,
                controller: _scannerController,
                isVerifying: _isVerifying,
                scannerPaused: _scannerPaused,
                onDetect: _handleDetect,
              ),
              const SizedBox(height: 12),
              Text(
                _isVerifying
                    ? 'Saving dynamic QR attendance...'
                    : _scannerPaused
                    ? 'Scanner paused'
                    : 'Align student QR inside the frame',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Toggle torch',
                    onPressed: _isVerifying ? null : _toggleTorch,
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.flash_on_rounded),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Switch camera',
                    onPressed: _isVerifying ? null : _switchCamera,
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.cameraswitch_rounded),
                  ),
                ],
              ),
              if (_scannerPaused || _scanResult != null) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Scan Next QR',
                  icon: Icons.restart_alt_rounded,
                  minHeight: 48,
                  isLoading: _isVerifying,
                  onPressed: _isVerifying
                      ? null
                      : () => unawaited(_resumeScanner()),
                ),
              ],
            ],
          ),
        ),
        _ManualPayloadPanel(
          controller: _manualPayloadController,
          isProcessing: _isVerifying,
          onPasteFromClipboard: () => unawaited(_pastePayloadFromClipboard()),
          onSubmit: () => _processPayload(_manualPayloadController.text),
        ),
        if (_statusMessage != null && _scanResult == null)
          _StatusPanel(message: _statusMessage!),
        if (_scanResult != null) ...[
          _ScanResultCard(result: _scanResult!),
          _ValidationChecklist(alreadyMarked: _scanResult!.alreadyMarked),
        ],
      ],
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({
    required this.animation,
    required this.controller,
    required this.isVerifying,
    required this.scannerPaused,
    required this.onDetect,
  });

  final Animation<double> animation;
  final MobileScannerController controller;
  final bool isVerifying;
  final bool scannerPaused;
  final void Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.34),
          width: 1.4,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                onDetect: onDetect,
                placeholderBuilder: (context) => _ScannerPlaceholder(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Starting camera...',
                ),
                errorBuilder: (context, error) => _ScannerPlaceholder(
                  icon: Icons.videocam_off_rounded,
                  label:
                      'Camera unavailable. Use pasted payload for emulator testing.',
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: _ScannerOverlay(animation: animation),
              ),
            ),
            if (isVerifying || scannerPaused)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                  ),
                  child: Center(
                    child: isVerifying
                        ? CircularProgressIndicator(
                            color: colorScheme.secondary,
                            strokeWidth: 2.4,
                          )
                        : Icon(
                            Icons.pause_circle_filled_rounded,
                            color: colorScheme.primary,
                            size: 52,
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

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
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
    );
  }
}

class _ScannerPlaceholder extends StatelessWidget {
  const _ScannerPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface.withValues(alpha: 0.86),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary, size: 52),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
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

class _ManualPayloadPanel extends StatelessWidget {
  const _ManualPayloadPanel({
    required this.controller,
    required this.isProcessing,
    required this.onPasteFromClipboard,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isProcessing;
  final VoidCallback onPasteFromClipboard;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleInfoTile(
            title: 'Emulator testing',
            subtitle:
                'Paste a student QR payload when camera scanning is unavailable.',
            icon: Icons.content_paste_go_rounded,
            color: AppColors.amber,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !isProcessing,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Pasted QR payload',
              prefixIcon: Icon(Icons.qr_code_2_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: isProcessing ? null : onPasteFromClipboard,
              icon: const Icon(Icons.content_paste_rounded, size: 18),
              label: const Text('Paste from Clipboard'),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Process Pasted QR',
            icon: Icons.playlist_add_check_rounded,
            minHeight: 48,
            isLoading: isProcessing,
            onPressed: isProcessing ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.result});

  final QrAttendanceMarkResult result;

  @override
  Widget build(BuildContext context) {
    final badgeColor = result.alreadyMarked ? AppColors.amber : AppColors.cyan;

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
            child: ModuleBadge(
              label: result.alreadyMarked ? 'Duplicate' : 'Verified',
              icon: result.alreadyMarked
                  ? Icons.info_rounded
                  : Icons.check_circle_rounded,
              color: badgeColor,
            ),
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: result.studentName,
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
            title: DateFormat('hh:mm a').format(result.markedAt),
            subtitle: 'Time',
            icon: Icons.access_time_filled_rounded,
            color: const Color(0xFFFF8A7A),
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.message,
            subtitle: 'Result',
            icon: Icons.fact_check_rounded,
            color: badgeColor,
          ),
        ],
      ),
    );
  }
}

class _ValidationChecklist extends StatelessWidget {
  const _ValidationChecklist({required this.alreadyMarked});

  final bool alreadyMarked;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          const _ValidationRow(label: 'QR token validated'),
          const SizedBox(height: 8),
          const _ValidationRow(label: 'Active attendance session found'),
          const SizedBox(height: 8),
          const _ValidationRow(label: 'Student enrollment checked'),
          const SizedBox(height: 8),
          _ValidationRow(
            label: alreadyMarked
                ? 'Existing attendance record protected'
                : 'attendance_records saved with dynamic_qr',
          ),
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

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'QR not accepted',
        subtitle: message,
        icon: Icons.info_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
