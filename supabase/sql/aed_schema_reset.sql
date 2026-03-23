-- ============================================================
-- ReadySG AED Locations Schema (DESTRUCTIVE RESET)
-- Use this ONLY when you intentionally want to wipe and recreate
-- the AED table from scratch.
-- ============================================================

DROP TABLE IF EXISTS public.aed_locations CASCADE;

CREATE TABLE public.aed_locations (
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

CREATE INDEX IF NOT EXISTS aed_locations_coords
  ON public.aed_locations (latitude, longitude);

ALTER TABLE public.aed_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "AED locations viewable by all" ON public.aed_locations;
CREATE POLICY "AED locations viewable by all" ON public.aed_locations
  FOR SELECT USING (true);

-- Force PostgREST schema cache refresh so Edge Functions see latest columns
NOTIFY pgrst, 'reload schema';
