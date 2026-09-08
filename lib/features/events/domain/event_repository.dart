import 'package:avesso_x_go/features/events/presentation/screens/events_demo_data.dart';

/// Contrato do catálogo de eventos.
///
/// Combina os eventos seed/demo (fornecidos pelo aplicativo) com os eventos
/// criados pelo organizador e persistidos localmente. As telas nunca acessam
/// `shared_preferences` diretamente: a persistência vive na implementação
/// local desta interface.
abstract interface class EventRepository {
  /// Carrega o catálogo: eventos seed (uma única vez) + eventos persistidos,
  /// sem duplicar eventos com o mesmo [DemoEvent.id].
  Future<List<DemoEvent>> loadEvents();

  /// Busca um evento pelo [id] no catálogo completo (seed + persistido).
  Future<DemoEvent?> eventById(String id);

  /// Persiste um evento criado pelo organizador.
  ///
  /// Eventos com [id] já existente são atualizados; ids reservados aos
  /// eventos seed não são sobrescritos.
  Future<void> addEvent(DemoEvent event);
}