-- ============================================================
-- Fix: Remove duplicate quiz questions
-- Run this ONCE in the Supabase SQL Editor.
-- Safe to re-run (idempotent).
-- ============================================================

-- Step 1: Delete duplicate rows, keeping the oldest (min ctid) per (lesson_id, sort_order)
DELETE FROM quizzes
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY lesson_id, sort_order
             ORDER BY created_at ASC, id ASC
           ) AS rn
    FROM quizzes
  ) ranked
  WHERE rn > 1
);

-- Step 2: Add unique constraint so re-running seed never creates duplicates again.
-- (No-op if the constraint already exists.)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'quizzes_lesson_id_sort_order_key'
  ) THEN
    ALTER TABLE quizzes
      ADD CONSTRAINT quizzes_lesson_id_sort_order_key
      UNIQUE (lesson_id, sort_order);
  END IF;
END $$;

-- Verify: should show 5 questions per lesson (or 0 duplicates)
SELECT lesson_id, sort_order, COUNT(*) AS cnt
FROM quizzes
GROUP BY lesson_id, sort_order
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
-- Expected: 0 rows (no duplicates)
