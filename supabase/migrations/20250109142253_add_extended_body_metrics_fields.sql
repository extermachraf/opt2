-- Location: supabase/migrations/20250109142253_add_extended_body_metrics_fields.sql
-- Schema Analysis: Existing weight_entries table with weight_kg, body_fat_percentage, muscle_mass_kg
-- Integration Type: Extension - Adding new body metrics fields to existing table
-- Dependencies: weight_entries table (already exists)

-- Add new body metrics fields to the existing weight_entries table
ALTER TABLE public.weight_entries
ADD COLUMN waist_circumference_cm numeric,
ADD COLUMN hip_circumference_cm numeric,
ADD COLUMN lean_mass_kg numeric,
ADD COLUMN fat_mass_kg numeric,
ADD COLUMN cellular_mass_kg numeric,
ADD COLUMN phase_angle_degrees numeric,
ADD COLUMN hand_grip_strength_kg numeric;

-- Add index for better query performance on the new metrics
CREATE INDEX idx_weight_entries_waist_circumference ON public.weight_entries(waist_circumference_cm);
CREATE INDEX idx_weight_entries_hip_circumference ON public.weight_entries(hip_circumference_cm);
CREATE INDEX idx_weight_entries_lean_mass ON public.weight_entries(lean_mass_kg);

-- Add sample data to existing weight entries to demonstrate the new fields
DO $$
DECLARE
    existing_user_id UUID;
    sample_entry_id UUID;
BEGIN
    -- Get an existing user ID from the weight_entries table
    SELECT user_id INTO existing_user_id FROM public.weight_entries LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Get a recent weight entry to update with sample extended metrics
        SELECT id INTO sample_entry_id 
        FROM public.weight_entries 
        WHERE user_id = existing_user_id 
        ORDER BY recorded_at DESC 
        LIMIT 1;
        
        IF sample_entry_id IS NOT NULL THEN
            -- Update the existing entry with sample extended metrics
            UPDATE public.weight_entries 
            SET 
                waist_circumference_cm = 85.5,
                hip_circumference_cm = 95.2,
                lean_mass_kg = 55.8,
                fat_mass_kg = 18.4,
                cellular_mass_kg = 32.1,
                phase_angle_degrees = 6.8,
                hand_grip_strength_kg = 42.5
            WHERE id = sample_entry_id;
            
            RAISE NOTICE 'Updated existing weight entry with extended body metrics sample data';
        END IF;
        
        -- Insert a new comprehensive entry with all metrics
        INSERT INTO public.weight_entries (
            user_id, weight_kg, body_fat_percentage, muscle_mass_kg,
            waist_circumference_cm, hip_circumference_cm, lean_mass_kg,
            fat_mass_kg, cellular_mass_kg, phase_angle_degrees, hand_grip_strength_kg,
            notes, recorded_at
        ) VALUES (
            existing_user_id,
            76.8,
            19.2,
            48.5,
            84.0,
            94.5,
            56.2,
            17.8,
            31.8,
            7.1,
            43.2,
            'Misurazione completa con tutti i parametri corporei',
            CURRENT_DATE - INTERVAL '1 day'
        );
        
        RAISE NOTICE 'Added new comprehensive weight entry with all extended metrics';
    ELSE
        RAISE NOTICE 'No existing users found. Extended metrics fields added successfully but no sample data inserted.';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Sample data insertion failed: %. Schema modification completed successfully.', SQLERRM;
END $$;

-- Comment on new columns for documentation
COMMENT ON COLUMN public.weight_entries.waist_circumference_cm IS 'Circonferenza vita in centimetri';
COMMENT ON COLUMN public.weight_entries.hip_circumference_cm IS 'Circonferenza fianchi in centimetri';
COMMENT ON COLUMN public.weight_entries.lean_mass_kg IS 'Massa magra in chilogrammi';
COMMENT ON COLUMN public.weight_entries.fat_mass_kg IS 'Massa grassa in chilogrammi';
COMMENT ON COLUMN public.weight_entries.cellular_mass_kg IS 'Massa cellulare in chilogrammi';
COMMENT ON COLUMN public.weight_entries.phase_angle_degrees IS 'Angolo di fase in gradi';
COMMENT ON COLUMN public.weight_entries.hand_grip_strength_kg IS 'Forza di presa della mano in chilogrammi';