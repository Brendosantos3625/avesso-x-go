import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/app/app.dart';
import 'package:avesso_x_go/app/router/app_router.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildAppWithRouter(router) =>
      AvessoApp(router: router);

  testWidgets('aba Ingressos é acessível pela barra de navegação',
      (tester) async {
    final router = AppRouter.create();
    await tester.pumpWidget(buildAppWithRouter(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ingressos'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum ingresso ainda'), findsOneWidget);
  });

  testWidgets('alterna entre as abas principais pela barra de navegação',
      (tester) async {
    final router = AppRouter.create();
    await tester.pumpWidget(buildAppWithRouter(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Conta'), findsOneWidget);

    await tester.tap(find.text('Eventos'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Eventos'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('Eventos em destaque'), findsOneWidget);
  });

  testWidgets('rota aberta sem histórico oferece voltar para a Home',
      (tester) async {
    final router = AppRouter.create();
    await tester.pumpWidget(buildAppWithRouter(router));
    await tester.pumpAndSettle();

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsWidgets);

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.home_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Eventos em destaque'), findsOneWidget);
  });

  testWidgets('tela secundária com histórico mostra botão voltar',
      (tester) async {
    final router = AppRouter.create();
    await tester.pumpWidget(buildAppWithRouter(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver todos os eventos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sunset Festival'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar ingresso'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.arrow_back),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Eventos'),
      ),
      findsOneWidget,
    );
  });
}