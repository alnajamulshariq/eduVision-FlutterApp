import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/system_activity_log_model.dart';
import 'package:eduvision_app/features/admin/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminSystemActivityScreen extends ConsumerWidget {
  const AdminSystemActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(adminSystemActivityLogsProvider);
    final logs = logsAsync.maybeWhen(data: (data) => data, orElse: () => null);

    return ModuleScreenShell(
      title: 'System Activity',
      subtitle: 'Recent secure operations and monitoring events.',
      fallbackRoute: AppRoutes.admin,
      children: [
        _ActivityToolbar(
          logs: logs,
          isLoading: logsAsync.isLoading,
          onRefresh: () => ref.invalidate(adminSystemActivityLogsProvider),
        ),
        ...logsAsync.when(
          loading: () => const <Widget>[_ActivityLoadingPanel()],
          error: (error, _) => <Widget>[
            _ActivityErrorPanel(message: _cleanErrorMessage(error)),
          ],
          data: (activityLogs) => <Widget>[
            _ActivitySummaryPanel(logs: activityLogs),
            _ActivityListPanel(logs: activityLogs),
          ],
        ),
      ],
    );
  }
}

class _ActivityToolbar extends StatelessWidget {
  const _ActivityToolbar({
    required this.logs,
    required this.isLoading,
    required this.onRefresh,
  });

  final List<SystemActivityLogModel>? logs;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: ModuleInfoTile(
              title: 'Activity Feed',
              subtitle: logs == null
                  ? 'Loading recent activity.'
                  : '${logs!.length} recent events available.',
              icon: Icons.manage_search_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : onRefresh,
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ActivitySummaryPanel extends StatelessWidget {
  const _ActivitySummaryPanel({required this.logs});

  final List<SystemActivityLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayCount = logs.where(_isToday).length;
    final adminWriteCount = logs
        .where(
          (log) =>
              log.action.contains('created') || log.action.contains('assigned'),
        )
        .length;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Overview', icon: Icons.insights_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Today',
                  value: todayCount.toString(),
                  icon: Icons.today_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Recent',
                  value: logs.length.toString(),
                  icon: Icons.history_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ModuleMetricCard(
            label: 'Admin Writes',
            value: adminWriteCount.toString(),
            icon: Icons.admin_panel_settings_rounded,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _ActivityListPanel extends StatelessWidget {
  const _ActivityListPanel({required this.logs});

  final List<SystemActivityLogModel> logs;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Recent Activity',
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            const _EmptyActivityTile()
          else
            for (final log in logs) ...[
              _ActivityTile(log: log),
              if (log != logs.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.log});

  final SystemActivityLogModel log;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _activityColor(context, log.action);
    final description = log.description?.trim();

    return ModuleInfoTile(
      title: log.actionLabel,
      subtitle: [
        if (description != null && description.isNotEmpty) description,
        'Actor: ${log.actorLabel}',
        'Target: ${log.targetLabel}',
        _formatDateTime(log.createdAt),
      ].join(' - '),
      icon: _activityIcon(log.action),
      color: color,
      trailing: ModuleBadge(
        label: _shortTarget(log),
        icon: Icons.label_rounded,
        color: colorScheme.secondary,
      ),
    );
  }
}

class _ActivityLoadingPanel extends StatelessWidget {
  const _ActivityLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading activity',
        subtitle: 'Fetching recent system events from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _ActivityErrorPanel extends StatelessWidget {
  const _ActivityErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load activity',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
      ),
    );
  }
}

class _EmptyActivityTile extends StatelessWidget {
  const _EmptyActivityTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModuleInfoTile(
      title: 'No activity found',
      subtitle: 'Secure operations will appear here after backend writes run.',
      icon: Icons.info_outline_rounded,
      color: colorScheme.tertiary,
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

bool _isToday(SystemActivityLogModel log) {
  final localCreatedAt = log.createdAt.toLocal();
  final createdDate = DateTime(
    localCreatedAt.year,
    localCreatedAt.month,
    localCreatedAt.day,
  );
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return createdDate == today;
}

IconData _activityIcon(String action) {
  if (action.contains('password')) {
    return Icons.lock_reset_rounded;
  }

  if (action.contains('email')) {
    return Icons.mark_email_read_rounded;
  }

  if (action.contains('assigned')) {
    return Icons.assignment_ind_rounded;
  }

  if (action.contains('enrolled')) {
    return Icons.how_to_reg_rounded;
  }

  if (action.contains('created')) {
    return Icons.add_circle_outline_rounded;
  }

  return Icons.event_note_rounded;
}

Color _activityColor(BuildContext context, String action) {
  final colorScheme = Theme.of(context).colorScheme;

  if (action.contains('failed')) {
    return colorScheme.error;
  }

  if (action.contains('email')) {
    return colorScheme.secondary;
  }

  if (action.contains('password')) {
    return colorScheme.tertiary;
  }

  return colorScheme.primary;
}

String _shortTarget(SystemActivityLogModel log) {
  final type = log.targetType?.trim();

  if (type == null || type.isEmpty) {
    return 'System';
  }

  return type.replaceAll('_', ' ');
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '${local.year}-$month-$day $hour:$minute';
}

String _cleanErrorMessage(Object error) {
  final text = error.toString();

  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }

  return text;
}
