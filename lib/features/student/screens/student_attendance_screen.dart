import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/attendance_record_model.dart';
import 'package:eduvision_app/features/student/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(studentAttendanceRecordsProvider);

    final children = attendanceAsync.when(
      loading: () => <Widget>[
        const _AttendanceLoadingPanel(),
        const _AttendanceRuleCard(),
      ],
      error: (error, _) => <Widget>[
        _AttendanceErrorPanel(message: _cleanErrorMessage(error)),
        const _AttendanceRuleCard(),
      ],
      data: (records) => <Widget>[
        _OverallAttendanceSummary(records: records),
        _CurrentAttendanceCard(record: records.isEmpty ? null : records.first),
        _AttendanceRecordList(records: records),
        const _AttendanceRuleCard(),
        _AttendanceTimeline(records: records),
      ],
    );

    return ModuleScreenShell(
      title: 'My Attendance',
      subtitle: 'Course-wise attendance and eligibility from backend.',
      fallbackRoute: AppRoutes.student,
      children: children,
    );
  }
}

class _AttendanceLoadingPanel extends StatelessWidget {
  const _AttendanceLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const ModulePanel(
      padding: EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Loading attendance',
        subtitle: 'Fetching your attendance records from backend.',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.cyan,
        trailing: ModuleBadge(label: 'Loading', color: AppColors.cyan),
      ),
    );
  }
}

class _AttendanceErrorPanel extends StatelessWidget {
  const _AttendanceErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: ModuleInfoTile(
        title: 'Unable to load attendance',
        subtitle: message,
        icon: Icons.error_outline_rounded,
        color: AppColors.amber,
        trailing: const ModuleBadge(label: 'Error', color: AppColors.amber),
      ),
    );
  }
}

class _OverallAttendanceSummary extends StatelessWidget {
  const _OverallAttendanceSummary({required this.records});

