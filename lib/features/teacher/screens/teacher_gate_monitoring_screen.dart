import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

const _studentStatuses = [
  _StudentGateStatus(
    name: 'Ali Khan',
    rollNo: 'BSIT-2022-001',
    status: 'Inside University',
    entryTime: '12:15 PM',
    exitTime: 'Not Recorded',
  ),
  _StudentGateStatus(
    name: 'Sara Ahmed',
    rollNo: 'BSIT-2022-002',
    status: 'Inside University',
    entryTime: '08:05 AM',
    exitTime: 'Not Recorded',
  ),
  _StudentGateStatus(
    name: 'Ahmed Raza',
    rollNo: 'BSIT-2022-003',
    status: 'Outside University',
    entryTime: '08:15 AM',
    exitTime: '12:30 PM',
  ),
  _StudentGateStatus(
    name: 'Fatima Noor',
    rollNo: 'BSIT-2022-004',
    status: 'Not Scanned',
    entryTime: 'Not Recorded',
    exitTime: 'Not Recorded',
  ),
];

class TeacherGateMonitoringScreen extends StatelessWidget {
  const TeacherGateMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScreenShell(
      title: 'Student Gate Monitoring',
      subtitle: 'Monitor student campus presence preview.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        _AcademicFilterCard(),
        _CampusStatusSummary(),
        _StudentStatusList(students: _studentStatuses),
        _ImportantNoteCard(),
      ],
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
  const _CampusStatusSummary();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          ModuleMetricCard(
            label: 'Not Scanned',
            value: '1',
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

  final List<_StudentGateStatus> students;

  @override
  Widget build(BuildContext context) {
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

  final _StudentGateStatus student;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = switch (student.status) {
      'Inside University' => colorScheme.secondary,
      'Outside University' => colorScheme.tertiary,
      _ => colorScheme.error,
    };
    final statusIcon = switch (student.status) {
      'Inside University' => Icons.location_on_rounded,
      'Outside University' => Icons.location_off_rounded,
      _ => Icons.qr_code_2_rounded,
    };

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
            student.name,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: student.rollNo,
                icon: Icons.badge_rounded,
                color: colorScheme.primary,
              ),
              ModuleBadge(
                label: student.status,
                icon: statusIcon,
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: 'Entry Time',
                  value: student.entryTime,
                  icon: Icons.login_rounded,
                  color: student.entryTime == 'Not Recorded'
                      ? colorScheme.error
                      : colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimeBox(
                  label: 'Exit Time',
                  value: student.exitTime,
                  icon: Icons.logout_rounded,
                  color: student.exitTime == 'Not Recorded'
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.tertiary,
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

class _StudentGateStatus {
  const _StudentGateStatus({
    required this.name,
    required this.rollNo,
    required this.status,
    required this.entryTime,
    required this.exitTime,
  });

  final String name;
  final String rollNo;
  final String status;
  final String entryTime;
  final String exitTime;
}
