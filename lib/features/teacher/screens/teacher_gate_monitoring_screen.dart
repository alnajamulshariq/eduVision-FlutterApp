import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/gate_log_model.dart';
import 'package:eduvision_app/features/teacher/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherGateMonitoringScreen extends ConsumerWidget {
  const TeacherGateMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateStatusAsync = ref.watch(teacherGateStatusProvider);

    final dynamicChildren = gateStatusAsync.when(
      loading: () => <Widget>[const _GateStatusLoadingPanel()],
      error: (error, _) => <Widget>[
        _GateStatusErrorPanel(message: _cleanErrorMessage(error)),
      ],
      data: (students) => <Widget>[
        _CampusStatusSummary(students: students),
        _StudentStatusList(students: students),
      ],
    );

    return ModuleScreenShell(
      title: 'Student Gate Monitoring',
      subtitle: 'Monitor student campus presence from backend.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        const _AcademicFilterCard(),
        ...dynamicChildren,
        const _ImportantNoteCard(),
      ],
    );
  }
}

class _GateStatusLoadingPanel extends StatelessWidget {
  const _GateStatusLoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading gate status',
        subtitle: 'Fetching student campus presence from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class _GateStatusErrorPanel extends StatelessWidget {
  const _GateStatusErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load gate status',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
        trailing: ModuleBadge(label: 'Error', color: colorScheme.error),
      ),
    );
  }
}

class _AcademicFilterCard extends StatelessWidget {
  const _AcademicFilterCard();

  @override
  Widget build(BuildContext context) {
    return const ModulePanel(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Academic Filter',
            icon: Icons.filter_alt_rounded,
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: 'Department: BSIT',
                icon: Icons.account_tree_rounded,
              ),
              ModuleBadge(label: 'Batch: 2022', icon: Icons.groups_rounded),
              ModuleBadge(
                label: 'Semester: 8th Semester',
                icon: Icons.school_rounded,
              ),
              ModuleBadge(
                label: 'Subject: Database Systems',
                icon: Icons.storage_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampusStatusSummary extends StatelessWidget {
  const _CampusStatusSummary({required this.students});

  final List<GateLogModel> students;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final insideCount = students.where((log) => log.status == 'entry').length;
    final outsideCount = students.where((log) => log.status == 'exit').length;
    final notScannedCount = students
        .where((log) => log.status == 'not_scanned')
        .length;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Live Campus Status',
            icon: Icons.campaign_rounded,
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
          ModuleMetricCard(
            label: 'Not Scanned',
            value: notScannedCount.toString(),
            icon: Icons.qr_code_2_rounded,
            color: colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _StudentStatusList extends StatelessWidget {
  const _StudentStatusList({required this.students});

  final List<GateLogModel> students;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Student Status List',
            icon: Icons.people_alt_rounded,
          ),
          const SizedBox(height: 12),
          if (students.isEmpty)
            ModuleInfoTile(
              title: 'No enrolled students found',
              subtitle: 'Gate status appears here after backend data loads.',
              icon: Icons.inbox_rounded,
              color: colorScheme.error,
            )
          else
            for (final student in students) ...[
              _StudentStatusCard(student: student),
              if (student != students.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _StudentStatusCard extends StatelessWidget {
  const _StudentStatusCard({required this.student});

  final GateLogModel student;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = _statusColor(context, student.status);
    final statusIcon = _statusIcon(student.status);

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
          Text(
            _studentName(student),
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: _rollNo(student),
                icon: Icons.badge_rounded,
                color: colorScheme.primary,
              ),
              ModuleBadge(
                label: _statusLabel(student.status),
                icon: statusIcon,
                color: accent,
              ),
              if (_classLabel(student).isNotEmpty)
                ModuleBadge(
                  label: _classLabel(student),
                  icon: Icons.school_rounded,
                  color: colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: 'Latest Scan',
                  value: _latestScanText(student),
                  icon: Icons.schedule_rounded,
                  color: student.status == 'not_scanned'
                      ? colorScheme.error
                      : colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimeBox(
                  label: 'Gate',
                  value: student.gateLocation,
                  icon: Icons.meeting_room_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImportantNoteCard extends StatelessWidget {
  const _ImportantNoteCard();

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
            title: 'Gate vs Attendance',
            icon: Icons.info_rounded,
          ),
          const SizedBox(height: 10),
          Text(
            'Gate entry shows the student is present on campus. Class '
            'attendance confirms the student attended a specific class.',
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

class _TimeBox extends StatelessWidget {
  const _TimeBox({
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

Color _statusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (status) {
    'entry' => colorScheme.secondary,
    'exit' => colorScheme.tertiary,
    _ => colorScheme.error,
  };
}

IconData _statusIcon(String status) {
  return switch (status) {
    'entry' => Icons.location_on_rounded,
    'exit' => Icons.location_off_rounded,
    _ => Icons.qr_code_2_rounded,
  };
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

String _statusLabel(String status) {
  return switch (status) {
    'entry' => 'Inside University',
    'exit' => 'Outside University',
    _ => 'Not Scanned',
  };
}

String _latestScanText(GateLogModel log) {
  if (log.status == 'not_scanned' || log.time.trim().isEmpty) {
    return 'Not Recorded';
  }

  return _formatTime(log.time);
}

String _classLabel(GateLogModel log) {
  final parts = <String?>[
    log.departmentName,
    log.batchName,
    log.semesterName,
  ].where(_hasText).map((value) => value!.trim()).toList();

  return parts.join(' | ');
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
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
