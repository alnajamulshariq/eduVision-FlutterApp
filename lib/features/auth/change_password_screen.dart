import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/app_logo.dart';
import 'package:eduvision_app/core/widgets/glass_card.dart';
import 'package:eduvision_app/core/widgets/premium_background.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .changePasswordOnce(_passwordController.text);

    if (!mounted || !success) {
      return;
    }

    final user = ref.read(authControllerProvider).user;
    context.go(
      user == null ? AppRoutes.login : AppRoutes.dashboardForRole(user.role),
    );
  }

  Future<void> _handleLogout() async {
    await ref.read(authControllerProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.login);
        }
      });
    } else if (!user.mustChangePassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.dashboardForRole(user.role));
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PremiumBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompactHeight = constraints.maxHeight < 720;
              final viewInsets = MediaQuery.viewInsetsOf(context);
              final content = _ChangePasswordCard(
                formKey: _formKey,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                obscurePassword: _obscurePassword,
                obscureConfirmPassword: _obscureConfirmPassword,
                isLoading: authState.isLoading,
                errorMessage: authState.errorMessage,
                isCompactHeight: isCompactHeight,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onToggleConfirmPassword: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                onChanged: () {
                  ref.read(authControllerProvider.notifier).clearError();
                },
                onSubmit: _handleSubmit,
                onLogout: authState.isLoading ? null : _handleLogout,
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  20,
                  isCompactHeight ? 12 : 24,
                  20,
                  viewInsets.bottom + (isCompactHeight ? 12 : 24),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                        viewInsets.bottom -
                        (isCompactHeight ? 24 : 48),
                  ),
                  child: Center(child: content),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordCard extends StatelessWidget {
  const _ChangePasswordCard({
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.isCompactHeight,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onChanged,
    required this.onSubmit,
    required this.onLogout,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final bool isCompactHeight;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onLogout;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: GlassCard(
        padding: EdgeInsets.all(isCompactHeight ? 16 : 22),
        blurSigma: 14,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: AppLogo(compact: true, dense: isCompactHeight)),
              SizedBox(height: isCompactHeight ? 14 : 20),
              Text(
                'Create new password',
                style:
                    (isCompactHeight
                            ? textTheme.titleLarge
                            : textTheme.headlineSmall)
                        ?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a new password to continue to your workspace.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 14),
                _ChangePasswordErrorMessage(message: errorMessage!),
              ],
              SizedBox(height: isCompactHeight ? 14 : 18),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                onChanged: (_) => onChanged(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }

                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!isLoading) {
                    onSubmit();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    tooltip: obscureConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: onToggleConfirmPassword,
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                onChanged: (_) => onChanged(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your new password';
                  }

                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }

                  return null;
                },
              ),
              SizedBox(height: isCompactHeight ? 14 : 20),
              PrimaryButton(
                label: 'Save Password',
                icon: Icons.check_circle_rounded,
                isLoading: isLoading,
                minHeight: isCompactHeight ? 48 : 54,
                onPressed: isLoading ? null : onSubmit,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordErrorMessage extends StatelessWidget {
  const _ChangePasswordErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colorScheme.error),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
