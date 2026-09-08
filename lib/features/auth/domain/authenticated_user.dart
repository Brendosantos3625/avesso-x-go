import 'package:avesso_x_go/core/utils/greetings.dart';

/// Usuário autenticado no AVESSO X GO.
///
/// Modelo orientado a uma futura autenticação real: hoje é alimentado pelo
/// fluxo de demonstração (login/registro), mas já carrega as informações que
/// uma API de autenticação forneceria.
class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  /// Primeiro nome do usuário (usado na saudação da Home).
  String get firstName => Greetings.firstName(name);

  /// Iniciais usadas no avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0].toUpperCase()}${parts.last[0].toUpperCase()}';
  }

  /// Serializa o usuário para persistir a sessão localmente.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  /// Reconstrói um usuário a partir da representação persistida.
  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) =>
      AuthenticatedUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );
}