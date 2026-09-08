import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/app/app.dart';
import 'package:avesso_x_go/app/router/app_router.dart';
import 'package:avesso_x_go/app/theme/theme_controller.dart';
import 'package:avesso_x_go/app/theme/theme_mode_store.dart';
import 'package:avesso_x_go/features/auth/application/session_controller.dart';
import 'package:avesso_x_go/features/auth/data/local_auth_repository.dart';
import 'package:avesso_x_go/features/auth/data/session_store.dart';
import 'package:avesso_x_go/features/auth/domain/auth_repository.dart';
import 'package:avesso_x_go/features/auth/domain/authenticated_user.dart';
import 'package:avesso_x_go/features/events/application/catalog_controller.dart';
import 'package:avesso_x_go/features/events/data/local_event_repository.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';
import 'package:avesso_x_go/features/tickets/application/purchase_controller.dart';
import 'package:avesso_x_go/features/tickets/data/local_purchase_repository.dart';
import 'package:avesso_x_go/features/tickets/domain/ticket.dart';

const _user = AuthenticatedUser(
  id: 'user-1',
  name: 'Ana Lima',
  email: 'ana@example.com',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Eventos criados persistem após reinicialização', () {
    test('evento criado pelo organizador reaparece em um novo repositório',
        () async {
      final event = DemoEvent(
        id: 'workshop-flutter',
        title: 'Workshop Flutter',
        location: 'São Paulo',
        date: DateTime(2026, 11, 20),
        description: 'Oficina prática de Flutter.',
        price: 89.0,
        category: 'Tecnologia',
      );

      final repository = LocalEventRepository();
      await repository.addEvent(event);

      final restarted = LocalEventRepository();
      final events = await restarted.loadEvents();

      expect(events.any((e) => e.id == event.id), isTrue);
      final restored = await restarted.eventById(event.id);
      expect(restored, isNotNull);
      expect(restored!.title, 'Workshop Flutter');
      expect(restored.price, 89.0);
    });

    test('dados seed não duplicam a cada carga', () async {
      final first = await LocalEventRepository().loadEvents();
      final second = await LocalEventRepository().loadEvents();
      final third = await LocalEventRepository().loadEvents();

      final seedIds = first.map((e) => e.id).toSet();
      expect(seedIds.length, demoEvents.length);
      expect(first.length, demoEvents.length);
      expect(second.length, demoEvents.length);
      expect(third.length, demoEvents.length);
    });

    test('evento com id de seed não é sobrescrito nem duplicado', () async {
      final repository = LocalEventRepository();
      await repository.addEvent(demoEvents.first);

      final events = await repository.loadEvents();
      final duplicates =
          events.where((e) => e.id == demoEvents.first.id).toList();
      expect(duplicates.length, 1);
      expect(events.length, demoEvents.length);
    });
  });

  group('Pedidos e ingressos persistem após reinicialização', () {
    test('pedido criado continua existindo em um novo repositório', () async {
      final repository = LocalPurchaseRepository();
      final saved = await repository.buy(user: _user, event: demoEvents.first);

      expect(saved, isTrue);

      final restarted = LocalPurchaseRepository();
      final orders = await restarted.loadOrders();

      expect(orders.length, 1);
      expect(orders.first.userId, _user.id);
      expect(orders.first.eventId, demoEvents.first.id);
      expect(orders.first.status, 'confirmado');
      expect(orders.first.total, demoEvents.first.price);
    });

    test('ingresso criado continua existindo em um novo repositório', () async {
      final repository = LocalPurchaseRepository();
      await repository.buy(user: _user, event: demoEvents.first);

      final restarted = LocalPurchaseRepository();
      final tickets = await restarted.loadTickets();

      expect(tickets.length, 1);
      expect(tickets.first.userId, _user.id);
      expect(tickets.first.eventId, demoEvents.first.id);
      expect(tickets.first.status, Ticket.statusActive);
      expect(tickets.first.orderId, isNotEmpty);
    });
  });

  group('Compra não duplica pedidos nem ingressos', () {
    test('uma compra gera exatamente um pedido', () async {
      final repository = LocalPurchaseRepository();

      final saved = await repository.buy(user: _user, event: demoEvents.first);
      expect(saved, isTrue);

      expect((await repository.loadOrders()).length, 1);
      expect((await repository.loadTickets()).length, 1);

      final restarted = LocalPurchaseRepository();
      expect((await restarted.loadOrders()).length, 1);
      expect((await restarted.loadTickets()).length, 1);
    });

    test('reabrir o aplicativo não reprocessa nem duplica a compra', () async {
      final controller = PurchaseController();
      await controller.load();

      final saved = await controller.buy(user: _user, event: demoEvents.first);
      expect(saved, isTrue);

      final restartedController = PurchaseController();
      await restartedController.load();

      expect(restartedController.orders.length, 1);
      expect(restartedController.tickets.length, 1);
      expect(restartedController.ticketsFor(_user).length, 1);
    });
  });

  group('Login após reiniciar', () {
    test('usuário autentica novamente com um novo repositório', () async {
      final repository = LocalAuthRepository();
      await repository.register(
        name: 'Brendo Silva',
        email: 'brendo@example.com',
        password: 'segredo123',
      );

      final restarted = LocalAuthRepository();
      final result = await restarted.login(
        email: 'brendo@example.com',
        password: 'segredo123',
      );

      expect(result, isA<AuthSuccess>());
    });

    test('sessão é restaurada após reiniciar o aplicativo', () async {
      final store = SharedPreferencesSessionStore();
      final first = SessionController(sessionStore: store);
      expect(
        await first.login(
          email: LocalAuthRepository.demoEmail,
          password: LocalAuthRepository.demoPassword,
        ),
        isNull,
      );
      first.dispose();

      final restarted = SessionController(sessionStore: store);
      await restarted.restore();

      expect(restarted.isAuthenticated, isTrue);
      expect(restarted.user?.email, LocalAuthRepository.demoEmail);
      restarted.dispose();

      final signedOut = SessionController(sessionStore: store);
      signedOut.signOut();

      final afterSignOut = SessionController(sessionStore: store);
      await afterSignOut.restore();
      expect(
        afterSignOut.user?.email,
        LocalAuthRepository.demoEmail,
      );
      afterSignOut.dispose();
    });
  });

  group('Tema persiste após reiniciar', () {
    test('preferência salva é carregada por uma nova instância do controlador',
        () async {
      final controller = ThemeController(store: SharedPreferencesThemeModeStore());
      await controller.setMode(ThemeMode.light);
      controller.dispose();

      final restarted =
          ThemeController(store: SharedPreferencesThemeModeStore());
      await restarted.load();

      expect(restarted.isLight, isTrue);
      restarted.dispose();
    });
  });

  group('Dados persistidos inválidos não derrubam o aplicativo', () {
    test('repositórios retornam estado seguro com JSON corrompido', () async {
      SharedPreferences.setMockInitialValues({
        LocalEventRepository.storageKey: '{corrompido',
        LocalPurchaseRepository.storageKey: 'definitivamente inválido',
        SharedPreferencesSessionStore.storageKey: '%%%',
        LocalAuthRepository.storageKey: '[{quebrado',
      });

      final catalog = CatalogController();
      await catalog.load();
      expect(catalog.events.length, demoEvents.length);

      final purchases = PurchaseController();
      await purchases.load();
      expect(purchases.orders, isEmpty);
      expect(purchases.tickets, isEmpty);

      final session = SessionController(
        sessionStore: SharedPreferencesSessionStore(),
      );
      await session.restore();
      expect(session.isAuthenticated, isTrue);
      session.dispose();
    });

    test('carregar catálogo com repository inválido não lança exceção',
        () async {
      SharedPreferences.setMockInitialValues({
        LocalEventRepository.storageKey: 'not-json',
      });

      final repository = LocalEventRepository();
      final events = await repository.loadEvents();
      expect(events.length, demoEvents.length);

      final byId = await repository.eventById(demoEvents.first.id);
      expect(byId, isNotNull);
    });
  });

  group('Fluxo completo de compra na interface', () {
    testWidgets('ingresso aparece em Meus Ingressos após comprar',
        (tester) async {
      final router = AppRouter.create();
      final session = SessionController(
        user: _user,
        repository: LocalAuthRepository(),
      );

      await tester.pumpWidget(
        AvessoApp(router: router, sessionController: session),
      );
      await tester.pumpAndSettle();

      router.go('/event/${demoEvents.first.id}');
      await tester.pumpAndSettle();
      expect(find.text('Comprar ingresso'), findsOneWidget);

      await tester.ensureVisible(find.text('Comprar ingresso'));
      await tester.tap(find.text('Comprar ingresso'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar pagamento'));
      await tester.pumpAndSettle();

      expect(find.text('Compra confirmada!'), findsOneWidget);

      await tester.tap(find.text('Ver meus ingressos'));
      await tester.pumpAndSettle();

      expect(find.text(demoEvents.first.title), findsOneWidget);
      expect(find.text('Nenhum ingresso ainda'), findsNothing);

      session.dispose();
    });
  });
}