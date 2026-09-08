import 'package:flutter/widgets.dart';

import 'catalog_controller.dart';

/// Disponibiliza o [CatalogController] para a árvore de widgets.
class CatalogScope extends InheritedNotifier<CatalogController> {
  const CatalogScope({
    super.key,
    required CatalogController controller,
    required super.child,
  }) : super(notifier: controller);

  static CatalogController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CatalogScope>();
    assert(
      scope != null,
      'CatalogScope.of() called with no CatalogScope in context',
    );
    return scope!.notifier!;
  }
}