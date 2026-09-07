import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avesso_x_go/app/app.dart';
import 'package:avesso_x_go/app/router/app_router.dart';

void main() {
  Widget buildApp() => AvessoApp(router: AppRouter.create());

  testWidgets('App starts and shows the home screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('AVESSO X GO'), findsOneWidget);
    expect(find.text('Eventos em destaque'), findsOneWidget);
  });

  testWidgets('Navigates from home to events', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver todos os eventos'));
    await tester.pumpAndSettle();

    expect(find.text('Eventos'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('Navigates from events to event details', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver todos os eventos'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sunset Festival'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar ingresso'), findsOneWidget);
    expect(find.text('Sobre o evento'), findsOneWidget);
  });
}