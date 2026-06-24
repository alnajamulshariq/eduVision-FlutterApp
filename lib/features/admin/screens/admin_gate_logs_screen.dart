import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class AdminGateLogsScreen extends StatelessWidget {
  const AdminGateLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Gate Logs',
      subtitle: 'Entry and exit records preview.',
      fallbackRoute: AppRoutes.admin,
      children: const [
        ModulePanel(child: ModuleChipRow(labels: ['Today', 'Entry', 'Exit'])),
        ModuleInfoTile(
          title: 'Ali Khan',
          subtitle: 'Entry - 08:00 AM - Main Gate',
          icon: Icons.login_rounded,
          color: AppColors.cyan,
        ),
        ModuleInfoTile(
          title: 'Sara Ahmed',
          subtitle: 'Exit - 12:30 PM - Main Gate',
          icon: Icons.logout_rounded,
          color: AppColors.amber,
        ),
        ModuleInfoTile(
          title: 'Ahmed Raza',
          subtitle: 'Entry - 08:15 AM - Main Gate',
          icon: Icons.login_rounded,
          color: AppColors.blue,
        ),
      ],
    );
  }
}
