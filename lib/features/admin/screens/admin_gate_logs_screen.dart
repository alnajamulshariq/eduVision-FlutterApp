import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/features/admin/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminGateLogsScreen extends ConsumerStatefulWidget {
  const AdminGateLogsScreen({super.key});

  @override
  ConsumerState<AdminGateLogsScreen> createState() =>
      _AdminGateLogsScreenState();
}

class _AdminGateLogsScreenState extends ConsumerState<AdminGateLogsScreen> {
  bool _isVerifying = false;
  GateLogModel? _recordedLog;

  Future<void> _simulateGateScan() async {
    if (_isVerifying) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _recordedLog = null;
    });

    final result = await ref
        .read(adminGateRepositoryProvider)
        .createNextGateLogForFirstActiveStudent(gateLocation: 'Main Gate');

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<GateLogModel>(:final data):
        setState(() {
          _isVerifying = false;
          _recordedLog = data;
        });
        ref.invalidate(adminGateLogsProvider);
        showModuleSnackBar(
          context,
          '${_actionLabel(data.status)} recorded successfully.',
        );
      case Failure<GateLogModel>(:final exception):
        setState(() {
          _isVerifying = false;
          _recordedLog = null;
        });
        showModuleSnackBar(context, exception.message);
    }
  }

  void _resetPreview() {
    setState(() {
      _isVerifying = false;
      _recordedLog = null;
    });
    showModuleSnackBar(context, 'Gate scan preview reset.');
  }

  @override
  Widget build(BuildContext context) {
    final gateLogsAsync = ref.watch(adminGateLogsProvider);
    final logs = gateLogsAsync.maybeWhen(
      data: (logs) => logs,
      orElse: () => const <GateLogModel>[],
    );

    return ModuleScreenShell(
      title: 'Gate Logs',
      subtitle: 'Campus entry and exit records from backend.',
      fallbackRoute: AppRoutes.admin,
      children: [
        _GateOverviewSummary(logs: logs),
        _SimulatedGateScanCard(
          isVerifying: _isVerifying,
          latestLog: logs.isEmpty ? null : logs.first,
          recordedLog: _recordedLog,
          onSimulate: _simulateGateScan,
          onReset: _resetPreview,
        ),
        const _FilterChipsCard(),
        gateLogsAsync.when(
          loading: () => const _GateLogsLoadingPanel(),
          error: (error, _) =>
              _GateLogsErrorPanel(message: _cleanErrorMessage(error)),
          data: (logs) => _GateLogsList(logs: logs),
        ),
      ],
    );
  }
}

class _GateOverviewSummary extends StatelessWidget {
  const _GateOverviewSummary({required this.logs});

  final List<GateLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latestByStudent = _latestLogsByStudent(logs);
    final insideCount = latestByStudent.values
        .where((log) => log.status == 'entry')
        .length;
    final outsideCount = latestByStudent.values
        .where((log) => log.status == 'exit')
        .length;
    final emailCount = logs.where((log) => log.parentEmailSent).length;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Gate Overview Summary',
            icon: Icons.security_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Inside',
                  value: insideCount.toString(),
                  icon: Icons.location_on_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Outside',
                  value: outsideCount.toString(),
                  icon: Icons.location_off_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Scans',
                  value: logs.length.toString(),
                  icon: Icons.qr_code_2_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Emails',
                  value: emailCount.toString(),
                  icon: Icons.mark_email_read_rounded,
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

class _SimulatedGateScanCard extends StatelessWidget {
  const _SimulatedGateScanCard({
    required this.isVerifying,
    required this.latestLog,
    required this.recordedLog,
    required this.onSimulate,
    required this.onReset,
  });

  final bool isVerifying;
  final GateLogModel? latestLog;
  final GateLogModel? recordedLog;
  final VoidCallback onSimulate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayLog = recordedLog ?? latestLog;
    final isInside = displayLog?.status == 'entry';
    final accent = displayLog == null
        ? colorScheme.error
        : isInside
        ? colorScheme.secondary
        : colorScheme.tertiary;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Simulated Gate Scan',
            icon: Icons.qr_code_scanner_rounded,
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: _studentName(displayLog),
            subtitle: 'Roll No: ${_rollNo(displayLog)}',
            icon: Icons.person_rounded,
            color: colorScheme.primary,
            trailing: ModuleBadge(
              label: _campusShortStatus(displayLog),
              icon: isInside
                  ? Icons.location_on_rounded
                  : Icons.location_off_rounded,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  label: 'Current Status',
                  value: _campusStatus(displayLog),
                  icon: isInside
                      ? Icons.location_on_rounded
                      : Icons.location_off_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailBox(
                  label: 'Next Scan Action',
                  value: _nextAction(displayLog),
                  icon: displayLog?.status == 'entry'
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (isVerifying || recordedLog != null) ...[
            const SizedBox(height: 12),
            _ScanResultBox(isVerifying: isVerifying, recordedLog: recordedLog),
          ],
          const SizedBox(height: 12),
          Text(
            'The demo scan saves the next entry or exit action for the first active student.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: isVerifying
                ? 'Verifying dynamic QR...'
                : 'Simulate Gate Scan',
            icon: Icons.qr_code_scanner_rounded,
            isLoading: isVerifying,
            minHeight: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onPressed: isVerifying ? null : onSimulate,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isVerifying ? null : onReset,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Reset Preview'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanResultBox extends StatelessWidget {
  const _ScanResultBox({required this.isVerifying, required this.recordedLog});

  final bool isVerifying;
  final GateLogModel? recordedLog;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = recordedLog?.status == 'entry'
        ? colorScheme.secondary
        : colorScheme.tertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isVerifying ? colorScheme.primary : successColor).withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isVerifying ? colorScheme.primary : successColor).withValues(
            alpha: 0.26,
          ),
        ),
      ),
      child: isVerifying
          ? Row(
              children: [
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verifying dynamic QR...',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_actionLabel(recordedLog?.status ?? '')} recorded successfully',
                  style: textTheme.bodyMedium?.copyWith(
                    color: successColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recordedLog?.parentEmailSent ?? false
                      ? 'Parent email notification sent'
                      : 'Parent email notification planned',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ModuleBadge(
                  label: 'Time: ${_formatTime(recordedLog?.time ?? '')}',
                  icon: Icons.schedule_rounded,
                  color: successColor,
                ),
              ],
            ),
    );
  }
}

