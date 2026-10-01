-- Summit v1 schema: profiles, friends, races, flights, items and race events.
-- Clients read through row-level security; game rules (items, race state) run in server functions
-- with the service role, so nobody can cheat by writing progress directly.

create extension if not exists pgcrypto;

-- Profiles ---------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_]{3,20}$'),
  display_name text not null,
  climber_color text not null default 'plum'
    check (climber_color in ('glacier','lagoon','moss','sunflower','ember','coral','berry','plum')),
  created_at timestamptz not null default now()
);

-- Friends ----------------------------------------------------------------

create table public.friendships (
  requester_id uuid not null references public.profiles (id) on delete cascade,
  addressee_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  primary key (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

-- Races ------------------------------------------------------------------

create table public.races (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  mountain_id text not null default 'fuji',
  status text not null default 'open' check (status in ('open','climbing','final_push','finished')),
  created_by uuid not null references public.profiles (id),
  created_at timestamptz not null default now(),
  started_at timestamptz,
  first_summit_at timestamptz,
  closes_at timestamptz            -- first_summit_at + 3 days
);

create table public.race_members (
  race_id uuid not null references public.races (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  accepted boolean not null default false,
  joined_at timestamptz not null default now(),
  virtual_flights numeric not null default 0,   -- computed by the server
  summited_at timestamptz,
  primary key (race_id, user_id)
);

-- Flights: hourly buckets uploaded from HealthKit ----------------------------

create table public.flight_buckets (
  user_id uuid not null references public.profiles (id) on delete cascade,
  bucket_start timestamptz not null,
  flights integer not null check (flights >= 0 and flights <= 400),
  synced_at timestamptz not null default now(),
  primary key (user_id, bucket_start)
);

-- Items and events -------------------------------------------------------------

create table public.items (
  id uuid primary key default gen_random_uuid(),
  race_id uuid not null references public.races (id) on delete cascade,
  owner_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null check (kind in ('snowball','shortcut_sign','chocolate_bar')),
  found_at timestamptz not null default now(),
  found_at_flights numeric not null,
  used_at timestamptz
);

create table public.shortcut_signs (
  id uuid primary key default gen_random_uuid(),
  race_id uuid not null references public.races (id) on delete cascade,
  placed_by uuid not null references public.profiles (id) on delete cascade,
  at_flights numeric not null,
  placed_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '48 hours',
  triggered_by uuid references public.profiles (id),
  triggered_at timestamptz
);

-- Everything that happened in a race; the app replays these in the catch-up.
create table public.race_events (
  id uuid primary key default gen_random_uuid(),
  race_id uuid not null references public.races (id) on delete cascade,
  kind text not null check (kind in (
    'snowball_hit','shortcut_detour','chocolate_eaten','item_found',
    'camp_reached','overtake','summit','race_started','race_closed')),
  actor_id uuid references public.profiles (id),
  target_id uuid references public.profiles (id),
  flights numeric,
  at_flights numeric,
  happened_at timestamptz not null default now(),
  payload jsonb not null default '{}'::jsonb
);

create index race_events_race_time on public.race_events (race_id, happened_at);

-- Row-level security ----------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.friendships enable row level security;
alter table public.races enable row level security;
alter table public.race_members enable row level security;
alter table public.flight_buckets enable row level security;
alter table public.items enable row level security;
alter table public.shortcut_signs enable row level security;
alter table public.race_events enable row level security;

create or replace function public.is_race_member(r uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from race_members where race_id = r and user_id = auth.uid());
$$;

-- Profiles: everyone signed in can find people; you edit only yourself.
create policy "profiles readable" on public.profiles for select to authenticated using (true);
create policy "own profile insert" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "own profile update" on public.profiles for update to authenticated using (id = auth.uid());

-- Friendships: you see and manage the ones you're part of.
create policy "own friendships" on public.friendships for select to authenticated
  using (auth.uid() in (requester_id, addressee_id));
create policy "send request" on public.friendships for insert to authenticated
  with check (requester_id = auth.uid());
create policy "answer request" on public.friendships for update to authenticated
  using (addressee_id = auth.uid());
create policy "remove friendship" on public.friendships for delete to authenticated
  using (auth.uid() in (requester_id, addressee_id));

-- Races and their data: members can read; writes go through server functions.
create policy "members read races" on public.races for select to authenticated using (public.is_race_member(id));
create policy "members read members" on public.race_members for select to authenticated using (public.is_race_member(race_id));
create policy "members read events" on public.race_events for select to authenticated using (public.is_race_member(race_id));
create policy "members read signs" on public.shortcut_signs for select to authenticated using (public.is_race_member(race_id));
create policy "own items" on public.items for select to authenticated using (owner_id = auth.uid());

-- Flights: you upload your own buckets; race members' totals come from virtual_flights.
create policy "own buckets read" on public.flight_buckets for select to authenticated using (user_id = auth.uid());
create policy "own buckets write" on public.flight_buckets for insert to authenticated with check (user_id = auth.uid());
create policy "own buckets update" on public.flight_buckets for update to authenticated using (user_id = auth.uid());
