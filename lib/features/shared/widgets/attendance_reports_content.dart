import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/attendance_report_model.dart';
import 'package:flutter/material.dart';

class AttendanceReportsContent extends StatefulWidget {
  const AttendanceReportsContent({
    super.key,
    required this.reports,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.showTeacher = false,
  });

  final List<AttendanceReportModel> reports;
  final String emptyTitle;
  final String emptySubtitle;
  final bool showTeacher;

  @override
  State<AttendanceReportsContent> createState() =>
      _AttendanceReportsContentState();
}

class _AttendanceReportsContentState extends State<AttendanceReportsContent> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final reports = widget.reports;

    if (reports.isEmpty) {
      return _EmptyReportsPanel(
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
      );
    }

    final selectedIndex = _selectedIndex.clamp(0, reports.length - 1).toInt();
    final selectedReport = reports[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopAnalyticsSummary(reports: reports),
        const SizedBox(height: 10),
        _SessionReportCard(
          report: selectedReport,
          showTeacher: widget.showTeacher,
        ),
        const SizedBox(height: 10),
        _StudentResultList(records: selectedReport.records),
        const SizedBox(height: 10),
        const _AttendanceRuleCard(),
        const SizedBox(height: 10),
        _SessionReportsList(
          reports: reports,
          selectedIndex: selectedIndex,
          showTeacher: widget.showTeacher,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
      ],
    );
  }
}

class _TopAnalyticsSummary extends StatelessWidget {
  const _TopAnalyticsSummary({required this.reports});

  final List<AttendanceReportModel> reports;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalStudents = reports.fold<int>(
      0,
      (total, report) => total + report.totalStudents,
    );
    final presentCount = reports.fold<int>(
      0,
      (total, report) => total + report.presentCount,
    );
    final absentCount = reports.fold<int>(
      0,
      (total, report) => total + report.absentCount,
    );
    final average = _overallAverage(reports);
    final riskStudents = _riskStudentCount(reports);

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Analytics Summary',
            subtitle: 'Backend attendance rollup',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Avg Attendance',
                  value: _percentageLabel(average),
                  icon: Icons.stacked_line_chart_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Sessions',
                  value: reports.length.toString(),
                  icon: Icons.event_note_rounded,
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
                  label: 'Present',
                  value: presentCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Absent',
                  value: absentCount.toString(),
                  icon: Icons.warning_rounded,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Records',
                  value: totalStudents.toString(),
                  icon: Icons.groups_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Under 75%',
                  value: riskStudents.toString(),
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

class _SessionReportCard extends StatelessWidget {
  const _SessionReportCard({required this.report, required this.showTeacher});

