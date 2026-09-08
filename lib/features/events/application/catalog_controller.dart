import 'package:flutter/foundation.dart';

import 'package:avesso_x_go/features/events/data/local_event_repository.dart';
import 'package:avesso_x_go/features/events/domain/event_repository.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';

/// Mantém o catálogo de eventos (seed + persistidos) e orquestra a camada de
/// dados. As telas leem o catálogo aqui, nunca acessam `shared_preferences`.
class CatalogController extends ChangeNotifier {
  CatalogController({EventRepository? repository})
      : _repository = repository ?? LocalEventRepository();

  static List<DemoEvent> get _seedEvents => demoEvents;

  final EventRepository _repository;

  List<DemoEvent> _events = _seedEvents;
  Future<void>? _loadFuture;

  /// Eventos disponíveis (seed + criados pelo organizador).
  ///
  /// Antes do carregamento assíncrono, expõe os eventos seed para que as
  /// telas nunca apresentem um catálogo vazio.
  List<DemoEvent> get events => _events.isEmpty ? _seedEvents : _events;

  /// Busca um evento pelo id no catálogo completo.
  DemoEvent? eventById(String id) {
    for (final event in events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  /// Carrega o catálogo persistido (seed + eventos do organizador).
  Future<void> load() => _loadFuture ??= _load();

  Future<void> _load() async {
    _events = await _repository.loadEvents();
    notifyListeners();
  }

  /// Persiste um novo evento criado pelo organizador.
  Future<void> addEvent(DemoEvent event) async {
    await _repository.addEvent(event);
    _events = await _repository.loadEvents();
    notifyListeners();
  }
}