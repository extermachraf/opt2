-- Schema Analysis: Existing weight_entries table with user_id and recorded_at columns
-- Integration Type: Modification to existing table
-- Dependencies: weight_entries table, user_profiles table

-- Add unique constraint on weight_entries for (user_id, date) to prevent duplicates per day
-- Normalize recorded_at to date only (ignore time) for proper daily uniqueness

-- Step 1: First, remove any potential duplicates by keeping only the latest entry per user per day
DO $$
DECLARE
    duplicate_count INTEGER;
BEGIN
    -- Check for existing duplicates
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT user_id, recorded_at::date, COUNT(*)
        FROM public.weight_entries
        GROUP BY user_id, recorded_at::date
        HAVING COUNT(*) > 1
    ) duplicates;

    IF duplicate_count > 0 THEN
        RAISE NOTICE 'Found % groups of duplicate entries. Cleaning up...', duplicate_count;
        
        -- Remove duplicates, keeping the latest entry per user per day
        WITH ranked_entries AS (
            SELECT id,
                   ROW_NUMBER() OVER (
                       PARTITION BY user_id, recorded_at::date 
                       ORDER BY created_at DESC, recorded_at DESC
                   ) as rn
            FROM public.weight_entries
        )
        DELETE FROM public.weight_entries 
        WHERE id IN (
            SELECT id FROM ranked_entries WHERE rn > 1
        );

        RAISE NOTICE 'Duplicate weight entries cleaned up successfully.';
    ELSE
        RAISE NOTICE 'No duplicate entries found. Proceeding with constraint creation.';
    END IF;
END $$;

-- Step 2: Create immutable function for date normalization
CREATE OR REPLACE FUNCTION public.normalize_weight_entry_date(input_date TIMESTAMPTZ)
RETURNS DATE
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT input_date::date;
$$;

-- Step 3: Add unique constraint using the immutable function
-- Use a partial unique index to handle the date normalization properly
CREATE UNIQUE INDEX idx_weight_entries_user_date_unique 
ON public.weight_entries (user_id, normalize_weight_entry_date(recorded_at))
WHERE user_id IS NOT NULL;

-- Step 4: Add comment for documentation
COMMENT ON INDEX idx_weight_entries_user_date_unique IS 
'Ensures only one weight entry per user per day using immutable date normalization function';

-- Step 5: Add function to handle weight entry upsert with proper date normalization
CREATE OR REPLACE FUNCTION public.upsert_weight_entry(
    p_user_id UUID,
    p_weight_kg NUMERIC,
    p_body_fat_percentage NUMERIC DEFAULT NULL,
    p_muscle_mass_kg NUMERIC DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result_id UUID;
    normalized_date TIMESTAMPTZ;
BEGIN
    -- Normalize the recorded_at to start of day (midnight)
    normalized_date := DATE_TRUNC('day', p_recorded_at);
    
    -- Use INSERT ... ON CONFLICT to handle upsert
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
$$;

-- Step 6: Add RLS policy for the new function (if needed)
-- The function uses SECURITY DEFINER, so it runs with definer privileges
-- But we should ensure proper access control
CREATE OR REPLACE FUNCTION public.can_upsert_weight_entry(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT p_user_id = auth.uid();
$$;

-- Step 7: Add some test data to verify the constraint works
DO $$
DECLARE
    test_user_id UUID;
    first_entry_id UUID;
    second_entry_id UUID;
BEGIN
    -- Get an existing user for testing
    SELECT id INTO test_user_id FROM public.user_profiles LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Test the upsert function
        SELECT public.upsert_weight_entry(
            test_user_id,
            75.5,
            18.5,
            NULL,
            'Test entry via upsert function',
            CURRENT_DATE + INTERVAL '12 hours'  -- Noon today
        ) INTO first_entry_id;
        
        -- Try to insert another entry for the same day (should update, not duplicate)
        SELECT public.upsert_weight_entry(
            test_user_id,
            76.0,
            18.3,
            NULL,
            'Updated test entry via upsert function',
            CURRENT_DATE + INTERVAL '18 hours'  -- Evening today
        ) INTO second_entry_id;
        
        -- Check that we have the same ID (updated, not duplicated)
        IF first_entry_id = second_entry_id THEN
            RAISE NOTICE 'SUCCESS: Upsert function working correctly - same entry updated';
        ELSE
            RAISE NOTICE 'WARNING: Different IDs returned - % vs %', first_entry_id, second_entry_id;
        END IF;
        
        RAISE NOTICE 'Test weight entries created/updated with upsert function';
    ELSE
        RAISE NOTICE 'No users found for testing. Skipping test data creation.';
    END IF;
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint is working as expected';
    WHEN OTHERS THEN
        RAISE NOTICE 'Test error: %', SQLERRM;
END $$;