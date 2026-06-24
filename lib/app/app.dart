import 'package:eduvision_app/app/router.dart';
import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/app/theme_controller.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EduVisionApp extends ConsumerWidget {
  const EduVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: EduVisionTheme.lightTheme,
      darkTheme: EduVisionTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 560),
      themeAnimationCurve: Curves.easeInOutCubic,
      routerConfig: router,
    );
  }
}
