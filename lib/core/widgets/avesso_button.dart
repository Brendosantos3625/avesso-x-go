import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AvessoButtonType { primary, secondary, outline }

class AvessoButton extends StatelessWidget {
  const AvessoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AvessoButtonType.primary,
    this.loading = false,
    this.disabled = false,
    this.danger = false,
    this.expanded = true,
    this.icon,
    this.minimumSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final AvessoButtonType type;
  final bool loading;
  final bool disabled;
  final bool danger;
  final bool expanded;
  final IconData? icon;
  final Size? minimumSize;

  bool get _enabled => !loading && !disabled && onPressed != null;

  Color get _accentColor => danger ? AppColors.error : AppColors.primary;

  Color get _foregroundColor => switch (type) {
        AvessoButtonType.primary => AppColors.onPrimary,
        AvessoButtonType.secondary => AppColors.textPrimary,
        AvessoButtonType.outline => _accentColor,
      };

  Color get _backgroundColor => switch (type) {
        AvessoButtonType.primary => _accentColor,
        AvessoButtonType.secondary => AppColors.surfaceAlt,
        AvessoButtonType.outline => Colors.transparent,
      };

  BorderSide get _borderSide => BorderSide(
        color: _enabled
            ? _accentColor
            : _accentColor.withValues(alpha: 0.5),
        width: 1.4,
      );

  @override
  Widget build(BuildContext context) {
    final Widget content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: _foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: _foregroundColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _foregroundColor.withValues(
                      alpha: _enabled ? 1 : 0.65,
                    ),
                  ),
                ),
              ),
            ],
          );

    final Size size = minimumSize ??
        (expanded ? const Size(double.infinity, 52) : const Size(0, 52));

    final ButtonStyle style = switch (type) {
      AvessoButtonType.outline => OutlinedButton.styleFrom(
          minimumSize: size,
          side: _borderSide,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          foregroundColor: _foregroundColor,
          textStyle: AppTextStyles.labelLarge,
        ),
      AvessoButtonType.secondary => FilledButton.styleFrom(
          minimumSize: size,
          backgroundColor: AppColors.surfaceAlt,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surfaceAlt.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.textPrimary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      AvessoButtonType.primary => FilledButton.styleFrom(
          minimumSize: size,
          backgroundColor: _backgroundColor,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: _backgroundColor.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
    };

    return switch (type) {
      AvessoButtonType.outline => OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: style,
          child: content,
        ),
      _ => FilledButton(
          onPressed: _enabled ? onPressed : null,
          style: style,
          child: content,
        ),
    };
  }
}