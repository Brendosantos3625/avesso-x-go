import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistência da preferência de tema. Usa `shared_preferences`, sem backend.
abstract class ThemeModeStore {
  Future<ThemeMode?> load();

  Future<void> save(ThemeMode mode);
}

class SharedPreferencesThemeModeStore implements ThemeModeStore {
  static const String storageKey = 'theme_mode';

  @override
  Future<ThemeMode?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _fromStorage(prefs.getString(storageKey));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, _toStorage(mode));
    } catch (_) {
      // Falha de persistência não deve impedir a troca de tema em memória.
    }
  }

  static ThemeMode? _fromStorage(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  static String _toStorage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}