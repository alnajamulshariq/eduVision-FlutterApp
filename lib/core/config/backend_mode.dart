import 'package:eduvision_app/core/config/env_config.dart';

enum BackendMode {
  mock,
  supabase;

  static BackendMode get current {
    if (EnvConfig.useMockData) {
      return BackendMode.mock;
    }

    if (EnvConfig.hasSupabaseConfig) {
      return BackendMode.supabase;
    }

    return BackendMode.mock;
  }

  bool get isMock => this == BackendMode.mock;

  bool get isSupabase => this == BackendMode.supabase;
}
