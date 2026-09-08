import 'package:flutter/material.dart';

import 'package:avesso_x_go/app/theme/theme_scope.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);
    final theme = ThemeScope.of(context);

    return Scaffold(
      appBar: AvessoAppBar(title: 'Configurações'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Preferências', style: styles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(
                  'Notificações',
                  style: styles.bodyLarge,
                ),
                subtitle: Text(
                  'Alertas de eventos e ofertas',
                  style: styles.bodySmall,
                ),
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Tema', style: styles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ThemeOptionTile(
                    icon: Icons.light_mode_outlined,
                    label: 'Claro',
                    selected: theme.isLight,
                    onTap: () =>
                        theme.setMode(ThemeMode.light),
                  ),
                  const Divider(),
                  _ThemeOptionTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Escuro',
                    selected: theme.isDark,
                    onTap: () => theme.setMode(ThemeMode.dark),
                  ),
                  const Divider(),
                  _ThemeOptionTile(
                    icon: Icons.brightness_auto_outlined,
                    label: 'Sistema',
                    selected: theme.isSystem,
                    onTap: () =>
                        theme.setMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Sobre', style: styles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text(
                  'AVESSO X GO — versão demo',
                  style: styles.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: styles.bodyLarge),
      trailing: selected
          ? Icon(Icons.check_circle, color: colors.primary)
          : null,
      selected: selected,
      selectedTileColor: colors.surfaceAlt,
      onTap: selected ? null : onTap,
    );
  }
}