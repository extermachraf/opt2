-- Location: supabase/migrations/20250109142254_update_upsert_weight_entry_function.sql
-- Schema Analysis: Updating existing upsert_weight_entry function to handle new body metrics fields
-- Integration Type: Enhancement - Extending existing function with new parameters
-- Dependencies: upsert_weight_entry function (already exists), weight_entries table with new columns

-- Update the existing upsert_weight_entry function to handle the new body metrics fields
CREATE OR REPLACE FUNCTION public.upsert_weight_entry(
    p_user_id UUID,
    p_weight_kg NUMERIC,
    p_body_fat_percentage NUMERIC DEFAULT NULL,
    p_muscle_mass_kg NUMERIC DEFAULT NULL,
    p_waist_circumference_cm NUMERIC DEFAULT NULL,
    p_hip_circumference_cm NUMERIC DEFAULT NULL,
    p_lean_mass_kg NUMERIC DEFAULT NULL,
    p_fat_mass_kg NUMERIC DEFAULT NULL,
    p_cellular_mass_kg NUMERIC DEFAULT NULL,
    p_phase_angle_degrees NUMERIC DEFAULT NULL,
    p_hand_grip_strength_kg NUMERIC DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    entry_id UUID;
    normalized_date DATE;
BEGIN
    -- Normalize the recorded_at to date only (remove time component)
    normalized_date := p_recorded_at::DATE;
    
    -- Try to find existing entry for this user and date
    SELECT id INTO entry_id
    FROM public.weight_entries
    WHERE user_id = p_user_id 
    AND recorded_at::DATE = normalized_date;
    
    IF entry_id IS NOT NULL THEN
        -- Update existing entry with all provided values
        UPDATE public.weight_entries
        SET 
            weight_kg = p_weight_kg,
            body_fat_percentage = p_body_fat_percentage,
            muscle_mass_kg = p_muscle_mass_kg,
            waist_circumference_cm = p_waist_circumference_cm,
            hip_circumference_cm = p_hip_circumference_cm,
            lean_mass_kg = p_lean_mass_kg,
            fat_mass_kg = p_fat_mass_kg,
            cellular_mass_kg = p_cellular_mass_kg,
            phase_angle_degrees = p_phase_angle_degrees,
            hand_grip_strength_kg = p_hand_grip_strength_kg,
            notes = p_notes,
            created_at = CURRENT_TIMESTAMP
        WHERE id = entry_id;
        
        RETURN entry_id;
    ELSE
        -- Insert new entry with all fields
        INSERT INTO public.weight_entries (
            user_id,
            weight_kg,
            body_fat_percentage,
            muscle_mass_kg,
            waist_circumference_cm,
            hip_circumference_cm,
            lean_mass_kg,
            fat_mass_kg,
            cellular_mass_kg,
            phase_angle_degrees,
            hand_grip_strength_kg,
            notes,
            recorded_at,
            created_at
        ) VALUES (
            p_user_id,
            p_weight_kg,
            p_body_fat_percentage,
            p_muscle_mass_kg,
            p_waist_circumference_cm,
            p_hip_circumference_cm,
            p_lean_mass_kg,
            p_fat_mass_kg,
            p_cellular_mass_kg,
            p_phase_angle_degrees,
            p_hand_grip_strength_kg,
            p_notes,
            normalized_date,
            CURRENT_TIMESTAMP
        ) RETURNING id INTO entry_id;
        
        RETURN entry_id;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in upsert_weight_entry: %', SQLERRM;
END;
$$;

-- Ensure proper permissions for the function
GRANT EXECUTE ON FUNCTION public.upsert_weight_entry TO authenticated;

-- Comment on the updated function
COMMENT ON FUNCTION public.upsert_weight_entry IS 'Enhanced function to upsert weight entries with all extended body composition metrics including waist/hip circumference, lean/fat/cellular mass, phase angle, and hand grip strength';