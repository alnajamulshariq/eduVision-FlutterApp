import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/features/admin/admin_dashboard_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_academics_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_attendance_reports_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_gate_logs_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_gate_qr_scanner_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_message_reports_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_users_screen.dart';
import 'package:eduvision_app/features/auth/login_screen.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:eduvision_app/features/splash/splash_screen.dart';
import 'package:eduvision_app/features/student/screens/student_anonymous_message_screen.dart';
import 'package:eduvision_app/features/student/screens/student_attendance_screen.dart';
import 'package:eduvision_app/features/student/screens/student_gate_history_screen.dart';
import 'package:eduvision_app/features/student/screens/student_qr_screen.dart';
import 'package:eduvision_app/features/student/student_dashboard_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_anonymous_messages_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_attendance_reports_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_gate_monitoring_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_qr_scanner_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_start_attendance_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_timetable_screen.dart';
import 'package:eduvision_app/features/teacher/teacher_dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;
      final isPublicRoute = path == AppRoutes.splash || path == AppRoutes.login;

      if (!isPublicRoute && !authState.isAuthenticated) {
        return AppRoutes.login;
      }

      if (path == AppRoutes.login && authState.isAuthenticated) {
        final user = authState.user;
        if (user != null) {
          return AppRoutes.dashboardForRole(user.role);
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.student,
        name: 'student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentQr,
        name: 'student-qr',
        builder: (context, state) => const StudentQrScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAttendance,
        name: 'student-attendance',
        builder: (context, state) => const StudentAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentGateHistory,
        name: 'student-gate-history',
        builder: (context, state) => const StudentGateHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAnonymousMessage,
        name: 'student-anonymous-message',
        builder: (context, state) => const StudentAnonymousMessageScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacher,
        name: 'teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherTimetable,
        name: 'teacher-timetable',
        builder: (context, state) => const TeacherTimetableScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherStartAttendance,
        name: 'teacher-start-attendance',
        builder: (context, state) => const TeacherStartAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherAttendanceReports,
        name: 'teacher-attendance-reports',
        builder: (context, state) => const TeacherAttendanceReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherQrScanner,
        name: 'teacher-qr-scanner',
        builder: (context, state) => const TeacherQrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherAnonymousMessages,
        name: 'teacher-anonymous-messages',
        builder: (context, state) => const TeacherAnonymousMessagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherGateMonitoring,
        name: 'teacher-gate-monitoring',
        builder: (context, state) => const TeacherGateMonitoringScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        name: 'admin-users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAcademics,
        name: 'admin-academics',
        builder: (context, state) => const AdminAcademicsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAttendanceReports,
        name: 'admin-attendance-reports',
        builder: (context, state) => const AdminAttendanceReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminGateLogs,
        name: 'admin-gate-logs',
        builder: (context, state) => const AdminGateLogsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminGateQrScanner,
        name: 'admin-gate-qr-scanner',
        builder: (context, state) => const AdminGateQrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminMessageReports,
        name: 'admin-message-reports',
        builder: (context, state) => const AdminMessageReportsScreen(),
      ),
    ],
  );
});
