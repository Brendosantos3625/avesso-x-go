import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_radius.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/core/widgets/avesso_error_state.dart';
import 'package:avesso_x_go/features/events/application/catalog_scope.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final event = CatalogScope.of(context).eventById(eventId);

    return Scaffold(
      appBar: AvessoAppBar(title: event?.title ?? 'Evento'),
      body: event == null
          ? AvessoErrorState(
              title: 'Evento não encontrado',
              message: 'Este evento pode não estar mais disponível.',
              onRetry: () => context.go(RouteNames.events),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EventHero(category: event.category),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      event.title,
                      style: AppTextStyles.of(context).headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      text: event.location,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: event.formattedDate,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Sobre o evento',
                      style: AppTextStyles.of(context).titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      event.description,
                      style: AppTextStyles.of(context).bodyLarge
                          .copyWith(color: AppColors.of(context).textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AvessoCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ingresso',
                            style: AppTextStyles.of(context).bodyMedium.copyWith(
                                  color: AppColors.of(context).textSecondary,
                                ),
                          ),
                          Text(
                            event.formattedPrice,
                            style: AppTextStyles.of(context).titleLarge.copyWith(
                                  color: AppColors.of(context).primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AvessoButton(
                      label: 'Comprar ingresso',
                      icon: Icons.confirmation_number_outlined,
                      onPressed: () => context.push(
                        RouteNames.checkoutWith(event.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _EventHero extends StatelessWidget {
  const _EventHero({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.surfaceAlt],
        ),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      ),
      child: Center(
        child: Icon(
          Icons.event_available,
          size: 64,
          color: colors.onPrimary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: styles.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}