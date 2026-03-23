// Supabase Edge Function: sync-aed
// Fetches all AED locations from data.gov.sg and upserts them into the
// Supabase aed_locations table.
//
// Deploy:  supabase functions deploy sync-aed
// Invoke:  supabase functions invoke sync-aed
//          (or trigger via Supabase Dashboard → Edge Functions → Invoke)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const DATASET_ID = 'd_4e6b82c58a8a832f6f1fee5dfa6d47ea'
const POLL_URL =
  `https://api-open.data.gov.sg/v1/public/api/datasets/${DATASET_ID}/poll-download`

Deno.serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // ── 1. Get the signed download URL ────────────────────────────────────────
  const pollRes = await fetch(POLL_URL)
  const pollJson = await pollRes.json()

  if (pollJson.code !== 0) {
    return new Response(
      JSON.stringify({ error: `poll-download failed: ${pollJson.errMsg}` }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    )
  }

  // ── 2. Download the full GeoJSON ──────────────────────────────────────────
  const dataRes = await fetch(pollJson.data.url)
  const geoJson = await dataRes.json()

  const features = geoJson.features as Array<{
    properties: {
      AED_ID: string
      LATITUDE: number
      LONGITUDE: number
      BUILDING_NAME: string | null
      ROAD_NAME: string | null
      HOUSE_NUMBER: string | null
      UNIT_NUMBER: string | null
      POSTAL_CODE: string | null
      AED_LOCATION_DESCRIPTION: string | null
      AED_LOCATION_FLOOR_LEVEL: string | null
      OPERATING_HOURS: string | null
    }
  }>

  // ── 3. Map to Supabase rows ───────────────────────────────────────────────
  const records = features.map((f) => ({
    aed_id: f.properties.AED_ID,
    latitude: f.properties.LATITUDE,
    longitude: f.properties.LONGITUDE,
    building_name: f.properties.BUILDING_NAME ?? '',
    road_name: f.properties.ROAD_NAME ?? '',
    house_number: f.properties.HOUSE_NUMBER ?? '',
    unit_number: f.properties.UNIT_NUMBER ?? null,
    postal_code: f.properties.POSTAL_CODE ?? '',
    location_description: f.properties.AED_LOCATION_DESCRIPTION ?? '',
    floor_level: f.properties.AED_LOCATION_FLOOR_LEVEL ?? '',
    operating_hours: f.properties.OPERATING_HOURS ?? '',
    synced_at: new Date().toISOString(),
  }))

  // ── 4. Upsert in batches of 500 ──────────────────────────────────────────
  const BATCH_SIZE = 500
  let upserted = 0

  for (let i = 0; i < records.length; i += BATCH_SIZE) {
    const batch = records.slice(i, i + BATCH_SIZE)
    const { error } = await supabase
      .from('aed_locations')
      .upsert(batch, { onConflict: 'aed_id' })
    if (error) {
      return new Response(
        JSON.stringify({ error: error.message, upserted }),
        { status: 500, headers: { 'Content-Type': 'application/json' } },
      )
    }
    upserted += batch.length
  }

  return new Response(
    JSON.stringify({ success: true, total: records.length, upserted }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  )
})
