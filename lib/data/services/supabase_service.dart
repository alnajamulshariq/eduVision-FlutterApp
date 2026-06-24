import 'package:eduvision_app/core/config/env_config.dart';
import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';

class SupabaseService {
  const SupabaseService();

  bool get isConfigured => EnvConfig.hasSupabaseConfig;

  Future<Result<void>> initialize() async {
    // TODO: Initialize the Supabase client after credentials are configured.
    return const Result.failure(
      AppException(
        message: 'Supabase initialization is not connected yet.',
        code: 'supabase_not_connected',
      ),
    );
  }
}