class _FilterChipsCard extends StatelessWidget {
  const _FilterChipsCard();

  @override
  Widget build(BuildContext context) {
    return const ModulePanel(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Filters', icon: Icons.tune_rounded),
          SizedBox(height: 12),
          ModuleChipRow(labels: ['Latest First', 'Entry', 'Exit', 'Main Gate']),
        ],
      ),
    );
  }
}

class _GateLogsLoadingPanel extends StatelessWidget {
  const _GateLogsLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading gate logs',
        subtitle: 'Fetching saved campus scans from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _GateLogsErrorPanel extends StatelessWidget {
  const _GateLogsErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load gate logs',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
        trailing: ModuleBadge(label: 'Error', color: colorScheme.error),
      ),
    );
  }
}

class _GateLogsList extends StatelessWidget {
  const _GateLogsList({required this.logs});

  final List<GateLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Gate Logs List',
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            ModuleInfoTile(
              title: 'No gate logs found',
              subtitle: 'Use the simulated gate scan to save the first log.',
              icon: Icons.inbox_rounded,
              color: colorScheme.error,
            )
          else
            for (final log in logs) ...[
              _GateLogCard(log: log),
              if (log != logs.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _GateLogCard extends StatelessWidget {
  const _GateLogCard({required this.log});

  final GateLogModel log;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEntry = log.status == 'entry';
    final accent = isEntry ? colorScheme.secondary : colorScheme.tertiary;
    final action = _actionLabel(log.status);

    return ModuleInfoTile(
      title: _studentName(log),
      subtitle:
          '$action, ${_formatTime(log.time)}, ${_formatDate(log.date)}, ${log.gateLocation}, ${_emailStatus(log)}',
      icon: isEntry ? Icons.login_rounded : Icons.logout_rounded,
      color: accent,
      trailing: ModuleBadge(
        label: action,
        icon: isEntry ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
        color: accent,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

Map<String, GateLogModel> _latestLogsByStudent(List<GateLogModel> logs) {
  final latestByStudent = <String, GateLogModel>{};

  for (final log in logs) {
    latestByStudent.putIfAbsent(log.studentId, () => log);
  }

  return latestByStudent;
}

String _studentName(GateLogModel? log) {
  final name = log?.studentName?.trim();

  if (name != null && name.isNotEmpty) {
    return name;
  }

  return 'Active Student';
}

String _rollNo(GateLogModel? log) {
  final rollNo = log?.rollNo?.trim();

  if (rollNo != null && rollNo.isNotEmpty) {
    return rollNo;
  }

  return '--';
}

String _campusShortStatus(GateLogModel? log) {
  if (log == null) {
    return 'No Scan';
  }

  return log.status == 'entry' ? 'Inside' : 'Outside';
}

String _campusStatus(GateLogModel? log) {
  if (log == null) {
    return 'No Gate Scan Yet';
  }

  return log.status == 'entry' ? 'Inside University' : 'Outside University';
}

String _nextAction(GateLogModel? log) {
  return log?.status == 'entry' ? 'Exit' : 'Entry';
}

String _actionLabel(String status) {
  return status == 'entry' ? 'Entry' : 'Exit';
}

String _emailStatus(GateLogModel log) {
  return log.parentEmailSent ? 'Email Sent' : 'Email Planned';
}

String _formatDate(DateTime value) {
  final localValue = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final logDate = DateTime(localValue.year, localValue.month, localValue.day);

  if (logDate == today) {
    return 'Today';
  }

  if (logDate == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }

  final day = localValue.day.toString().padLeft(2, '0');
  final month = localValue.month.toString().padLeft(2, '0');
  final year = localValue.year.toString();

  return '$day/$month/$year';
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

String _cleanErrorMessage(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
