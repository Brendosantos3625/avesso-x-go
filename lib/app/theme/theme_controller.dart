import 'package:flutter/material.dart';

import 'theme_mode_store.dart';

/// Controla o [ThemeMode] vigente e persiste a preferência do usuário.
class ThemeController extends ChangeNotifier {
  ThemeController({
    required ThemeModeStore store,
    ThemeMode initialMode = ThemeMode.dark,
  })  : _store = store, // ignore: prefer_initializing_formals
        _mode = initialMode;

  final ThemeModeStore _store;

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  bool get isLight => _mode == ThemeMode.light;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isSystem => _mode == ThemeMode.system;

  /// Carrega a preferência salva (fallback seguro para o modo padrão).
  Future<void> load() async {
    final saved = await _store.load();
    if (saved != null && saved != _mode) {
      _mode = saved;
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
    await _store.save(mode);
  }
}