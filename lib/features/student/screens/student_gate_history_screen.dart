import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/features/student/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentGateHistoryScreen extends ConsumerWidget {
  const StudentGateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateLogsAsync = ref.watch(studentGateLogsProvider);

    final children = gateLogsAsync.when(
      loading: () => <Widget>[
        const _GateLoadingPanel(),
        const _EntryExitLogicCard(),
      ],
      error: (error, _) => <Widget>[
        _GateErrorPanel(message: _cleanErrorMessage(error)),
        const _EntryExitLogicCard(),
      ],
      data: (logs) => <Widget>[
        _CurrentStatusCard(logs: logs),
        _TodayTimelineCard(events: _todayLogs(logs)),
        _ParentNotificationCard(latestLog: logs.isEmpty ? null : logs.first),
        const _EntryExitLogicCard(),
      ],
    );

    return ModuleScreenShell(
      title: 'Gate History',
      subtitle: 'Campus entry and exit activity from backend.',
      fallbackRoute: AppRoutes.student,
      children: children,
    );
  }
}

class _GateLoadingPanel extends StatelessWidget {
  const _GateLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading gate history',
        subtitle: 'Fetching your campus gate logs from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _GateErrorPanel extends StatelessWidget {
  const _GateErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load gate history',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
        trailing: ModuleBadge(label: 'Error', color: colorScheme.error),
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({required this.logs});

  final List<GateLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final latestLog = logs.isEmpty ? null : logs.first;
    final isInside = latestLog?.status == 'entry';
    final accent = latestLog == null
        ? colorScheme.error
        : isInside
        ? colorScheme.secondary
        : colorScheme.tertiary;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _studentName(latestLog),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Roll No: ${_rollNo(latestLog)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ModuleBadge(
                label: _statusBadge(latestLog),
                icon: _statusIcon(latestLog),
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: _campusStatus(latestLog),
            subtitle: 'Current campus status',
            icon: isInside
                ? Icons.location_on_rounded
                : Icons.location_off_rounded,
            color: accent,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Last Scan',
                  value: _lastScanText(latestLog),
                  icon: Icons.schedule_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Gate',
                  value: _gateText(latestLog),
                  icon: Icons.meeting_room_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            latestLog == null
                ? 'No gate scan has been saved for this student yet.'
                : 'Next gate scan will be recorded as ${_nextAction(latestLog)}.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayTimelineCard extends StatelessWidget {
  const _TodayTimelineCard({required this.events});

  final List<GateLogModel> events;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Today Timeline',
            icon: Icons.timeline_rounded,
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            ModuleInfoTile(
              title: 'No gate scans today',
              subtitle: 'Today\'s entry and exit logs will appear here.',
              icon: Icons.inbox_rounded,
              color: colorScheme.error,
            )
          else
            for (final event in events) ...[
              _TimelineEventCard(event: event),
              if (event != events.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({required this.event});

  final GateLogModel event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEntry = event.status == 'entry';
    final accent = isEntry ? colorScheme.secondary : colorScheme.tertiary;
    final action = _actionLabel(event.status);

    return ModuleInfoTile(
      title: '${_formatTime(event.time)}, $action',
      subtitle: '${event.gateLocation} - ${_emailStatus(event)}',
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

class _ParentNotificationCard extends StatelessWidget {
  const _ParentNotificationCard({required this.latestLog});

  final GateLogModel? latestLog;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sent = latestLog?.parentEmailSent ?? false;
    final accent = sent ? colorScheme.secondary : colorScheme.primary;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleInfoTile(
            title: 'Parent Alert',
            subtitle: sent
                ? 'Email notification was marked as sent.'
                : 'Parent email notification is planned for this flow.',
            icon: sent
                ? Icons.mark_email_read_rounded
                : Icons.pending_actions_rounded,
            color: accent,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.34),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent Email',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  latestLog?.parentEmail ?? 'Not configured',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ModuleBadge(
                  label: sent
                      ? 'Notification Status: Sent'
                      : 'Notification Status: Planned',
                  icon: sent
                      ? Icons.mark_email_read_rounded
                      : Icons.pending_actions_rounded,
                  color: accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryExitLogicCard extends StatelessWidget {
  const _EntryExitLogicCard();

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
            title: 'Entry/Exit Logic',
            icon: Icons.rule_folder_rounded,
          ),
          const SizedBox(height: 10),
          Text(
            'EduVision checks the student\'s previous gate activity and '
            'automatically assigns the next action.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(label: '1st Scan = Entry'),
              ModuleBadge(label: '2nd Scan = Exit'),
              ModuleBadge(label: '3rd Scan = Entry'),
              ModuleBadge(label: '4th Scan = Exit'),
            ],
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

List<GateLogModel> _todayLogs(List<GateLogModel> logs) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayLogs = logs.where((log) {
    final localDate = log.date.toLocal();
    final logDate = DateTime(localDate.year, localDate.month, localDate.day);

    return logDate == today;
  }).toList();

  todayLogs.sort((a, b) => a.time.compareTo(b.time));

  return todayLogs;
}

String _studentName(GateLogModel? log) {
  final name = log?.studentName?.trim();

  if (name != null && name.isNotEmpty) {
    return name;
  }

  return 'Student';
}

String _rollNo(GateLogModel? log) {
  final rollNo = log?.rollNo?.trim();

  if (rollNo != null && rollNo.isNotEmpty) {
    return rollNo;
  }

  return '--';
}

String _statusBadge(GateLogModel? log) {
  if (log == null) {
    return 'Not Scanned';
  }

  return log.status == 'entry' ? 'Entry Active' : 'Exit Active';
}

String _campusStatus(GateLogModel? log) {
  if (log == null) {
    return 'No Gate Scan Yet';
  }

  return log.status == 'entry' ? 'Inside University' : 'Outside University';
}

String _lastScanText(GateLogModel? log) {
  if (log == null || log.time.trim().isEmpty) {
    return '--';
  }

  return _formatTime(log.time);
}

String _gateText(GateLogModel? log) {
  final gate = log?.gateLocation.trim();

  if (gate == null || gate.isEmpty) {
    return '--';
  }

  return gate.replaceAll(' Gate', '');
}

String _nextAction(GateLogModel log) {
  return log.status == 'entry' ? 'Exit' : 'Entry';
}

String _actionLabel(String status) {
  return status == 'entry' ? 'Entry' : 'Exit';
}

String _emailStatus(GateLogModel log) {
  return log.parentEmailSent ? 'Parent Email Sent' : 'Email Planned';
}

IconData _statusIcon(GateLogModel? log) {
  if (log == null) {
    return Icons.qr_code_2_rounded;
  }

  return log.status == 'entry' ? Icons.login_rounded : Icons.logout_rounded;
}

String _formatTime(String value) {
  final parts = value.trim().split(':');

  if (parts.length < 2) {
    return value;
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
