import 'package:flutter/widgets.dart';

import 'theme_controller.dart';

/// Disponibiliza o [ThemeController] para a árvore de widgets.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope.of() called with no ThemeScope in context');
    return scope!.notifier!;
  }
}