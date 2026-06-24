import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.compact = false,
    this.dense = false,
    this.alignment = CrossAxisAlignment.center,
  });

  final bool compact;
  final bool dense;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final markSize = compact ? (dense ? 44.0 : 54.0) : 74.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: compact ? (dense ? 25 : 30) : 40,
          ),
        ),
        SizedBox(height: compact ? (dense ? 8 : 12) : 18),
        Text(
          AppConstants.appName,
          style:
              (compact
                      ? dense
                            ? textTheme.titleLarge
                            : textTheme.headlineSmall
                      : textTheme.displaySmall)
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
        if (!compact) ...[
          const SizedBox(height: 8),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
