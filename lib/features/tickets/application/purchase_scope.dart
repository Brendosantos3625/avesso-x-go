import 'package:flutter/widgets.dart';

import 'purchase_controller.dart';

/// Disponibiliza o [PurchaseController] para a árvore de widgets.
class PurchaseScope extends InheritedNotifier<PurchaseController> {
  const PurchaseScope({
    super.key,
    required PurchaseController controller,
    required super.child,
  }) : super(notifier: controller);

  static PurchaseController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PurchaseScope>();
    assert(
      scope != null,
      'PurchaseScope.of() called with no PurchaseScope in context',
    );
    return scope!.notifier!;
  }
}