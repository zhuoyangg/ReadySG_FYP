-- ============================================================
-- ReadySG Auth/Profile Security Schema
--
-- Run after the base schema so per-user profile and progress
-- writes are protected by explicit row level security policies.
-- ============================================================

alter table profiles enable row level security;
alter table user_progress enable row level security;

create unique index if not exists idx_user_progress_user_lesson_unique
  on user_progress(user_id, lesson_id);

drop policy if exists "Users can read own profile" on profiles;
create policy "Users can read own profile"
  on profiles for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "Users can insert own profile" on profiles;
create policy "Users can insert own profile"
  on profiles for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on profiles;
create policy "Users can update own profile"
  on profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "Users can read own progress" on user_progress;
create policy "Users can read own progress"
  on user_progress for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own progress" on user_progress;
create policy "Users can insert own progress"
  on user_progress for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own progress" on user_progress;
create policy "Users can update own progress"
  on user_progress for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
