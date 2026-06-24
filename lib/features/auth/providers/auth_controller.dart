import 'package:eduvision_app/core/utils/result.dart';
import 'package:eduvision_app/data/models/app_user_model.dart';
import 'package:eduvision_app/features/auth/providers/auth_provider.dart';
import 'package:eduvision_app/features/auth/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> checkAuthStatus() async {
    state = AuthState.loading(
      user: state.user,
      selectedRoleForDemo: state.selectedRoleForDemo,
    );

    final result = await ref.read(authRepositoryProvider).getCurrentUser();

    if (result case Success<AppUserModel?>(:final data)) {
      state = data == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(data);
      return;
    }

    if (result case Failure<AppUserModel?>(:final exception)) {
      state = AuthState.error(exception.message);
    }
  }

  Future<AppUserModel?> login(String email, String password) async {
    clearError();
    state = AuthState.loading(
      user: state.user,
      selectedRoleForDemo: state.selectedRoleForDemo,
    );

    final result = await ref
        .read(authRepositoryProvider)
        .loginWithEmailPassword(
          universityEmail: email.trim(),
          password: password,
        );

    if (result case Success<AppUserModel>(:final data)) {
      state = AuthState.authenticated(data);
      return data;
    }

    if (result case Failure<AppUserModel>(:final exception)) {
      state = AuthState.error(exception.message);
    }

    return null;
  }

  Future<void> logout() async {
    state = AuthState.loading(
      user: state.user,
      selectedRoleForDemo: state.selectedRoleForDemo,
    );

    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.unauthenticated();
  }

  Future<bool> changePasswordOnce(String newPassword) async {
    final currentUser = state.user;

    if (currentUser == null) {
      state = const AuthState.error('Please log in before changing password.');
      return false;
    }

    final result = await ref
        .read(authRepositoryProvider)
        .changePasswordOnce(
          userId: currentUser.id,
          currentPassword: '',
          newPassword: newPassword,
        );

    if (result is Success<void>) {
      // TODO: Route first-login users to a dedicated password change screen.
      state = AuthState.authenticated(
        currentUser.copyWith(isFirstLogin: false, passwordChangedOnce: true),
      );
      return true;
    }

    if (result case Failure<void>(:final exception)) {
      state = AuthState.error(exception.message);
    }

    return false;
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    state = state.copyWith(clearError: true);
  }
}
