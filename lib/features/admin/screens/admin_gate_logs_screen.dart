import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

const _gateLogs = [
  _GateLog(
    student: 'Ali Khan',
    action: 'Entry',
    time: '08:00 AM',
    gate: 'Main Gate',
    emailStatus: 'Email Sent',
  ),
  _GateLog(
    student: 'Ali Khan',
    action: 'Exit',
    time: '11:30 AM',
    gate: 'Main Gate',
    emailStatus: 'Email Sent',
  ),
  _GateLog(
    student: 'Ali Khan',
    action: 'Entry',
    time: '12:15 PM',
    gate: 'Main Gate',
    emailStatus: 'Email Sent',
  ),
  _GateLog(
    student: 'Sara Ahmed',
    action: 'Entry',
    time: '08:05 AM',
    gate: 'Main Gate',
    emailStatus: 'Email Sent',
  ),
  _GateLog(
    student: 'Ahmed Raza',
    action: 'Exit',
    time: '12:30 PM',
    gate: 'Main Gate',
    emailStatus: 'Email Sent',
  ),
];

class AdminGateLogsScreen extends StatefulWidget {
  const AdminGateLogsScreen({super.key});

  @override
  State<AdminGateLogsScreen> createState() => _AdminGateLogsScreenState();
}

class _AdminGateLogsScreenState extends State<AdminGateLogsScreen> {
  bool _isVerifying = false;
  bool _scanCompleted = false;
  String? _recordedTime;

  Future<void> _simulateGateScan() async {
    if (_isVerifying) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _scanCompleted = false;
      _recordedTime = null;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    setState(() {
      _isVerifying = false;
      _scanCompleted = true;
      _recordedTime = TimeOfDay.now().format(context);
    });

    showModuleSnackBar(context, 'Mock gate scan preview completed.');
  }

  void _resetPreview() {
    setState(() {
      _isVerifying = false;
      _scanCompleted = false;
      _recordedTime = null;
    });
    showModuleSnackBar(context, 'Gate scan preview reset.');
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Gate Logs',
      subtitle: 'Campus entry and exit records preview.',
      fallbackRoute: AppRoutes.admin,
      children: [
        const _GateOverviewSummary(),
        _SimulatedGateScanCard(
          isVerifying: _isVerifying,
          scanCompleted: _scanCompleted,
          recordedTime: _recordedTime,
          onSimulate: _simulateGateScan,
          onReset: _resetPreview,
        ),
        const _FilterChipsCard(),
        const _GateLogsList(logs: _gateLogs),
      ],
    );
  }
}

class _GateOverviewSummary extends StatelessWidget {
  const _GateOverviewSummary();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  value: '2',
                  icon: Icons.location_on_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Outside',
                  value: '1',
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
                  value: '5',
                  icon: Icons.qr_code_2_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Emails',
                  value: '5',
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
    required this.scanCompleted,
    required this.recordedTime,
    required this.onSimulate,
    required this.onReset,
  });

  final bool isVerifying;
  final bool scanCompleted;
  final String? recordedTime;
  final VoidCallback onSimulate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
            title: 'Ali Khan',
            subtitle: 'Roll No: BSIT-2022-001',
            icon: Icons.person_rounded,
            color: colorScheme.primary,
            trailing: ModuleBadge(
              label: 'Inside',
              icon: Icons.location_on_rounded,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  label: 'Current Status',
                  value: 'Inside University',
                  icon: Icons.location_on_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailBox(
                  label: 'Next Scan Action',
                  value: 'Exit',
                  icon: Icons.logout_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (isVerifying || scanCompleted) ...[
            const SizedBox(height: 12),
            _ScanResultBox(
              isVerifying: isVerifying,
              recordedTime: recordedTime,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Preview only: no real QR scan, backend save, or email is sent.',
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
  const _ScanResultBox({required this.isVerifying, required this.recordedTime});

  final bool isVerifying;
  final String? recordedTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isVerifying ? colorScheme.primary : colorScheme.secondary)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isVerifying ? colorScheme.primary : colorScheme.secondary)
              .withValues(alpha: 0.26),
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
                  'Exit recorded successfully',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Parent email notification sent',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ModuleBadge(
                  label: 'Time: ${recordedTime ?? '--'}',
                  icon: Icons.schedule_rounded,
                  color: colorScheme.secondary,
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
          ModuleChipRow(labels: ['Today', 'Entry', 'Exit', 'Main Gate']),
        ],
      ),
    );
  }
}

class _GateLogsList extends StatelessWidget {
  const _GateLogsList({required this.logs});

  final List<_GateLog> logs;

  @override
  Widget build(BuildContext context) {
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

  final _GateLog log;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEntry = log.action == 'Entry';
    final accent = isEntry ? colorScheme.secondary : colorScheme.tertiary;

    return ModuleInfoTile(
      title: log.student,
      subtitle: '${log.action}, ${log.time}, ${log.gate}, ${log.emailStatus}',
      icon: isEntry ? Icons.login_rounded : Icons.logout_rounded,
      color: accent,
      trailing: ModuleBadge(
        label: log.action,
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

class _GateLog {
  const _GateLog({
    required this.student,
    required this.action,
    required this.time,
    required this.gate,
    required this.emailStatus,
  });

  final String student;
  final String action;
  final String time;
  final String gate;
  final String emailStatus;
}
