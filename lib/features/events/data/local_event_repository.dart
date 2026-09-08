import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/features/events/domain/event_repository.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';

/// Implementação local do catálogo de eventos.
///
/// Usa `shared_preferences` apenas para os eventos criados pelo organizador.
/// Os eventos seed/demo permanecem no código (`demoEvents`) — por isso nunca
/// há duplicação de seed: o catálogo é sempre `seed + persistidos`, com ids
/// únicos garantidos na combinação.
class LocalEventRepository implements EventRepository {
  LocalEventRepository();

  static const String storageKey = 'events_repository';

  @override
  Future<DemoEvent?> eventById(String id) async {
    final events = await loadEvents();
    for (final event in events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  @override
  Future<List<DemoEvent>> loadEvents() async {
    final all = <DemoEvent>[...demoEvents];
    final persisted = await _loadPersisted();
    for (final event in persisted) {
      final exists = all.any((existing) => existing.id == event.id);
      if (!exists) {
        all.add(event);
      }
    }
    return all;
  }

  @override
  Future<void> addEvent(DemoEvent event) async {
    final isSeedId = demoEvents.any((seed) => seed.id == event.id);
    if (isSeedId) {
      return;
    }

    final persisted = await _loadPersisted();
    final existingIndex = persisted.indexWhere(
      (existing) => existing.id == event.id,
    );
    if (existingIndex >= 0) {
      persisted[existingIndex] = event;
    } else {
      persisted.add(event);
    }
    await _save(persisted);
  }

  Future<List<DemoEvent>> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) {
        return <DemoEvent>[];
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => DemoEvent.fromJson(
              (item as Map).cast<String, dynamic>(),
            ),
          )
          .toList();
    } catch (_) {
      // Dados persistidos inválidos não devem derrubar o aplicativo.
      return <DemoEvent>[];
    }
  }

  Future<void> _save(List<DemoEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        storageKey,
        jsonEncode(events.map((event) => event.toJson()).toList()),
      );
    } catch (_) {
      // Falha ao persistir não impede a sessão em memória.
    }
  }
}