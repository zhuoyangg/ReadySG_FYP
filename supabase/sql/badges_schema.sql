-- ─────────────────────────────────────────────────────────────────────────────
-- badges_schema.sql
-- Run in Supabase SQL Editor to create badges + user_badges tables
-- and seed the 6 earnable badges for Day 15-16 gamification.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── badges table ─────────────────────────────────────────────────────────────
create table if not exists badges (
  id           text primary key,          -- e.g. 'milestone_1'
  name         text not null,
  description  text not null,
  icon_name    text not null,             -- maps to Flutter IconData name
  category     text not null,            -- 'milestone' | 'streak' | 'quiz'
  threshold    int  not null default 1,  -- lessons / streak days / score needed
  points_reward int not null default 0
);

-- Compatibility for legacy badges table versions:
-- if the table already exists without newer columns, add them.
alter table badges add column if not exists icon_name text;
alter table badges add column if not exists category text;
alter table badges add column if not exists threshold int;
alter table badges add column if not exists points_reward int;

-- Backfill defaults for existing rows before enforcing NOT NULL.
update badges
set icon_name = 'emoji_events'
where icon_name is null;

update badges
set category = 'milestone'
where category is null;

update badges
set threshold = 1
where threshold is null;

update badges
set points_reward = 0
where points_reward is null;

alter table badges alter column icon_name set not null;
alter table badges alter column category set not null;
alter table badges alter column threshold set not null;
alter table badges alter column threshold set default 1;
alter table badges alter column points_reward set not null;
alter table badges alter column points_reward set default 0;

-- If a legacy schema created badges.id/user_badges.badge_id as UUID, migrate to text
-- so stable semantic IDs like "milestone_1" can be seeded and referenced.
do $$
declare
  id_type text;
  fk_name text;
begin
  select data_type
    into id_type
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'badges'
    and column_name = 'id';

  if id_type = 'uuid' then
    -- Drop FK(s) from user_badges.badge_id -> badges.id before type change.
    for fk_name in
      select c.conname
      from pg_constraint c
      join pg_class t on t.oid = c.conrelid
      join pg_namespace n on n.oid = t.relnamespace
      where n.nspname = 'public'
        and t.relname = 'user_badges'
        and c.contype = 'f'
    loop
      execute format('alter table public.user_badges drop constraint if exists %I', fk_name);
    end loop;

    alter table public.badges
      alter column id type text using id::text;

    alter table public.user_badges
      alter column badge_id type text using badge_id::text;

    alter table public.user_badges
      add constraint user_badges_badge_id_fkey
      foreign key (badge_id) references public.badges(id) on delete cascade;
  end if;
end $$;

-- ── user_badges table ─────────────────────────────────────────────────────────
create table if not exists user_badges (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references profiles(id) on delete cascade,
  badge_id   text not null references badges(id) on delete cascade,
  awarded_at timestamptz not null default now(),
  unique (user_id, badge_id)
);

-- Index for fast per-user lookup
create index if not exists idx_user_badges_user_id on user_badges(user_id);

-- Enable Row-Level Security
alter table badges      enable row level security;
alter table user_badges enable row level security;

drop policy if exists "Authenticated users can read badges" on badges;
-- badges: anyone authenticated can read
create policy "Authenticated users can read badges"
  on badges for select
  to authenticated
  using (true);

drop policy if exists "Users can read own badges" on user_badges;
-- user_badges: users can only see their own earned badges
create policy "Users can read own badges"
  on user_badges for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Service role can upsert user_badges" on user_badges;
-- user_badges: service role inserts on award (app uses service key for upsert)
create policy "Service role can upsert user_badges"
  on user_badges for insert
  to authenticated
  with check (auth.uid() = user_id);

-- ── Seed: 6 earnable badges ───────────────────────────────────────────────────
insert into badges (id, name, description, icon_name, category, threshold, points_reward)
values
  -- Milestone badges (lessons completed)
  ('milestone_1',
   'First Steps',
   'Complete your first lesson.',
   'school',
   'milestone', 1, 10),

  ('milestone_5',
   'On a Roll',
   'Complete 5 lessons.',
   'local_fire_department',
   'milestone', 5, 25),

  ('milestone_10',
   'Knowledge Seeker',
   'Complete 10 lessons.',
   'emoji_events',
   'milestone', 10, 50),

  -- Streak badges (consecutive active days)
  ('streak_3',
   '3-Day Streak',
   'Stay active for 3 days in a row.',
   'whatshot',
   'streak', 3, 15),

  ('streak_7',
   'Week Warrior',
   'Stay active for 7 days in a row.',
   'military_tech',
   'streak', 7, 40),

  -- Perfect quiz badge
  ('quiz_perfect',
   'Perfect Score',
   'Score 100% on any quiz.',
   'star',
   'quiz', 100, 20)

on conflict (id) do update set
  name          = excluded.name,
  description   = excluded.description,
  icon_name     = excluded.icon_name,
  category      = excluded.category,
  threshold     = excluded.threshold,
  points_reward = excluded.points_reward;
