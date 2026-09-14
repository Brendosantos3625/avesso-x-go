-- =============================================================================
-- AVESSO X GO — Adiciona quantity à tabela orders
-- -----------------------------------------------------------------------------
-- Alinha o schema Supabase ao modelo local Order
-- (lib/features/tickets/domain/order.dart), que já persiste `quantity` em cada
-- pedido, eliminando a inconsistência documentada em docs/backend-migration.md.
--
-- Observações:
--   * Coluna inteira, NOT NULL e com padrão seguro (1): pedidos já existentes
--     recebem quantidade 1 sem quebra, e novos pedidos nunca ficam sem valor.
--   * Constraint orders_quantity_at_least_one impede quantidade menor que 1.
--   * Apenas adiciona; não altera colunas existentes, RLS ou políticas.
-- =============================================================================

alter table public.orders
  add column quantity integer not null default 1;

comment on column public.orders.quantity is
  'Quantidade de ingressos do pedido. Inteiro, obrigatório, mínimo 1.';

alter table public.orders
  add constraint orders_quantity_at_least_one check (quantity >= 1);