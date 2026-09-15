import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Inicializa o cliente Supabase com segurança, sem derrubar o modo local.
///
/// - Sem credenciais configuradas: nada é feito (aplicativo segue 100% local).
/// - Com credenciais: tenta [Supabase.initialize]; em caso de falha (rede,
///   URL inválido, etc.) apenas registra o erro e a aplicação continua no
///   modo local, sem quebrar a experiência atual.
abstract final class SupabaseService {
  static bool _initialized = false;

  /// `true` quando o Supabase foi inicializado com sucesso (credenciais
  /// válidas presentes). Usado pela composição para escolher o repositório.
  static bool get isReady => _initialized;

  /// Liga o cliente Supabase se [SupabaseConfig.isConfigured] e se o app
  /// ainda não tiver inicializado.
  ///
  /// Seguro chamar no `main()`, pois nunca lança exceção.
  static Future<void> initialize() async {
    if (_initialized || !SupabaseConfig.isConfigured) {
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('AVESSO X GO — Supabase inicializado.');
    } catch (error) {
      debugPrint('AVESSO X GO — Falha ao inicializar Supabase: $error');
    }
  }
}