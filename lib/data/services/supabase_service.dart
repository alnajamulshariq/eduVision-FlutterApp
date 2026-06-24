import 'package:eduvision_app/core/config/backend_mode.dart';
import 'package:eduvision_app/core/config/env_config.dart';
import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  const SupabaseService();

  BackendMode get backendMode => BackendMode.current;

  bool get isMockMode => backendMode.isMock;

  bool get isConfigured => EnvConfig.hasSupabaseConfig;

  bool get canUseSupabase => backendMode.isSupabase && isConfigured;

  SupabaseClient? get client {
    if (!canUseSupabase) {
      return null;
    }

    // TODO: Return Supabase.instance.client after real initialization is enabled.
    return null;
  }

  Future<Result<void>> initialize() async {
    if (!canUseSupabase) {
      return const Result.success(null);
    }

    // TODO: Initialize Supabase only after credentials, auth, and RLS are reviewed.
    // Example later:
    // await Supabase.initialize(
    //   url: EnvConfig.supabaseUrl,
    //   anonKey: EnvConfig.supabaseAnonKey,
    // );
    return const Result.failure(
      AppException(
        message: 'Supabase initialization is prepared but not enabled yet.',
        code: 'supabase_initialization_pending',
      ),
    );
  }
}
