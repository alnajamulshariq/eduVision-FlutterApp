import 'package:eduvision_app/core/errors/app_exception.dart';
import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/app_user_model.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  const AuthRepository({this.supabaseService, this.preferences});

  static const _mockUserEmailKey = 'eduvision_mock_auth_email';
  static const _mockPasswordChangedKeyPrefix =
      'eduvision_mock_password_changed_';

  final SupabaseService? supabaseService;
  final SharedPreferences? preferences;

  Future<Result<AppUserModel>> loginWithEmailPassword({
    required String universityEmail,
    required String password,
  }) async {
    if (_shouldUseMockAuth) {
      final user = _findMockUser(universityEmail, password);

      if (user == null) {
        return const Result.failure(
          AppException(
            message: 'Invalid university email or password.',
            code: 'invalid_mock_credentials',
          ),
        );
      }

      await preferences?.setString(_mockUserEmailKey, user.universityEmail);
      return Result.success(_withMockPasswordState(user));
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message: 'Supabase is not ready. Please restart the app.',
            code: 'supabase_not_ready',
          ),
        );
      }

      final response = await client.auth.signInWithPassword(
        email: universityEmail.trim().toLowerCase(),
        password: password,
      );

      final authUser = response.user;

      if (authUser == null) {
        return const Result.failure(
          AppException(
            message: 'Login failed. Please check your credentials.',
            code: 'supabase_login_failed',
          ),
        );
      }

      final profile = await client
          .from('app_users')
          .select()
          .eq('id', authUser.id)
          .eq('is_active', true)
          .single();

      return Result.success(AppUserModel.fromJson(profile));
    } on AuthException catch (exception) {
      return Result.failure(
        AppException(message: exception.message, code: 'supabase_auth_error'),
      );
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Login failed. Please check your account profile.',
          code: 'supabase_profile_error',
        ),
      );
    }
  }

  Future<Result<AppUserModel?>> getCurrentUser() async {
    if (_shouldUseMockAuth) {
      final email = preferences?.getString(_mockUserEmailKey);

      if (email == null || email.isEmpty) {
        return const Result<AppUserModel?>.success(null);
      }

      final user = _mockUsers[email.toLowerCase()];
      return Result.success(user == null ? null : _withMockPasswordState(user));
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result<AppUserModel?>.success(null);
      }

      final authUser = client.auth.currentUser;

      if (authUser == null) {
        return const Result<AppUserModel?>.success(null);
      }

      final profile = await client
          .from('app_users')
          .select()
          .eq('id', authUser.id)
          .eq('is_active', true)
          .single();

      return Result.success(AppUserModel.fromJson(profile));
    } catch (_) {
      return const Result<AppUserModel?>.success(null);
    }
  }

  Future<Result<void>> logout() async {
    if (_shouldUseMockAuth) {
      await preferences?.remove(_mockUserEmailKey);
      return const Result.success(null);
    }

    try {
      final client = supabaseService?.client;
      await client?.auth.signOut();
      return const Result.success(null);
    } catch (_) {
      return const Result.success(null);
    }
  }

  Future<Result<void>> changePasswordOnce({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_shouldUseMockAuth) {
      if (newPassword.trim().length < 6) {
        return const Result.failure(
          AppException(
            message: 'Password must be at least 6 characters.',
            code: 'mock_password_too_short',
          ),
        );
      }

      await preferences?.setBool(_passwordChangedKey(userId), true);
      return const Result.success(null);
    }

    if (newPassword.trim().length < 6) {
      return const Result.failure(
        AppException(
          message: 'Password must be at least 6 characters.',
          code: 'password_too_short',
        ),
      );
    }

    try {
      final client = supabaseService?.client;

      if (client == null) {
        return const Result.failure(
          AppException(
            message: 'Supabase is not ready. Please restart the app.',
            code: 'supabase_not_ready',
          ),
        );
      }

      await client.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );

      await client
          .from('app_users')
          .update({'is_first_login': false, 'password_changed_once': true})
          .eq('id', userId);

      return const Result.success(null);
    } catch (_) {
      return const Result.failure(
        AppException(
          message: 'Password could not be changed right now.',
          code: 'supabase_password_change_failed',
        ),
      );
    }
  }

  Future<Result<void>> resetPasswordByAdmin({
    required String userId,
    required String temporaryPassword,
  }) async {
    if (_shouldUseMockAuth) {
      await preferences?.remove(_passwordChangedKey(userId));
      return const Result.success(null);
    }

    return _notImplemented('Supabase admin password reset');
  }

  Result<T> _notImplemented<T>(String feature) {
    return Result.failure(AppException.notImplemented(feature));
  }

  bool get _shouldUseMockAuth {
    return supabaseService == null || supabaseService!.isMockMode;
  }

  AppUserModel? _findMockUser(String universityEmail, String password) {
    final normalizedEmail = universityEmail.trim().toLowerCase();
    final expectedPassword = _mockPasswords[normalizedEmail];

    if (expectedPassword == null || expectedPassword != password) {
      return null;
    }

    return _mockUsers[normalizedEmail];
  }

  AppUserModel _withMockPasswordState(AppUserModel user) {
    final passwordChanged =
        preferences?.getBool(_passwordChangedKey(user.id)) ??
        user.passwordChangedOnce;

    return user.copyWith(
      isFirstLogin: !passwordChanged,
      passwordChangedOnce: passwordChanged,
    );
  }

  static String _passwordChangedKey(String userId) {
    return '$_mockPasswordChangedKeyPrefix$userId';
  }

  static final Map<String, String> _mockPasswords = {
    'student@eduvision.edu': 'student123',
    'teacher@eduvision.edu': 'teacher123',
    'admin@eduvision.edu': 'admin123',
  };

  static final Map<String, AppUserModel> _mockUsers = {
    'student@eduvision.edu': _mockUser(
      id: 'mock-student-001',
      name: 'Ali Khan',
      universityEmail: 'student@eduvision.edu',
      role: 'student',
    ),
    'teacher@eduvision.edu': _mockUser(
      id: 'mock-teacher-001',
      name: 'Mr. Ahmad',
      universityEmail: 'teacher@eduvision.edu',
      role: 'teacher',
    ),
    'admin@eduvision.edu': _mockUser(
      id: 'mock-admin-001',
      name: 'Admin User',
      universityEmail: 'admin@eduvision.edu',
      role: 'admin',
    ),
  };

  static AppUserModel _mockUser({
    required String id,
    required String name,
    required String universityEmail,
    required String role,
  }) {
    final createdAt = DateTime.utc(2026, 6, 24);

    return AppUserModel(
      id: id,
      name: name,
      universityEmail: universityEmail,
      role: role,
      isFirstLogin: true,
      passwordChangedOnce: false,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}
