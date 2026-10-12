-- Executar UMA VEZ no Supabase SQL Editor, depois de fazer backup/exportação.
-- Acrescenta metadados para quadros eliminatórios e progressão dos vencedores.
alter table public.matches add column if not exists bracket_id uuid;
alter table public.matches add column if not exists round_number integer;
alter table public.matches add column if not exists next_match_id uuid references public.matches(id) on delete set null;
alter table public.matches add column if not exists next_slot text check (next_slot in ('a','b'));
create index if not exists matches_bracket_id_idx on public.matches(bracket_id);
create index if not exists matches_status_mat_idx on public.matches(status, mat);

-- Campo sexo usado na edição e validação das categorias adultas.
alter table public.athletes add column if not exists gender text;
