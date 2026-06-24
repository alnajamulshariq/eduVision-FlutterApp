import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  static const _courses = [
    _CourseAttendance(
      subject: 'Database Systems',
      attendance: 90,
      status: 'Present Trend',
      method: 'Face Recognition',
    ),
    _CourseAttendance(
      subject: 'Web Engineering',
      attendance: 82,
      status: 'Good',
      method: 'Manual/Session Preview',
    ),
    _CourseAttendance(
      subject: 'Artificial Intelligence',
      attendance: 76,
      status: 'Needs Attention',
      method: 'Face Recognition Preview',
    ),
    _CourseAttendance(
      subject: 'Software Project',
      attendance: 70,
      status: 'At Risk',
      method: 'Missed Sessions',
    ),
  ];

  static const _timeline = [
    _AttendanceTimelineItem(
      day: 'Today',
      subject: 'Database Systems',
      status: 'Present',
      attendance: 90,
    ),
    _AttendanceTimelineItem(
      day: 'Yesterday',
      subject: 'Web Engineering',
      status: 'Present',
      attendance: 82,
    ),
    _AttendanceTimelineItem(
      day: 'Monday',
      subject: 'Artificial Intelligence',
      status: 'Present',
      attendance: 76,
    ),
    _AttendanceTimelineItem(
      day: 'Friday',
      subject: 'Software Project',
      status: 'Absent',
      attendance: 70,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'My Attendance',
      subtitle: 'Course-wise attendance and eligibility preview.',
      fallbackRoute: AppRoutes.student,
      children: const [
        _OverallAttendanceSummary(),
        _CurrentCourseCard(),
        _CourseAttendanceList(courses: _courses),
        _AttendanceRuleCard(),
        _AttendanceTimeline(timeline: _timeline),
      ],
    );
  }
}

class _OverallAttendanceSummary extends StatelessWidget {
  const _OverallAttendanceSummary();

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.86,
                      strokeWidth: 8,
                      color: colorScheme.secondary,
                      backgroundColor: colorScheme.secondary.withValues(
                        alpha: 0.13,
                      ),
                    ),
                    Center(
                      child: Text(
                        '86%',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Attendance',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ModuleBadge(
                          label: 'Status: Eligible',
                          icon: Icons.verified_rounded,
                          color: AppColors.cyan,
                        ),
                        ModuleBadge(
                          label: 'Minimum Required: 75%',
                          icon: Icons.rule_rounded,
                          color: AppColors.blue,
                        ),
                        ModuleBadge(
                          label: 'Current Risk: Low',
                          icon: Icons.shield_rounded,
                          color: AppColors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.86,
              minHeight: 8,
              color: colorScheme.secondary,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentCourseCard extends StatelessWidget {
  const _CurrentCourseCard();

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
            children: [
              Expanded(
                child: Text(
                  'Database Systems',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const ModuleBadge(
                label: 'Present',
                icon: Icons.check_circle_rounded,
                color: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(label: 'Mr. Ahmad', icon: Icons.co_present_rounded),
              ModuleBadge(label: 'BSIT', icon: Icons.account_tree_rounded),
              ModuleBadge(label: 'Batch 2022', icon: Icons.groups_rounded),
              ModuleBadge(label: '8th Semester', icon: Icons.school_rounded),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Frame Presence',
                  value: '18/20',
                  icon: Icons.photo_camera_rounded,
                  color: AppColors.blue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Percentage',
                  value: '90%',
                  icon: Icons.percent_rounded,
                  color: AppColors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const ModuleInfoTile(
            title: 'Face Recognition',
            subtitle: 'Today\'s attendance method',
            icon: Icons.face_retouching_natural_rounded,
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          Text(
            'Marked present because presence is above the 75% threshold.',
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

class _CourseAttendanceList extends StatelessWidget {
  const _CourseAttendanceList({required this.courses});

  final List<_CourseAttendance> courses;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course-wise Attendance',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final course in courses) ...[
            _CourseAttendanceCard(course: course),
            if (course != courses.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CourseAttendanceCard extends StatelessWidget {
  const _CourseAttendanceCard({required this.course});

  final _CourseAttendance course;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final eligible = course.attendance >= 75;
    final accent = eligible ? colorScheme.secondary : AppColors.red;

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
                child: Text(
                  course.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ModuleBadge(
                label: '${course.attendance}%',
                icon: Icons.percent_rounded,
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: course.attendance / 100,
              minHeight: 7,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.13),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: course.status,
                icon: eligible
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: accent,
              ),
              ModuleBadge(
                label: course.method,
                icon: course.method.contains('Face')
                    ? Icons.face_retouching_natural_rounded
                    : Icons.fact_check_rounded,
                color: eligible ? AppColors.blue : AppColors.amber,
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
          const ModuleInfoTile(
            title: 'Attendance Rule',
            subtitle: '75% or above = Present / Eligible',
            icon: Icons.rule_rounded,
            color: AppColors.cyan,
          ),
          const SizedBox(height: 10),
          const ModuleInfoTile(
            title: 'Below 75%',
            subtitle: 'Absent / Risk',
            icon: Icons.warning_rounded,
            color: AppColors.amber,
          ),
          const SizedBox(height: 12),
          Text(
            'EduVision calculates attendance using continuous presence across '
            'captured frames instead of a single image.',
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

class _AttendanceTimeline extends StatelessWidget {
  const _AttendanceTimeline({required this.timeline});

  final List<_AttendanceTimelineItem> timeline;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final item in timeline) ...[
            _TimelineRow(item: item),
            if (item != timeline.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item});

  final _AttendanceTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final present = item.status == 'Present';
    final accent = present ? colorScheme.secondary : AppColors.red;

    return ModuleInfoTile(
      title: '${item.day}, ${item.subject}',
      subtitle: '${item.status} - ${item.attendance}%',
      icon: present ? Icons.check_circle_rounded : Icons.warning_rounded,
      color: accent,
      trailing: ModuleBadge(label: item.status, color: accent),
    );
  }
}

class _CourseAttendance {
  const _CourseAttendance({
    required this.subject,
    required this.attendance,
    required this.status,
    required this.method,
  });

  final String subject;
  final int attendance;
  final String status;
  final String method;
}

class _AttendanceTimelineItem {
  const _AttendanceTimelineItem({
    required this.day,
    required this.subject,
    required this.status,
    required this.attendance,
  });

  final String day;
  final String subject;
  final String status;
  final int attendance;
}
