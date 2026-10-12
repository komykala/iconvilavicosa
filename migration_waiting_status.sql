-- Executar no Supabase SQL Editor antes de utilizar a função "Colocar em espera".
-- Permite suspender um combate sem o cancelar nem o perder da fila.
alter table public.matches drop constraint if exists matches_status_check;
alter table public.matches add constraint matches_status_check
 check (status in ('pending','called','in_progress','waiting','completed','cancelled'));
