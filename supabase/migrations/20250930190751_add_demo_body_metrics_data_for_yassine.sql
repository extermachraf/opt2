-- Location: supabase/migrations/20250930190751_add_demo_body_metrics_data_for_yassine.sql
-- Schema Analysis: Existing schema with user_profiles, weight_entries, and medical_profiles tables
-- Integration Type: Additive - Adding demo data for specific user account
-- Dependencies: user_profiles, weight_entries, medical_profiles tables

-- Add comprehensive body metrics demo data for yassine00kriouet@gmail.com account
DO $$
DECLARE
    target_user_id UUID;
    entry_date DATE;
    weight_value NUMERIC;
    bmi_value NUMERIC;
    body_fat NUMERIC;
    muscle_mass NUMERIC;
    day_offset INTEGER;
BEGIN
    -- Find the user ID for yassine00kriouet@gmail.com
    SELECT id INTO target_user_id 
    FROM public.user_profiles 
    WHERE email = 'yassine00kriouet@gmail.com';
    
    -- If user exists, create comprehensive demo data
    IF target_user_id IS NOT NULL THEN
        
        -- Create/update medical profile with height for BMI calculations
        INSERT INTO public.medical_profiles (
            user_id, 
            height_cm, 
            current_weight_kg,
            target_weight_kg,
            goal_type,
            gender_at_birth,
            activity_level,
            target_daily_calories,
            target_protein_g,
            target_carbs_g,
            target_fat_g,
            bmr_calories
        ) VALUES (
            target_user_id,
            175.0, -- 175 cm height
            82.5,  -- Current weight
            75.0,  -- Target weight
            'weight_loss'::public.goal_type,
            'male'::public.gender,
            'moderately_active'::public.activity_level,
            2000,  -- Daily calorie target
            120,   -- Protein target in grams
            250,   -- Carbs target in grams
            67,    -- Fat target in grams
            1680   -- BMR calories
        )
        ON CONFLICT (user_id) 
        DO UPDATE SET
            height_cm = EXCLUDED.height_cm,
            current_weight_kg = EXCLUDED.current_weight_kg,
            target_weight_kg = EXCLUDED.target_weight_kg,
            goal_type = EXCLUDED.goal_type,
            updated_at = CURRENT_TIMESTAMP;

        -- Generate weight entries for the past 6 months (182 days) with realistic progression
        FOR day_offset IN 0..181 LOOP
            entry_date := CURRENT_DATE - day_offset;
            
            -- Calculate realistic weight loss progression (starting higher, trending down)
            weight_value := 85.0 - (day_offset * 0.015) + (RANDOM() * 0.8 - 0.4); -- Gradual loss with random variation
            
            -- Calculate BMI based on height (175 cm) and current weight
            bmi_value := weight_value / POWER(1.75, 2);
            
            -- Calculate body fat percentage (decreasing over time)
            body_fat := 22.0 - (day_offset * 0.01) + (RANDOM() * 1.0 - 0.5);
            
            -- Calculate muscle mass (slight increase over time)
            muscle_mass := 28.0 + (day_offset * 0.005) + (RANDOM() * 0.5 - 0.25);
            
            -- Insert weight entry
            INSERT INTO public.weight_entries (
                user_id,
                weight_kg,
                body_fat_percentage,
                muscle_mass_kg,
                recorded_at,
                notes
            ) VALUES (
                target_user_id,
                ROUND(weight_value, 1),
                ROUND(body_fat, 1),
                ROUND(muscle_mass, 1),
                entry_date + INTERVAL '8 hours', -- Morning weigh-ins
                CASE 
                    WHEN day_offset % 30 = 0 THEN 'Monthly check-in - staying consistent!'
                    WHEN day_offset % 14 = 0 THEN 'Bi-weekly progress check'
                    WHEN day_offset % 7 = 0 THEN 'Weekly weigh-in'
                    WHEN weight_value < 80.0 THEN 'Great progress, feeling lighter!'
                    WHEN weight_value > 83.0 THEN 'Need to stay focused on diet'
                    WHEN RANDOM() > 0.7 THEN 'Post-workout measurement'
                    ELSE NULL
                END
            );
        END LOOP;

        -- Add some specific milestone entries with detailed notes
        INSERT INTO public.weight_entries (
            user_id,
            weight_kg,
            body_fat_percentage,
            muscle_mass_kg,
            recorded_at,
            notes
        ) VALUES
            (target_user_id, 85.2, 22.8, 27.5, CURRENT_DATE - INTERVAL '180 days', 'Starting my weight loss journey today! Feeling motivated.'),
            (target_user_id, 83.1, 21.2, 28.1, CURRENT_DATE - INTERVAL '150 days', 'One month in - seeing good progress with diet changes.'),
            (target_user_id, 81.5, 20.5, 28.5, CURRENT_DATE - INTERVAL '120 days', 'Halfway to goal! Adding more cardio to routine.'),
            (target_user_id, 80.2, 19.8, 28.8, CURRENT_DATE - INTERVAL '90 days', 'Three months of consistency paying off!'),
            (target_user_id, 78.9, 18.9, 29.2, CURRENT_DATE - INTERVAL '60 days', 'Almost at target weight, feeling great!'),
            (target_user_id, 77.8, 18.2, 29.5, CURRENT_DATE - INTERVAL '30 days', 'New personal best! Muscle mass increasing.'),
            (target_user_id, 76.5, 17.8, 29.8, CURRENT_DATE - INTERVAL '7 days', 'Last week - very close to goal weight!'),
            (target_user_id, 75.8, 17.5, 30.0, CURRENT_DATE, 'Today - Almost reached my target! Feeling fantastic.');

        RAISE NOTICE 'Successfully added comprehensive body metrics demo data for user: yassine00kriouet@gmail.com';
        RAISE NOTICE 'Created % weight entries spanning 6 months', (182 + 8)::text;
        RAISE NOTICE 'Weight progression: 85.2 kg → 75.8 kg (9.4 kg loss)';
        RAISE NOTICE 'Body fat reduction: 22.8%% → 17.5%% (5.3%% decrease)';
        RAISE NOTICE 'Muscle mass gain: 27.5 kg → 30.0 kg (2.5 kg increase)';
        
    ELSE
        RAISE NOTICE 'User with email yassine00kriouet@gmail.com not found in user_profiles table';
    END IF;
    
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Some weight entries already exist, skipping duplicates';
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: User may not exist or data integrity issue';
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error while adding demo data: %', SQLERRM;
END $$;