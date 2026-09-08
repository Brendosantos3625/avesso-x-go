/// Ingresso gerado por uma compra simulada no AVESSO X GO.
///
/// Cada pedido confirmado gera um ingresso vinculado ao mesmo evento
/// ([eventId]) e ao mesmo usuário comprador ([userId]). O vínculo com o
/// pedido ([orderId]) permite rastrear a origem da compra sem duplicar
/// lógica: pedido e ingresso são criados juntos na mesma operação de compra.
class Ticket {
  const Ticket({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.eventId,
    required this.purchasedAt,
    this.status = statusActive,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        userId: json['user_id'] as String,
        eventId: json['event_id'] as String,
        purchasedAt: DateTime.parse(json['purchased_at'] as String),
        status: json['status'] as String? ?? statusActive,
      );

  /// Status de um ingresso válido.
  static const String statusActive = 'ativo';

  final String id;
  final String orderId;
  final String userId;
  final String eventId;
  final DateTime purchasedAt;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'user_id': userId,
        'event_id': eventId,
        'purchased_at': purchasedAt.toIso8601String(),
        'status': status,
      };
}