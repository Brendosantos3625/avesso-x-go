import 'package:flutter_test/flutter_test.dart';

import 'package:avesso_x_go/features/auth/application/auth_repository_factory.dart';
import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';
import 'package:avesso_x_go/features/auth/data/supabase_auth_repository.dart';

void main() {
  test('com Supabase pronto usa SupabaseAuthRepository', () {
    final repository = AuthRepositoryFactory(supabaseReady: true).create();

    expect(repository, isA<SupabaseAuthRepository>());
  });

  test('sem Supabase usa LocalAuthRepository', () {
    final repository = AuthRepositoryFactory(supabaseReady: false).create();

    expect(repository, isA<LocalAuthRepository>());
  });

  test('padrão sem inicialização usa LocalAuthRepository', () {
    final repository = AuthRepositoryFactory().create();

    expect(repository, isA<LocalAuthRepository>());
  });
}