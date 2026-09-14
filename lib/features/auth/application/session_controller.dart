import 'package:flutter/foundation.dart';

import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    AuthenticatedUser? user,
    AuthRepository? repository,
  }) : _repository = repository ?? LocalAuthRepository() {
    _user = user ?? _repository.getCurrentUser();
  }

  final AuthRepository _repository;

  AuthenticatedUser? _user;

  AuthenticatedUser? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> restore() async {
    final currentUser = _repository.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    _user = currentUser;
    notifyListeners();
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final result = await _repository.login(
      email: email,
      password: password,
    );

    return _apply(result);
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
    );

    return _apply(result);
  }

  Future<void> signOut() async {
    await _repository.signOut();

    _user = null;
    notifyListeners();
  }

  String? _apply(AuthResult result) {
    switch (result) {
      case AuthSuccess(:final user):
        _user = user;
        notifyListeners();
        return null;

      case AuthFailure(:final message):
        return message;
    }
  }
}