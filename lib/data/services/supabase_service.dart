import 'package:eduvision_app/core/utils/result.dart';

class SupabaseService {
  const SupabaseService();

  bool get isConfigured => false;

  bool get isMockMode => true;

  bool get canUseSupabase => false;

  String get statusMessage =>
      'Supabase is not connected yet. App is running in mock mode.';

  Future<Result<void>> initialize() async {
    // TODO: Add supabase_flutter during the real backend integration phase.
    // TODO: Call Supabase.initialize only after credentials, auth, and RLS are ready.
    return const Result.success(null);
  }
}