  final List<AttendanceRecordModel> records;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final average = _averageAttendance(records);
    final hasRecords = records.isNotEmpty;
    final eligible = hasRecords && average >= 75;
    final accent = eligible ? colorScheme.secondary : AppColors.amber;
    final statusLabel = hasRecords
        ? eligible
              ? 'Eligible'
              : 'At Risk'
        : 'No Data';

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
                      value: hasRecords ? average / 100 : 0,
                      strokeWidth: 8,
                      color: accent,
                      backgroundColor: accent.withValues(alpha: 0.13),
                    ),
                    Center(
                      child: Text(
                        hasRecords ? _percentageLabel(average) : '--',
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ModuleBadge(
                          label: 'Status: $statusLabel',
                          icon: eligible
                              ? Icons.verified_rounded
                              : Icons.info_outline_rounded,
                          color: accent,
                        ),
                        const ModuleBadge(
                          label: 'Minimum Required: 75%',
                          icon: Icons.rule_rounded,
                          color: AppColors.blue,
                        ),
                        ModuleBadge(
                          label: 'Records: ${records.length}',
                          icon: Icons.fact_check_rounded,
                          color: AppColors.cyan,
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
              value: hasRecords ? average / 100 : 0,
              minHeight: 8,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentAttendanceCard extends StatelessWidget {
  const _CurrentAttendanceCard({required this.record});

  final AttendanceRecordModel? record;

  @override
  Widget build(BuildContext context) {
    if (record == null) {
      return const ModulePanel(
        padding: EdgeInsets.all(14),
        child: ModuleInfoTile(
          title: 'No attendance records yet',
          subtitle:
              'Your attendance records will appear here after your teacher saves attendance.',
          icon: Icons.event_busy_rounded,
          color: AppColors.amber,
          trailing: ModuleBadge(label: 'Empty', color: AppColors.amber),
        ),
      );
    }

    final currentRecord = record!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPresent = currentRecord.attendanceStatus == 'present';
    final accent = isPresent ? colorScheme.secondary : AppColors.red;

    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Latest Attendance Record',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ModuleBadge(
                label: _statusLabel(currentRecord.attendanceStatus),
                icon: isPresent
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModuleBadge(
                label: _recordTitle(currentRecord),
                icon: Icons.menu_book_rounded,
                color: AppColors.cyan,
              ),
              if (_hasText(currentRecord.teacherName))
                ModuleBadge(
                  label: currentRecord.teacherName!,
                  icon: Icons.person_rounded,
                  color: AppColors.blue,
                ),
              if (_hasText(_classLabel(currentRecord)))
                ModuleBadge(
                  label: _classLabel(currentRecord),
                  icon: Icons.school_rounded,
                ),
              if (_hasText(_timeLabel(currentRecord)))
                ModuleBadge(
                  label: _timeLabel(currentRecord),
                  icon: Icons.access_time_rounded,
                ),
              ModuleBadge(
                label: _methodLabel(currentRecord.attendanceMethod),
                icon: currentRecord.attendanceMethod == 'dynamic_qr'
                    ? Icons.qr_code_2_rounded
                    : Icons.face_retouching_natural_rounded,
              ),
              ModuleBadge(
                label: _formatDate(_recordDisplayDate(currentRecord)),
                icon: Icons.calendar_month_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Frame Presence',
                  value: _framesText(currentRecord),
                  icon: Icons.photo_camera_rounded,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Percentage',
                  value: _percentageLabel(currentRecord.attendancePercentage),
                  icon: Icons.percent_rounded,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ModuleInfoTile(
            title: _recordTitle(currentRecord),
            subtitle:
                '${_methodLabel(currentRecord.attendanceMethod)} attendance saved from backend',
            icon: currentRecord.attendanceMethod == 'dynamic_qr'
                ? Icons.qr_code_2_rounded
                : Icons.face_retouching_natural_rounded,
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          Text(
            isPresent
                ? 'Marked present because attendance is at least 75%.'
                : 'Marked absent because attendance is below 75%.',
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

class _AttendanceRecordList extends StatelessWidget {
  const _AttendanceRecordList({required this.records});

  final List<AttendanceRecordModel> records;

  @override
  Widget build(BuildContext context) {
    return ModulePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Records',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const ModuleInfoTile(
              title: 'No saved records found',
              subtitle:
                  'Once attendance is saved by your teacher, records will be visible here.',
              icon: Icons.inbox_rounded,
              color: AppColors.amber,
            )
          else
            for (final record in records) ...[
              _AttendanceRecordCard(record: record),
              if (record != records.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  const _AttendanceRecordCard({required this.record});

  final AttendanceRecordModel record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPresent = record.attendanceStatus == 'present';
    final accent = isPresent ? colorScheme.secondary : AppColors.red;

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
                  _recordTitle(record),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ModuleBadge(
                label: _percentageLabel(record.attendancePercentage),
                icon: Icons.percent_rounded,
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: record.attendancePercentage / 100,
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
                label: _statusLabel(record.attendanceStatus),
                icon: isPresent
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: accent,
              ),
              if (_hasText(record.teacherName))
                ModuleBadge(
                  label: record.teacherName!,
                  icon: Icons.person_rounded,
                  color: AppColors.blue,
                ),
              if (_hasText(_classLabel(record)))
                ModuleBadge(
                  label: _classLabel(record),
                  icon: Icons.school_rounded,
                  color: AppColors.cyan,
                ),
              ModuleBadge(
                label: _formatDate(_recordDisplayDate(record)),
                icon: Icons.calendar_month_rounded,
              ),
              ModuleBadge(
                label: _methodLabel(record.attendanceMethod),
                icon: record.attendanceMethod == 'dynamic_qr'
                    ? Icons.qr_code_2_rounded
                    : Icons.face_retouching_natural_rounded,
                color: AppColors.blue,
              ),
              ModuleBadge(
                label: 'Frames: ${_framesText(record)}',
                icon: Icons.photo_camera_rounded,
                color: colorScheme.secondary,
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
  const _AttendanceTimeline({required this.records});

  final List<AttendanceRecordModel> records;

  @override
  Widget build(BuildContext context) {
    final recentRecords = records.take(5).toList();

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
          if (recentRecords.isEmpty)
            const ModuleInfoTile(
              title: 'No recent timeline',
              subtitle:
                  'Attendance history will appear after records are saved.',
              icon: Icons.timeline_rounded,
              color: AppColors.amber,
            )
          else
            for (final record in recentRecords) ...[
              _TimelineRow(record: record),
              if (record != recentRecords.last) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.record});

  final AttendanceRecordModel record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final present = record.attendanceStatus == 'present';
    final accent = present ? colorScheme.secondary : AppColors.red;

    return ModuleInfoTile(
      title:
          '${_formatDate(_recordDisplayDate(record))}, ${_recordTitle(record)}',
      subtitle:
          '${_statusLabel(record.attendanceStatus)} - ${_percentageLabel(record.attendancePercentage)}',
      icon: present ? Icons.check_circle_rounded : Icons.warning_rounded,
      color: accent,
      trailing: ModuleBadge(
        label: _statusLabel(record.attendanceStatus),
        color: accent,
      ),
    );
  }
}

DateTime _recordDisplayDate(AttendanceRecordModel record) {
  return record.sessionDate ?? record.createdAt;
}

String _recordTitle(AttendanceRecordModel record) {
  final subjectName = record.subjectName?.trim();

  if (subjectName != null && subjectName.isNotEmpty) {
    return subjectName;
  }

  return 'Session ${_shortId(record.sessionId)}';
}

String _classLabel(AttendanceRecordModel record) {
  final parts = <String?>[
    record.departmentName,
    record.batchName,
    record.semesterName,
  ].where(_hasText).map((value) => value!.trim()).toList();

  return parts.join(' | ');
}

String _timeLabel(AttendanceRecordModel record) {
  if (!_hasText(record.startTime) || !_hasText(record.endTime)) {
    return '';
  }

  return '${_formatTime(record.startTime!)} - ${_formatTime(record.endTime!)}';
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

double _averageAttendance(List<AttendanceRecordModel> records) {
  if (records.isEmpty) {
    return 0;
  }

  final total = records.fold<double>(
    0,
    (sum, record) => sum + record.attendancePercentage,
  );

  return total / records.length;
}

String _percentageLabel(double value) {
  final rounded = value.roundToDouble();

  if ((value - rounded).abs() < 0.01) {
    return '${value.round()}%';
  }

  return '${value.toStringAsFixed(1)}%';
}

String _framesText(AttendanceRecordModel record) {
  if (record.totalFrames == 0) {
    return '${record.framesDetected}';
  }

  return '${record.framesDetected}/${record.totalFrames}';
}

String _methodLabel(String value) {
  return value
      .split('_')
      .where((word) => word.trim().isNotEmpty)
      .map((word) {
        final trimmed = word.trim();

        if (trimmed.length == 1) {
          return trimmed.toUpperCase();
        }

        return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
      })
      .join(' ');
}

String _statusLabel(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized.isEmpty) {
    return 'Unknown';
  }

  return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
}

String _formatDate(DateTime value) {
  final localValue = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final recordDate = DateTime(
    localValue.year,
    localValue.month,
    localValue.day,
  );

  if (recordDate == today) {
    return 'Today';
  }

  if (recordDate == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }

  final day = localValue.day.toString().padLeft(2, '0');
  final month = localValue.month.toString().padLeft(2, '0');
  final year = localValue.year.toString();

  return '$day/$month/$year';
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

String _shortId(String value) {
  if (value.length <= 8) {
    return value;
  }

  return value.substring(0, 8);
}

String _cleanErrorMessage(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
