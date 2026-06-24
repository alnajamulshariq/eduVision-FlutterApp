import 'package:eduvision_app/app/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton.filledTonal(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () {
        ref.read(themeModeControllerProvider.notifier).toggleTheme();
      },
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.68)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0.18, end: 1).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.72, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}
