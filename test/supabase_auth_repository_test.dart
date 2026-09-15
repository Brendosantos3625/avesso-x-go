import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:avesso_x_go/features/auth/data/supabase_auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';

class FakeSupabaseAuthClient implements SupabaseAuthClient {
  FakeSupabaseAuthClient({
    this.current,
    this.signInResult,
    this.signUpResult,
    this.signInError,
    this.signUpError,
    this.signOutError,
  });

  User? current;
  AuthResponse? signInResult;
  AuthResponse? signUpResult;
  Object? signInError;
  Object? signUpError;
  Object? signOutError;
  bool failCurrentUser = false;

  int loginCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? lastLoginEmail;
  Map<String, dynamic>? lastSignUpData;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastLoginEmail = email;

    if (signInError != null) {
      throw signInError!;
    }

    return signInResult ?? AuthResponse(user: current);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    signUpCalls++;
    lastSignUpData = data;

    if (signUpError != null) {
      throw signUpError!;
    }

    return signUpResult ?? AuthResponse(user: current);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;

    if (signOutError != null) {
      throw signOutError!;
    }
  }

  @override
  User? get currentUser {
    if (failCurrentUser) {
      throw StateError('Supabase não inicializado');
    }

    return current;
  }
}

User _supaUser({
  String id = 'user-123',
  String email = 'ana@example.com',
  String fullName = 'Ana Lima',
}) {
  return User.fromJson({
    'id': id,
    'email': email,
    'user_metadata': {'full_name': fullName},
  })!;
}

Session _sessionWith(User user) {
  return Session(
    accessToken: 'access-token',
    tokenType: 'bearer',
    refreshToken: 'refresh-token',
    user: user,
  );
}

SupabaseAuthRepository _repo(FakeSupabaseAuthClient client) =>
    SupabaseAuthRepository(auth: client);

void main() {
  group('login', () {
    test('com sucesso mapeia nome do metadata e e-mail normalizado', () async {
      final client = FakeSupabaseAuthClient(
        signInResult: AuthResponse(
          user: _supaUser(email: 'caio@example.com', fullName: 'Caio Souza'),
        ),
      );

      final result = await _repo(client).login(
        email: ' CAIO@EXAMPLE.com ',
        password: 'segredo123',
      );

      expect(result, isA<AuthSuccess>());
      final user = (result as AuthSuccess).user;
      expect(user.id, 'user-123');
      expect(user.name, 'Caio Souza');
      expect(user.email, 'caio@example.com');
      expect(client.lastLoginEmail, 'caio@example.com');
    });

    test('com credenciais inválidas retorna mensagem amigável', () async {
      final client = FakeSupabaseAuthClient(
        signInError: AuthException('Invalid login credentials'),
      );

      final result = await _repo(client).login(
        email: 'ana@example.com',
        password: 'senha-errada',
      );

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).message, 'E-mail ou senha incorretos.');
    });

    test('com erro inesperado retorna mensagem genérica', () async {
      final client = FakeSupabaseAuthClient(signInError: Exception('boom'));

      final result = await _repo(client).login(
        email: 'ana@example.com',
        password: 'segredo123',
      );

      expect(result, isA<AuthFailure>());
      expect(
        (result as AuthFailure).message,
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    });

    test('sem usuário na resposta não autentica', () async {
      final client = FakeSupabaseAuthClient(signInResult: AuthResponse());

      final result = await _repo(client).login(
        email: 'ana@example.com',
        password: 'segredo123',
      );

      expect(result, isA<AuthFailure>());
      expect(
        (result as AuthFailure).message,
        'Não foi possível concluir o login.',
      );
    });
  });

  group('register', () {
    test('envia full_name no metadata e autentica com sessão', () async {
      final user = _supaUser(fullName: 'Caio Souza');
      final client = FakeSupabaseAuthClient(
        signUpResult: AuthResponse(user: user, session: _sessionWith(user)),
      );

      final result = await _repo(client).register(
        name: ' Caio Souza ',
        email: 'caio@example.com',
        password: 'segredo123',
      );

      expect(client.lastSignUpData, {'full_name': 'Caio Souza'});
      expect(result, isA<AuthSuccess>());
      expect((result as AuthSuccess).user.name, 'Caio Souza');
    });

    test('sem sessão pede confirmação de e-mail', () async {
      final user = _supaUser();
      final client = FakeSupabaseAuthClient(
        signUpResult: AuthResponse(user: user),
      );

      final result = await _repo(client).register(
        name: 'Ana Lima',
        email: 'ana@example.com',
        password: 'segredo123',
      );

      expect(result, isA<AuthFailure>());
      expect(
        (result as AuthFailure).message,
        'Conta criada! Confirme seu e-mail antes de entrar.',
      );
    });

    test('com e-mail já registrado retorna mensagem amigável', () async {
      final client = FakeSupabaseAuthClient(
        signUpError: AuthException('User already registered'),
      );

      final result = await _repo(client).register(
        name: 'Ana Lima',
        email: 'ana@example.com',
        password: 'segredo123',
      );

      expect(result, isA<AuthFailure>());
      expect(
        (result as AuthFailure).message,
        'Este e-mail já está cadastrado.',
      );
    });

    test('não chama o Supabase quando a validação local falha', () async {
      final client = FakeSupabaseAuthClient(signUpResult: AuthResponse());

      final result = await _repo(client).register(
        name: 'Ana',
        email: 'ana@example.com',
        password: '123',
      );

      expect(result, isA<AuthFailure>());
      expect(client.signUpCalls, 0);
    });
  });

  group('sessão', () {
    test('getCurrentUser retorna o usuário da sessão atual', () {
      final client = FakeSupabaseAuthClient(current: _supaUser());

      final user = _repo(client).getCurrentUser();

      expect(user?.id, 'user-123');
      expect(user?.name, 'Ana Lima');
      expect(user?.email, 'ana@example.com');
    });

    test('getCurrentUser retorna null sem sessão', () {
      final client = FakeSupabaseAuthClient();

      expect(_repo(client).getCurrentUser(), isNull);
    });

    test('getCurrentUser não lança quando o cliente falha', () {
      final client = FakeSupabaseAuthClient()..failCurrentUser = true;

      expect(_repo(client).getCurrentUser(), isNull);
    });

    test('signOut delega para o Supabase', () async {
      final client = FakeSupabaseAuthClient();

      await _repo(client).signOut();

      expect(client.signOutCalls, 1);
    });

    test('signOut não lança em falha de rede', () async {
      final client = FakeSupabaseAuthClient(signOutError: Exception('net'));

      await _repo(client).signOut();

      expect(client.signOutCalls, 1);
    });
  });
}