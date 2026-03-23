-- ============================================================
-- ReadySG Recent Activity Sync Schema
--
-- Run in Supabase SQL Editor to enable cross-device recent
-- activity / recent practice session syncing while preserving
-- the original completion timestamp (`activity_at`).
-- ============================================================

create table if not exists recent_activity (
  id              text primary key,
  user_id         uuid not null references profiles(id) on delete cascade,
  activity_type   text not null,
  activity_at     timestamptz not null default now(),
  title           text not null,
  score           integer,
  correct_answers integer,
  total_questions integer,
  passed          boolean,
  points_earned   integer,
  streak_count    integer,
  created_at      timestamptz not null default now()
);

create index if not exists idx_recent_activity_user_id
  on recent_activity(user_id);

create index if not exists idx_recent_activity_user_id_activity_at
  on recent_activity(user_id, activity_at desc);

alter table recent_activity enable row level security;

drop policy if exists "Users can read own recent activity" on recent_activity;
create policy "Users can read own recent activity"
  on recent_activity for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own recent activity" on recent_activity;
create policy "Users can insert own recent activity"
  on recent_activity for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own recent activity" on recent_activity;
create policy "Users can update own recent activity"
  on recent_activity for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
