import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/dashboard_action_card.dart';
import 'package:eduvision_app/core/widgets/dashboard_shell.dart';
import 'package:eduvision_app/core/widgets/dashboard_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      roleLabel: 'Teacher Workspace',
      title: 'Welcome, Teacher',
      subtitle: 'Manage lectures, attendance sessions, and student monitoring.',
      stats: const [
        DashboardStat(
          label: 'Classes',
          value: '2',
          icon: Icons.calendar_month_rounded,
          accentColor: AppColors.cyan,
        ),
        DashboardStat(
          label: 'Sessions',
          value: 'Preview',
          icon: Icons.play_circle_rounded,
          accentColor: AppColors.blue,
        ),
        DashboardStat(
          label: 'Messages',
          value: '3',
          icon: Icons.forum_rounded,
          accentColor: AppColors.amber,
        ),
      ],
      actions: [
        DashboardActionCard(
          title: 'Today\'s Timetable',
          subtitle: 'View scheduled classes',
          icon: Icons.calendar_month_rounded,
          accentColor: AppColors.cyan,
          onTap: () {
            context.push(AppRoutes.teacherTimetable);
          },
        ),
        DashboardActionCard(
          title: 'Start Attendance',
          subtitle: 'Prepare attendance session flow',
          icon: Icons.play_circle_rounded,
          accentColor: AppColors.blue,
          status: 'Preview',
          onTap: () {
            context.push(AppRoutes.teacherStartAttendance);
          },
        ),
        DashboardActionCard(
          title: 'Attendance Reports',
          subtitle: 'Review session analytics',
          icon: Icons.analytics_rounded,
          accentColor: AppColors.amber,
          onTap: () {
            context.push(AppRoutes.teacherAttendanceReports);
          },
        ),
        DashboardActionCard(
          title: 'QR Scanner',
          subtitle: 'Dynamic QR scan preview',
          icon: Icons.qr_code_scanner_rounded,
          accentColor: AppColors.amber,
          status: 'Preview',
          onTap: () {
            context.push(AppRoutes.teacherQrScanner);
          },
        ),
        DashboardActionCard(
          title: 'Anonymous Messages',
          subtitle: 'Read student feedback',
          icon: Icons.forum_rounded,
          accentColor: Color(0xFFB48CFF),
          onTap: () {
            context.push(AppRoutes.teacherAnonymousMessages);
          },
        ),
        DashboardActionCard(
          title: 'Student Gate Monitoring',
          subtitle: 'Monitor student campus status',
          icon: Icons.manage_search_rounded,
          accentColor: Color(0xFFFF8A7A),
          onTap: () {
            context.push(AppRoutes.teacherGateMonitoring);
          },
        ),
      ],
    );
  }
}
