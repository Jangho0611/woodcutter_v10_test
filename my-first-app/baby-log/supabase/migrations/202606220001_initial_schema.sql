create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.children (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  birth_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

create table public.feeding_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  fed_at timestamptz not null,
  feeding_type text not null check (feeding_type in ('breast', 'formula', 'mixed')),
  amount_ml integer check (amount_ml is null or amount_ml >= 0),
  memo text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sleep_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz,
  memo text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ended_at is null or ended_at >= started_at)
);

create table public.diaper_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  changed_at timestamptz not null,
  condition text not null check (condition in ('normal', 'loose', 'hard')),
  memo text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index children_user_id_idx
  on public.children (user_id);

create index feeding_records_user_fed_at_idx
  on public.feeding_records (user_id, fed_at desc);

create index sleep_records_user_started_at_idx
  on public.sleep_records (user_id, started_at desc);

create index diaper_records_user_changed_at_idx
  on public.diaper_records (user_id, changed_at desc);

create unique index one_open_sleep_per_child
  on public.sleep_records (child_id)
  where ended_at is null;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger set_children_updated_at
  before update on public.children
  for each row execute function public.set_updated_at();

create trigger set_feeding_records_updated_at
  before update on public.feeding_records
  for each row execute function public.set_updated_at();

create trigger set_sleep_records_updated_at
  before update on public.sleep_records
  for each row execute function public.set_updated_at();

create trigger set_diaper_records_updated_at
  before update on public.diaper_records
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, coalesce(new.email, ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.children enable row level security;
alter table public.feeding_records enable row level security;
alter table public.sleep_records enable row level security;
alter table public.diaper_records enable row level security;

create policy "profiles_select_own"
on public.profiles
for select
using (auth.uid() = id);

create policy "profiles_update_own"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "children_select_own"
on public.children
for select
using (auth.uid() = user_id);

create policy "children_insert_own"
on public.children
for insert
with check (auth.uid() = user_id);

create policy "children_update_own"
on public.children
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "children_delete_own"
on public.children
for delete
using (auth.uid() = user_id);

create policy "feeding_records_select_own_child"
on public.feeding_records
for select
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "feeding_records_insert_own_child"
on public.feeding_records
for insert
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "feeding_records_update_own_child"
on public.feeding_records
for update
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
)
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "feeding_records_delete_own_child"
on public.feeding_records
for delete
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "sleep_records_select_own_child"
on public.sleep_records
for select
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "sleep_records_insert_own_child"
on public.sleep_records
for insert
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "sleep_records_update_own_child"
on public.sleep_records
for update
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
)
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "sleep_records_delete_own_child"
on public.sleep_records
for delete
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "diaper_records_select_own_child"
on public.diaper_records
for select
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "diaper_records_insert_own_child"
on public.diaper_records
for insert
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "diaper_records_update_own_child"
on public.diaper_records
for update
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
)
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);

create policy "diaper_records_delete_own_child"
on public.diaper_records
for delete
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.children c
    where c.id = child_id
      and c.user_id = auth.uid()
  )
);
