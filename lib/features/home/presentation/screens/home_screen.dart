import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/constants/app_constants.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_radius.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/utils/greetings.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/features/auth/application/session_scope.dart';
import 'package:avesso_x_go/features/events/application/catalog_scope.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final featured = CatalogScope.of(context).events.take(4).toList();
    final session = SessionScope.of(context);
    final greeting = Greetings.greeting(session.user?.name);

    return Scaffold(
      appBar: AvessoAppBar(
        title: AppConstants.appName,
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(RouteNames.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: styles.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Descubra experiências inesquecíveis perto de você.',
                style: styles.bodyMedium
                    .copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Eventos em destaque', style: styles.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _FeaturedEventCard(event: featured[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AvessoButton(
                label: 'Ver todos os eventos',
                type: AvessoButtonType.outline,
                onPressed: () => context.go(RouteNames.events),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({required this.event});

  final DemoEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return SizedBox(
      width: 240,
      child: AvessoCard(
        onTap: () => context.push(RouteNames.eventDetailsWith(event.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryBadge(label: event.category),
            const Spacer(),
            Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    event.formattedDate,
                    style: styles.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              event.formattedPrice,
              style: styles.labelLarge
                  .copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        label,
        style: styles.labelLarge.copyWith(
          color: colors.primary,
          fontSize: 12,
        ),
      ),
    );
  }
}