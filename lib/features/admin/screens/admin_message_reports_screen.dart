import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class AdminMessageReportsScreen extends StatelessWidget {
  const AdminMessageReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Message Reports',
      subtitle: 'Reported anonymous messages preview.',
      fallbackRoute: AppRoutes.admin,
      children: [
        ModulePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModuleInfoTile(
                title: 'Reported message preview',
                subtitle: 'Teacher: Mr. Ahmad',
                icon: Icons.report_rounded,
                color: AppColors.amber,
                trailing: ModuleBadge(
                  label: 'Pending Review',
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(height: 12),
              ModuleButtonRow(
                labels: const ['Review', 'Mark Safe', 'Escalate'],
                onPressed: (label) {
                  showModuleSnackBar(context, '$label preview action.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
