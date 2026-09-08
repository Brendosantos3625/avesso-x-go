import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/features/auth/application/session_scope.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final user = SessionScope.of(context).user;
    final displayName = user?.name ?? 'Visitante';
    final displayEmail =
        user?.email ?? 'Entre para acessar sua conta.';

    return Scaffold(
      appBar: AvessoAppBar(title: 'Perfil', showBackButton: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colors.surfaceAlt,
                    child: Text(
                      user?.initials ?? 'U',
                      style: styles.headlineSmall.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    displayName,
                    style: styles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    displayEmail,
                    style: styles.bodyMedium
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Conta', style: styles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(
                      'Configurações',
                      style: styles.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(RouteNames.settings),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: Text(
                      'Painel do organizador',
                      style: styles.bodyLarge,
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
              onPressed: () {
                SessionScope.of(context).signOut();
                context.go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}