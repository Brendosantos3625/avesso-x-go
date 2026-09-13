# Migração para Backend — AVESSO X GO

Plano e status da migração do **AVESSO X GO** de um MVP 100% local (Flutter +
`SharedPreferences`) para uma arquitetura com backend **Supabase**.

## Status atual

| Item | Status |
| --- | --- |
| Auditoria da arquitetura | Concluída |
| Dependência `supabase_flutter` | Adicionada (`^2.17.2`) |
| Configuração segura por ambiente | Criada (`lib/core/supabase/`) |
| Migration SQL inicial | Criada (`supabase/migrations/`) |
| RLS + trigger de perfil | Criados na migration |
| Migração dos repositórios | **Não iniciada** (etapa futura) |
| Pagamento real | **Não implementado** |
| Persistência local | **Preservada** |

## Arquitetura proposta

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation (telas)                                        │
└───────────────▲─────────────────────────────────────────────┘
                │
┌───────────────┴───────────────┐
│ Controllers (ChangeNotifier)  │  SessionController, CatalogController,
│ + Scopes (InheritedNotifier)  │  PurchaseController
└───────────────▲───────────────┘
                │
┌───────────────┴───────────────┐
│ Repository (contrato no domínio) │  AuthRepository, EventRepository,
│                                │  PurchaseRepository
└───────────┬──────────┬─────────┘
            │          │
   Data Source local  Data Source remoto (etapa futura)
   SharedPreferences  Supabase (client autenticado)
