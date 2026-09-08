import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(AppColors.dark);

  static ThemeData get light => _build(AppColors.light);

  static ColorScheme _colorScheme(AppColors colors) {
    return ColorScheme(
      brightness: colors.brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      error: colors.error,
      onError: colors.onError,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerHighest: colors.surfaceAlt,
      outline: colors.border,
      outlineVariant: colors.border,
      onSurfaceVariant: colors.textSecondary,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData _build(AppColors colors) {
    final styles = AppTextStyles.resolve(colors);
    final colorScheme = _colorScheme(colors);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      textTheme: styles.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: styles.titleLarge,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.3),
        selectionHandleColor: colors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        labelStyle: AppTextStyles.resolve(colors)
            .bodyMedium
            .copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.resolve(colors)
            .bodyMedium
            .copyWith(color: colors.textSecondary.withValues(alpha: 0.6)),
        errorStyle: AppTextStyles.resolve(colors)
            .bodySmall
            .copyWith(color: colors.error),
        counterStyle: AppTextStyles.resolve(colors).bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        enabledBorder: _inputBorder(colors.border, 1),
        focusedBorder: _inputBorder(colors.primary, 1.6),
        errorBorder: _inputBorder(colors.error, 1),
        focusedErrorBorder: _inputBorder(colors.error, 1.6),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
          borderSide: BorderSide(color: colors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.5),
          textStyle: styles.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.primary,
          disabledForegroundColor: colors.primary.withValues(alpha: 0.4),
          side: BorderSide(color: colors.primary),
          textStyle: styles.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: styles.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primary.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => styles.labelLarge.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.textSecondary,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
      ),
    );
  }
}