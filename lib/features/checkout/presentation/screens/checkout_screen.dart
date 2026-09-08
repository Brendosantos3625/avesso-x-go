import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_card.dart';
import 'package:avesso_x_go/core/widgets/avesso_error_state.dart';
import 'package:avesso_x_go/features/auth/application/session_scope.dart';
import 'package:avesso_x_go/features/events/application/catalog_scope.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';
import 'package:avesso_x_go/features/tickets/application/purchase_scope.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.eventId});

  final String? eventId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _confirming = false;

  DemoEvent? _resolveEvent(BuildContext context) {
    final catalog = CatalogScope.of(context);
    final eventId = widget.eventId;
    if (eventId != null) {
      final event = catalog.eventById(eventId);
      if (event != null) {
        return event;
      }
    }
    if (catalog.events.isNotEmpty) {
      return catalog.events.first;
    }
    return null;
  }

  Future<void> _confirmPayment(DemoEvent event) async {
    setState(() => _confirming = true);

    final user = SessionScope.of(context).user;
    if (user == null) {
      setState(() => _confirming = false);
      return;
    }

    final success = await PurchaseScope.of(context).buy(
      user: user,
      event: event,
    );

    if (!mounted) {
      return;
    }
    setState(() => _confirming = false);

    if (success) {
      context.push(RouteNames.checkoutSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final event = _resolveEvent(context);

    if (event == null) {
      return Scaffold(
        appBar: AvessoAppBar(title: 'Checkout'),
        body: SafeArea(
          child: AvessoErrorState(
            title: 'Evento não encontrado',
            message: 'Este evento pode não estar mais disponível.',
            onRetry: () => context.go(RouteNames.events),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AvessoAppBar(title: 'Checkout'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Resumo do pedido', style: styles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            AvessoCard(
              child: Column(
                children: [
                  _SummaryRow(label: 'Evento', value: event.title),
                  const _SummaryDivider(),
                  _SummaryRow(label: 'Data', value: event.formattedDate),
                  const _SummaryDivider(),
                  _SummaryRow(label: 'Quantidade', value: '1 ingresso'),
                  const _SummaryDivider(),
                  _SummaryRow(
                      label: 'Valor unitário', value: event.formattedPrice),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AvessoCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: styles.titleMedium,
                  ),
                  Text(
                    event.formattedPrice,
                    style: styles.titleLarge.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceAlt.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Pagamento em ambiente de demonstração. '
                      'Nenhuma cobrança real será realizada.',
                      style: styles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AvessoButton(
              label: 'Confirmar pagamento',
              icon: Icons.check_circle_outline,
              loading: _confirming,
              onPressed: _confirming
                  ? null
                  : () => _confirmPayment(event),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: styles.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: styles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider();
  }
}