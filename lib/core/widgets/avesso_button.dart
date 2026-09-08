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

  Color _accentColor(AppColors colors) =>
      danger ? colors.error : colors.primary;

  Color _foregroundColor(AppColors colors) => switch (type) {
        AvessoButtonType.primary => colors.onPrimary,
        AvessoButtonType.secondary => colors.textPrimary,
        AvessoButtonType.outline => _accentColor(colors),
      };

  Color _backgroundColor(AppColors colors) => switch (type) {
        AvessoButtonType.primary => _accentColor(colors),
        AvessoButtonType.secondary => colors.surfaceAlt,
        AvessoButtonType.outline => Colors.transparent,
      };

  BorderSide _borderSide(AppColors colors) {
    final accent = _accentColor(colors);
    return BorderSide(
      color: _enabled ? accent : accent.withValues(alpha: 0.5),
      width: 1.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final foregroundColor = _foregroundColor(colors);

    final Widget content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foregroundColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: styles.labelLarge.copyWith(
                    color: foregroundColor.withValues(
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
          side: _borderSide(colors),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          foregroundColor: foregroundColor,
          textStyle: styles.labelLarge,
        ),
      AvessoButtonType.secondary => FilledButton.styleFrom(
          minimumSize: size,
          backgroundColor: colors.surfaceAlt,
          foregroundColor: colors.textPrimary,
          disabledBackgroundColor: colors.surfaceAlt.withValues(alpha: 0.4),
          disabledForegroundColor: colors.textPrimary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: styles.labelLarge,
        ),
      AvessoButtonType.primary => FilledButton.styleFrom(
          minimumSize: size,
          backgroundColor: _backgroundColor(colors),
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: _backgroundColor(colors).withValues(alpha: 0.4),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: styles.labelLarge,
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