```

A interface consumida pela apresentação não muda: cada `Repository` ganhará uma
implementação remota (`SupabaseAuthRepository`, `SupabaseEventRepository`,
`SupabasePurchaseRepository`) que poderá ser combinada com a local até a
conclusão da migração. O padrão `Presentation → Controller → Repository →
Data Source` é mantido.

## Tabelas e relacionamentos

### `profiles`
- `id` (uuid PK → `auth.users.id`, cascade)
- `full_name`, `email`, `avatar_url`, `created_at`, `updated_at`
- Criado automaticamente pela trigger `handle_new_user()`.

### `organizer_profiles`
- `id` (uuid PK), `user_id` (FK → `profiles`, unique), `display_name` (NOT NULL),
  `description`, `created_at`, `updated_at`

### `events`
- `id` (uuid PK), `organizer_id` (FK → `organizer_profiles`),
  `title` (NOT NULL), `description`, `category`, `location`,
  `starts_at`, `ends_at`, `price numeric(12,2)`, `image_url`, `status`,
  `created_at`, `updated_at`
- `status`: `draft | published | cancelled | finished`
- Índices: `organizer_id`, `status`, `starts_at`

### `orders`
- `id` (uuid PK), `buyer_id` (FK → `profiles`, cascade), `event_id`
  (FK → `events`, `ON DELETE RESTRICT` para preservar histórico),
  `status`, `total_amount numeric(12,2)`, `created_at`
- `status`: `pending | confirmed | cancelled | refunded`

### `tickets`
- `id` (uuid PK), `order_id` (FK → `orders`, cascade), `buyer_id`
  (FK → `profiles`, cascade), `event_id` (FK → `events`, restrict),
  `ticket_code` (unique NOT NULL), `status`, `created_at`
- `status`: `active | used | cancelled | refunded`

### Diagrama

```
auth.users ──1:1── profiles
profiles ──1:N── organizer_profiles (unique user_id)
organizer_profiles ──1:N── events
events ──1:N── orders ──1:N── tickets
profiles ──1:N── orders / tickets (buyer)
```

## Estratégia de autenticação

- Autenticação por **Supabase Auth** (email + senha) em etapa futura.
- O app usa apenas a **chave pública (anon key)**; nunca `service_role`.
- Sessão gerenciada pelo `supabase_flutter` (persistência própria), substituindo
  gradualmente o `SharedPreferencesSessionStore`.
- O `AuthenticatedUser` ganhará mapeamento a partir do `User` do Supabase
  (`id` = `auth.uid()`, `name`/`email` vindos do perfil).
- A conta demo e o fluxo local continuam funcionando até a troca ser validada.

## Estratégia de RLS

Resumo (detalhes na migration):

| Tabela | Políticas |
| --- | --- |
| `profiles` | select/insert/update do próprio (`auth.uid() = id`) |
| `organizer_profiles` | select/insert/update/delete do próprio (`auth.uid() = user_id`) |
| `events` | leitura pública de `published`; organizador administra os próprios |
| `orders` | comprador lê os próprios; organizador lê dos seus eventos |
| `tickets` | comprador lê os próprios; organizador lê dos seus eventos |

Princípios:
- Nenhuma política aberta (`using(true)`) em dados privados.
- `orders` e `tickets` **não possuem INSERT/UPDATE** nesta etapa (documentado na
  migration) — serão adicionadas com o backend de compras.

## Configuração local

O app segue funcionando sem backend quando as variáveis não existem. Estrutura
criada:

- `lib/core/supabase/supabase_config.dart` — lê `SUPABASE_URL` e
  `SUPABASE_ANON_KEY` via `String.fromEnvironment`.
- `lib/core/supabase/supabase_service.dart` — inicializa o cliente com
  segurança (no-op sem configuração; nunca lança exceção em falha).
- `main.dart` chama `SupabaseService.initialize()`; se não configurado, nada
  acontece e o modo local vigente é preservado.

### Variáveis necessárias

| Variável | Obrigatória | Onde obter |
| --- | --- | --- |
| `SUPABASE_URL` | sim (p/ backend) | Settings → API |
| `SUPABASE_ANON_KEY` | sim (p/ backend) | Settings → API (chave pública) |

### Como rodar com Supabase

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Ou via arquivo:

```bash
cp .env.example .env    # preencha os valores
flutter run --dart-define-from-file=.env
```

> `*.env` está no `.gitignore`. Nunca commite `.env` nem cole chaves no código.

### Como aplicar a migration

```bash
supabase link --project-ref <ref>
supabase db push
```

Ou cole `supabase/migrations/20260912000100_initial_schema.sql` no SQL Editor.

## O que ainda permanece local

- Contas de usuário e sessão (`LocalAuthRepository`,
  `SharedPreferencesSessionStore`).
- Catálogo de eventos (`LocalEventRepository`, eventos seed no código).
- Pedidos e ingressos (`LocalPurchaseRepository`).
- Preferência de tema (`SharedPreferencesThemeModeStore`).
- Fluxo de compra demonstrativo (sem pagamento real).

## Limitações atuais

1. **Perfil pré-existente sem trigger:** usuários criados antes da trigger não
   possuem `profiles` — reexecutar `handle_new_user()` manualmente ou recriar.
2. **INSERT/UPDATE de pedidos e ingressos:** políticas ausentes de propósito;
   a criação só será liberada junto com o backend de compras.
3. **Detalhes do evento no pedido:** o comprador só vê detalhes de eventos
   leitura-apta (publicados). Eventos em `draft` não são visíveis a compradores.
4. **`DemoEvent` em `presentation/screens`:** modelo usado pelas camadas de
   domínio/dados (inversão de dependência). Refatoração planejada, não feita
   nesta etapa para não alterar contratos.
5. **`orders` sem `quantity`:** o MVP local guarda `quantity` no pedido; a
   tabela inicial não prevê quantidade (evolução posterior, sem bloquear etapas).

## Próximos passos

1. Criar projeto Supabase e aplicar a migration.
2. Implementar `SupabaseAuthRepository` e fluxo de sessão via Supabase Auth
   (mantendo fallback local).
3. Implementar `SupabaseEventRepository` (catalogar eventos publicados + CRUD
   do organizador).
4. Implementar `SupabasePurchaseRepository` (insert seguro de `orders`/`tickets`
   com RLS) mantendo o fluxo visual demonstrativo.
5. Validar RLS e sessão em dispositivo real + web.
6. Definir modelo de pagamento (gateway) em etapa separada.

## Riscos conhecidos

- **Configuração incorreta** pode levar o app a rodar em modo local sem falhas
  visíveis — mitigado pelo log em `SupabaseService`.
- **Falha de rede/Supabase indisponível** — aplicativo permanece no modo local
  nesta etapa (degradação graciosa prevista, sem `loading states` de backend).
- **RLS mal entendida** pode bloquear consultas do organizador — mitigado por
  políticas explícitas por papel (comprador vs. organizador) e testes manuais.
- **Migração dos repositórios** deve acontecer de forma gradual e validada a
  cada substituição, por contrato (`AuthRepository` etc.), sem mudança visual.