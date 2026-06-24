import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const midnight = Color(0xFF07111F);
  static const navy = Color(0xFF0B1628);
  static const panel = Color(0xFF111C2E);
  static const panelSoft = Color(0xFF16243A);
  static const border = Color(0xFF26364F);
  static const cyan = Color(0xFF31D6C9);
  static const blue = Color(0xFF4F8CFF);
  static const amber = Color(0xFFF7B955);
  static const red = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF4F8FF);
  static const textMuted = Color(0xFFA9B7CC);

  static const lightBackground = Color(0xFFF4F8FF);
  static const lightPanel = Color(0xFFFFFFFF);
  static const lightPanelSoft = Color(0xFFEAF3FF);
  static const lightBorder = Color(0xFFD4E3F6);
  static const lightTextPrimary = Color(0xFF102033);
  static const lightTextMuted = Color(0xFF5F6F86);
}

abstract final class EduVisionTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppColors.midnight : AppColors.lightBackground;
    final surface = isDark ? AppColors.panel : AppColors.lightPanel;
    final surfaceSoft = isDark ? AppColors.panelSoft : AppColors.lightPanelSoft;
    final outline = isDark ? AppColors.border : AppColors.lightBorder;
    final onSurface = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.textMuted
        : AppColors.lightTextMuted;

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: brightness,
      ),
    );

    final colorScheme = baseTheme.colorScheme.copyWith(
      primary: isDark ? AppColors.blue : const Color(0xFF236BFE),
      secondary: isDark ? AppColors.cyan : const Color(0xFF00A8B6),
      tertiary: AppColors.amber,
      error: AppColors.red,
      surface: surface,
      surfaceContainerHighest: surfaceSoft,
      outline: outline,
      onPrimary: Colors.white,
      onSecondary: isDark ? AppColors.midnight : Colors.white,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
    );

    final baseTextTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: baseTextTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      iconTheme: IconThemeData(color: onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        titleTextStyle: GoogleFonts.inter(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? surfaceSoft.withValues(alpha: 0.84)
            : Colors.white.withValues(alpha: 0.82),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: onSurfaceVariant),
        labelStyle: TextStyle(color: onSurfaceVariant),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: _inputBorder(outline),
        enabledBorder: _inputBorder(outline),
        focusedBorder: _inputBorder(colorScheme.secondary, width: 1.6),
        errorBorder: _inputBorder(colorScheme.error),
        focusedErrorBorder: _inputBorder(colorScheme.error, width: 1.6),
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: isDark ? 0.78 : 0.82),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outline.withValues(alpha: 0.76)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: surfaceSoft,
          disabledForegroundColor: onSurfaceVariant,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outline.withValues(alpha: 0.82)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary.withValues(
                alpha: isDark ? 0.24 : 0.12,
              );
            }
            return surface.withValues(alpha: isDark ? 0.54 : 0.70);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return onSurfaceVariant;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: colorScheme.primary);
            }
            return BorderSide(color: outline.withValues(alpha: 0.72));
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.inter(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.56),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
