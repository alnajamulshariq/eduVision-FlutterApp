import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/dashboard_action_card.dart';
import 'package:eduvision_app/core/widgets/dashboard_shell.dart';
import 'package:eduvision_app/core/widgets/dashboard_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      roleLabel: 'Admin Console',
      title: 'Welcome, Admin',
      subtitle: 'Control users, academics, reports, gate logs, and messages.',
      stats: const [
        DashboardStat(
          label: 'Users',
          value: '140',
          icon: Icons.group_rounded,
          accentColor: AppColors.cyan,
        ),
        DashboardStat(
          label: 'Reports',
          value: 'Ready',
          icon: Icons.analytics_rounded,
          accentColor: AppColors.blue,
        ),
        DashboardStat(
          label: 'Alerts',
          value: '0',
          icon: Icons.notifications_active_rounded,
          accentColor: AppColors.amber,
        ),
      ],
      actions: [
        DashboardActionCard(
          title: 'User Management',
          subtitle: 'Manage student and staff accounts',
          icon: Icons.group_rounded,
          accentColor: AppColors.cyan,
          onTap: () {
            context.push(AppRoutes.adminUsers);
          },
        ),
        DashboardActionCard(
          title: 'Academic Management',
          subtitle: 'Departments, batches, semesters, subjects',
          icon: Icons.account_tree_rounded,
          accentColor: AppColors.blue,
          onTap: () {
            context.push(AppRoutes.adminAcademics);
          },
        ),
        DashboardActionCard(
          title: 'Attendance Reports',
          subtitle: 'Analytics and student records',
          icon: Icons.analytics_rounded,
          accentColor: AppColors.amber,
          onTap: () {
            context.push(AppRoutes.adminAttendanceReports);
          },
        ),
        DashboardActionCard(
          title: 'Gate Logs',
          subtitle: 'Entry and exit records',
          icon: Icons.door_back_door_rounded,
          accentColor: Color(0xFFFF8A7A),
          onTap: () {
            context.push(AppRoutes.adminGateLogs);
          },
        ),
        DashboardActionCard(
          title: 'Message Reports',
          subtitle: 'Moderation and reported messages',
          icon: Icons.report_rounded,
          accentColor: Color(0xFFB48CFF),
          onTap: () {
            context.push(AppRoutes.adminMessageReports);
          },
        ),
      ],
    );
  }
}
