import 'authenticated_user.dart';

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

  AuthenticatedUser? getCurrentUser();

  Future<void> signOut();
}