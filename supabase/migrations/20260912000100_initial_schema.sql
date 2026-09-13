-- =============================================================================
-- AVESSO X GO — Esquema inicial (Supabase / PostgreSQL)
-- -----------------------------------------------------------------------------
-- Migration inicial: perfis, organizadores, eventos, pedidos e ingressos.
-- Inclui RLS (Row Level Security) e trigger de criação automática de perfil.
--
-- Observações:
--   * UUIDs com gen_random_uuid() (nativo no PostgreSQL 13+ / Supabase).
--   * Timestamps com fuso horário (timestamptz), padrão agora().
--   * Nenhuma credencial de serviço vive aqui; apenas schema + políticas.
--   * Pedidos/ingressos ainda não possuem políticas de INSERT: a criação de
--     pedidos será definida quando o backend de compras for implementado.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Função utilitária: atualiza updated_at automaticamente.
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- =============================================================================
-- Tabela: profiles
-- -----------------------------------------------------------------------------
-- Perfil público vinculado obrigatoriamente a um usuário do Supabase Auth.
-- O email é um espelho do auth.users para consultas do aplicativo.
-- =============================================================================
create table public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  full_name  text,
  email      text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is
  'Perfil de usuário, vinculado 1:1 a um registro em auth.users.';
comment on column public.profiles.id is
  'Mesmo id do usuário em auth.users.';
comment on column public.profiles.email is
  'Espelho do e-mail de auth.users, conveniência para consultas do app.';

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Trigger: cria o perfil automaticamente após INSERT em auth.users.
-- Idempotente: ON CONFLICT DO NOTHING evita duplicação de perfil.
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'name',
      ''
    ),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =============================================================================
-- Tabela: organizer_profiles
-- -----------------------------------------------------------------------------
-- Perfil de organizador. Um usuário pode ter no máximo um perfil de
-- organizador (índice único em user_id).
-- =============================================================================
create table public.organizer_profiles (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  display_name text not null,
  description  text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint organizer_profiles_user_id_key unique (user_id)
);

comment on table public.organizer_profiles is
  'Perfis de organizador. Um usuário autenticado pode ter no máximo um.';

create trigger organizer_profiles_set_updated_at
  before update on public.organizer_profiles
  for each row execute function public.set_updated_at();

-- =============================================================================
-- Tabela: events
-- -----------------------------------------------------------------------------
-- Eventos publicados por organizadores. O status controla visibilidade e RLS.
-- =============================================================================
create table public.events (
  id            uuid primary key default gen_random_uuid(),
  organizer_id  uuid not null references public.organizer_profiles(id)
                on delete cascade,
  title         text not null,
  description   text,
  category      text,
  location      text,
  starts_at     timestamptz,
  ends_at       timestamptz,
  price         numeric(12, 2) not null default 0,
  image_url     text,
  status        text not null default 'draft',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint events_price_non_negative check (price >= 0),
  constraint events_status_valid check (
    status in ('draft', 'published', 'cancelled', 'finished')
  )
);

comment on table public.events is
  'Eventos do catálogo. RLS permite leitura pública apenas de eventos publicados.';
comment on column public.events.status is
  'draft | published | cancelled | finished';
comment on column public.events.price is
  'Preço unitário do ingresso em moeda (numeric 12,2).';

create index events_organizer_id_idx on public.events(organizer_id);
create index events_status_idx on public.events(status);
create index events_starts_at_idx on public.events(starts_at);

create trigger events_set_updated_at
  before update on public.events
  for each row execute function public.set_updated_at();

-- =============================================================================
-- Tabela: orders
-- -----------------------------------------------------------------------------
-- Pedidos de compra de um comprador para um evento.
-- =============================================================================
create table public.orders (
  id           uuid primary key default gen_random_uuid(),
  buyer_id     uuid not null references public.profiles(id) on delete cascade,
  event_id     uuid not null references public.events(id) on delete restrict,
  status       text not null default 'pending',
  total_amount numeric(12, 2) not null default 0,
  created_at   timestamptz not null default now(),
  constraint orders_total_non_negative check (total_amount >= 0),
  constraint orders_status_valid check (
    status in ('pending', 'confirmed', 'cancelled', 'refunded')
  )
);

comment on table public.orders is
  'Pedido de compra. ON DELETE RESTRICT no evento preserva o histórico de vendas.';
comment on column public.orders.status is
  'pending | confirmed | cancelled | refunded';

create index orders_buyer_id_idx on public.orders(buyer_id);
create index orders_event_id_idx on public.orders(event_id);
create index orders_created_at_idx on public.orders(created_at);

