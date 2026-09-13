/// Configuração de ambiente para o backend Supabase.
///
/// As credenciais NUNCA são fixadas no código. Elas são injetadas em tempo de
/// compilação via `--dart-define` (ou `--dart-define-from-file`):
///
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://seu-projeto.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=<anon-key-publica>
/// ```
///
/// Apenas a chave pública (anon key) do projeto é utilizada. Chaves
/// `service_role`, senhas de banco e tokens administrativos NÃO devem ser
/// usados pelo aplicativo em hipótese alguma.
///
/// Quando as variáveis não são fornecidas, [isConfigured] retorna `false` e a
/// aplicação continua funcionando 100% no modo local (demonstração).
abstract final class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// `true` quando o URL e a chave pública estão disponíveis.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}