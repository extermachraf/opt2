-- Fix weight entries constraint for upsert functionality
-- This migration fixes the unique constraint issue preventing weight entry upserts

-- Drop existing problematic index if it exists (safety check)
DROP INDEX IF EXISTS public.idx_weight_entries_user_recorded_date;

-- Create the unique index for weight entries using the normalize_weight_entry_date function
-- This ensures only one weight entry per user per day
CREATE UNIQUE INDEX IF NOT EXISTS weight_entries_user_date_constraint 
ON public.weight_entries (user_id, normalize_weight_entry_date(recorded_at));

-- Create performance index for better query performance
CREATE INDEX IF NOT EXISTS idx_weight_entries_user_recorded_date 
ON public.weight_entries (user_id, recorded_at);

-- Update the upsert_weight_entry function to use the correct constraint name
CREATE OR REPLACE FUNCTION public.upsert_weight_entry(
    p_user_id uuid, 
    p_weight_kg numeric, 
    p_body_fat_percentage numeric DEFAULT NULL::numeric, 
    p_muscle_mass_kg numeric DEFAULT NULL::numeric, 
    p_notes text DEFAULT NULL::text, 
    p_recorded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    result_id UUID;
    normalized_date TIMESTAMPTZ;
BEGIN
    -- Normalize the recorded_at to start of day (midnight)
    normalized_date := DATE_TRUNC('day', p_recorded_at);
    
    -- Use INSERT ... ON CONFLICT with the normalized date function
    INSERT INTO public.weight_entries (
        user_id,
        weight_kg,
        body_fat_percentage,
        muscle_mass_kg,
        notes,
        recorded_at,
        created_at
    )
    VALUES (
        p_user_id,
        p_weight_kg,
        p_body_fat_percentage,
        p_muscle_mass_kg,
        p_notes,
        normalized_date,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (user_id, normalize_weight_entry_date(recorded_at))
    DO UPDATE SET
        weight_kg = EXCLUDED.weight_kg,
        body_fat_percentage = EXCLUDED.body_fat_percentage,
        muscle_mass_kg = EXCLUDED.muscle_mass_kg,
        notes = EXCLUDED.notes,
        recorded_at = normalized_date,
        created_at = CURRENT_TIMESTAMP  -- Update timestamp on upsert
    RETURNING id INTO result_id;
    
    RETURN result_id;
END;
$function$;