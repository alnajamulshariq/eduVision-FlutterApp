import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/app_user_model.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';

class AuthRepository {
  const AuthRepository({this.supabaseService});

  final SupabaseService? supabaseService;

  Future<Result<AppUserModel>> loginWithEmailPassword({
    required String universityEmail,
    required String password,
  }) async {
    return _notImplemented('Email and password login');
  }

  Future<Result<AppUserModel?>> getCurrentUser() async {
    return _notImplemented('Current user lookup');
  }

  Future<Result<void>> logout() async {
    return _notImplemented('Logout');
  }

  Future<Result<void>> changePasswordOnce({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return _notImplemented('First login password change');
  }

  Future<Result<void>> resetPasswordByAdmin({
    required String userId,
    required String temporaryPassword,
  }) async {
    return _notImplemented('Admin password reset');
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }
}
