import 'dart:async';

import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/app_logo.dart';
import 'package:eduvision_app/core/widgets/premium_background.dart';
import 'package:eduvision_app/features/auth/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 4), _navigateFromAuth);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _navigateFromAuth() async {
    await ref.read(authControllerProvider.notifier).checkAuthStatus();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    final route = authState.isAuthenticated && user != null
        ? AppRoutes.dashboardForRole(user.role)
        : AppRoutes.login;

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              children: [Spacer(), _SplashLogo(), Spacer(), _SplashLoading()],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return const AppLogo()
        .animate()
        .fadeIn(duration: 700.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 780.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(begin: 0.08, end: 0, duration: 700.ms);
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: colorScheme.surface.withValues(alpha: 0.42),
              color: colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Preparing secure workspace...',
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.12);
  }
}
