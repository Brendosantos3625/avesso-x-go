import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

/// Implementação local de autenticação (modo demonstração / fallback).
///
/// Mantém o fluxo atual 100% local: uma conta demo padrão já vem como sessão
/// inicial ([getCurrentUser]) e cadastros são persistidos em
/// `shared_preferences`. Não acessa rede nem o Supabase. É a alternativa
/// segura até a migração real para `SupabaseAuthRepository`.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository();

  /// Chave usada para persistir as contas cadastradas localmente.
  static const String storageKey = 'local_auth_accounts';

  /// Conta demo padrão do AVESSO X GO.
  static const String demoEmail = 'usuario@avesso.com';
  static const String demoPassword = 'avesso2026';
  static const String demoName = 'Usuário';

  final Map<String, _LocalAccount> _accounts = {};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    _accounts[demoEmail] = _LocalAccount(name: demoName, password: demoPassword);

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) {
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _accounts[entry.key] =
            _LocalAccount.fromJson((entry.value as Map).cast<String, dynamic>());
      }
    } catch (_) {
      // Dados corrompidos não devem derrubar a autenticação local.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        storageKey,
        jsonEncode({
          for (final entry in _accounts.entries)
            if (entry.key != demoEmail)
              entry.key: entry.value.toJson(),
        }),
      );
    } catch (_) {
      // Falha de persistência não impede o cadastro em memória.
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || password.isEmpty) {
      return const AuthFailure('E-mail ou senha incorretos.');
    }

    await _ensureLoaded();

    final account = _accounts[cleanEmail];
    if (account == null || account.password != password) {
      return const AuthFailure('E-mail ou senha incorretos.');
    }

    return AuthSuccess(
      AuthenticatedUser(
        id: cleanEmail,
        name: account.name,
        email: cleanEmail,
      ),
    );
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

    await _ensureLoaded();

    if (_accounts.containsKey(cleanEmail)) {
      return const AuthFailure('Este e-mail já está cadastrado.');
    }

    _accounts[cleanEmail] = _LocalAccount(name: cleanName, password: password);
    await _save();

    return AuthSuccess(
      AuthenticatedUser(
        id: cleanEmail,
        name: cleanName,
        email: cleanEmail,
      ),
    );
  }

  @override
  AuthenticatedUser? getCurrentUser() {
    return const AuthenticatedUser(
      id: demoEmail,
      name: demoName,
      email: demoEmail,
    );
  }

  @override
  Future<void> signOut() async {}
}

class _LocalAccount {
  const _LocalAccount({required this.name, required this.password});

  factory _LocalAccount.fromJson(Map<String, dynamic> json) => _LocalAccount(
        name: json['name'] as String,
        password: json['password'] as String,
      );

  final String name;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'password': password,
      };
}