import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';
import 'package:avesso_x_go/features/tickets/domain/order.dart';
import 'package:avesso_x_go/features/tickets/domain/purchase_repository.dart';
import 'package:avesso_x_go/features/tickets/domain/ticket.dart';

/// Implementação local de compras (pedidos + ingressos).
///
/// Persiste pedidos e ingressos juntos, em uma única operação de escrita por
/// compra, garantindo consistência: uma compra confirmada gera exatamente um
/// pedido e um ingresso, sem duplicação após reiniciar o aplicativo.
class LocalPurchaseRepository implements PurchaseRepository {
  LocalPurchaseRepository();

  static const String storageKey = 'purchase_data';

  @override
  Future<bool> buy({
    required AuthenticatedUser user,
    required DemoEvent event,
    int quantity = 1,
  }) async {
    final now = DateTime.now();
    final suffix = '${user.id}-${now.microsecondsSinceEpoch}';

    final order = Order(
      id: 'order-$suffix',
      userId: user.id,
      eventId: event.id,
      quantity: quantity,
      total: event.price * quantity,
      createdAt: now,
    );
    final ticket = Ticket(
      id: 'ticket-$suffix',
      orderId: order.id,
      userId: user.id,
      eventId: event.id,
      purchasedAt: now,
    );

    final data = await _loadRaw();
    data.orders.add(order);
    data.tickets.add(ticket);

    return _save(data);
  }

  @override
  Future<List<Order>> loadOrders() async {
    final data = await _loadRaw();
    return data.orders;
  }

  @override
  Future<List<Ticket>> loadTickets() async {
    final data = await _loadRaw();
    return data.tickets;
  }

  Future<_PurchaseData> _loadRaw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) {
        return _PurchaseData();
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final orders = (decoded['orders'] as List<dynamic>? ?? const [])
          .map(
            (item) => Order.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
      final tickets = (decoded['tickets'] as List<dynamic>? ?? const [])
          .map(
            (item) => Ticket.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
      return _PurchaseData(orders: orders, tickets: tickets);
    } catch (_) {
      // Dados persistidos inválidos não devem derrubar o aplicativo.
      return _PurchaseData();
    }
  }

  Future<bool> _save(_PurchaseData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        storageKey,
        jsonEncode({
          'orders': data.orders.map((order) => order.toJson()).toList(),
          'tickets': data.tickets.map((ticket) => ticket.toJson()).toList(),
        }),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _PurchaseData {
  _PurchaseData({List<Order>? orders, List<Ticket>? tickets})
      : orders = orders ?? <Order>[],
        tickets = tickets ?? <Ticket>[];

  final List<Order> orders;
  final List<Ticket> tickets;
}