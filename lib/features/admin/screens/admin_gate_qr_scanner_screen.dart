import 'dart:async';

import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/features/admin/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminGateQrScannerScreen extends ConsumerStatefulWidget {
  const AdminGateQrScannerScreen({super.key});

  @override
  ConsumerState<AdminGateQrScannerScreen> createState() =>
      _AdminGateQrScannerScreenState();
}

class _AdminGateQrScannerScreenState
    extends ConsumerState<AdminGateQrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final MobileScannerController _scannerController;
  final TextEditingController _manualPayloadController =
      TextEditingController();
  GateLogModel? _scanResult;
  String? _statusMessage;
  bool _isProcessing = false;
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
    if (_isProcessing) {
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
      showModuleSnackBar(context, 'Paste or scan a valid Gate Access QR.');
      return;
    }

    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _scanResult = null;
      _statusMessage = null;
    });

    await _pauseScanner();

    if (!mounted) {
      return;
    }

    final result = await ref
        .read(adminGateRepositoryProvider)
        .createNextGateLogFromQrPayload(
          payload: trimmedPayload,
          gateLocation: 'Main Gate',
        );

    if (!mounted) {
      return;
    }

    if (result case Success<GateLogModel>(:final data)) {
      setState(() {
        _isProcessing = false;
        _scanResult = data;
        _statusMessage = '${_actionLabel(data.status)} recorded successfully.';
      });
      ref.invalidate(adminGateLogsProvider);
      showModuleSnackBar(context, _statusMessage!);
      return;
    }

    if (result case Failure<GateLogModel>(:final exception)) {
      setState(() {
        _isProcessing = false;
        _statusMessage = exception.message;
      });
      showModuleSnackBar(context, exception.message);
    }
  }

  Future<void> _pauseScanner() async {
    try {
      await _scannerController.stop();
    } catch (_) {
      // Camera startup can race with manual paste; resume handles restart.
    }

    if (mounted) {
      setState(() {
        _scannerPaused = true;
      });
    }
  }

  Future<void> _resumeScanner() async {
    setState(() {
      _isProcessing = false;
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
        _statusMessage = 'Unable to restart the gate QR camera.';
      });
      showModuleSnackBar(context, _statusMessage!);
    }
  }

  Future<void> _pastePayloadFromClipboard() async {
    if (_isProcessing) {
      return;
    }

    final data = await Clipboard.getData('text/plain');

    if (!mounted) {
      return;
    }

    final payload = data?.text?.trim();

    if (payload == null || payload.isEmpty) {
      showModuleSnackBar(context, 'Clipboard does not contain a Gate QR.');
      return;
    }

    _manualPayloadController.text = payload;
    _manualPayloadController.selection = TextSelection.collapsed(
      offset: payload.length,
    );
    showModuleSnackBar(context, 'Gate QR payload pasted from clipboard.');
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

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Gate QR Scanner',
      subtitle: 'Scan Gate Access QR to save campus entry or exit.',
      fallbackRoute: AppRoutes.adminGateLogs,
      children: [
        ModulePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _ScannerFrame(
                animation: _scanController,
                controller: _scannerController,
                isProcessing: _isProcessing,
                scannerPaused: _scannerPaused,
                onDetect: _handleDetect,
              ),
              const SizedBox(height: 12),
              Text(
                _isProcessing
                    ? 'Saving gate scan...'
                    : _scannerPaused
                    ? 'Scanner paused'
                    : 'Align student Gate Access QR inside the frame',
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
                    onPressed: _isProcessing ? null : _toggleTorch,
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
                    onPressed: _isProcessing ? null : _switchCamera,
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
                  isLoading: _isProcessing,
                  onPressed: _isProcessing
                      ? null
                      : () => unawaited(_resumeScanner()),
                ),
              ],
            ],
          ),
        ),
        _ManualPayloadPanel(
          controller: _manualPayloadController,
          isProcessing: _isProcessing,
          onPasteFromClipboard: () => unawaited(_pastePayloadFromClipboard()),
          onSubmit: () => _processPayload(_manualPayloadController.text),
        ),
        if (_statusMessage != null && _scanResult == null)
          _StatusPanel(message: _statusMessage!),
        if (_scanResult != null) ...[
          _ScanResultCard(result: _scanResult!),
          _ParentEmailNote(log: _scanResult!),
        ],
      ],
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({
    required this.animation,
    required this.controller,
    required this.isProcessing,
    required this.scannerPaused,
    required this.onDetect,
  });

  final Animation<double> animation;
  final MobileScannerController controller;
  final bool isProcessing;
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
            if (isProcessing || scannerPaused)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                  ),
                  child: Center(
                    child: isProcessing
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
                'Paste a Gate Access QR payload when camera scanning is unavailable.',
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
              labelText: 'Pasted Gate QR payload',
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
            label: 'Process Gate QR',
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

  final GateLogModel result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEntry = result.status == 'entry';
    final accent = isEntry ? colorScheme.secondary : colorScheme.tertiary;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ModuleBadge(
            label: '${_actionLabel(result.status)} recorded',
            icon: isEntry ? Icons.login_rounded : Icons.logout_rounded,
            color: accent,
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: _studentName(result),
            subtitle: 'Student',
            icon: Icons.person_rounded,
            color: AppColors.cyan,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: _rollNo(result),
            subtitle: 'Roll No',
            icon: Icons.badge_rounded,
            color: AppColors.blue,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.departmentName ?? 'Not linked',
            subtitle: 'Department',
            icon: Icons.account_tree_rounded,
            color: AppColors.amber,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.batchName ?? 'Not linked',
            subtitle: 'Batch',
            icon: Icons.groups_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: result.semesterName ?? 'Not linked',
            subtitle: 'Semester',
            icon: Icons.school_rounded,
            color: const Color(0xFFB48CFF),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  label: 'Action',
                  value: _actionLabel(result.status),
                  icon: isEntry ? Icons.login_rounded : Icons.logout_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailBox(
                  label: 'Campus Status',
                  value: _campusStatus(result),
                  icon: isEntry
                      ? Icons.location_on_rounded
                      : Icons.location_off_rounded,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  label: 'Time',
                  value: _formatTime(result.time),
                  icon: Icons.schedule_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailBox(
                  label: 'Gate',
                  value: result.gateLocation,
                  icon: Icons.sensor_door_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
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
        title: 'Gate QR not accepted',
        subtitle: message,
        icon: Icons.info_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _ParentEmailNote extends StatelessWidget {
  const _ParentEmailNote({required this.log});

  final GateLogModel log;

  @override
  Widget build(BuildContext context) {
    final status = _parentEmailStatus(log);

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: status.title,
        subtitle: status.subtitle,
        icon: status.icon,
        color: status.color,
      ),
    );
  }
}

class _ParentEmailStatus {
  const _ParentEmailStatus({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

_ParentEmailStatus _parentEmailStatus(GateLogModel log) {
  final status = log.parentEmailNotificationStatus?.trim().toLowerCase();
  final message = log.parentEmailNotificationMessage?.trim();

  if (log.parentEmailSent || status == 'sent') {
    return const _ParentEmailStatus(
      title: 'Parent Email: Sent',
      subtitle: 'Parent was notified through the secure backend service.',
      icon: Icons.mark_email_read_rounded,
      color: AppColors.cyan,
    );
  }

  if (status == 'provider_not_configured') {
    return _ParentEmailStatus(
      title: 'Parent Email: Pending',
      subtitle: _displayMessage(message, 'Email provider not configured.'),
      icon: Icons.mark_email_unread_rounded,
      color: AppColors.amber,
    );
  }

  if (status == 'parent_email_missing') {
    return _ParentEmailStatus(
      title: 'Parent Email: Parent email not available',
      subtitle: _displayMessage(
        message,
        'No parent email is saved for this student.',
      ),
      icon: Icons.contact_mail_rounded,
      color: AppColors.amber,
    );
  }

  if (status == 'failed') {
    return _ParentEmailStatus(
      title: 'Parent Email: Failed, Gate Log Saved',
      subtitle: _displayMessage(
        message,
        'The gate log was saved, but the email could not be sent.',
      ),
      icon: Icons.mark_email_unread_rounded,
      color: AppColors.amber,
    );
  }

  return _ParentEmailStatus(
    title: 'Parent Email: Pending',
    subtitle: _displayMessage(
      message,
      'Parent email notification is waiting for backend confirmation.',
    ),
    icon: Icons.mark_email_unread_rounded,
    color: AppColors.amber,
  );
}

String _displayMessage(String? message, String fallback) {
  if (message == null || message.isEmpty) {
    return fallback;
  }

  return message;
}

String _studentName(GateLogModel log) {
  final name = log.studentName?.trim();

  if (name != null && name.isNotEmpty) {
    return name;
  }

  return 'Student';
}

String _rollNo(GateLogModel log) {
  final rollNo = log.rollNo?.trim();

  if (rollNo != null && rollNo.isNotEmpty) {
    return rollNo;
  }

  return '--';
}

String _actionLabel(String status) {
  return status == 'entry' ? 'Entry' : 'Exit';
}

String _campusStatus(GateLogModel log) {
  return log.status == 'entry' ? 'Inside University' : 'Outside University';
}

String _formatTime(String value) {
  final parts = value.trim().split(':');

  if (parts.length < 2) {
    return '--';
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) {
    return value;
  }

  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0
      ? 12
      : hour > 12
      ? hour - 12
      : hour;
  final displayMinute = minute.toString().padLeft(2, '0');

  return '$displayHour:$displayMinute $period';
}
