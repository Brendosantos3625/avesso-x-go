import 'package:flutter/material.dart';

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
  bool _darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AvessoAppBar(title: 'Configurações'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Preferências', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: Text(
                      'Notificações',
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      'Alertas de eventos e ofertas',
                      style: AppTextStyles.bodySmall,
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text(
                      'Tema escuro',
                      style: AppTextStyles.bodyLarge,
                    ),
                    value: _darkModeEnabled,
                    onChanged: (value) =>
                        setState(() => _darkModeEnabled = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Sobre', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AvessoCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text(
                  'AVESSO X GO — versão demo',
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}