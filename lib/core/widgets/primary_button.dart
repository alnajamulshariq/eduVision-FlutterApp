import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.minHeight = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double minHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = isLoading || onPressed == null;
    final foreground = colorScheme.onPrimary;

    final child = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 10),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.34),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: disabled
                  ? null
                  : LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
              color: disabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.primary,
            ),
            child: InkWell(
              onTap: disabled ? null : onPressed,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  child: Padding(
                    padding: padding,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: disabled
                            ? colorScheme.onSurfaceVariant
                            : foreground,
                        fontWeight: FontWeight.w900,
                      ),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: disabled
                              ? colorScheme.onSurfaceVariant
                              : foreground,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
