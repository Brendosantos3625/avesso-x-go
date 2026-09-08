import 'authenticated_user.dart';

/// Resultado de uma operação de autenticação.
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);

  final AuthenticatedUser user;
}

class AuthFailure extends AuthResult {
  const AuthFailure(this.message);

  final String message;
}

/// Contrato da camada de autenticação.
///
/// A regra de validação de credenciais vive aqui (no repositório), nunca nas
/// telas. As telas apenas coletam e-mail/senha, tratam loading/erro e navegam
/// em caso de sucesso.
///
/// Situado para suportar uma futura autenticação real: trocar a implementação
/// local por uma remota não altera a interface consumida pela aplicação.
abstract interface class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });
}