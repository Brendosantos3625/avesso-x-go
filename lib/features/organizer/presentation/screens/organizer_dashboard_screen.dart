import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/utils/formatters.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/features/events/application/catalog_scope.dart';
import 'package:avesso_x_go/features/tickets/application/purchase_scope.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final events = CatalogScope.of(context).events;
    final purchases = PurchaseScope.of(context);
    final ordersCount = purchases.orders.length;
    final ticketsCount = purchases.tickets.length;
    final revenue =
        events.fold<double>(0, (sum, event) => sum + event.price);

    final stats = <_Stat>[
      _Stat(
        label: 'Eventos',
        value: events.length.toString(),
        icon: Icons.event_available,
      ),
      _Stat(
        label: 'Pedidos',
        value: ordersCount.toString(),
        icon: Icons.receipt_long_outlined,
      ),
      _Stat(
        label: 'Ingressos',
        value: ticketsCount.toString(),
        icon: Icons.confirmation_number_outlined,
      ),
      _Stat(
        label: 'Receita (demonstrativa)',
        value: Formatters.formatBRL(revenue),
        icon: Icons.payments_outlined,
      ),
    ];

    return Scaffold(
      appBar: AvessoAppBar(title: 'Painel do Organizador'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceAlt.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Pedidos e ingressos refletem as compras simuladas '
                          'salvas localmente. Valores financeiros são '
                          'demonstrativos. Não há integração financeira real.',
                      style: styles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 3 : 1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.3,
                  children: [
                    for (final stat in stats) _StatCard(stat: stat),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Seus eventos', style: styles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            for (final event in events) ...[
              AvessoCard(
                onTap: () => context.push(
                  RouteNames.eventDetailsWith(event.id),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            event.formattedDate,
                            style: styles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      event.formattedPrice,
                      style: styles.labelLarge
                          .copyWith(color: colors.primary),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
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
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return AvessoCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: colors.primary),
          const Spacer(),
          Text(stat.value, style: styles.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stat.label,
            style: styles.bodySmall,
          ),
        ],
      ),
    );
  }
}