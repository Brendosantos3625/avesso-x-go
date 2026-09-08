import 'package:flutter_test/flutter_test.dart';

import 'package:avesso_x_go/core/utils/greetings.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';

void main() {
  group('Greetings.firstName', () {
    test('extrai o primeiro nome de um nome completo', () {
      expect(Greetings.firstName('Brendo Oliveira Silva'), 'Brendo');
    });

    test('retorna o próprio nome quando já é curto', () {
      expect(Greetings.firstName('Brendo'), 'Brendo');
    });

    test('ignora espaços extras ao redor e internos', () {
      expect(Greetings.firstName('  Brendo   Oliveira  '), 'Brendo');
    });

    test('retorna vazio para nome nulo ou vazio', () {
      expect(Greetings.firstName(null), '');
      expect(Greetings.firstName(''), '');
      expect(Greetings.firstName('   '), '');
    });
  });

  group('Greetings.greeting', () {
    test('usa o primeiro nome na saudação', () {
      expect(Greetings.greeting('Brendo Oliveira'), 'Olá, Brendo! 👋');
    });

    test('aplica fallback seguro quando não há nome', () {
      expect(Greetings.greeting(null), 'Olá! 👋');
      expect(Greetings.greeting(''), 'Olá! 👋');
      expect(Greetings.greeting('   '), 'Olá! 👋');
    });
  });

  group('AuthenticatedUser', () {
    test('expoõe o primeiro nome a partir do nome completo', () {
      const user = AuthenticatedUser(
        id: '1',
        name: 'Brendo Oliveira Silva',
        email: 'brendo@example.com',
      );
      expect(user.firstName, 'Brendo');
    });

    test('expõe iniciais do nome completo', () {
      const user = AuthenticatedUser(
        id: '1',
        name: 'Brendo Oliveira',
        email: 'brendo@example.com',
      );
      expect(user.initials, 'BO');
    });
  });
}