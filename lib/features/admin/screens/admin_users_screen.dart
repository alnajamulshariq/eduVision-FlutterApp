import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'User Management',
      subtitle: 'Manage students, teachers, and admins.',
      fallbackRoute: AppRoutes.admin,
      children: [
        const ModulePanel(
          child: Row(
            children: [
              Expanded(
                child: ModuleMetricCard(
                  label: 'Students',
                  value: '120',
                  icon: Icons.school_rounded,
                  color: AppColors.cyan,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Teachers',
                  value: '18',
                  icon: Icons.co_present_rounded,
                  color: AppColors.blue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModuleMetricCard(
                  label: 'Admins',
                  value: '2',
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
        ),
        ModulePanel(
          child: ModuleButtonRow(
            labels: const ['Add Student', 'Add Teacher', 'Reset Password'],
            onPressed: (label) {
              showModuleSnackBar(context, '$label preview action.');
            },
          ),
        ),
        const ModulePanel(
          child: Column(
            children: [
              ModuleInfoTile(
                title: 'Ali Khan',
                subtitle: 'Student - BSIT 2022',
                icon: Icons.person_rounded,
                color: AppColors.cyan,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'Mr. Ahmad',
                subtitle: 'Teacher - Database Systems',
                icon: Icons.co_present_rounded,
                color: AppColors.blue,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'Admin Office',
                subtitle: 'Admin - System Console',
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
