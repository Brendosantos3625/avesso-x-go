import 'package:flutter/foundation.dart';

import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';
import 'package:avesso_x_go/features/tickets/data/local_purchase_repository.dart';
import 'package:avesso_x_go/features/tickets/domain/order.dart';
import 'package:avesso_x_go/features/tickets/domain/purchase_repository.dart';
import 'package:avesso_x_go/features/tickets/domain/ticket.dart';

/// Mantém os dados de compra (pedidos e ingressos) e orquestra a camada de
/// dados. O fluxo de compra passa por aqui: uma compra confirmada gera um
/// único pedido e um único ingresso, ambos persistidos localmente.
class PurchaseController extends ChangeNotifier {
  PurchaseController({PurchaseRepository? repository})
      : _repository = repository ?? LocalPurchaseRepository();

  final PurchaseRepository _repository;

  List<Order> _orders = const [];
  List<Ticket> _tickets = const [];
  Future<void>? _loadFuture;

  /// Todos os pedidos persistidos.
  List<Order> get orders => _orders;

  /// Todos os ingressos persistidos.
  List<Ticket> get tickets => _tickets;

  /// Pedidos do usuário informado.
  List<Order> ordersFor(AuthenticatedUser user) =>
      _orders.where((order) => order.userId == user.id).toList();

  /// Ingressos do usuário informado.
  List<Ticket> ticketsFor(AuthenticatedUser user) =>
      _tickets.where((ticket) => ticket.userId == user.id).toList();

  /// Carrega pedidos e ingressos persistidos.
  Future<void> load() => _loadFuture ??= _load();

  Future<void> _load() async {
    _orders = await _repository.loadOrders();
    _tickets = await _repository.loadTickets();
    notifyListeners();
  }

  /// Conclui uma compra simulada e mantém os dados atualizados em memória.
  ///
  /// Retorna `true` quando o pedido e o ingresso foram persistidos.
  Future<bool> buy({
    required AuthenticatedUser user,
    required DemoEvent event,
    int quantity = 1,
  }) async {
    final saved = await _repository.buy(
      user: user,
      event: event,
      quantity: quantity,
    );
    if (saved) {
      await _load();
    }
    return saved;
  }
}