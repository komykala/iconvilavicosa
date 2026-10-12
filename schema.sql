create extension if not exists pgcrypto;
create table if not exists public.athletes (
 id uuid primary key default gen_random_uuid(), display_name text not null, email text, team text, belt text, age_text text, weight_text text, gender text,
 arrived boolean not null default false, weighed boolean not null default false, notes text, created_at timestamptz not null default now()
);
create table if not exists public.matches (
 id uuid primary key default gen_random_uuid(), match_code text, category text not null, mat integer not null check(mat in (1,2)),
 fighter_a_id uuid references public.athletes(id) on delete set null, fighter_b_id uuid references public.athletes(id) on delete set null,
 fighter_a_name text not null, fighter_b_name text not null, status text not null default 'pending' check(status in ('pending','called','in_progress','completed','cancelled')),
 winner_id uuid references public.athletes(id) on delete set null, winner_name text, completed_at timestamptz, created_at timestamptz not null default now()
);
alter table public.athletes enable row level security; alter table public.matches enable row level security;
create policy "authenticated athletes select" on public.athletes for select to authenticated using(true);
create policy "authenticated athletes insert" on public.athletes for insert to authenticated with check(true);
create policy "authenticated athletes update" on public.athletes for update to authenticated using(true) with check(true);
create policy "authenticated athletes delete" on public.athletes for delete to authenticated using(true);
create policy "authenticated matches select" on public.matches for select to authenticated using(true);
create policy "authenticated matches insert" on public.matches for insert to authenticated with check(true);
create policy "authenticated matches update" on public.matches for update to authenticated using(true) with check(true);
create policy "authenticated matches delete" on public.matches for delete to authenticated using(true);
alter publication supabase_realtime add table public.athletes;
alter publication supabase_realtime add table public.matches;
