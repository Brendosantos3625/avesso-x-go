import 'package:flutter/widgets.dart';

import 'session_controller.dart';

/// Disponibiliza o [SessionController] para a árvore de widgets.
class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(
      scope != null,
      'SessionScope.of() called with no SessionScope in context',
    );
    return scope!.notifier!;
  }
}