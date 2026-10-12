-- ICON Tournament: sexo do atleta para impedir confrontos mistos na categoria adulta (18+).
-- Seguro para executar mais do que uma vez.
alter table public.athletes add column if not exists gender text;
-- Valores aceites pela aplicação: M (Masculino), F (Feminino), NULL (por indicar).
