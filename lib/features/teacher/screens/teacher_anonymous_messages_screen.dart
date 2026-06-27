import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/teacher_anonymous_message_model.dart';
import 'package:eduvision_app/features/teacher/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherAnonymousMessagesScreen extends ConsumerStatefulWidget {
  const TeacherAnonymousMessagesScreen({super.key});

  @override
  ConsumerState<TeacherAnonymousMessagesScreen> createState() =>
      _TeacherAnonymousMessagesScreenState();
}

class _TeacherAnonymousMessagesScreenState
    extends ConsumerState<TeacherAnonymousMessagesScreen> {
  final _busyMessageIds = <String>{};

  Future<void> _markResolved(TeacherAnonymousMessageModel message) async {
    if (_busyMessageIds.contains(message.id) || message.status == 'resolved') {
      return;
    }

    setState(() => _busyMessageIds.add(message.id));

    final result = await ref
        .read(teacherMessageRepositoryProvider)
        .markMessageResolved(messageId: message.id);

    if (!mounted) {
      return;
    }

    setState(() => _busyMessageIds.remove(message.id));

    switch (result) {
      case Success<void>():
        ref.invalidate(teacherAnonymousMessagesProvider);
        showModuleSnackBar(context, 'Message marked resolved.');
      case Failure<void>(:final exception):
        showModuleSnackBar(context, exception.message);
    }
  }

  Future<void> _reportMessage(TeacherAnonymousMessageModel message) async {
    if (_busyMessageIds.contains(message.id) || message.isReported) {
      return;
    }

    setState(() => _busyMessageIds.add(message.id));

    final result = await ref
        .read(teacherMessageRepositoryProvider)
        .reportMessage(
          messageId: message.id,
          reportReason: 'Reported by teacher for admin review',
        );

    if (!mounted) {
      return;
    }

    setState(() => _busyMessageIds.remove(message.id));

    switch (result) {
      case Success<void>():
        ref.invalidate(teacherAnonymousMessagesProvider);
        showModuleSnackBar(context, 'Message reported to admin.');
      case Failure<void>(:final exception):
        showModuleSnackBar(context, exception.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(teacherAnonymousMessagesProvider);

    final messagePanels = messagesAsync.when(
      loading: () => <Widget>[const _MessagesLoadingPanel()],
      error: (error, _) => <Widget>[
        _MessagesErrorPanel(message: _cleanErrorMessage(error)),
      ],
      data: (messages) => <Widget>[
        _MessageSummaryCard(messages: messages),
        _AnonymousMessageList(
          messages: messages,
          busyMessageIds: _busyMessageIds,
          onMarkResolved: _markResolved,
          onReport: _reportMessage,
        ),
      ],
    );

    return ModuleScreenShell(
      title: 'Anonymous Messages',
      subtitle: 'Read and manage student feedback.',
      fallbackRoute: AppRoutes.teacher,
      children: [...messagePanels, const _TeacherPrivacyNote()],
    );
  }
}

class _MessagesLoadingPanel extends StatelessWidget {
  const _MessagesLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading messages',
        subtitle: 'Fetching anonymous feedback from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _MessagesErrorPanel extends StatelessWidget {
  const _MessagesErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load messages',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
        trailing: ModuleBadge(label: 'Error', color: colorScheme.error),
      ),
    );
  }
}

class _MessageSummaryCard extends StatelessWidget {
  const _MessageSummaryCard({required this.messages});

  final List<TeacherAnonymousMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final newCount = messages
        .where((message) => message.status == 'new')
        .length;
    final resolvedCount = messages
        .where((message) => message.status == 'resolved')
        .length;
    final reportedCount = messages
        .where((message) => message.isReported || message.status == 'reported')
        .length;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Message Summary',
            icon: Icons.forum_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'New',
                  value: newCount.toString(),
                  icon: Icons.mark_chat_unread_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Resolved',
                  value: resolvedCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ModuleMetricCard(
            label: 'Reported',
            value: reportedCount.toString(),
            icon: Icons.report_rounded,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _AnonymousMessageList extends StatelessWidget {
  const _AnonymousMessageList({
    required this.messages,
    required this.busyMessageIds,
    required this.onMarkResolved,
    required this.onReport,
  });

  final List<TeacherAnonymousMessageModel> messages;
  final Set<String> busyMessageIds;
  final ValueChanged<TeacherAnonymousMessageModel> onMarkResolved;
  final ValueChanged<TeacherAnonymousMessageModel> onReport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Anonymous Feedback',
            icon: Icons.feedback_rounded,
          ),
          const SizedBox(height: 12),
          if (messages.isEmpty)
            ModuleInfoTile(
              title: 'No anonymous messages yet',
              subtitle: 'Student feedback will appear here anonymously.',
              icon: Icons.inbox_rounded,
              color: colorScheme.error,
            )
          else
            for (final message in messages) ...[
              _AnonymousMessageCard(
                message: message,
                isBusy: busyMessageIds.contains(message.id),
                onMarkResolved: () => onMarkResolved(message),
                onReport: () => onReport(message),
              ),
              if (message != messages.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _AnonymousMessageCard extends StatelessWidget {
  const _AnonymousMessageCard({
    required this.message,
    required this.isBusy,
    required this.onMarkResolved,
    required this.onReport,
  });

  final TeacherAnonymousMessageModel message;
  final bool isBusy;
  final VoidCallback onMarkResolved;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolved = message.status == 'resolved';
    final reported = message.isReported || message.status == 'reported';
    final statusColor = reported
        ? colorScheme.tertiary
        : resolved
        ? colorScheme.secondary
        : colorScheme.primary;

    return Container(
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
                label: 'Anonymous',
                icon: Icons.visibility_off_rounded,
                color: colorScheme.secondary,
              ),
              ModuleBadge(
                label: _statusLabel(message),
                icon: reported
                    ? Icons.report_rounded
                    : resolved
                    ? Icons.check_circle_rounded
                    : Icons.fiber_new_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${message.message}"',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: 'Subject: ${_subjectLabel(message)}',
                icon: Icons.storage_rounded,
                color: colorScheme.primary,
              ),
              ModuleBadge(
                label: 'Received: ${_formatDateTime(message.createdAt)}',
                icon: Icons.schedule_rounded,
                color: colorScheme.tertiary,
              ),
              if (message.reportReason?.trim().isNotEmpty ?? false)
                ModuleBadge(
                  label: 'Report: ${message.reportReason}',
                  icon: Icons.rule_rounded,
                  color: colorScheme.tertiary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy || resolved ? null : onMarkResolved,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(resolved ? 'Resolved' : 'Mark Resolved'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy || reported ? null : onReport,
                  icon: const Icon(Icons.report_rounded, size: 18),
                  label: Text(reported ? 'Reported' : 'Report'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeacherPrivacyNote extends StatelessWidget {
  const _TeacherPrivacyNote();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Student identities are hidden from teachers. Reported messages '
              'are reviewed by admin only when required.',
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

String _subjectLabel(TeacherAnonymousMessageModel message) {
  final subjectName = message.subjectName?.trim();

  if (subjectName != null && subjectName.isNotEmpty) {
    return subjectName;
  }

  return 'General Feedback';
}

String _statusLabel(TeacherAnonymousMessageModel message) {
  if (message.isReported || message.status == 'reported') {
    return 'Reported';
  }

  if (message.status == 'resolved') {
    return 'Resolved';
  }

  return 'New';
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
