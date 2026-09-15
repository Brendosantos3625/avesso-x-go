import 'package:flutter_test/flutter_test.dart';

import 'package:avesso_x_go/features/auth/application/session_controller.dart';
import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.currentUser,
    this.loginResult = const AuthFailure('falha no login'),
    this.registerResult = const AuthFailure('falha no registro'),
  });

  AuthenticatedUser? currentUser;
  AuthResult loginResult;
  AuthResult registerResult;
  int signOutCalls = 0;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    return loginResult;
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return registerResult;
  }

  @override
  AuthenticatedUser? getCurrentUser() => currentUser;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

AuthenticatedUser _user() => const AuthenticatedUser(
      id: 'user-123',
      name: 'Ana Lima',
      email: 'ana@example.com',
    );

void main() {
  group('SessionController', () {
    test('login com sucesso atualiza a sessão', () async {
      final user = _user();
      final repository =
          FakeAuthRepository(loginResult: AuthSuccess(user));
      final controller = SessionController(repository: repository);

      final error = await controller.login(
        email: user.email,
        password: 'segredo123',
      );

      expect(error, isNull);
      expect(controller.user, user);
      expect(controller.isAuthenticated, isTrue);
    });

    test('login com falha mantém a sessão e retorna a mensagem', () async {
      final user = _user();
      final repository = FakeAuthRepository(
        loginResult: const AuthFailure('E-mail ou senha incorretos.'),
      );
      final controller = SessionController(user: user, repository: repository);

      final error = await controller.login(
        email: user.email,
        password: 'senha-errada',
      );

      expect(error, 'E-mail ou senha incorretos.');
      expect(controller.user, user);
      expect(controller.isAuthenticated, isTrue);
    });

    test('register com sucesso atualiza a sessão', () async {
      final user = _user();
      final repository =
          FakeAuthRepository(registerResult: AuthSuccess(user));
      final controller = SessionController(repository: repository);

      final error = await controller.register(
        name: user.name,
        email: user.email,
        password: 'segredo123',
      );

      expect(error, isNull);
      expect(controller.user, user);
      expect(controller.isAuthenticated, isTrue);
    });

    test('register com falha mantém a sessão e retorna a mensagem', () async {
      final user = _user();
      final repository = FakeAuthRepository(
        registerResult: const AuthFailure('Este e-mail já está cadastrado.'),
      );
      final controller = SessionController(user: user, repository: repository);

      final error = await controller.register(
        name: user.name,
        email: user.email,
        password: 'segredo123',
      );

      expect(error, 'Este e-mail já está cadastrado.');
      expect(controller.user, user);
    });

    test('signOut limpa a sessão e chama o repositório', () async {
      final user = _user();
      final repository = FakeAuthRepository(currentUser: user);
      final controller = SessionController(repository: repository);
      expect(controller.isAuthenticated, isTrue);

      await controller.signOut();

      expect(controller.user, isNull);
      expect(controller.isAuthenticated, isFalse);
      expect(repository.signOutCalls, 1);
    });

    test('restore carrega a sessão persistida', () async {
      final user = _user();
      final repository = FakeAuthRepository();
      final controller = SessionController(repository: repository);
      expect(controller.user, isNull);

      repository.currentUser = user;
      await controller.restore();

      expect(controller.user, user);
      expect(controller.isAuthenticated, isTrue);
    });

    test('restore sem sessão não lança e mantém deslogado', () async {
      final repository = FakeAuthRepository();
      final controller = SessionController(repository: repository);

      await controller.restore();

      expect(controller.user, isNull);
      expect(controller.isAuthenticated, isFalse);
    });

    test('padrão usa LocalAuthRepository em modo local', () {
      final controller = SessionController();

      expect(controller.user, isNotNull);
      expect(controller.user!.name, LocalAuthRepository.demoName);
      expect(controller.isAuthenticated, isTrue);
    });
  });
}