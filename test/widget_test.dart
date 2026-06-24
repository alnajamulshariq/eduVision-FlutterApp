import 'package:eduvision_app/app/app.dart';
import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/app/theme_controller.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/features/admin/admin_dashboard_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_academics_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_attendance_reports_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_gate_logs_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_message_reports_screen.dart';
import 'package:eduvision_app/features/admin/screens/admin_users_screen.dart';
import 'package:eduvision_app/features/student/screens/student_anonymous_message_screen.dart';
import 'package:eduvision_app/features/student/screens/student_attendance_screen.dart';
import 'package:eduvision_app/features/student/screens/student_gate_history_screen.dart';
import 'package:eduvision_app/features/student/screens/student_qr_screen.dart';
import 'package:eduvision_app/features/student/student_dashboard_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_anonymous_messages_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_gate_monitoring_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_qr_scanner_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_start_attendance_screen.dart';
import 'package:eduvision_app/features/teacher/screens/teacher_timetable_screen.dart';
import 'package:eduvision_app/features/teacher/teacher_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('EduVision app opens the login screen after splash', (
    tester,
  ) async {
    await _pumpEduVisionApp(tester);

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Login screen fits a 360x740 mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpEduVisionApp(tester);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Student dashboard shows compact controls on 360x740', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          theme: EduVisionTheme.lightTheme,
          darkTheme: EduVisionTheme.darkTheme,
          home: const StudentDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Student Workspace'), findsOneWidget);
    expect(find.text('My Dynamic QR'), findsOneWidget);
    expect(find.text('My Attendance'), findsOneWidget);
    expect(tester.getRect(find.text('My Attendance')).bottom, lessThan(740));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Demo screens render on 360x740 in light and dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final cases = <_ScreenCase>[
      _ScreenCase('Student dashboard', () => const StudentDashboardScreen()),
      _ScreenCase('Teacher dashboard', () => const TeacherDashboardScreen()),
      _ScreenCase('Admin dashboard', () => const AdminDashboardScreen()),
      _ScreenCase('Student QR', () => const StudentQrScreen()),
      _ScreenCase('Student attendance', () => const StudentAttendanceScreen()),
      _ScreenCase(
        'Student gate history',
        () => const StudentGateHistoryScreen(),
      ),
      _ScreenCase(
        'Student anonymous message',
        () => const StudentAnonymousMessageScreen(),
      ),
      _ScreenCase('Teacher timetable', () => const TeacherTimetableScreen()),
      _ScreenCase(
        'Teacher start attendance',
        () => const TeacherStartAttendanceScreen(),
      ),
      _ScreenCase('Teacher QR scanner', () => const TeacherQrScannerScreen()),
      _ScreenCase(
        'Teacher anonymous messages',
        () => const TeacherAnonymousMessagesScreen(),
      ),
      _ScreenCase(
        'Teacher gate monitoring',
        () => const TeacherGateMonitoringScreen(),
      ),
      _ScreenCase('Admin users', () => const AdminUsersScreen()),
      _ScreenCase('Admin academics', () => const AdminAcademicsScreen()),
      _ScreenCase(
        'Admin attendance reports',
        () => const AdminAttendanceReportsScreen(),
      ),
      _ScreenCase('Admin gate logs', () => const AdminGateLogsScreen()),
      _ScreenCase(
        'Admin message reports',
        () => const AdminMessageReportsScreen(),
      ),
    ];

    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      for (final screenCase in cases) {
        await _pumpStandaloneScreen(tester, screenCase.build(), themeMode);
        await tester.pump(const Duration(milliseconds: 100));

        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: '${screenCase.name} should render without layout errors.',
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 20));
      }
    }
  });
}

Future<void> _pumpEduVisionApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const EduVisionApp(),
    ),
  );
}

Future<void> _pumpStandaloneScreen(
  WidgetTester tester,
  Widget screen,
  ThemeMode themeMode,
) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        theme: EduVisionTheme.lightTheme,
        darkTheme: EduVisionTheme.darkTheme,
        themeMode: themeMode,
        home: screen,
      ),
    ),
  );
}

class _ScreenCase {
  const _ScreenCase(this.name, this.build);

  final String name;
  final Widget Function() build;
}
