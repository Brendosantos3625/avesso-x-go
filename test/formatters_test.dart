import 'package:flutter_test/flutter_test.dart';

import 'package:avesso_x_go/core/utils/formatters.dart';

void main() {
  group('Formatters.formatBRL', () {
    test('formats a decimal value with a comma', () {
      expect(Formatters.formatBRL(99.9), 'R\$ 99,90');
    });

    test('formats thousands with dot separators', () {
      expect(Formatters.formatBRL(1000), 'R\$ 1.000,00');
    });

    test('formats integer and cents values', () {
      expect(Formatters.formatBRL(0), 'R\$ 0,00');
      expect(Formatters.formatBRL(5.5), 'R\$ 5,50');
    });

    test('formats values above millions', () {
      expect(Formatters.formatBRL(142800), 'R\$ 142.800,00');
    });

    test('handles negative values', () {
      expect(Formatters.formatBRL(-10.05), '-R\$ 10,05');
    });

    test('rounds to two decimals', () {
      expect(Formatters.formatBRL(1234.567), 'R\$ 1.234,57');
    });
  });

  group('Formatters.formatDateBR', () {
    test('formats dates as dd/mm/yyyy', () {
      expect(Formatters.formatDateBR(DateTime(2026, 9, 5)), '05/09/2026');
    });
  });
}