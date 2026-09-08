import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/core/constants/app_constants.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

/// Implementação local/demo do [AuthRepository].
///
/// Mantém as contas em memória (incluindo a conta demo) e persiste contas
/// cadastradas via `shared_preferences`. As senhas nunca são armazenadas em
/// texto puro: apenas um hash SHA-256 é guardado.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository();

  static const String storageKey = 'auth_accounts';

  /// Credenciais da conta demo.
  static const String demoEmail = 'demo@avesso.com';
  static const String demoPassword = 'avesso123';

  static const String _demoId = 'demo-user';
  static const String _incorrectCredentialsMessage =
      'E-mail ou senha incorretos.';
  static const String _emailTakenMessage = 'Este e-mail já está cadastrado.';
  static const String _invalidInputMessage =
      'Informe um nome e um e-mail válidos.';

  final Map<String, _AuthAccount> _accounts = <String, _AuthAccount>{};
  Future<void>? _loadFuture;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await _ensureLoaded();

    final account = _accounts[normalizeEmail(email)];
    if (account == null || !_verify(password, account.passwordHash)) {
      return const AuthFailure(_incorrectCredentialsMessage);
    }
    return AuthSuccess(account.toAuthenticatedUser());
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureLoaded();

    final cleanName = name.trim();
    final key = normalizeEmail(email);
    if (cleanName.isEmpty || key.isEmpty) {
      return const AuthFailure(_invalidInputMessage);
    }
    if (_accounts.containsKey(key)) {
      return const AuthFailure(_emailTakenMessage);
    }

    final account = _AuthAccount(
      id: key,
      name: cleanName,
      email: key,
      passwordHash: _hash(password),
    );
    _accounts[key] = account;
    await _persist();

    return AuthSuccess(account.toAuthenticatedUser());
  }

  Future<void> _ensureLoaded() => _loadFuture ??= _load();

  Future<void> _load() async {
    _seedDemoAccount();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) {
        return;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final item in decoded) {
        final account = _AuthAccount.fromJson(
          (item as Map).cast<String, dynamic>(),
        );
        _accounts[account.email] = account;
      }
    } catch (_) {
      // Persistência indisponível: mantém apenas a conta demo em memória.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _accounts.values
          .where((account) => !account.isDemo)
          .map((account) => account.toJson())
          .toList();
      await prefs.setString(storageKey, jsonEncode(data));
    } catch (_) {
      // Falha ao persistir não impede o cadastro em memória.
    }
  }

  void _seedDemoAccount() {
    _accounts[demoEmail] = _AuthAccount(
      id: _demoId,
      name: AppConstants.demoUserName,
      email: demoEmail,
      passwordHash: _hash(demoPassword),
      isDemo: true,
    );
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static String _hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  static bool _verify(String password, String storedHash) =>
      _hash(password) == storedHash;
}

class _AuthAccount {
  const _AuthAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.isDemo = false,
  });

  factory _AuthAccount.fromJson(Map<String, dynamic> json) {
    return _AuthAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
    );
  }

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final bool isDemo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
    };
  }

  AuthenticatedUser toAuthenticatedUser() {
    return AuthenticatedUser(id: id, name: name, email: email);
  }
}