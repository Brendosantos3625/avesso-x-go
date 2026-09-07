abstract final class Formatters {
  static String formatBRL(double value) {
    final negative = value < 0;
    final totalCents = (value.abs() * 100).round();
    final reais = totalCents ~/ 100;
    final centavos = totalCents % 100;
    final sign = negative ? '-' : '';
    return '${sign}R\$ '
        '${_groupThousands(reais)},'
        '${centavos.toString().padLeft(2, '0')}';
  }

  static String formatDateBR(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String _groupThousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}