import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/core/widgets/avesso_empty_state.dart';
import 'package:avesso_x_go/features/auth/application/session_scope.dart';
import 'package:avesso_x_go/features/events/application/catalog_scope.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';
import 'package:avesso_x_go/features/tickets/application/purchase_scope.dart';
import 'package:avesso_x_go/features/tickets/domain/ticket.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final session = SessionScope.of(context);
    final purchase = PurchaseScope.of(context);
    final catalog = CatalogScope.of(context);

    final user = session.user;
    final tickets =
        user == null ? const <Ticket>[] : purchase.ticketsFor(user);

    return Scaffold(
      appBar: AvessoAppBar(
        title: 'Meus ingressos',
        showBackButton: false,
      ),
      body: SafeArea(
        child: tickets.isEmpty
            ? AvessoEmptyState(
                title: 'Nenhum ingresso ainda',
                message:
                    'Quando você comprar ingressos, eles aparecerão aqui.',
                icon: Icons.confirmation_number_outlined,
                actionLabel: 'Explorar eventos',
                onAction: () => context.go(RouteNames.events),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: tickets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final event = catalog.eventById(ticket.eventId);
                  return _TicketCard(
                    ticket: ticket,
                    event: event,
                    colors: colors,
                    styles: styles,
                  );
                },
              ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.event,
    required this.colors,
    required this.styles,
  });

  final Ticket ticket;
  final DemoEvent? event;
  final AppColors colors;
  final AppTextStyles styles;

  @override
  Widget build(BuildContext context) {
    final title = event?.title ?? 'Evento indisponível';
    final subtitle = event?.formattedDate ?? 'Compra local salva';

    return AvessoCard(
      onTap: event == null
          ? null
          : () => context.push(RouteNames.eventDetailsWith(event!.id)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: styles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Código ${ticket.id}',
                  style: styles.labelLarge
                      .copyWith(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            ticket.status,
            style: styles.labelLarge.copyWith(color: colors.accent),
          ),
        ],
      ),
    );
  }
}