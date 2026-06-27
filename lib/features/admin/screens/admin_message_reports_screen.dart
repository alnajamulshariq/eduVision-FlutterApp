import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/anonymous_message_model.dart';
import 'package:eduvision_app/features/admin/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminMessageReportsScreen extends ConsumerStatefulWidget {
  const AdminMessageReportsScreen({super.key});

  @override
  ConsumerState<AdminMessageReportsScreen> createState() =>
      _AdminMessageReportsScreenState();
}

class _AdminMessageReportsScreenState
    extends ConsumerState<AdminMessageReportsScreen> {
  final _revealedMessageIds = <String>{};

  void _toggleSenderReveal(String messageId) {
    setState(() {
      if (!_revealedMessageIds.add(messageId)) {
        _revealedMessageIds.remove(messageId);
      }
    });

    if (_revealedMessageIds.contains(messageId)) {
      showModuleSnackBar(context, 'Sender revealed for admin review.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportedMessagesProvider);

    final reportPanels = reportsAsync.when(
      loading: () => <Widget>[const _ReportsLoadingPanel()],
      error: (error, _) => <Widget>[
        _ReportsErrorPanel(message: _cleanErrorMessage(error)),
      ],
      data: (reports) => <Widget>[
        _ReportOverviewCard(reports: reports),
        _ReportedMessagesList(
          reports: reports,
          revealedMessageIds: _revealedMessageIds,
          onRevealSender: _toggleSenderReveal,
        ),
      ],
    );

    return ModuleScreenShell(
      title: 'Message Reports',
      subtitle: 'Review reported anonymous messages from backend.',
      fallbackRoute: AppRoutes.admin,
      children: [...reportPanels, const _PrivacyAccountabilityCard()],
    );
  }
}

class _ReportsLoadingPanel extends StatelessWidget {
  const _ReportsLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading reports',
        subtitle: 'Fetching reported anonymous messages from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _ReportsErrorPanel extends StatelessWidget {
  const _ReportsErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load message reports',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
        trailing: ModuleBadge(label: 'Error', color: colorScheme.error),
      ),
    );
  }
}

class _ReportOverviewCard extends StatelessWidget {
  const _ReportOverviewCard({required this.reports});

  final List<AnonymousMessageModel> reports;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pendingCount = reports.where((report) {
      final status = report.reportStatus ?? report.status;
      return status == 'pending' || status == 'reported';
    }).length;
    final reviewedCount = reports.length - pendingCount;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Report Overview',
            icon: Icons.dashboard_customize_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Pending',
                  value: pendingCount.toString(),
                  icon: Icons.hourglass_top_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Reviewed',
                  value: reviewedCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ModuleMetricCard(
            label: 'Reported Messages',
            value: reports.length.toString(),
            icon: Icons.report_rounded,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ReportedMessagesList extends StatelessWidget {
  const _ReportedMessagesList({
    required this.reports,
    required this.revealedMessageIds,
    required this.onRevealSender,
  });

  final List<AnonymousMessageModel> reports;
  final Set<String> revealedMessageIds;
  final ValueChanged<String> onRevealSender;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Reported Messages',
            icon: Icons.report_rounded,
          ),
          const SizedBox(height: 12),
          if (reports.isEmpty)
            ModuleInfoTile(
              title: 'No reported messages',
              subtitle: 'Teacher reports will appear here for admin review.',
              icon: Icons.inbox_rounded,
              color: colorScheme.error,
            )
          else
            for (final report in reports) ...[
              _ReportedMessageCard(
                report: report,
                senderRevealed: revealedMessageIds.contains(report.id),
                onRevealSender: () => onRevealSender(report.id),
              ),
              if (report != reports.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ReportedMessageCard extends StatelessWidget {
  const _ReportedMessageCard({
    required this.report,
    required this.senderRevealed,
    required this.onRevealSender,
  });

  final AnonymousMessageModel report;
  final bool senderRevealed;
  final VoidCallback onRevealSender;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: _reportStatus(report),
                icon: Icons.pending_actions_rounded,
                color: colorScheme.tertiary,
              ),
              ModuleBadge(
                label: _formatDateTime(
                  report.reportCreatedAt ?? report.createdAt,
                ),
                icon: Icons.schedule_rounded,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${report.message}"',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _ReportDetailTile(
                label: 'Reported By',
                value:
                    report.reportedByTeacherName ??
                    report.teacherName ??
                    'Teacher',
                icon: Icons.co_present_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                label: 'Subject',
                value: report.subjectName ?? 'General Feedback',
                icon: Icons.storage_rounded,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                label: 'Reason',
                value: report.reportReason ?? 'No reason provided',
                icon: Icons.rule_rounded,
                color: colorScheme.tertiary,
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                label: 'Identity',
                value: senderRevealed
                    ? _senderSummary(report)
                    : 'Hidden until admin investigation',
                icon: senderRevealed
                    ? Icons.person_search_rounded
                    : Icons.visibility_off_rounded,
                color: senderRevealed
                    ? colorScheme.tertiary
                    : colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRevealSender,
              icon: Icon(
                senderRevealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
              ),
              label: Text(senderRevealed ? 'Hide Sender' : 'Reveal Sender'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          if (senderRevealed) ...[
            const SizedBox(height: 12),
            _SenderDetailsPanel(report: report),
          ],
        ],
      ),
    );
  }
}

class _SenderDetailsPanel extends StatelessWidget {
  const _SenderDetailsPanel({required this.report});

