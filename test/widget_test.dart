import 'package:eduvision_app/app/app.dart';
import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/app/theme_controller.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/features/student/student_dashboard_screen.dart';
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
