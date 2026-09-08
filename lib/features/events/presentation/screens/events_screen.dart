import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_radius.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/core/widgets/avesso_empty_state.dart';
import 'package:avesso_x_go/core/widgets/avesso_text_field.dart';
import 'package:avesso_x_go/features/events/application/catalog_scope.dart';

import 'events_demo_data.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const List<String> _categories = [
    'Todos',
    'Festival',
    'Show',
    'Tecnologia',
    'Esporte',
  ];

  String _query = '';
  String? _category;

  bool get _allCategories => _category == null;

  List<DemoEvent> get _filteredEvents {
    final query = _query.trim().toLowerCase();
    final catalog = CatalogScope.of(context).events;
    return catalog.where((event) {
      final matchesCategory =
          _allCategories || event.category == _category;
      final matchesQuery =
          query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AvessoAppBar(title: 'Eventos', showBackButton: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: AvessoTextField(
                hint: 'Buscar evento',
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryFilters(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final category in _categories)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(category),
                showCheckmark: false,
                selected: _allCategories
                    ? category == 'Todos'
                    : category == _category,
                onSelected: (_) => setState(() {
                  _category = category == 'Todos' ? null : category;
                }),
                labelStyle: styles.bodyMedium.copyWith(
                  color: _isSelected(category)
                      ? colors.onPrimary
                      : colors.textSecondary,
                ),
                selectedColor: colors.primary,
                backgroundColor: colors.surfaceAlt,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppRadius.extraLarge,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSelected(String category) {
    return _allCategories ? category == 'Todos' : category == _category;
  }

  Widget _buildResults() {
    final events = _filteredEvents;

    if (events.isEmpty) {
      return const AvessoEmptyState(
        title: 'Nenhum evento encontrado',
        message: 'Tente ajustar a busca ou os filtros.',
        icon: Icons.search_off,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          >= 900 => 3,
          >= 600 => 2,
          _ => 1,
        };

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 200,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) => _EventCard(
            event: events[index],
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final DemoEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return AvessoCard(
      onTap: () => context.push(RouteNames.eventDetailsWith(event.id)),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            ),
            child: Text(
              event.category,
              style: styles.labelLarge
                  .copyWith(color: colors.primary, fontSize: 12),
            ),
          ),
          const Spacer(),
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            event.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.formattedDate,
                  style: styles.bodySmall,
                ),
              ),
              Text(
                event.formattedPrice,
                style: styles.labelLarge
                    .copyWith(color: colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}