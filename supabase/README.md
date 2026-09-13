# Supabase — AVESSO X GO

Estrutura de banco e configuração do backend Supabase do **AVESSO X GO**.

```
supabase/
├── migrations/
│   └── 20260912000100_initial_schema.sql   # Esquema inicial (perfis, eventos, pedidos, ingressos)
└── README.md
```

> Nenhuma credencial real, chave `service_role` ou segredo deve ser adicionada
> neste repositório (ver `.gitignore` e `docs/backend-migration.md`).

---

## Como aplicar a migration

1. Instale o [Supabase CLI](https://supabase.com/docs/guides/cli).
2. Vincule o projeto (gera `supabase/config.toml`):

   ```bash
   supabase link --project-ref <seu-projeto-ref>
   ```

3. Aplique as migrations pendentes:

   ```bash
   supabase db push
   ```

Ou, no SQL Editor do dashboard do Supabase, cole o conteúdo de
`migrations/20260912000100_initial_schema.sql`.

---

## O que o esquema cria

| Tabela             | Descrição                                                                |
| ------------------ | ------------------------------------------------------------------------ |
| `profiles`         | Perfil do usuário, `1:1` com `auth.users`. Criado por trigger.           |
| `organizer_profiles` | Perfil de organizador (1 por usuário).                                 |
| `events`           | Eventos do catálogo. RLS: leitura pública apenas de `published`.         |
| `orders`           | Pedidos de compra. `ON DELETE RESTRICT` preserva histórico.              |
| `tickets`          | Ingressos emitidos por um pedido. `ticket_code` único.                   |

Relacionamentos principais:

```
auth.users 1─1 profiles 1─N organizer_profiles (1 por user)
organizer_profiles 1─N events
profiles 1─N orders 1─N tickets (buyer)
events 1─N orders 1─N tickets (event)
```

## Row Level Security (RLS)

Todas as tabelas têm RLS ativa. Resumo das políticas:

- `profiles`: usuário vê/atualiza apenas o próprio perfil.
- `organizer_profiles`: usuário vê/edita apenas o próprio perfil de organizador.
- `events`: qualquer pessoa lê eventos `published`; o organizador administra
  (insert/update/delete/select, incluindo rascunhos) apenas os próprios eventos.
- `orders`: comprador vê os próprios pedidos; organizador vê pedidos dos seus eventos.
- `tickets`: comprador vê os próprios ingressos; organizador vê ingressos dos seus eventos.

**Decisões de política documentadas (portanto restritivas):**

- `orders` e `tickets` **não têm políticas de INSERT/UPDATE** nesta etapa — a
  criação de pedidos e a emissão de ingressos serão implementadas junto com o
  backend de compras. Não há brechas abertas (`using(true)`) em dados privados.
- Leitura pública de `events` é filtrada por `status = 'published'` (dados de
  catálogo, não privados).

## Trigger de perfil

`handle_new_user()` (SECURITY DEFINER) cria o perfil automaticamente no
`INSERT` em `auth.users`, é **idempotente** (`ON CONFLICT (id) DO NOTHING`) e
não expõe dados sensíveis. Funciona com cadastro pelo Supabase Auth.

> Se um usuário já existia antes da criação da trigger com perfil ausente,
> use `handle_new_user()` manualmente ou recrie o usuário. (Limitação conhecida,
> ver `docs/backend-migration.md`.)

## Configuração do aplicativo

As credenciais são injetadas via `--dart-define` (chave pública apenas):

```bash
flutter run \
  --dart-define=SUPABASE_URL=<projeto>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Ou por arquivo (use `.env.example` como base e renomeie para `.env`):

```bash
flutter run --dart-define-from-file=.env
```

Sem essas variáveis, o app roda 100% em modo local (demonstração), sem quebrar.