import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

/// Persistência da sessão autenticada. Usa `shared_preferences`, sem backend.
abstract class SessionStore {
  Future<AuthenticatedUser?> load();

  Future<void> save(AuthenticatedUser user);

  Future<void> clear();
}

class SharedPreferencesSessionStore implements SessionStore {
  static const String storageKey = 'auth_session';

  @override
  Future<AuthenticatedUser?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) {
        return null;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AuthenticatedUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(AuthenticatedUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, jsonEncode(user.toJson()));
    } catch (_) {
      // Falha de persistência não deve impedir o login em memória.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (_) {
      // Falha ao limpar não deve derrubar o aplicativo.
    }
  }
}