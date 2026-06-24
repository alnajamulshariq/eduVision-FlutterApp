import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class TeacherAnonymousMessagesScreen extends StatelessWidget {
  const TeacherAnonymousMessagesScreen({super.key});

  static const _messages = [
    'Sir, Lecture 4 was difficult to understand.',
    'Please provide additional practice exercises.',
    'The classroom projector is not working properly.',
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Anonymous Messages',
      subtitle: 'Read and manage student feedback.',
      fallbackRoute: AppRoutes.teacher,
      children: [
        for (final message in _messages)
          ModulePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModuleInfoTile(
                  title: 'Student Feedback',
                  subtitle: message,
                  icon: Icons.forum_rounded,
                  color: AppColors.cyan,
                ),
                const SizedBox(height: 12),
                ModuleButtonRow(
                  labels: const ['Mark Resolved', 'Report'],
                  onPressed: (label) {
                    showModuleSnackBar(context, '$label preview saved.');
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
