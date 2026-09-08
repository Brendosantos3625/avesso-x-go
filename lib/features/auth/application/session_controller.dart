import 'package:flutter/foundation.dart';

import 'package:avesso_x_go/core/constants/app_constants.dart';
import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';
import 'package:avesso_x_go/features/auth/data/session_store.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

/// Mantém o estado do usuário autenticado e orquestra a camada de
/// autenticação (repositório).
///
/// Mantém um usuário de demonstração como padrão para que o app não quebre
/// sem backend. A validação de credenciais acontece no [AuthRepository], nunca
/// nas telas.
///
/// Quando um [SessionStore] é fornecido, a sessão é persistida localmente:
/// após um login/cadastro bem-sucedido o usuário permanece conectado ao
/// fechar e reabrir o aplicativo, até que [signOut] seja chamado.
class SessionController extends ChangeNotifier {
  SessionController({
    AuthenticatedUser? user,
    AuthRepository? repository,
    SessionStore? sessionStore,
  })  : _user = user ?? _demoUser,
        _repository = repository ?? LocalAuthRepository(),
        _sessionStore = sessionStore; // ignore: prefer_initializing_formals

  static const AuthenticatedUser _demoUser = AuthenticatedUser(
    id: 'demo-user',
    name: AppConstants.demoUserName,
    email: AppConstants.demoUserEmail,
  );

  final AuthRepository _repository;
  final SessionStore? _sessionStore;

  AuthenticatedUser? _user;

  AuthenticatedUser? get user => _user;

  bool get isAuthenticated => _user != null;

  /// Restaura a sessão persistida, se existir.
  ///
  /// Quando não há sessão salva (primeira execução ou após [signOut]), mantém
  /// o comportamento padrão do controller.
  Future<void> restore() async {
    final stored = await _sessionStore?.load();
    if (stored == null) {
      return;
    }
    if (_user == null || stored.email != _user?.email) {
      _user = stored;
      notifyListeners();
    }
  }

  /// Autentica com e-mail e senha.
  ///
  /// Retorna `null` em caso de sucesso (criando a sessão) ou a mensagem de
  /// erro quando as credenciais são inválidas.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    return _apply(
      await _repository.login(email: email, password: password),
    );
  }

  /// Cadastra uma conta local e autentica o usuário recém-criado.
  ///
  /// Retorna `null` em caso de sucesso ou a mensagem de erro.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _apply(
      await _repository.register(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  void signOut() {
    _user = null;
    _sessionStore?.clear();
    notifyListeners();
  }

  String? _apply(AuthResult result) {
    switch (result) {
      case AuthSuccess(:final user):
        _user = user;
        _sessionStore?.save(user);
        notifyListeners();
        return null;
      case AuthFailure(:final message):
        return message;
    }
  }
}