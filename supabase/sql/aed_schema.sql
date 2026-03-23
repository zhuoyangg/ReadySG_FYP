-- ============================================================
-- ReadySG AED Locations Schema (NON-DESTRUCTIVE)
-- Safe to re-run in Supabase SQL Editor.
--
-- This script does NOT drop data.
-- For destructive reset, use: supabase/sql/aed_schema_reset.sql
-- ============================================================

-- Create if missing
CREATE TABLE IF NOT EXISTS public.aed_locations (
  aed_id               TEXT             PRIMARY KEY,
  latitude             DOUBLE PRECISION NOT NULL,
  longitude            DOUBLE PRECISION NOT NULL,
  building_name        TEXT             NOT NULL DEFAULT '',
  road_name            TEXT             NOT NULL DEFAULT '',
  house_number         TEXT             NOT NULL DEFAULT '',
  unit_number          TEXT,
  postal_code          TEXT             NOT NULL DEFAULT '',
  location_description TEXT             NOT NULL DEFAULT '',
  floor_level          TEXT             NOT NULL DEFAULT '',
  operating_hours      TEXT             NOT NULL DEFAULT '',
  synced_at            TIMESTAMPTZ      DEFAULT NOW()
);

-- Ensure expected columns exist for legacy compatibility
ALTER TABLE public.aed_locations
  ADD COLUMN IF NOT EXISTS aed_id TEXT,
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS building_name TEXT,
  ADD COLUMN IF NOT EXISTS road_name TEXT,
  ADD COLUMN IF NOT EXISTS house_number TEXT,
  ADD COLUMN IF NOT EXISTS unit_number TEXT,
  ADD COLUMN IF NOT EXISTS postal_code TEXT,
  ADD COLUMN IF NOT EXISTS location_description TEXT,
  ADD COLUMN IF NOT EXISTS floor_level TEXT,
  ADD COLUMN IF NOT EXISTS operating_hours TEXT,
  ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;

-- Backfill defaults for nullable legacy rows
UPDATE public.aed_locations SET building_name = '' WHERE building_name IS NULL;
UPDATE public.aed_locations SET road_name = '' WHERE road_name IS NULL;
UPDATE public.aed_locations SET house_number = '' WHERE house_number IS NULL;
UPDATE public.aed_locations SET postal_code = '' WHERE postal_code IS NULL;
UPDATE public.aed_locations SET location_description = '' WHERE location_description IS NULL;
UPDATE public.aed_locations SET floor_level = '' WHERE floor_level IS NULL;
UPDATE public.aed_locations SET operating_hours = '' WHERE operating_hours IS NULL;
UPDATE public.aed_locations SET synced_at = NOW() WHERE synced_at IS NULL;

-- Enforce expected defaults / constraints on known fields
ALTER TABLE public.aed_locations
  ALTER COLUMN building_name SET DEFAULT '',
  ALTER COLUMN road_name SET DEFAULT '',
  ALTER COLUMN house_number SET DEFAULT '',
  ALTER COLUMN postal_code SET DEFAULT '',
  ALTER COLUMN location_description SET DEFAULT '',
  ALTER COLUMN floor_level SET DEFAULT '',
  ALTER COLUMN operating_hours SET DEFAULT '',
  ALTER COLUMN synced_at SET DEFAULT NOW();

-- NOTE: We do not force NOT NULL on latitude/longitude/aed_id here to avoid
-- breaking legacy rows during non-destructive migrations.

CREATE INDEX IF NOT EXISTS aed_locations_coords
  ON public.aed_locations (latitude, longitude);

ALTER TABLE public.aed_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "AED locations viewable by all" ON public.aed_locations;
CREATE POLICY "AED locations viewable by all" ON public.aed_locations
  FOR SELECT USING (true);

-- Force PostgREST schema cache refresh so Edge Functions see latest columns
NOTIFY pgrst, 'reload schema';
