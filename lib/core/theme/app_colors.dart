import 'package:flutter/material.dart';

/// Paleta de cores centralizada do AVESSO X GO.
///
/// Cada tema (claro e escuro) fornece sua própria instância. As telas devem
/// acessar a paleta vigente via [AppColors.of] (ou `context.colors`) em vez de
/// usar valores fixos, garantindo que a troca de tema reflita em toda a
/// aplicação.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.onSurface,
    required this.error,
    required this.onError,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color onSurface;
  final Color error;
  final Color onError;

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    primary: Color(0xFFFF7A00),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF00C2B8),
    onAccent: Color(0xFF06292A),
    background: Color(0xFF0F182B),
    surface: Color(0xFF121C2F),
    surfaceAlt: Color(0xFF162241),
    border: Color(0xFF2B3A5E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA7B0CB),
    onSurface: Color(0xFFFFFFFF),
    error: Color(0xFFFF5C5C),
    onError: Color(0xFFFFFFFF),
  );

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    primary: Color(0xFFBF360C),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF008A82),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEFF1F6),
    border: Color(0xFFDFE4EE),
    textPrimary: Color(0xFF141A26),
    textSecondary: Color(0xFF5C667A),
    onSurface: Color(0xFF141A26),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? AppColors.dark;

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? onSurface,
    Color? error,
    Color? onError,
  }) {
    return AppColors(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      onSurface: onSurface ?? this.onSurface,
      error: error ?? this.error,
      onError: onError ?? this.onError,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      onAccent: Color.lerp(onAccent, other.onAccent, t) ?? onAccent,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt:
          Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      onSurface: Color.lerp(onSurface, other.onSurface, t) ?? onSurface,
      error: Color.lerp(error, other.error, t) ?? error,
      onError: Color.lerp(onError, other.onError, t) ?? onError,
    );
  }
}

extension AppColorsContextX on BuildContext {
  AppColors get colors => AppColors.of(this);
}