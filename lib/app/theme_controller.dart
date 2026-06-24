import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be provided at app startup.',
  );
});

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _themeModeKey = 'eduvision_theme_mode';

  @override
  ThemeMode build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return _modeFromStorage(preferences.getString(_themeModeKey)) ??
        ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final preferences = ref.read(sharedPreferencesProvider);
    unawaited(preferences.setString(_themeModeKey, _modeToStorage(mode)));
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }

  String _modeToStorage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'dark',
    };
  }

  ThemeMode? _modeFromStorage(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };
  }
}
