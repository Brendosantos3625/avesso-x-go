import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto do AVESSO X GO.
///
/// As cores vêm da paleta vigente ([AppColors]) para que o tema claro e o
/// escuro sejam refletidos em toda a aplicação sem cores espalhadas pelas
/// telas. Use [AppTextStyles.of] dentro de widgets que possuem `BuildContext`.
@immutable
class AppTextStyles {
  const AppTextStyles(this.colors);

  final AppColors colors;

  TextStyle get headlineLarge => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: colors.textPrimary,
      );

  TextStyle get headlineMedium => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: colors.textPrimary,
      );

  TextStyle get headlineSmall => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: colors.textPrimary,
      );

  TextStyle get titleLarge => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: colors.textPrimary,
      );

  TextStyle get titleMedium => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: colors.textPrimary,
      );

  TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: colors.textPrimary,
      );

  TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: colors.textPrimary,
      );

  TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: colors.textSecondary,
      );

  TextStyle get labelLarge => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: colors.textPrimary,
      );

  TextTheme get textTheme => TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
      );

  static AppTextStyles of(BuildContext context) =>
      AppTextStyles(AppColors.of(context));

  static AppTextStyles resolve(AppColors colors) => AppTextStyles(colors);
}