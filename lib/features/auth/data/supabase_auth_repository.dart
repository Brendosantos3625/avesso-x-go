import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        return const AuthFailure(
          'Não foi possível concluir o login.',
        );
      }

      return AuthSuccess(_mapUser(user));
    } on AuthException catch (error) {
      return AuthFailure(_mapAuthError(error));
    } catch (_) {
      return const AuthFailure(
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      return const AuthFailure('Informe seu nome.');
    }

    if (cleanEmail.isEmpty) {
      return const AuthFailure('Informe seu e-mail.');
    }

    if (password.length < 6) {
      return const AuthFailure(
        'A senha deve ter pelo menos 6 caracteres.',
      );
    }

    try {
      final response = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'full_name': cleanName,
        },
      );

      final user = response.user;

      if (user == null) {
        return const AuthFailure(
          'Não foi possível criar sua conta.',
        );
      }

      if (response.session == null) {
        return const AuthFailure(
          'Conta criada! Confirme seu e-mail antes de entrar.',
        );
      }

      return AuthSuccess(_mapUser(user));
    } on AuthException catch (error) {
      return AuthFailure(_mapAuthError(error));
    } catch (_) {
      return const AuthFailure(
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    }
  }

  @override
  AuthenticatedUser? getCurrentUser() {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    return _mapUser(user);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AuthenticatedUser _mapUser(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    final name =
        (metadata['full_name'] as String?)?.trim() ??
        (metadata['name'] as String?)?.trim() ??
        user.email?.split('@').first ??
        'Usuário';

    return AuthenticatedUser(
      id: user.id,
      name: name,
      email: user.email ?? '',
    );
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }

    if (message.contains('user already registered')) {
      return 'Este e-mail já está cadastrado.';
    }

    if (message.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }

    if (message.contains('password')) {
      return 'A senha informada não atende aos requisitos.';
    }

    return error.message;
  }
}