-- =============================================================================
-- Tabela: tickets
-- -----------------------------------------------------------------------------
-- Ingresso emitido por um pedido. ticket_code é único por ingresso.
-- =============================================================================
create table public.tickets (
  id          uuid primary key default gen_random_uuid(),
  order_id    uuid not null references public.orders(id) on delete cascade,
  buyer_id    uuid not null references public.profiles(id) on delete cascade,
  event_id    uuid not null references public.events(id) on delete restrict,
  ticket_code text not null unique,
  status      text not null default 'active',
  created_at  timestamptz not null default now(),
  constraint tickets_status_valid check (
    status in ('active', 'used', 'cancelled', 'refunded')
  )
);

comment on table public.tickets is
  'Ingresso vinculado a um pedido. ticket_code único identifica o ingresso.';
comment on column public.tickets.status is
  'active | used | cancelled | refunded';

create index tickets_buyer_id_idx on public.tickets(buyer_id);
create index tickets_order_id_idx on public.tickets(order_id);
create index tickets_event_id_idx on public.tickets(event_id);

-- =============================================================================
-- Row Level Security
-- =============================================================================

-- -----------------------------------------------------------------------------
-- profiles
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;

create policy "profile_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profile_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profile_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Sem política de DELETE: a remoção acontece em auth.users (cascade).

-- -----------------------------------------------------------------------------
-- organizer_profiles
-- -----------------------------------------------------------------------------
alter table public.organizer_profiles enable row level security;

create policy "organizer_select_own"
  on public.organizer_profiles for select
  using (auth.uid() = user_id);

create policy "organizer_insert_own"
  on public.organizer_profiles for insert
  with check (auth.uid() = user_id);

create policy "organizer_update_own"
  on public.organizer_profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "organizer_delete_own"
  on public.organizer_profiles for delete
  using (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- events
-- -----------------------------------------------------------------------------
alter table public.events enable row level security;

-- Leitura pública do catálogo: apenas eventos publicados (dados não privados).
create policy "events_select_published"
  on public.events for select
  using (status = 'published');

-- Organizador vê (inclusive rascunhos) e administra os próprios eventos.
create policy "events_select_own_organizer"
  on public.events for select
  using (
    exists (
      select 1
      from public.organizer_profiles op
      where op.id = events.organizer_id
        and op.user_id = auth.uid()
    )
  );

create policy "events_insert_own"
  on public.events for insert
  with check (
    exists (
      select 1
      from public.organizer_profiles op
      where op.id = events.organizer_id
        and op.user_id = auth.uid()
    )
  );

create policy "events_update_own"
  on public.events for update
  using (
    exists (
      select 1
      from public.organizer_profiles op
      where op.id = events.organizer_id
        and op.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1
      from public.organizer_profiles op
      where op.id = events.organizer_id
        and op.user_id = auth.uid()
    )
  );

create policy "events_delete_own"
  on public.events for delete
  using (
    exists (
      select 1
      from public.organizer_profiles op
      where op.id = events.organizer_id
        and op.user_id = auth.uid()
    )
  );

-- -----------------------------------------------------------------------------
-- orders
-- -----------------------------------------------------------------------------
alter table public.orders enable row level security;

-- Comprador vê os próprios pedidos.
create policy "orders_select_own"
  on public.orders for select
  using (auth.uid() = buyer_id);

-- Organizador consulta pedidos dos próprios eventos.
create policy "orders_select_organizer"
  on public.orders for select
  using (
    exists (
      select 1
      from public.events e
      join public.organizer_profiles op on op.id = e.organizer_id
      where e.id = orders.event_id
        and op.user_id = auth.uid()
    )
  );

-- Sem políticas de INSERT/UPDATE/DELETE nesta etapa: a criação de pedidos será
-- definida junto com o backend de compras (etapa futura).

-- -----------------------------------------------------------------------------
-- tickets
-- -----------------------------------------------------------------------------
alter table public.tickets enable row level security;

-- Comprador vê os próprios ingressos.
create policy "tickets_select_own"
  on public.tickets for select
  using (auth.uid() = buyer_id);

-- Organizador consulta ingressos dos próprios eventos.
create policy "tickets_select_organizer"
  on public.tickets for select
  using (
    exists (
      select 1
      from public.events e
      join public.organizer_profiles op on op.id = e.organizer_id
      where e.id = tickets.event_id
        and op.user_id = auth.uid()
    )
  );

-- Sem políticas de INSERT/UPDATE/DELETE nesta etapa: emissão de ingressos será
-- definida junto com o backend de compras (etapa futura).