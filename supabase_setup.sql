-- Cocina Gourmet Congelados - setup recomendado para analytics v10
-- Ejecutar en Supabase SQL Editor.

create table if not exists analytics_daily (
  event_date date not null,
  event_type text not null,
  label text not null default 'general',
  total integer not null default 0,
  updated_at timestamptz default now(),
  primary key (event_date, event_type, label)
);

create or replace function increment_analytics_daily(
  p_event_date date,
  p_event_type text,
  p_label text default 'general'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into analytics_daily (event_date, event_type, label, total, updated_at)
  values (
    p_event_date,
    nullif(trim(p_event_type), ''),
    coalesce(nullif(trim(p_label), ''), 'general'),
    1,
    now()
  )
  on conflict (event_date, event_type, label)
  do update set
    total = analytics_daily.total + 1,
    updated_at = now();
end;
$$;

grant execute on function increment_analytics_daily(date, text, text) to anon, authenticated;

create index if not exists analytics_daily_event_date_idx
  on analytics_daily (event_date desc);

create index if not exists analytics_daily_event_type_idx
  on analytics_daily (event_type);

-- Recomendacion de seguridad:
-- 1. Activar RLS en tablas sensibles.
-- 2. products/categories/zones pueden tener SELECT publico si son catalogo.
-- 3. inserts/updates/deletes de admin NO deberian depender solo de una password en frontend.
-- 4. La tabla config contiene admin_password: no la expongas con SELECT publico.
--    Para seguridad real, mover admin a Supabase Auth o Edge Function.
-- 5. orders recibe datos de clientes: permitir insert publico solo con columnas esperadas,
--    y lectura solo autenticada/admin.

-- Config bancaria centralizada. El index.html usa key = bank_info.
insert into config (key, value)
values ('bank_info', 'Banco:
CBU:
Alias:')
on conflict (key) do nothing;
