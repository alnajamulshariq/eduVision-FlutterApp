import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/dashboard_action_card.dart';
import 'package:eduvision_app/core/widgets/dashboard_shell.dart';
import 'package:eduvision_app/core/widgets/dashboard_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      roleLabel: 'Student Workspace',
      title: 'Welcome, Student',
      subtitle: 'Your attendance, gate activity, and communication tools.',
      stats: const [
        DashboardStat(
          label: 'Status',
          value: 'Preview',
          icon: Icons.fact_check_rounded,
          accentColor: AppColors.cyan,
        ),
        DashboardStat(
          label: 'Attendance',
          value: '0%',
          icon: Icons.percent_rounded,
          accentColor: AppColors.blue,
        ),
        DashboardStat(
          label: 'Gate',
          value: 'Pending',
          icon: Icons.sensor_door_rounded,
          accentColor: AppColors.amber,
        ),
      ],
      actions: [
        DashboardActionCard(
          title: 'My Dynamic QR',
          subtitle: 'Secure attendance QR preview',
          icon: Icons.qr_code_2_rounded,
          accentColor: AppColors.cyan,
          status: 'Preview',
          onTap: () {
            context.push(AppRoutes.studentQr);
          },
        ),
        DashboardActionCard(
          title: 'My Attendance',
          subtitle: 'Course-wise attendance summaries',
          icon: Icons.fact_check_rounded,
          accentColor: AppColors.blue,
          onTap: () {
            context.push(AppRoutes.studentAttendance);
          },
        ),
        DashboardActionCard(
          title: 'Gate History',
          subtitle: 'Entry and exit activity logs',
          icon: Icons.sensor_door_rounded,
          accentColor: AppColors.amber,
          onTap: () {
            context.push(AppRoutes.studentGateHistory);
          },
        ),
        DashboardActionCard(
          title: 'Anonymous Message',
          subtitle: 'Send anonymous academic feedback',
          icon: Icons.mark_unread_chat_alt_rounded,
          accentColor: Color(0xFFB48CFF),
          onTap: () {
            context.push(AppRoutes.studentAnonymousMessage);
          },
        ),
      ],
    );
  }
}
