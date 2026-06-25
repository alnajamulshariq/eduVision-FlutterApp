import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/data/models/timetable_model.dart';
import 'package:eduvision_app/features/teacher/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherTimetableScreen extends ConsumerWidget {
  const TeacherTimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(teacherTimetableProvider);

    return ModuleScreenShell(
      title: 'Today\'s Timetable',
      subtitle: 'Scheduled classes preview.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        const ModulePanel(
          child: ModuleInfoTile(
            title: 'Backend Connected',
            subtitle: 'Today\'s timetable loads from Supabase when available.',
            icon: Icons.schedule_rounded,
            color: AppColors.cyan,
            trailing: ModuleBadge(label: 'Live', color: AppColors.cyan),
          ),
        ),
        ...timetableAsync.when(
          data: (timetable) {
            if (timetable.isEmpty) {
              return [
                const ModuleInfoTile(
                  title: 'No class scheduled today',
                  subtitle: 'No timetable record was found for today.',
                  icon: Icons.event_busy_rounded,
                  color: AppColors.amber,
                ),
              ];
            }

            return timetable.map(_buildTimetableTile).toList();
          },
          loading: () {
            return [
              const ModuleInfoTile(
                title: 'Loading timetable',
                subtitle: 'Please wait while today\'s classes are loaded.',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.cyan,
              ),
            ];
          },
          error: (_, _) {
            return [
              const ModuleInfoTile(
                title: 'Unable to load timetable',
                subtitle: 'Please check backend connection and try again.',
                icon: Icons.error_outline_rounded,
                color: AppColors.amber,
              ),
            ];
          },
        ),
      ],
    );
  }

  ModuleInfoTile _buildTimetableTile(TimetableModel item) {
    return ModuleInfoTile(
      title: '${_formatTime(item.startTime)} to ${_formatTime(item.endTime)}',
      subtitle:
          'Subject ${_shortId(item.subjectId)} - Department ${_shortId(item.departmentId)} - Semester ${_shortId(item.semesterId)}',
      icon: Icons.calendar_month_rounded,
      color: AppColors.blue,
      trailing: ModuleBadge(label: _formatDay(item.day), color: AppColors.blue),
    );
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
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }

  String _formatDay(String value) {
    if (value.trim().isEmpty) {
      return 'Today';
    }

    final normalized = value.trim().toLowerCase();

    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8);
  }
}
