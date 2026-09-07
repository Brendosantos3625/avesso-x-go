import 'package:flutter/material.dart';

import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/utils/formatters.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  static const List<_Stat> _stats = [
    _Stat(
      label: 'Eventos ativos',
      value: '12',
      icon: Icons.event_available,
    ),
    _Stat(
      label: 'Ingressos vendidos',
      value: '3.420',
      icon: Icons.confirmation_number_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final revenue = Formatters.formatBRL(142800);

    return Scaffold(
      appBar: AvessoAppBar(title: 'Painel do Organizador'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 3 : 1;

            return GridView.count(
              padding: const EdgeInsets.all(AppSpacing.lg),
              crossAxisCount: columns,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
              children: [
                for (final stat in _stats) _StatCard(stat: stat),
                _StatCard(
                  stat: _Stat(
                    label: 'Receita',
                    value: revenue,
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return AvessoCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: AppColors.primary),
          const Spacer(),
          Text(stat.value, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stat.label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}