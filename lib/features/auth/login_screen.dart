import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/app_info_button.dart';
import 'package:eduvision_app/core/widgets/app_logo.dart';
import 'package:eduvision_app/core/widgets/glass_card.dart';
import 'package:eduvision_app/core/widgets/premium_background.dart';
import 'package:eduvision_app/core/widgets/primary_button.dart';
import 'package:eduvision_app/core/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum UserRole {
  student('Student', Icons.person_rounded, AppRoutes.student),
  teacher('Teacher', Icons.co_present_rounded, AppRoutes.teacher),
  admin('Admin', Icons.admin_panel_settings_rounded, AppRoutes.admin);

  const UserRole(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.go(_selectedRole.route);
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

              if (metrics.isVerySmallHeight || isKeyboardOpen) {
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
            'Sign in to continue to your ${AppConstants.appName} workspace.',
            style:
                (metrics.isCompactHeight
                        ? textTheme.bodySmall
                        : textTheme.bodyMedium)
                    ?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.32,
                    ),
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email address is required';
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
            onFieldSubmitted: (_) => _handleLogin(),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          SizedBox(height: metrics.sectionGap),
          Text(
            'Select role',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: metrics.microGap + 2),
          _RolePicker(
            selectedRole: _selectedRole,
            compact: metrics.isCompactHeight,
            onChanged: (role) {
              setState(() => _selectedRole = role);
            },
          ),
          SizedBox(height: metrics.buttonGap),
          PrimaryButton(
            label: 'Login as ${_selectedRole.label}',
            icon: Icons.arrow_forward_rounded,
            minHeight: metrics.buttonHeight,
            padding: metrics.buttonPadding,
            onPressed: _handleLogin,
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
  const _LoginMetrics({
    required this.isWide,
    required this.isCompactHeight,
    required this.isVerySmallHeight,
  });

  factory _LoginMetrics.fromConstraints(BoxConstraints constraints) {
    final isCompactHeight = constraints.maxHeight < 760;
    final isVerySmallHeight = constraints.maxHeight < 680;

    return _LoginMetrics(
      isWide: constraints.maxWidth >= 920 && !isCompactHeight,
      isCompactHeight: isCompactHeight,
      isVerySmallHeight: isVerySmallHeight,
    );
  }

  final bool isWide;
  final bool isCompactHeight;
  final bool isVerySmallHeight;

  double get outerHorizontalPadding => isCompactHeight ? 20 : 22;
  double get outerVerticalPadding => isCompactHeight ? 12 : 22;
  double get topGap => isCompactHeight ? 8 : 14;
  double get logoGap => isCompactHeight ? 10 : 18;
  double get cardPadding => isCompactHeight ? 16 : 22;
  double get microGap => isCompactHeight ? 4 : 8;
  double get fieldGap => isCompactHeight ? 10 : 14;
  double get sectionGap => isCompactHeight ? 12 : 18;
  double get buttonGap => isCompactHeight ? 14 : 20;
  double get buttonHeight => isCompactHeight ? 50 : 56;
  double get aboutButtonHeight => isCompactHeight ? 30 : 36;

  EdgeInsets get fieldPadding =>
      EdgeInsets.symmetric(horizontal: 14, vertical: isCompactHeight ? 12 : 16);

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

class _RolePicker extends StatelessWidget {
  const _RolePicker({
    required this.selectedRole,
    required this.compact,
    required this.onChanged,
  });

  final UserRole selectedRole;
  final bool compact;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 270;

        if (vertical) {
          return Column(
            children: [
              for (final role in UserRole.values) ...[
                if (role.index > 0) SizedBox(height: compact ? 6 : 8),
                _RoleOption(
                  role: role,
                  selected: selectedRole == role,
                  compact: compact,
                  onSelected: () => onChanged(role),
                ),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (final role in UserRole.values) ...[
              if (role.index > 0) SizedBox(width: compact ? 7 : 10),
              Expanded(
                child: _RoleOption(
                  role: role,
                  selected: selectedRole == role,
                  compact: compact,
                  onSelected: () => onChanged(role),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.role,
    required this.selected,
    required this.compact,
    required this.onSelected,
  });

  final UserRole role;
  final bool selected;
  final bool compact;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 9 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.62),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
            gradient: selected
                ? LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.18),
                      colorScheme.secondary.withValues(alpha: 0.10),
                    ],
                  )
                : null,
            color: selected
                ? null
                : colorScheme.surface.withValues(alpha: 0.38),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                role.icon,
                size: compact ? 16 : 19,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: compact ? 5 : 8),
              Flexible(
                child: Text(
                  role.label,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? textTheme.labelSmall : textTheme.labelLarge)
                      ?.copyWith(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
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
