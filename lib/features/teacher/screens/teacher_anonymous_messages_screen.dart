import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

const _teacherMessages = [
  _AnonymousFeedback(
    message: 'Sir, Lecture 4 was difficult to understand.',
    subject: 'Database Systems',
    received: 'Today, 10:30 AM',
    status: 'New',
  ),
  _AnonymousFeedback(
    message: 'Please provide additional practice exercises.',
    subject: 'Database Systems',
    received: 'Yesterday, 02:15 PM',
    status: 'Resolved',
  ),
  _AnonymousFeedback(
    message: 'The classroom projector is not working properly.',
    subject: 'Database Systems',
    received: 'Today, 09:15 AM',
    status: 'New',
  ),
];

class TeacherAnonymousMessagesScreen extends StatelessWidget {
  const TeacherAnonymousMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScreenShell(
      title: 'Anonymous Messages',
      subtitle: 'Read and manage student feedback.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        _MessageSummaryCard(),
        _AnonymousMessageList(messages: _teacherMessages),
        _TeacherPrivacyNote(),
      ],
    );
  }
}

class _MessageSummaryCard extends StatelessWidget {
  const _MessageSummaryCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  value: '3',
                  icon: Icons.mark_chat_unread_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Resolved',
                  value: '1',
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ModuleMetricCard(
            label: 'Reported',
            value: '1',
            icon: Icons.report_rounded,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _AnonymousMessageList extends StatelessWidget {
  const _AnonymousMessageList({required this.messages});

  final List<_AnonymousFeedback> messages;

  @override
  Widget build(BuildContext context) {
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
          for (final message in messages) ...[
            _AnonymousMessageCard(feedback: message),
            if (message != messages.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _AnonymousMessageCard extends StatelessWidget {
  const _AnonymousMessageCard({required this.feedback});

  final _AnonymousFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolved = feedback.status == 'Resolved';
    final statusColor = resolved ? colorScheme.secondary : colorScheme.primary;

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
                label: feedback.status,
                icon: resolved
                    ? Icons.check_circle_rounded
                    : Icons.fiber_new_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${feedback.message}"',
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
                label: 'Subject: ${feedback.subject}',
                icon: Icons.storage_rounded,
                color: colorScheme.primary,
              ),
              ModuleBadge(
                label: 'Received: ${feedback.received}',
                icon: Icons.schedule_rounded,
                color: colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModuleSnackBar(
                      context,
                      'Message marked resolved in preview.',
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark Resolved'),
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
                  onPressed: () {
                    showModuleSnackBar(
                      context,
                      'Message reported to admin in preview.',
                    );
                  },
                  icon: const Icon(Icons.report_rounded, size: 18),
                  label: const Text('Report'),
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

class _AnonymousFeedback {
  const _AnonymousFeedback({
    required this.message,
    required this.subject,
    required this.received,
    required this.status,
  });

  final String message;
  final String subject;
  final String received;
  final String status;
}
