/// Utilitários de saudação baseados no nome do usuário autenticado.
abstract final class Greetings {
  /// Extrai o primeiro nome a partir de um nome completo.
  ///
  /// Retorna uma string vazia caso o nome seja nulo, vazio ou apenas
  /// espaços/tabulações.
  static String firstName(String? fullName) {
    final clean = fullName?.trim() ?? '';
    if (clean.isEmpty) {
      return '';
    }
    return clean.split(RegExp(r'\s+')).first;
  }

  /// Monta a saudação usando o primeiro nome do usuário.
  ///
  /// Caso não exista um nome utilizável, aplica um fallback seguro.
  static String greeting(String? fullName) {
    final name = firstName(fullName);
    return name.isEmpty ? 'Olá! 👋' : 'Olá, $name! 👋';
  }
}