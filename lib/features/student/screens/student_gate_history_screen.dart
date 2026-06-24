import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

const _todayGateEvents = [
  _GateTimelineItem(
    time: '08:00 AM',
    action: 'Entry',
    gate: 'Main Gate',
    notification: 'Parent Email Sent',
  ),
  _GateTimelineItem(
    time: '11:30 AM',
    action: 'Exit',
    gate: 'Main Gate',
    notification: 'Parent Email Sent',
  ),
  _GateTimelineItem(
    time: '12:15 PM',
    action: 'Entry',
    gate: 'Main Gate',
    notification: 'Parent Email Sent',
  ),
];

class StudentGateHistoryScreen extends StatelessWidget {
  const StudentGateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScreenShell(
      title: 'Gate History',
      subtitle: 'Campus entry and exit activity preview.',
      fallbackRoute: AppRoutes.student,
      children: [
        _CurrentStatusCard(),
        _TodayTimelineCard(events: _todayGateEvents),
        _ParentNotificationCard(),
        _EntryExitLogicCard(),
      ],
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                      'Ali Khan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Roll No: BSIT-2022-001',
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
                label: 'Entry Active',
                icon: Icons.login_rounded,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: 'Inside University',
            subtitle: 'Current campus status',
            icon: Icons.location_on_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Last Scan',
                  value: '12:15 PM',
                  icon: Icons.schedule_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Gate',
                  value: 'Main',
                  icon: Icons.meeting_room_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Dynamic QR preview confirms the student is currently inside the '
            'university campus.',
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

  final List<_GateTimelineItem> events;

  @override
  Widget build(BuildContext context) {
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

  final _GateTimelineItem event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEntry = event.action == 'Entry';
    final accent = isEntry ? colorScheme.secondary : colorScheme.tertiary;

    return ModuleInfoTile(
      title: '${event.time}, ${event.action}',
      subtitle: '${event.gate} - ${event.notification}',
      icon: isEntry ? Icons.login_rounded : Icons.logout_rounded,
      color: accent,
      trailing: ModuleBadge(
        label: event.action,
        icon: isEntry ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
        color: accent,
      ),
    );
  }
}

class _ParentNotificationCard extends StatelessWidget {
  const _ParentNotificationCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleInfoTile(
            title: 'Parent Alert',
            subtitle:
                'Email notification preview is enabled for every gate scan.',
            icon: Icons.mark_email_read_rounded,
            color: colorScheme.primary,
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
                  'parent@example.com',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ModuleBadge(
                  label: 'Notification Status: Sent Preview',
                  icon: Icons.mark_email_read_rounded,
                  color: colorScheme.secondary,
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

class _GateTimelineItem {
  const _GateTimelineItem({
    required this.time,
    required this.action,
    required this.gate,
    required this.notification,
  });

  final String time;
  final String action;
  final String gate;
  final String notification;
}
