import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class StudentGateHistoryScreen extends StatelessWidget {
  const StudentGateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Gate History',
      subtitle: 'Entry and exit activity preview.',
      fallbackRoute: AppRoutes.student,
      children: const [
        ModulePanel(
          child: ModuleInfoTile(
            title: 'Inside University',
            subtitle: 'Current campus status',
            icon: Icons.location_on_rounded,
            color: AppColors.cyan,
            trailing: ModuleBadge(label: 'Live Preview', color: AppColors.cyan),
          ),
        ),
        ModulePanel(
          child: Column(
            children: [
              ModuleInfoTile(
                title: '08:00 AM',
                subtitle: 'Entry - Main Gate',
                icon: Icons.login_rounded,
                color: AppColors.cyan,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: '11:30 AM',
                subtitle: 'Exit - Main Gate',
                icon: Icons.logout_rounded,
                color: AppColors.amber,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: '12:15 PM',
                subtitle: 'Entry - Main Gate',
                icon: Icons.login_rounded,
                color: AppColors.blue,
              ),
            ],
          ),
        ),
        ModulePanel(
          child: ModuleInfoTile(
            title: 'Parent Notification',
            subtitle: 'Email notification preview enabled',
            icon: Icons.mark_email_read_rounded,
            color: Color(0xFFB48CFF),
            trailing: ModuleBadge(label: 'Enabled', color: Color(0xFFB48CFF)),
          ),
        ),
      ],
    );
  }
}
