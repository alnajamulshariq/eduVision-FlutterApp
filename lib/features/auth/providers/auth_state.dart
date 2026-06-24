import 'package:eduvision_app/data/models/app_user_model.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    required this.isFirstLogin,
    this.user,
    this.errorMessage,
    this.selectedRoleForDemo,
  });

  const AuthState.initial()
    : isLoading = false,
      user = null,
      errorMessage = null,
      isAuthenticated = false,
      isFirstLogin = false,
      selectedRoleForDemo = null;

  AuthState.loading({this.user, this.selectedRoleForDemo})
    : isLoading = true,
      errorMessage = null,
      isAuthenticated = user != null,
      isFirstLogin = user?.isFirstLogin ?? false;

  AuthState.authenticated(AppUserModel authenticatedUser)
    : isLoading = false,
      user = authenticatedUser,
      errorMessage = null,
      isAuthenticated = true,
      isFirstLogin = authenticatedUser.isFirstLogin,
      selectedRoleForDemo = authenticatedUser.role;

  const AuthState.unauthenticated()
    : isLoading = false,
      user = null,
      errorMessage = null,
      isAuthenticated = false,
      isFirstLogin = false,
      selectedRoleForDemo = null;

  const AuthState.error(String message, {this.selectedRoleForDemo})
    : isLoading = false,
      user = null,
      errorMessage = message,
      isAuthenticated = false,
      isFirstLogin = false;

  final bool isLoading;
  final AppUserModel? user;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isFirstLogin;
  final String? selectedRoleForDemo;

  AuthState copyWith({
    bool? isLoading,
    AppUserModel? user,
    String? errorMessage,
    bool clearError = false,
    bool? isAuthenticated,
    bool? isFirstLogin,
    String? selectedRoleForDemo,
  }) {
    final nextUser = user ?? this.user;

    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: nextUser,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? nextUser != null,
      isFirstLogin: isFirstLogin ?? nextUser?.isFirstLogin ?? false,
      selectedRoleForDemo: selectedRoleForDemo ?? this.selectedRoleForDemo,
    );
  }
}
