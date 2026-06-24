import 'package:eduvision_app/data/repositories/auth_repository.dart';
import 'package:eduvision_app/data/services/face_api_service.dart';
import 'package:eduvision_app/data/services/qr_token_service.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return const SupabaseService();
});

final qrTokenServiceProvider = Provider<QrTokenService>((ref) {
  return const QrTokenService();
});

final faceApiServiceProvider = Provider<FaceApiService>((ref) {
  return const FaceApiService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabaseService: ref.watch(supabaseServiceProvider));
});