  final AttendanceReportModel report;
  final bool showTeacher;

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
            title: 'Selected Session',
            subtitle:
                '${_formatDate(report.sessionDate)} - '
                '${_formatTimeRange(report.startTime, report.endTime)}',
            icon: Icons.analytics_rounded,
            trailing: ModuleBadge(
              label: _titleCase(report.status),
              icon: Icons.verified_rounded,
              color: _statusColor(context, report.status),
            ),
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: _displayOrFallback(report.subjectName, 'Subject'),
            subtitle: 'Subject',
            icon: Icons.menu_book_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10),
          if (showTeacher) ...[
            Row(
              children: [
                Expanded(
                  child: _DetailTile(
                    label: 'Teacher',
                    value: _displayOrFallback(report.teacherName, 'Teacher'),
                    icon: Icons.co_present_rounded,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailTile(
                    label: 'Department',
                    value: _displayOrFallback(
                      report.departmentName,
                      'Department',
                    ),
                    icon: Icons.account_tree_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: _DetailTile(
                  label: 'Batch',
                  value: _displayOrFallback(report.batchName, 'Batch'),
                  icon: Icons.groups_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailTile(
                  label: 'Semester',
                  value: _displayOrFallback(report.semesterName, 'Semester'),
                  icon: Icons.school_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (!showTeacher) ...[
            const SizedBox(height: 8),
            _DetailTile(
              label: 'Department',
              value: _displayOrFallback(report.departmentName, 'Department'),
              icon: Icons.account_tree_rounded,
              color: colorScheme.primary,
            ),
          ],
          const SizedBox(height: 8),
          _DetailTile(
            label: 'Session Time',
            value: _formatTimeRange(report.startTime, report.endTime),
            icon: Icons.schedule_rounded,
            color: colorScheme.primary,
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
                  value: report.totalStudents.toString(),
                  icon: Icons.groups_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Present',
                  value: report.presentCount.toString(),
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
                  value: report.absentCount.toString(),
                  icon: Icons.warning_rounded,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Average',
                  value: _percentageLabel(report.averagePercentage),
                  icon: Icons.percent_rounded,
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

class _StudentResultList extends StatelessWidget {
  const _StudentResultList({required this.records});

  final List<AttendanceStudentRecordModel> records;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Student Records',
            subtitle:
                '${records.length} student result'
                '${records.length == 1 ? '' : 's'}',
            icon: Icons.fact_check_rounded,
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            ModuleInfoTile(
              title: 'No student records yet',
              subtitle: 'This session has no attendance records to display.',
              icon: Icons.assignment_late_rounded,
              color: colorScheme.tertiary,
            )
          else
            for (final record in records) ...[
              _StudentResultCard(record: record),
              if (record != records.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _StudentResultCard extends StatelessWidget {
  const _StudentResultCard({required this.record});

  final AttendanceStudentRecordModel record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPresent = _isPresent(record);
    final meetsRule = record.attendancePercentage >= 75;
    final statusColor = isPresent ? colorScheme.secondary : colorScheme.error;
    final methodColor = record.attendanceMethod == 'dynamic_qr'
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
                      _displayOrFallback(record.studentName, 'Student'),
                      maxLines: 2,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll No: ${_displayOrFallback(record.rollNo, record.studentId)}',
                      maxLines: 2,
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
                label: _titleCase(record.attendanceStatus),
                icon: isPresent
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '75% minimum',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Attendance ${_percentageLabel(record.attendancePercentage)}',
                style: textTheme.labelLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _ThresholdProgressBar(
            value: record.attendancePercentage,
            color: statusColor,
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: _framesLabel(record),
                icon: record.totalFrames <= 0
                    ? Icons.qr_code_2_rounded
                    : Icons.photo_camera_rounded,
                color: record.totalFrames <= 0
                    ? colorScheme.tertiary
                    : colorScheme.secondary,
              ),
              ModuleBadge(
                label: _methodLabel(record.attendanceMethod),
                icon: record.attendanceMethod == 'dynamic_qr'
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

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Attendance Rule',
            subtitle: 'Threshold used in reports',
            icon: Icons.rule_rounded,
          ),
          const SizedBox(height: 12),
          ModuleInfoTile(
            title: '75% or above = Present',
            subtitle: 'Students meet the attendance threshold.',
            icon: Icons.check_circle_rounded,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 9),
          ModuleInfoTile(
            title: 'Below 75% = Absent',
            subtitle: 'Students are flagged for follow-up.',
            icon: Icons.warning_rounded,
            color: colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _SessionReportsList extends StatelessWidget {
  const _SessionReportsList({
    required this.reports,
    required this.selectedIndex,
    required this.showTeacher,
    required this.onSelected,
  });

  final List<AttendanceReportModel> reports;
  final int selectedIndex;
  final bool showTeacher;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Session Reports',
            subtitle: 'Tap a session to inspect records',
            icon: Icons.stacked_bar_chart_rounded,
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < reports.length; index++) ...[
            _SessionReportListCard(
              report: reports[index],
              isSelected: index == selectedIndex,
              showTeacher: showTeacher,
              onTap: () => onSelected(index),
            ),
            if (index != reports.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SessionReportListCard extends StatelessWidget {
  const _SessionReportListCard({
    required this.report,
    required this.isSelected,
    required this.showTeacher,
    required this.onTap,
  });

  final AttendanceReportModel report;
  final bool isSelected;
  final bool showTeacher;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = _averageColor(context, report.averagePercentage);
    final selectedBorder = isSelected
        ? colorScheme.primary
        : colorScheme.outline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.10)
                : colorScheme.surface.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedBorder.withValues(alpha: isSelected ? 0.66 : 0.34),
            ),
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
                          _displayOrFallback(report.subjectName, 'Subject'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _sessionSubtitle(report, showTeacher: showTeacher),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ModuleBadge(
                    label: _healthLabel(report.averagePercentage),
                    icon: report.averagePercentage >= 75
                        ? Icons.verified_rounded
                        : Icons.warning_rounded,
                    color: accent,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    _percentageLabel(report.averagePercentage),
                    style: textTheme.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${report.presentCount}/${report.totalStudents} present',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              _ThresholdProgressBar(
                value: report.averagePercentage,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyReportsPanel extends StatelessWidget {
  const _EmptyReportsPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: title,
        subtitle: subtitle,
        icon: Icons.assignment_outlined,
        color: colorScheme.tertiary,
      ),
    );
  }
}

class AttendanceReportsLoadingPanel extends StatelessWidget {
  const AttendanceReportsLoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading attendance reports',
        subtitle: 'Fetching session analytics from backend.',
        icon: Icons.hourglass_top_rounded,
        color: colorScheme.primary,
        trailing: ModuleBadge(label: 'Loading', color: colorScheme.primary),
      ),
    );
  }
}

class AttendanceReportsErrorPanel extends StatelessWidget {
  const AttendanceReportsErrorPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load attendance reports',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: colorScheme.error,
      ),
    );
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

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedValue = (value / 100).clamp(0.0, 1.0).toDouble();

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
                  value: normalizedValue,
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

double _overallAverage(List<AttendanceReportModel> reports) {
  final records = reports.expand((report) => report.records).toList();

  if (records.isEmpty) {
    return 0;
  }

  final total = records.fold<double>(
    0,
    (sum, record) => sum + record.attendancePercentage,
  );

  return total / records.length;
}

int _riskStudentCount(List<AttendanceReportModel> reports) {
  final studentIds = <String>{};

  for (final report in reports) {
    for (final record in report.records) {
      if (record.attendancePercentage < 75 || !_isPresent(record)) {
        studentIds.add(record.studentId);
      }
    }
  }

  return studentIds.length;
}

bool _isPresent(AttendanceStudentRecordModel record) {
  return record.attendanceStatus.trim().toLowerCase() == 'present';
}

Color _averageColor(BuildContext context, double value) {
  final colorScheme = Theme.of(context).colorScheme;

  if (value >= 85) {
    return colorScheme.secondary;
  }

  if (value >= 75) {
    return colorScheme.primary;
  }

  return colorScheme.error;
}

Color _statusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;
  final normalized = status.trim().toLowerCase();

  if (normalized == 'completed') {
    return colorScheme.secondary;
  }

  if (normalized == 'active') {
    return colorScheme.primary;
  }

  return colorScheme.tertiary;
}

String _displayOrFallback(String? value, String fallback) {
  final trimmed = value?.trim();

  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }

  return fallback;
}

String _percentageLabel(double value) {
  final rounded = value.round();

  return '$rounded%';
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String _formatTimeRange(String startTime, String endTime) {
  return '${_formatTime(startTime)} to ${_formatTime(endTime)}';
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
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final displayMinute = minute.toString().padLeft(2, '0');

  return '$displayHour:$displayMinute $period';
}

String _methodLabel(String value) {
  return switch (value.trim().toLowerCase()) {
    'dynamic_qr' => 'Dynamic QR',
    'face_recognition' => 'Face Recognition',
    _ => _titleCase(value.replaceAll('_', ' ')),
  };
}

String _framesLabel(AttendanceStudentRecordModel record) {
  if (record.totalFrames <= 0) {
    return 'QR Backup';
  }

  return 'Frames: ${record.framesDetected}/${record.totalFrames}';
}

String _titleCase(String value) {
  final words = value
      .trim()
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return 'Unknown';
  }

  return words
      .map(
        (word) => word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _healthLabel(double average) {
  if (average >= 85) {
    return 'Healthy';
  }

  if (average >= 75) {
    return 'Good';
  }

  return 'Risk';
}

String _sessionSubtitle(
  AttendanceReportModel report, {
  required bool showTeacher,
}) {
  final pieces = [
    _formatDate(report.sessionDate),
    _formatTimeRange(report.startTime, report.endTime),
    _displayOrFallback(report.departmentName, 'Department'),
    _displayOrFallback(report.batchName, 'Batch'),
    _displayOrFallback(report.semesterName, 'Semester'),
  ];

  if (showTeacher) {
    pieces.insert(0, _displayOrFallback(report.teacherName, 'Teacher'));
  }

  return pieces.join(' - ');
}
