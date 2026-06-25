import 'package:eduvision_app/core/config/env_config.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  const SupabaseService();

  static bool _initialized = false;

  bool get isConfigured => EnvConfig.hasSupabaseConfig;

  bool get canUseSupabase {
    return EnvConfig.hasSupabaseConfig && !EnvConfig.useMockData;
  }

  bool get isMockMode => !canUseSupabase;

  SupabaseClient? get client {
    if (!_initialized || !canUseSupabase) {
      return null;
    }

    return Supabase.instance.client;
  }

  String get statusMessage {
    if (!EnvConfig.hasSupabaseConfig) {
      return 'Supabase credentials are missing. App is running in mock mode.';
    }

    if (EnvConfig.useMockData) {
      return 'Supabase credentials found, but USE_MOCK_DATA is true. App is running in mock mode.';
    }

    if (!_initialized) {
      return 'Supabase is configured but not initialized yet.';
    }

    return 'Supabase is connected.';
  }

  Future<Result<void>> initialize() async {
    if (!canUseSupabase) {
      return const Result.success(null);
    }

    if (_initialized) {
      return const Result.success(null);
    }

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );

    _initialized = true;
    return const Result.success(null);
  }
}
