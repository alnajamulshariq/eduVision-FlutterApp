import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class AdminAttendanceReportsScreen extends StatelessWidget {
  const AdminAttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Attendance Reports',
      subtitle: 'View attendance analytics preview.',
      fallbackRoute: AppRoutes.admin,
      children: const [
        ModulePanel(
          child: Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Present',
                  value: '86%',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.cyan,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Absent',
                  value: '14%',
                  icon: Icons.cancel_rounded,
                  color: AppColors.amber,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Sessions',
                  value: '12',
                  icon: Icons.event_note_rounded,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ),
        ModulePanel(
          child: Column(
            children: [
              ModuleInfoTile(
                title: 'Database Systems',
                subtitle: 'BSIT 2022 - 90%',
                icon: Icons.analytics_rounded,
                color: AppColors.cyan,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'Web Engineering',
                subtitle: 'BSSE 2023 - 82%',
                icon: Icons.bar_chart_rounded,
                color: AppColors.blue,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'AI',
                subtitle: 'BSIT 2022 - 76%',
                icon: Icons.psychology_rounded,
                color: AppColors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
