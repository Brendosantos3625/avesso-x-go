import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/app/app.dart';
import 'package:avesso_x_go/app/router/app_router.dart';
import 'package:avesso_x_go/features/auth/application/session_controller.dart';
import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Login valida credenciais', () {
    test('aceita senha correta da conta demo', () async {
      final session = SessionController();

      final error = await session.login(
        email: LocalAuthRepository.demoEmail,
        password: LocalAuthRepository.demoPassword,
      );

      expect(error, isNull);
      expect(session.user?.email, LocalAuthRepository.demoEmail);
      session.dispose();
    });

    test('rejeita senha incorreta sem alterar a sessão atual', () async {
      final session = SessionController();

      final error = await session.login(
        email: LocalAuthRepository.demoEmail,
        password: 'senha-errada',
      );

      expect(error, 'E-mail ou senha incorretos.');
      expect(session.user?.email, LocalAuthRepository.demoEmail);
      session.dispose();
    });

    test('rejeita e-mail inexistente', () async {
      final session = SessionController();

      final error = await session.login(
        email: 'nao-existe@avesso.com',
        password: 'qualquer-senha',
      );

      expect(error, 'E-mail ou senha incorretos.');
      expect(session.user?.email, LocalAuthRepository.demoEmail);
      session.dispose();
    });

    test('rejeita e-mail vazio no repositório', () async {
      final session = SessionController();

      final error = await session.login(email: '', password: '123456');

      expect(error, 'E-mail ou senha incorretos.');
      session.dispose();
    });

    test('rejeita senha vazia no repositório', () async {
      final session = SessionController();

      final error = await session.login(
        email: LocalAuthRepository.demoEmail,
        password: '',
      );

      expect(error, 'E-mail ou senha incorretos.');
      session.dispose();
    });
  });

  group('Cadastro armazena a senha localmente', () {
    test('usuário cadastrado loga com a senha correta', () async {
      final session = SessionController();

      final registerError = await session.register(
        name: 'Ana Lima',
        email: 'ana@example.com',
        password: 'segredo123',
      );

      expect(registerError, isNull);
      expect(session.user?.name, 'Ana Lima');

      session.signOut();
      final loginError = await session.login(
        email: 'ana@example.com',
        password: 'segredo123',
      );

      expect(loginError, isNull);
      expect(session.user?.email, 'ana@example.com');
      session.dispose();
    });

    test('usuário cadastrado não loga com senha diferente', () async {
      final session = SessionController();

      await session.register(
        name: 'Ana Lima',
        email: 'ana@example.com',
        password: 'segredo123',
      );

      session.signOut();
      final loginError = await session.login(
        email: 'ana@example.com',
        password: 'senha-diferente',
      );

      expect(loginError, 'E-mail ou senha incorretos.');
      expect(session.isAuthenticated, isFalse);
      session.dispose();
    });

    test('rejeita cadastro com e-mail já existente', () async {
      final session = SessionController();

      await session.register(
        name: 'Primeiro',
        email: 'dup@example.com',
        password: '123456',
      );

      final error = await session.register(
        name: 'Segundo',
        email: 'dup@example.com',
        password: '654321',
      );

      expect(error, 'Este e-mail já está cadastrado.');
      session.dispose();
    });
  });

  group('Tela de login', () {
    testWidgets('valida campos vazios sem chamar o repositório',
        (tester) async {
      final router = AppRouter.create();

      await tester.pumpWidget(
        AvessoApp(router: router, sessionController: SessionController()),
      );
      await tester.pumpAndSettle();

      router.go('/login');
      await tester.pumpAndSettle();

      final submitButton = find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Entrar'),
      );

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
      expect(find.text('E-mail ou senha incorretos.'), findsNothing);
    });

    testWidgets('mostra erro na tela com senha incorreta', (tester) async {
      final router = AppRouter.create();

      await tester.pumpWidget(
        AvessoApp(router: router, sessionController: SessionController()),
      );
      await tester.pumpAndSettle();

      router.go('/login');
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(
        fields.at(0),
        LocalAuthRepository.demoEmail,
      );
      await tester.enterText(fields.at(1), 'senha-errada');

      await tester.tap(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text('Entrar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    });
  });
}