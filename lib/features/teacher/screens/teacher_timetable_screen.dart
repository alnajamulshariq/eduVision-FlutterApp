import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class TeacherTimetableScreen extends StatelessWidget {
  const TeacherTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Today\'s Timetable',
      subtitle: 'Scheduled classes preview.',
      fallbackRoute: AppRoutes.teacher,
      children: const [
        ModulePanel(
          child: ModuleInfoTile(
            title: 'Preview Mode',
            subtitle: 'Current class status badge',
            icon: Icons.schedule_rounded,
            color: AppColors.cyan,
            trailing: ModuleBadge(label: 'Preview', color: AppColors.cyan),
          ),
        ),
        ModuleInfoTile(
          title: '09:00 AM to 10:00 AM',
          subtitle: 'Database Systems - BSIT 2022 - 8th Semester',
          icon: Icons.calendar_month_rounded,
          color: AppColors.blue,
        ),
        ModuleInfoTile(
          title: '11:00 AM to 12:00 PM',
          subtitle: 'Web Engineering - BSSE 2023 - 6th Semester',
          icon: Icons.event_available_rounded,
          color: AppColors.amber,
        ),
      ],
    );
  }
}
