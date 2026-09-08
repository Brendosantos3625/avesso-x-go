import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle, size: 96, color: colors.accent),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Compra confirmada!',
                textAlign: TextAlign.center,
                style: styles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Seu ingresso já está disponível na aba Ingressos.',
                textAlign: TextAlign.center,
                style: styles.bodyMedium
                    .copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AvessoButton(
                label: 'Ver meus ingressos',
                icon: Icons.confirmation_number_outlined,
                onPressed: () => context.go(RouteNames.tickets),
              ),
              const SizedBox(height: AppSpacing.md),
              AvessoButton(
                label: 'Voltar ao início',
                type: AvessoButtonType.outline,
                onPressed: () => context.go(RouteNames.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}