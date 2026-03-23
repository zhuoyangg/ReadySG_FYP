-- ============================================================
-- ReadySG Schema Migration v2 — Course → Lesson → Slide
-- Run this ONCE in Supabase SQL Editor before seed_data.sql.
-- Safe to re-run: uses IF NOT EXISTS / IF EXISTS guards.
-- ============================================================

-- ─── 1. Create courses table ──────────────────────────────

CREATE TABLE IF NOT EXISTS courses (
  id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  title         TEXT        NOT NULL,
  description   TEXT        NOT NULL DEFAULT '',
  thumbnail_url TEXT,
  category      TEXT        NOT NULL DEFAULT 'general',
  difficulty    TEXT        CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  sort_order    INTEGER     NOT NULL DEFAULT 0,
  is_published  BOOLEAN     NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Unique title index (allows re-running seed safely)
CREATE UNIQUE INDEX IF NOT EXISTS courses_title_unique ON courses (title);

ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Published courses viewable by all" ON courses;
CREATE POLICY "Published courses viewable by all" ON courses
  FOR SELECT USING (is_published = true);


-- ─── 2. Extend lessons table ──────────────────────────────
-- content stays JSONB — it now holds a structured slide array.
-- We add course_id, sort_order, points.

ALTER TABLE lessons ADD COLUMN IF NOT EXISTS course_id  UUID    REFERENCES courses(id) ON DELETE CASCADE;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS points     INTEGER NOT NULL DEFAULT 10;

-- Unique title so re-running seed never duplicates lessons
CREATE UNIQUE INDEX IF NOT EXISTS lessons_title_unique ON lessons (title);


-- ─── 3. Fix user_progress table ───────────────────────────

ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS completed    BOOLEAN     DEFAULT false;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS quiz_score   INTEGER     DEFAULT 0;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS best_score   INTEGER     DEFAULT 0;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;


-- ─── 4. Recreate quizzes with per-question structure ──────
-- Original schema stored all questions in one JSONB blob.
-- App expects one row per question.

DROP TABLE IF EXISTS quizzes CASCADE;

CREATE TABLE quizzes (
  id                   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id            UUID        REFERENCES lessons(id) ON DELETE CASCADE,
  question             TEXT        NOT NULL,
  options              JSONB       NOT NULL,
  correct_answer_index INTEGER     NOT NULL DEFAULT 0,
  explanation          TEXT        NOT NULL DEFAULT '',
  sort_order           INTEGER     NOT NULL DEFAULT 0,
  created_at           TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (lesson_id, sort_order)
);

ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Quizzes viewable by all" ON quizzes FOR SELECT USING (true);


-- ─── 5. Emergency guides table ────────────────────────────

CREATE TABLE IF NOT EXISTS emergency_guides (
  id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  title        TEXT        NOT NULL,
  description  TEXT        NOT NULL DEFAULT '',
  content      JSONB       NOT NULL DEFAULT '[]',
  sort_order   INTEGER     NOT NULL DEFAULT 0,
  is_published BOOLEAN     NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- If emergency_guides already existed from an older schema,
-- ensure expected columns are present for current app + seed scripts.
ALTER TABLE emergency_guides ADD COLUMN IF NOT EXISTS description  TEXT    NOT NULL DEFAULT '';
ALTER TABLE emergency_guides ADD COLUMN IF NOT EXISTS content      JSONB   NOT NULL DEFAULT '[]';
ALTER TABLE emergency_guides ADD COLUMN IF NOT EXISTS sort_order   INTEGER NOT NULL DEFAULT 0;
ALTER TABLE emergency_guides ADD COLUMN IF NOT EXISTS is_published BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE emergency_guides ADD COLUMN IF NOT EXISTS created_at   TIMESTAMPTZ DEFAULT NOW();

-- Legacy compatibility: older schemas may have extra NOT NULL columns that this
-- seed does not explicitly insert into (e.g. category, estimated_minutes).
-- If those columns exist, enforce safe defaults so inserts succeed.
DO $$
DECLARE
  steps_udt TEXT;
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'emergency_guides'
      AND column_name = 'category'
  ) THEN
    ALTER TABLE emergency_guides ALTER COLUMN category SET DEFAULT 'general';
    UPDATE emergency_guides SET category = 'general' WHERE category IS NULL;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'emergency_guides'
      AND column_name = 'estimated_minutes'
  ) THEN
    ALTER TABLE emergency_guides ALTER COLUMN estimated_minutes SET DEFAULT 5;
    UPDATE emergency_guides SET estimated_minutes = 5 WHERE estimated_minutes IS NULL;
  END IF;

  -- Some older schemas used a NOT NULL `steps` column (type varied by version).
  -- Detect type and set a compatible default + null backfill.
  SELECT c.udt_name INTO steps_udt
  FROM information_schema.columns c
  WHERE c.table_schema = 'public'
    AND c.table_name = 'emergency_guides'
    AND c.column_name = 'steps'
  LIMIT 1;

  IF steps_udt IS NOT NULL THEN
    IF steps_udt = 'jsonb' THEN
      ALTER TABLE emergency_guides ALTER COLUMN steps SET DEFAULT '[]'::jsonb;
      UPDATE emergency_guides SET steps = '[]'::jsonb WHERE steps IS NULL;
    ELSIF steps_udt = 'int4' OR steps_udt = 'int8' OR steps_udt = 'numeric' THEN
      ALTER TABLE emergency_guides ALTER COLUMN steps SET DEFAULT 0;
      UPDATE emergency_guides SET steps = 0 WHERE steps IS NULL;
    ELSE
      ALTER TABLE emergency_guides ALTER COLUMN steps SET DEFAULT '';
      UPDATE emergency_guides SET steps = '' WHERE steps IS NULL;
    END IF;
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS emergency_guides_title_unique ON emergency_guides (title);

ALTER TABLE emergency_guides ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Published guides viewable by all" ON emergency_guides;
CREATE POLICY "Published guides viewable by all" ON emergency_guides
  FOR SELECT USING (is_published = true);


-- ─── Verification ─────────────────────────────────────────

SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
