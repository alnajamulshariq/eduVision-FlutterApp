import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:eduvision_app/features/shared/widgets/attendance_reports_content.dart';
import 'package:eduvision_app/features/teacher/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherAttendanceReportsScreen extends ConsumerWidget {
  const TeacherAttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(teacherAttendanceReportsProvider);

    return ModuleScreenShell(
      title: 'Attendance Reports',
      subtitle: 'Your class sessions and student attendance records.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        reportsAsync.when(
          loading: () => const AttendanceReportsLoadingPanel(),
          error: (error, _) =>
              AttendanceReportsErrorPanel(message: _cleanErrorMessage(error)),
          data: (reports) => AttendanceReportsContent(
            reports: reports,
            emptyTitle: 'No attendance reports found',
            emptySubtitle:
                'Your completed attendance sessions will appear here.',
          ),
        ),
      ],
    );
  }
}

String _cleanErrorMessage(Object error) {
  final text = error.toString();

  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }

  return text;
}
