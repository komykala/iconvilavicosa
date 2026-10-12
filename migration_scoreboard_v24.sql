-- ICON Tournament App v24: campos de pontuação para o marcador
-- Executar uma única vez no SQL Editor do Supabase.
alter table public.matches
  add column if not exists score_a integer not null default 0,
  add column if not exists score_b integer not null default 0,
  add column if not exists advantages_a integer not null default 0,
  add column if not exists advantages_b integer not null default 0,
  add column if not exists penalties_a integer not null default 0,
  add column if not exists penalties_b integer not null default 0;
