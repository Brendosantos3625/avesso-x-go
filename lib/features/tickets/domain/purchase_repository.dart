import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';

import 'order.dart';
import 'ticket.dart';

/// Contrato de compra local.
///
/// Cada compra confirmada gera um único [Order] e um único [Ticket],
/// persistidos na mesma operação, garantindo que uma compra não duplique
/// pedidos nem ingressos, inclusive após reiniciar o aplicativo.
abstract interface class PurchaseRepository {
  /// Conclui uma compra simulada do [event] para o [user].
  ///
  /// Retorna `true` se pedido e ingresso foram persistidos, `false` em caso
  /// de falha na persistência.
  Future<bool> buy({
    required AuthenticatedUser user,
    required DemoEvent event,
    int quantity = 1,
  });

  /// Carrega todos os pedidos persistidos.
  Future<List<Order>> loadOrders();

  /// Carrega todos os ingressos persistidos.
  Future<List<Ticket>> loadTickets();
}