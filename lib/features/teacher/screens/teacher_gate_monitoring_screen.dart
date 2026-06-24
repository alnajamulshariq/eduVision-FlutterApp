import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class TeacherGateMonitoringScreen extends StatelessWidget {
  const TeacherGateMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Student Gate Monitoring',
      subtitle: 'Monitor student campus presence preview.',
      fallbackRoute: AppRoutes.teacher,
      children: const [
        ModulePanel(
          child: ModuleChipRow(labels: ['BSIT', 'Batch 2022', '8th Semester']),
        ),
        ModuleInfoTile(
          title: 'Ali Khan',
          subtitle: 'Inside University - Entry 08:05 AM',
          icon: Icons.person_pin_circle_rounded,
          color: AppColors.cyan,
          trailing: ModuleBadge(label: 'Inside', color: AppColors.cyan),
        ),
        ModuleInfoTile(
          title: 'Sara Ahmed',
          subtitle: 'Outside University - Exit 12:30 PM',
          icon: Icons.person_off_rounded,
          color: AppColors.amber,
          trailing: ModuleBadge(label: 'Outside', color: AppColors.amber),
        ),
        ModuleInfoTile(
          title: 'Ahmed Raza',
          subtitle: 'Inside University - Entry 08:15 AM',
          icon: Icons.person_pin_circle_rounded,
          color: AppColors.blue,
          trailing: ModuleBadge(label: 'Inside', color: AppColors.blue),
        ),
      ],
    );
  }
}
