-- Location: supabase/migrations/20250930185441_add_demo_body_metrics_data.sql
-- Schema Analysis: Existing weight_entries table with demo user account
-- Integration Type: Extension - Adding comprehensive sample data for demo account
-- Dependencies: weight_entries, user_profiles (demo@nutrivita.com user)

-- Add comprehensive weight entries data for demo account to enable effective date filter testing
-- This migration extends existing body metrics functionality with sample data spanning multiple time periods

DO $$
DECLARE
    demo_user_id UUID;
    entry_date TIMESTAMPTZ;
    weight_value NUMERIC;
    body_fat_value NUMERIC;
    muscle_mass_value NUMERIC;
    i INTEGER;
BEGIN
    -- Get demo user ID
    SELECT id INTO demo_user_id 
    FROM public.user_profiles 
    WHERE email = 'demo@nutrivita.com'
    LIMIT 1;

    -- Verify demo user exists
    IF demo_user_id IS NULL THEN
        RAISE EXCEPTION 'Demo user not found. Please ensure demo@nutrivita.com user exists.';
    END IF;

    -- Clear any existing weight entries for demo user to avoid duplicates
    DELETE FROM public.weight_entries WHERE user_id = demo_user_id;

    -- Add comprehensive weight entries spanning different time periods for effective date filter testing
    
    -- 1. Recent entries (last 7 days) - Daily entries
    FOR i IN 0..6 LOOP
        entry_date := CURRENT_TIMESTAMP - (i || ' days')::INTERVAL;
        weight_value := 78.5 + (RANDOM() * 2 - 1); -- 77.5-79.5 kg range
        body_fat_value := 16.0 + (RANDOM() * 2 - 1); -- 15.0-17.0% range
        muscle_mass_value := 32.0 + (RANDOM() * 1 - 0.5); -- 31.5-32.5 kg range
        
        INSERT INTO public.weight_entries (user_id, weight_kg, body_fat_percentage, muscle_mass_kg, recorded_at, notes)
        VALUES (
            demo_user_id,
            ROUND(weight_value, 1),
            ROUND(body_fat_value, 1),
            ROUND(muscle_mass_value, 1),
            entry_date,
            CASE 
                WHEN i = 0 THEN 'Current weight - feeling strong!'
                WHEN i = 1 THEN 'Good progress this week'
                WHEN i = 2 THEN 'Stayed consistent with workouts'
                WHEN i = 3 THEN 'Increased protein intake'
                WHEN i = 4 THEN 'Great gym session yesterday'
                WHEN i = 5 THEN 'Weekend cheat meal - back on track'
                ELSE 'Weekly check-in'
            END
        );
    END LOOP;

    -- 2. Weekly entries for past month (last 4 weeks)
    FOR i IN 1..4 LOOP
        entry_date := CURRENT_TIMESTAMP - (i || ' weeks')::INTERVAL;
        weight_value := 79.0 + (i * 0.3); -- Gradual weight loss trend
        body_fat_value := 17.0 + (i * 0.2);
        muscle_mass_value := 31.8 + (i * 0.1);
        
        INSERT INTO public.weight_entries (user_id, weight_kg, body_fat_percentage, muscle_mass_kg, recorded_at, notes)
        VALUES (
            demo_user_id,
            ROUND(weight_value, 1),
            ROUND(body_fat_value, 1),
            ROUND(muscle_mass_value, 1),
            entry_date,
            CASE 
                WHEN i = 1 THEN 'Weekly weigh-in - on track'
                WHEN i = 2 THEN 'Slow and steady progress'
                WHEN i = 3 THEN 'Started new training routine'
                ELSE 'Monthly progress check'
            END
        );
    END LOOP;

    -- 3. Monthly entries for past 6 months
    FOR i IN 1..6 LOOP
        entry_date := CURRENT_TIMESTAMP - (i || ' months')::INTERVAL;
        weight_value := 80.0 + (i * 0.5); -- Gradual weight loss over months
        body_fat_value := 18.0 + (i * 0.3);
        muscle_mass_value := 31.5 + (i * 0.1);
        
        INSERT INTO public.weight_entries (user_id, weight_kg, body_fat_percentage, muscle_mass_kg, recorded_at, notes)
        VALUES (
            demo_user_id,
            ROUND(weight_value, 1),
            ROUND(body_fat_value, 1),
            ROUND(muscle_mass_value, 1),
            entry_date,
            CASE 
                WHEN i = 1 THEN 'Monthly progress - great results!'
                WHEN i = 2 THEN 'Consistency paying off'
                WHEN i = 3 THEN 'Switched to Mediterranean diet'
                WHEN i = 4 THEN 'Added strength training'
                WHEN i = 5 THEN 'Started fitness journey seriously'
                ELSE 'Initial weight measurement'
            END
        );
    END LOOP;

    -- 4. Quarterly entries for past year
    FOR i IN 1..4 LOOP
        entry_date := CURRENT_TIMESTAMP - (i * 3 || ' months')::INTERVAL;
        weight_value := 82.0 + (i * 0.8); -- Initial higher weight
        body_fat_value := 19.0 + (i * 0.5);
        muscle_mass_value := 31.0 + (i * 0.2);
        
        INSERT INTO public.weight_entries (user_id, weight_kg, body_fat_percentage, muscle_mass_kg, recorded_at, notes)
        VALUES (
            demo_user_id,
            ROUND(weight_value, 1),
            ROUND(body_fat_value, 1),
            ROUND(muscle_mass_value, 1),
            entry_date,
            CASE 
                WHEN i = 1 THEN 'Quarterly review - excellent transformation!'
                WHEN i = 2 THEN 'Mid-year checkpoint'
                WHEN i = 3 THEN 'Spring fitness goals'
                ELSE 'New Year resolution - starting weight'
            END
        );
    END LOOP;

    -- 5. Add some random entries for better data distribution
    FOR i IN 1..10 LOOP
        entry_date := CURRENT_TIMESTAMP - (RANDOM() * 365 || ' days')::INTERVAL;
        weight_value := 78.0 + (RANDOM() * 6); -- 78-84 kg range
        body_fat_value := 15.5 + (RANDOM() * 4); -- 15.5-19.5% range
        muscle_mass_value := 31.0 + (RANDOM() * 2); -- 31-33 kg range
        
        INSERT INTO public.weight_entries (user_id, weight_kg, body_fat_percentage, muscle_mass_kg, recorded_at, notes)
        VALUES (
            demo_user_id,
            ROUND(weight_value, 1),
            ROUND(body_fat_value, 1),
            ROUND(muscle_mass_value, 1),
            entry_date,
            'Random progress check'
        );
    END LOOP;

    RAISE NOTICE 'Successfully added comprehensive body metrics data for demo account spanning multiple time periods.';
    RAISE NOTICE 'Total entries created: %', (7 + 4 + 6 + 4 + 10);
    RAISE NOTICE 'Date range: % to %', 
        (CURRENT_TIMESTAMP - '12 months'::INTERVAL)::DATE, 
        CURRENT_TIMESTAMP::DATE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding demo body metrics data: %', SQLERRM;
        RAISE;
END $$;