-- Location: supabase/migrations/20250930184814_add_body_metrics_sample_data.sql
-- Schema Analysis: weight_entries, user_profiles tables exist
-- Integration Type: additive data enhancement
-- Dependencies: weight_entries, user_profiles, medical_profiles

-- Add sample weight entries across different time periods for better filter demonstration
-- This migration adds realistic body metrics data spread across 6 months
-- to make date filtering more visible and effective

DO $$
DECLARE
    demo_user_id UUID;
    yassine_user_id UUID;
    start_weight NUMERIC := 78.0;
    current_weight NUMERIC;
    weight_variation NUMERIC;
    entry_date TIMESTAMPTZ;
    body_fat NUMERIC := 19.0;
    muscle_mass NUMERIC := 32.0;
    i INTEGER;
BEGIN
    -- Get existing user IDs from sample data
    SELECT id INTO demo_user_id FROM public.user_profiles WHERE email = 'demo@nutrivita.com' LIMIT 1;
    SELECT id INTO yassine_user_id FROM public.user_profiles WHERE email = 'yassine05kher@gmail.com' LIMIT 1;
    
    -- Only proceed if we have users to work with
    IF demo_user_id IS NOT NULL THEN
        -- Add weight entries for demo user spanning 6 months
        -- This creates a realistic weight loss journey
        FOR i IN 1..180 LOOP
            -- Calculate entry date (180 days ago to now)
            entry_date := NOW() - INTERVAL '1 day' * (180 - i);
            
            -- Skip some days to create realistic gaps
            CONTINUE WHEN (i % 3 = 0 AND i % 7 != 0); -- Skip every 3rd day except weekly entries
            
            -- Calculate realistic weight progression (gradual loss)
            current_weight := start_weight - (i * 0.02) + (random() * 0.4 - 0.2); -- Small daily variations
            
            -- Ensure weight doesn't go too low
            current_weight := GREATEST(current_weight, 70.0);
            
            -- Calculate corresponding body fat percentage and muscle mass
            body_fat := GREATEST(19.0 - (i * 0.01), 12.0);
            muscle_mass := LEAST(32.0 + (i * 0.005), 35.0);
            
            -- Insert weight entry
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
                demo_user_id,
                ROUND(current_weight, 1),
                ROUND(body_fat, 1),
                ROUND(muscle_mass, 1),
                CASE 
                    WHEN i % 20 = 0 THEN 'Controllo mensile - progressi costanti'
                    WHEN i % 14 = 0 THEN 'Misurazione settimanale'
                    WHEN current_weight < start_weight - 2 THEN 'Ottimi progressi!'
                    WHEN random() > 0.8 THEN 'Giornata di allenamento intenso'
                    ELSE NULL
                END,
                entry_date,
                entry_date
            );
        END LOOP;
    END IF;
    
    -- Add entries for second user if available
    IF yassine_user_id IS NOT NULL THEN
        -- Add more recent entries for the second user (last 60 days)
        start_weight := 72.5;
        body_fat := 16.0;
        muscle_mass := 34.0;
        
        FOR i IN 1..60 LOOP
            entry_date := NOW() - INTERVAL '1 day' * (60 - i);
            
            -- Skip some days for realistic gaps
            CONTINUE WHEN (i % 4 = 0); -- Skip every 4th day
            
            -- Calculate weight with different pattern (muscle gain)
            current_weight := start_weight + (i * 0.015) + (random() * 0.3 - 0.15);
            current_weight := LEAST(current_weight, 76.0); -- Cap the weight gain
            
            -- Adjust body fat and muscle mass for muscle gain scenario
            body_fat := GREATEST(16.0 - (i * 0.008), 13.0);
            muscle_mass := LEAST(34.0 + (i * 0.012), 37.5);
            
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
                yassine_user_id,
                ROUND(current_weight, 1),
                ROUND(body_fat, 1),
                ROUND(muscle_mass, 1),
                CASE 
                    WHEN i % 15 = 0 THEN 'Fase di massa muscolare - risultati positivi'
                    WHEN i % 7 = 0 THEN 'Controllo settimanale crescita muscolare'
                    WHEN current_weight > start_weight + 1 THEN 'Aumento massa magra come previsto'
                    ELSE NULL
                END,
                entry_date,
                entry_date
            );
        END LOOP;
    END IF;
    
    -- Add some medical profile data to ensure height is available for BMI calculation
    IF demo_user_id IS NOT NULL THEN
        INSERT INTO public.medical_profiles (
            user_id,
            height_cm,
            current_weight_kg,
            target_weight_kg,
            activity_level,
            goal_type,
            created_at,
            updated_at
        )
        VALUES (
            demo_user_id,
            175.0, -- 175 cm height
            76.0,  -- Current weight (will be updated by latest entry)
            72.0,  -- Target weight
            'moderately_active',
            'weight_loss',
            NOW(),
            NOW()
        )
        ON CONFLICT (user_id) 
        DO UPDATE SET
            height_cm = EXCLUDED.height_cm,
            activity_level = EXCLUDED.activity_level,
            goal_type = EXCLUDED.goal_type,
            updated_at = NOW();
    END IF;
    
    IF yassine_user_id IS NOT NULL THEN
        INSERT INTO public.medical_profiles (
            user_id,
            height_cm,
            current_weight_kg,
            target_weight_kg,
            activity_level,
            goal_type,
            created_at,
            updated_at
        )
        VALUES (
            yassine_user_id,
            180.0, -- 180 cm height
            74.0,  -- Current weight
            78.0,  -- Target weight (muscle gain)
            'very_active',
            'muscle_gain',
            NOW(),
            NOW()
        )
        ON CONFLICT (user_id)
        DO UPDATE SET
            height_cm = EXCLUDED.height_cm,
            activity_level = EXCLUDED.activity_level,
            goal_type = EXCLUDED.goal_type,
            updated_at = NOW();
    END IF;

    RAISE NOTICE 'Added body metrics sample data spanning 6 months for better filter demonstration';
    RAISE NOTICE 'Users can now see meaningful differences when switching between date ranges';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding sample data: %', SQLERRM;
        -- Don't fail the migration, just log the error
END $$;

-- Add helpful comment
COMMENT ON TABLE public.weight_entries IS 'Weight tracking entries with sample data spanning multiple time periods for effective date filtering';
COMMENT ON TABLE public.medical_profiles IS 'Medical profiles with height and goal information for BMI calculations';