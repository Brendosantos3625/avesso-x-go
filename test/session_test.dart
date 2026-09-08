import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/app/app.dart';
import 'package:avesso_x_go/app/router/app_router.dart';
import 'package:avesso_x_go/features/auth/application/session_controller.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home saúda com o primeiro nome do usuário autenticado',
      (tester) async {
    final session = SessionController(
      user: const AuthenticatedUser(
        id: '1',
        name: 'Brendo Oliveira Silva',
        email: 'brendo@example.com',
      ),
    );

    await tester.pumpWidget(
      AvessoApp(router: AppRouter.create(), sessionController: session),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá, Brendo! 👋'), findsOneWidget);

    session.dispose();
  });

  testWidgets('Home usa fallback seguro quando o usuário não tem nome',
      (tester) async {
    final session = SessionController(
      user: const AuthenticatedUser(
        id: '1',
        name: '',
        email: 'anon@example.com',
      ),
    );

    await tester.pumpWidget(
      AvessoApp(router: AppRouter.create(), sessionController: session),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá! 👋'), findsOneWidget);

    session.dispose();
  });

  testWidgets('Home usa fallback seguro após encerrar a sessão',
      (tester) async {
    final session = SessionController();
    session.signOut();

    await tester.pumpWidget(
      AvessoApp(router: AppRouter.create(), sessionController: session),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá! 👋'), findsOneWidget);

    session.dispose();
  });

  testWidgets('Registro alimenta a sessão e a saudação da Home',
      (tester) async {
    final router = AppRouter.create();

    await tester.pumpWidget(
      AvessoApp(router: router, sessionController: SessionController()),
    );
    await tester.pumpAndSettle();

    router.go('/register');
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Brendo da Silva');
    await tester.enterText(fields.at(1), 'brendo@example.com');
    await tester.enterText(fields.at(2), '123456');
    await tester.enterText(fields.at(3), '123456');

    await tester.tap(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Criar conta'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá, Brendo! 👋'), findsOneWidget);
  });
}