import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

const _studentResults = [
  _StudentAttendanceResult(
    name: 'Ali Khan',
    rollNo: 'BSIT-2022-001',
    attendance: 90,
    frames: '18/20',
    method: 'Face Recognition',
    status: 'Present',
  ),
  _StudentAttendanceResult(
    name: 'Sara Ahmed',
    rollNo: 'BSIT-2022-002',
    attendance: 80,
    frames: '16/20',
    method: 'Face Recognition',
    status: 'Present',
  ),
  _StudentAttendanceResult(
    name: 'Ahmed Raza',
    rollNo: 'BSIT-2022-003',
    attendance: 70,
    frames: '14/20',
    method: 'Face Recognition',
    status: 'Absent',
  ),
  _StudentAttendanceResult(
    name: 'Fatima Noor',
    rollNo: 'BSIT-2022-004',
    attendance: 100,
    frames: 'QR Backup',
    method: 'Dynamic QR',
    status: 'Present',
  ),
];

const _courseReports = [
  _CourseReport(
    subject: 'Database Systems',
    group: 'BSIT 2022',
    attendance: 90,
    status: 'Healthy',
  ),
  _CourseReport(
    subject: 'Web Engineering',
    group: 'BSSE 2023',
    attendance: 82,
    status: 'Good',
  ),
  _CourseReport(
    subject: 'Artificial Intelligence',
    group: 'BSIT 2022',
    attendance: 76,
    status: 'Watch',
  ),
  _CourseReport(
    subject: 'Software Project',
    group: 'BSIT 2022',
    attendance: 70,
    status: 'Risk',
  ),
];

class AdminAttendanceReportsScreen extends StatelessWidget {
  const AdminAttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScreenShell(
      title: 'Attendance Reports',
      subtitle: 'Smart attendance analytics and session reports preview.',
      fallbackRoute: AppRoutes.admin,
      children: [
        _TopAnalyticsSummary(),
        _LatestSessionReportCard(),
        _StudentResultList(results: _studentResults),
        _AttendanceRuleCard(),
        _CourseReportsList(reports: _courseReports),
        _ExportActions(),
      ],
    );
  }
}

