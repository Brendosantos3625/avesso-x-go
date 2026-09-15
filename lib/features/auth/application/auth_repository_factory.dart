import 'package:avesso_x_go/core/supabase/supabase_service.dart';
import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';
import 'package:avesso_x_go/features/auth/data/supabase_auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';

/// Escolhe o [AuthRepository] na camada de composição:
/// Supabase pronto (configurado + inicializado) → autenticação real;
/// caso contrário → modo 100% local, sem credenciais.
class AuthRepositoryFactory {
  AuthRepositoryFactory({bool? supabaseReady})
      : supabaseReady = supabaseReady ?? SupabaseService.isReady;

  final bool supabaseReady;

  AuthRepository create() {
    return supabaseReady ? SupabaseAuthRepository() : LocalAuthRepository();
  }
}