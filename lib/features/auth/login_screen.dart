import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/app_info_button.dart';
import 'package:eduvision_app/core/widgets/app_logo.dart';
import 'package:eduvision_app/core/widgets/glass_card.dart';
import 'package:eduvision_app/core/widgets/premium_background.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/core/widgets/theme_toggle_button.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final user = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    if (!mounted || user == null) return;

    context.go(AppRoutes.dashboardForRole(user.role));
  }

  void _fillDemoCredential(_DemoCredential credential) {
    // Autofill only. Role still comes from authenticated mock user data.
    ref.read(authControllerProvider.notifier).clearError();

    _emailController.value = TextEditingValue(
      text: credential.email,
      selection: TextSelection.collapsed(offset: credential.email.length),
    );

    _passwordController.value = TextEditingValue(
      text: credential.password,
      selection: TextSelection.collapsed(offset: credential.password.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PremiumBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final metrics = _LoginMetrics.fromConstraints(constraints);
              final viewInsets = MediaQuery.viewInsetsOf(context);
              final isKeyboardOpen = viewInsets.bottom > 0;

              final content = metrics.isWide
                  ? _buildWideContent(metrics)
                  : _buildMobileContent(metrics);

              if (metrics.isCompactHeight || isKeyboardOpen) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    top: metrics.outerVerticalPadding,
                    bottom: viewInsets.bottom + metrics.outerVerticalPadding,
                  ),
                  child: Align(alignment: Alignment.topCenter, child: content),
                );
              }

              return Center(child: content);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(_LoginMetrics metrics) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.outerHorizontalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _LoginToolbar(),
            SizedBox(height: metrics.topGap),
            AppLogo(compact: true, dense: metrics.isCompactHeight),
            SizedBox(height: metrics.logoGap),
            _LoginFormCard(metrics: metrics, form: _buildForm(metrics)),
          ],
        ),
      ),
    );
  }

  Widget _buildWideContent(_LoginMetrics metrics) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: metrics.outerVerticalPadding,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _LoginToolbar(),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: _LoginBrandPanel()),
                const SizedBox(width: 26),
                Expanded(
                  child: _LoginFormCard(
                    metrics: metrics,
                    form: _buildForm(metrics),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(_LoginMetrics metrics) {
    final authState = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style:
                (metrics.isCompactHeight
                        ? textTheme.titleLarge
                        : textTheme.headlineSmall)
                    ?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
          ),
          SizedBox(height: metrics.microGap),
          Text(
            'Sign in with your university email and password.',
            style:
                (metrics.isCompactHeight
                        ? textTheme.bodySmall
                        : textTheme.bodyMedium)
                    ?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.28,
                    ),
          ),
          if (authState.errorMessage != null) ...[
            SizedBox(height: metrics.fieldGap),
            _LoginErrorMessage(message: authState.errorMessage!),
          ],
          SizedBox(height: metrics.sectionGap),
          _CompactDemoAccessPanel(
            metrics: metrics,
            onCredentialSelected: _fillDemoCredential,
          ),
          SizedBox(height: metrics.sectionGap),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: metrics.isCompactHeight ? textTheme.bodyMedium : null,
            decoration: InputDecoration(
              isDense: metrics.isCompactHeight,
              contentPadding: metrics.fieldPadding,
              labelText: 'Email address',
              hintText: 'name@university.edu',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            onChanged: (_) {
              ref.read(authControllerProvider.notifier).clearError();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'University email is required';
              }
              return null;
            },
          ),
          SizedBox(height: metrics.fieldGap),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            style: metrics.isCompactHeight ? textTheme.bodyMedium : null,
            onFieldSubmitted: (_) {
              if (!authState.isLoading) _handleLogin();
            },
            decoration: InputDecoration(
              isDense: metrics.isCompactHeight,
              contentPadding: metrics.fieldPadding,
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            onChanged: (_) {
              ref.read(authControllerProvider.notifier).clearError();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          SizedBox(height: metrics.buttonGap),
          PrimaryButton(
            label: 'Login',
            icon: Icons.arrow_forward_rounded,
            isLoading: authState.isLoading,
            minHeight: metrics.buttonHeight,
            padding: metrics.buttonPadding,
            onPressed: authState.isLoading ? null : _handleLogin,
          ),
          SizedBox(height: metrics.microGap),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                minimumSize: Size(0, metrics.aboutButtonHeight),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: metrics.isCompactHeight ? 4 : 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => showEduVisionAboutSheet(context),
              icon: const Icon(Icons.info_outline_rounded, size: 17),
              label: const Text('About EduVision'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginMetrics {
  const _LoginMetrics({required this.isWide, required this.isCompactHeight});

  factory _LoginMetrics.fromConstraints(BoxConstraints constraints) {
    final isCompactHeight = constraints.maxHeight < 760;

    return _LoginMetrics(
      isWide: constraints.maxWidth >= 920 && !isCompactHeight,
      isCompactHeight: isCompactHeight,
    );
  }

  final bool isWide;
  final bool isCompactHeight;

  double get outerHorizontalPadding => isCompactHeight ? 18 : 22;
  double get outerVerticalPadding => isCompactHeight ? 10 : 22;
  double get topGap => isCompactHeight ? 6 : 14;
  double get logoGap => isCompactHeight ? 8 : 18;
  double get cardPadding => isCompactHeight ? 14 : 22;
  double get microGap => isCompactHeight ? 4 : 8;
  double get fieldGap => isCompactHeight ? 9 : 14;
  double get sectionGap => isCompactHeight ? 10 : 18;
  double get buttonGap => isCompactHeight ? 12 : 20;
  double get buttonHeight => isCompactHeight ? 48 : 56;
  double get aboutButtonHeight => isCompactHeight ? 30 : 36;

  EdgeInsets get fieldPadding =>
      EdgeInsets.symmetric(horizontal: 14, vertical: isCompactHeight ? 11 : 16);

  EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: 18, vertical: isCompactHeight ? 12 : 16);
}

class _LoginToolbar extends StatelessWidget {
  const _LoginToolbar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [AppInfoButton(), Spacer(), ThemeToggleButton()],
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(30),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(alignment: CrossAxisAlignment.start),
          SizedBox(height: 34),
          _InsightTile(
            label: 'Smart Attendance',
            value: 'Secure session-ready flow',
            icon: Icons.verified_user_rounded,
          ),
          SizedBox(height: 14),
          _InsightTile(
            label: 'Gate Monitoring',
            value: 'Entry and exit visibility',
            icon: Icons.sensor_door_rounded,
          ),
          SizedBox(height: 14),
          _InsightTile(
            label: 'Campus Communication',
            value: 'Anonymous messaging module',
            icon: Icons.mark_unread_chat_alt_rounded,
          ),
        ],
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({required this.metrics, required this.form});

  final _LoginMetrics metrics;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(metrics.cardPadding),
      blurSigma: metrics.isCompactHeight ? 12 : 14,
      child: form,
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              style: textTheme.bodySmall?.copyWith(
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

class _DemoCredential {
  const _DemoCredential({
    required this.role,
    required this.email,
    required this.password,
    required this.icon,
  });

  final String role;
  final String email;
  final String password;
  final IconData icon;

  static const values = [
    _DemoCredential(
      role: 'Student',
      email: 'student@eduvision.edu',
      password: 'student123',
      icon: Icons.person_rounded,
    ),
    _DemoCredential(
      role: 'Teacher',
      email: 'teacher@eduvision.edu',
      password: 'teacher123',
      icon: Icons.co_present_rounded,
    ),
    _DemoCredential(
      role: 'Admin',
      email: 'admin@eduvision.edu',
      password: 'admin123',
      icon: Icons.admin_panel_settings_rounded,
    ),
  ];
}

class _CompactDemoAccessPanel extends StatelessWidget {
  const _CompactDemoAccessPanel({
    required this.metrics,
    required this.onCredentialSelected,
  });

  final _LoginMetrics metrics;
  final ValueChanged<_DemoCredential> onCredentialSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(metrics.isCompactHeight ? 8 : 12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.key_rounded,
                color: colorScheme.primary,
                size: metrics.isCompactHeight ? 15 : 17,
              ),
              const SizedBox(width: 7),
              Text(
                'Demo Access',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Mock accounts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: metrics.isCompactHeight ? 10 : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.isCompactHeight ? 8 : 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = metrics.isCompactHeight ? 6.0 : 8.0;
              final itemWidth = (constraints.maxWidth - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final credential in _DemoCredential.values)
                    SizedBox(
                      width: credential.role == 'Admin'
                          ? constraints.maxWidth
                          : itemWidth,
                      child: _DemoQuickButton(
                        credential: credential,
                        metrics: metrics,
                        onPressed: () => onCredentialSelected(credential),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
class _DemoQuickButton extends StatelessWidget {
  const _DemoQuickButton({
    required this.credential,
    required this.metrics,
    required this.onPressed,
  });

  final _DemoCredential credential;
  final _LoginMetrics metrics;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, metrics.isCompactHeight ? 32 : 38),
        padding: EdgeInsets.symmetric(
          horizontal: metrics.isCompactHeight ? 8 : 10,
          vertical: metrics.isCompactHeight ? 7 : 9,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.34)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              credential.icon,
              size: metrics.isCompactHeight ? 13 : 15,
            ),
            const SizedBox(width: 5),
            Text(
              'Use ${credential.role}',
              maxLines: 1,
              style: TextStyle(
                fontSize: metrics.isCompactHeight ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.54)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
