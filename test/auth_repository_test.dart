import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/app_user_model.dart';
import 'package:eduvision_app/data/repositories/auth_repository.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'mock auth accepts the demo accounts with their expected roles',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = AuthRepository(
        supabaseService: const SupabaseService(),
        preferences: preferences,
      );

      const accounts = [
        (
          email: 'student@eduvision.edu',
          password: 'student123',
          role: 'student',
        ),
        (
          email: 'teacher@eduvision.edu',
          password: 'teacher123',
          role: 'teacher',
        ),
        (email: 'admin@eduvision.edu', password: 'admin123', role: 'admin'),
      ];

      for (final account in accounts) {
        final result = await repository.loginWithEmailPassword(
          universityEmail: account.email,
          password: account.password,
        );

        expect(result, isA<Success<AppUserModel>>());
        final user = (result as Success<AppUserModel>).data;
        expect(user.universityEmail, account.email);
        expect(user.role, account.role);
      }
    },
  );
}