class _TopAnalyticsSummary extends StatelessWidget {
  const _TopAnalyticsSummary();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Analytics Summary',
            subtitle: 'Live-style demo metrics',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Overall Present',
                  value: '86%',
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Absent Rate',
                  value: '14%',
                  icon: Icons.warning_rounded,
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
                  label: 'Sessions',
                  value: '12',
                  icon: Icons.event_note_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Risk Students',
                  value: '1',
                  icon: Icons.report_problem_rounded,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatestSessionReportCard extends StatelessWidget {
  const _LatestSessionReportCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Latest Session',
            subtitle: 'Database Systems report',
            icon: Icons.analytics_rounded,
            trailing: ModuleBadge(
              label: 'Smart Attendance Preview',
              icon: Icons.auto_awesome_rounded,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: 'Database Systems',
            subtitle: 'Subject',
            icon: Icons.storage_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DetailTile(
                  label: 'Teacher',
                  value: 'Mr. Ahmad',
                  icon: Icons.co_present_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailTile(
                  label: 'Department',
                  value: 'BSIT',
                  icon: Icons.account_tree_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DetailTile(
                  label: 'Batch',
                  value: '2022',
                  icon: Icons.groups_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailTile(
                  label: 'Semester',
                  value: '8th Semester',
                  icon: Icons.school_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DetailTile(
            label: 'Session Time',
            value: '09:00 AM to 10:00 AM',
            icon: Icons.schedule_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _DetailTile(
            label: 'Session Status',
            value: 'Preview Completed',
            icon: Icons.verified_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 14),
          Text(
            'Attendance Summary',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Total Students',
                  value: '4',
                  icon: Icons.groups_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Present',
                  value: '3',
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Absent',
                  value: '1',
                  icon: Icons.warning_rounded,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Face Recognized',
                  value: '3',
                  icon: Icons.face_retouching_natural_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ModuleMetricCard(
            label: 'QR Backup',
            value: '1',
            icon: Icons.qr_code_2_rounded,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _StudentResultList extends StatelessWidget {
  const _StudentResultList({required this.results});

  final List<_StudentAttendanceResult> results;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Student Results',
            subtitle: 'Same Smart Attendance demo data',
            icon: Icons.fact_check_rounded,
          ),
          const SizedBox(height: 12),
          for (final result in results) ...[
            _StudentResultCard(result: result),
            if (result != results.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _StudentResultCard extends StatelessWidget {
  const _StudentResultCard({required this.result});

  final _StudentAttendanceResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPresent = result.status == 'Present';
    final meetsRule = result.attendance >= 75;
    final statusColor = isPresent ? colorScheme.secondary : colorScheme.error;
    final methodColor = result.method == 'Dynamic QR'
        ? colorScheme.tertiary
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll No: ${result.rollNo}',
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
                label: result.status,
                icon: isPresent
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Text(
                '75% rule',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'Attendance: ${result.attendance}%',
                style: textTheme.labelLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _ThresholdProgressBar(value: result.attendance, color: statusColor),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: 'Frames: ${result.frames}',
                icon: result.frames == 'QR Backup'
                    ? Icons.qr_code_2_rounded
                    : Icons.photo_camera_rounded,
                color: result.frames == 'QR Backup'
                    ? colorScheme.tertiary
                    : colorScheme.secondary,
              ),
              ModuleBadge(
                label: result.method,
                icon: result.method == 'Dynamic QR'
                    ? Icons.qr_code_2_rounded
                    : Icons.face_retouching_natural_rounded,
                color: methodColor,
              ),
              ModuleBadge(
                label: meetsRule ? 'Rule: Present' : 'Rule: Absent',
                icon: meetsRule ? Icons.rule_rounded : Icons.report_rounded,
                color: meetsRule ? colorScheme.secondary : colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceRuleCard extends StatelessWidget {
  const _AttendanceRuleCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Attendance Rule',
            subtitle: 'Preview logic used in this demo',
            icon: Icons.rule_rounded,
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: '75% or above = Present',
            subtitle: 'Students meet the Smart Attendance threshold.',
            icon: Icons.check_circle_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: 'Below 75% = Absent',
            subtitle: 'Students are flagged for review or risk follow-up.',
            icon: Icons.warning_rounded,
            color: colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'EduVision calculates attendance using continuous presence across '
            'captured frames instead of a single image. Dynamic QR is used as '
            'a backup method for students with masks, veils, niqabs, or face '
            'coverings.',
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

class _CourseReportsList extends StatelessWidget {
  const _CourseReportsList({required this.reports});

  final List<_CourseReport> reports;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Course Reports',
            subtitle: 'Course-wise preview rollup',
            icon: Icons.stacked_bar_chart_rounded,
          ),
          const SizedBox(height: 12),
          for (final report in reports) ...[
            _CourseReportCard(report: report),
            if (report != reports.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CourseReportCard extends StatelessWidget {
  const _CourseReportCard({required this.report});

  final _CourseReport report;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = switch (report.status) {
      'Healthy' => colorScheme.secondary,
      'Good' => colorScheme.primary,
      'Watch' => colorScheme.tertiary,
      _ => colorScheme.error,
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.group,
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
                label: report.status,
                icon: report.status == 'Risk'
                    ? Icons.warning_rounded
                    : Icons.verified_rounded,
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${report.attendance}%',
                style: textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '75% minimum',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _ThresholdProgressBar(value: report.attendance, color: accent),
        ],
      ),
    );
  }
}

class _ExportActions extends StatelessWidget {
  const _ExportActions();

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Report Actions',
            subtitle: 'Frontend preview only',
            icon: Icons.ios_share_rounded,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Generate PDF Preview',
            icon: Icons.picture_as_pdf_rounded,
            minHeight: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onPressed: () => _showExportPreview(context),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showExportPreview(context),
              icon: const Icon(Icons.table_chart_rounded, size: 18),
              label: const Text('Export CSV Preview'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
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

  void _showExportPreview(BuildContext context) {
    showModuleSnackBar(context, 'Report export preview only.');
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 21),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
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
          ),
        ],
      ),
    );
  }
}

class _ThresholdProgressBar extends StatelessWidget {
  const _ThresholdProgressBar({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final markerLeft = (constraints.maxWidth * 0.75 - 1)
            .clamp(0.0, constraints.maxWidth - 2)
            .toDouble();

        return SizedBox(
          height: 12,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 8,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.13),
                ),
              ),
              Positioned(
                left: markerLeft,
                child: Container(
                  width: 2,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentAttendanceResult {
  const _StudentAttendanceResult({
    required this.name,
    required this.rollNo,
    required this.attendance,
    required this.frames,
    required this.method,
    required this.status,
  });

  final String name;
  final String rollNo;
  final int attendance;
  final String frames;
  final String method;
  final String status;
}

class _CourseReport {
  const _CourseReport({
    required this.subject,
    required this.group,
    required this.attendance,
    required this.status,
  });

  final String subject;
  final String group;
  final int attendance;
  final String status;
}
