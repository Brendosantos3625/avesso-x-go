import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/constants/app_constants.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AvessoAppBar(title: 'Perfil'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.surfaceAlt,
                    child: Text(
                      'UA',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppConstants.demoUserName,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppConstants.demoUserEmail,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Conta', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(
                      'Configurações',
                      style: AppTextStyles.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(RouteNames.settings),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: Text(
                      'Painel do organizador',
                      style: AppTextStyles.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(RouteNames.organizer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AvessoButton(
              label: 'Sair',
              type: AvessoButtonType.outline,
              danger: true,
              onPressed: () => context.go(RouteNames.login),
            ),
          ],
        ),
      ),
    );
  }
}