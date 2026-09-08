/// Pedido de compra criado após um checkout simulado no AVESSO X GO.
///
/// Representa uma compra concluída e fica vinculado ao usuário comprador
/// ([userId]) e ao evento adquirido ([eventId]). A duplicação é evitada na
/// camada de dados: cada compra gera um único pedido com [id] único.
class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.quantity,
    required this.total,
    required this.createdAt,
    this.status = statusConfirmed,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        eventId: json['event_id'] as String,
        quantity: json['quantity'] as int,
        total: (json['total'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
        status: json['status'] as String? ?? statusConfirmed,
      );

  /// Status de um pedido confirmado (arquitetura atual, pagamento simulado).
  static const String statusConfirmed = 'confirmado';

  final String id;
  final String userId;
  final String eventId;
  final int quantity;
  final double total;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'event_id': eventId,
        'quantity': quantity,
        'total': total,
        'created_at': createdAt.toIso8601String(),
        'status': status,
      };
}