  final AnonymousMessageModel report;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleInfoTile(
            title: 'Sender: ${report.studentName ?? 'Student'}',
            subtitle: 'Roll No: ${report.studentRollNo ?? '--'}',
            icon: Icons.person_search_rounded,
            color: colorScheme.tertiary,
          ),
          if (_classLabel(report).isNotEmpty) ...[
            const SizedBox(height: 10),
            ModuleInfoTile(
              title: _classLabel(report),
              subtitle: 'Academic profile',
              icon: Icons.school_rounded,
              color: colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportDetailTile extends StatelessWidget {
  const _ReportDetailTile({
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
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyAccountabilityCard extends StatelessWidget {
  const _PrivacyAccountabilityCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.policy_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'EduVision protects student identity for normal feedback. Admin '
              'can identify the sender only when a message is reported for '
              'harassment, threats, offensive language, or disciplinary review.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
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

String _reportStatus(AnonymousMessageModel report) {
  final status = report.reportStatus ?? report.status;

  if (status == 'pending' || status == 'reported') {
    return 'Pending Review';
  }

  if (status.trim().isEmpty) {
    return 'Reported';
  }

  return '${status[0].toUpperCase()}${status.substring(1)}';
}

String _senderSummary(AnonymousMessageModel report) {
  final name = report.studentName ?? 'Student';
  final rollNo = report.studentRollNo ?? '--';

  return '$name | Roll No: $rollNo';
}

String _classLabel(AnonymousMessageModel report) {
  final parts = <String?>[
    report.departmentName,
    report.batchName,
    report.semesterName,
  ].where(_hasText).map((value) => value!.trim()).toList();

  return parts.join(' | ');
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _formatDateTime(DateTime value) {
  final localValue = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(
    localValue.year,
    localValue.month,
    localValue.day,
  );
  final time = _formatTime(localValue);

  if (messageDate == today) {
    return 'Today, $time';
  }

  if (messageDate == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $time';
  }

  final day = localValue.day.toString().padLeft(2, '0');
  final month = localValue.month.toString().padLeft(2, '0');
  final year = localValue.year.toString();

  return '$day/$month/$year, $time';
}

String _formatTime(DateTime value) {
  final period = value.hour >= 12 ? 'PM' : 'AM';
  final displayHour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final displayMinute = value.minute.toString().padLeft(2, '0');

  return '$displayHour:$displayMinute $period';
}

String _cleanErrorMessage(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
