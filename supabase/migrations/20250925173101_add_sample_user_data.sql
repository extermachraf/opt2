-- Migration: Add Sample User Data for First-Time App Loading
-- Ensures app has data to display on dashboard for demo purposes

-- Use existing user ID from database to avoid foreign key constraint violation
-- The user_profiles.id field has a foreign key constraint with auth.users.id
DO $$
DECLARE
    demo_user_id uuid;
BEGIN
    -- Get an existing user ID from user_profiles
    SELECT id INTO demo_user_id 
    FROM public.user_profiles 
    LIMIT 1;
    
    -- Only proceed if we have a user ID
    IF demo_user_id IS NOT NULL THEN
        
        -- Update user profile with demo data (using existing user)
        UPDATE public.user_profiles 
        SET 
            email = 'demo@nutrivita.com',
            full_name = 'Demo User',
            date_of_birth = '1990-01-01'::date,
            gender = 'male'::public.gender,
            role = 'patient'::public.user_role,
            email_verified = true,
            registration_completed = true,
            updated_at = now()
        WHERE id = demo_user_id;
        
        -- Insert sample weight entries for chart data
        INSERT INTO public.weight_entries (
            id,
            user_id,
            weight_kg,
            recorded_at,
            notes
        ) VALUES 
            (gen_random_uuid(), demo_user_id, 75.5, CURRENT_DATE - INTERVAL '30 days', 'Starting weight'),
            (gen_random_uuid(), demo_user_id, 74.8, CURRENT_DATE - INTERVAL '20 days', 'Week 1 progress'),
            (gen_random_uuid(), demo_user_id, 74.2, CURRENT_DATE - INTERVAL '10 days', 'Week 2 progress'),
            (gen_random_uuid(), demo_user_id, 73.9, CURRENT_DATE, 'Current weight')
        ON CONFLICT (id) DO NOTHING;
        
        -- Insert sample meal entries for dashboard display
        INSERT INTO public.meal_entries (
            id,
            user_id,
            meal_type,
            meal_date,
            meal_time,
            notes
        ) VALUES 
            (gen_random_uuid(), demo_user_id, 'breakfast'::public.meal_type, CURRENT_DATE, '08:30:00'::time, 'Healthy breakfast'),
            (gen_random_uuid(), demo_user_id, 'lunch'::public.meal_type, CURRENT_DATE, '12:30:00'::time, 'Balanced lunch'),
            (gen_random_uuid(), demo_user_id, 'dinner'::public.meal_type, CURRENT_DATE, '19:00:00'::time, 'Light dinner')
        ON CONFLICT (id) DO NOTHING;
        
        -- Insert sample food items
        INSERT INTO public.food_items (
            id,
            name,
            calories_per_100g,
            protein_per_100g,
            carbs_per_100g,
            fat_per_100g,
            fiber_per_100g,
            brand,
            created_by
        ) VALUES 
            (gen_random_uuid(), 'Oatmeal', 389, 16.9, 66.3, 6.9, 10.6, 'Generic', demo_user_id),
            (gen_random_uuid(), 'Banana', 89, 1.1, 22.8, 0.3, 2.6, 'Fresh', demo_user_id),
            (gen_random_uuid(), 'Chicken Breast', 165, 31, 0, 3.6, 0, 'Fresh', demo_user_id),
            (gen_random_uuid(), 'Brown Rice', 123, 2.6, 23, 0.9, 1.8, 'Generic', demo_user_id)
        ON CONFLICT (id) DO NOTHING;
        
        -- Insert sample dashboard configuration for the demo user
        INSERT INTO public.dashboard_configurations (
            id,
            user_id,
            layout_config,
            theme_settings,
            is_active,
            created_at
        ) VALUES (
            gen_random_uuid(),
            demo_user_id,
            '{"columns": 2, "compact_mode": false}'::jsonb,
            '{"primary_color": "#4A90E2", "accent_color": "#50E3C2"}'::jsonb,
            true,
            now()
        ) ON CONFLICT (id) DO NOTHING;
        
        -- Insert sample dashboard widgets
        DECLARE
            dashboard_config_id uuid;
        BEGIN
            -- Get the dashboard configuration ID
            SELECT id INTO dashboard_config_id 
            FROM public.dashboard_configurations 
            WHERE user_id = demo_user_id 
            AND is_active = true 
            LIMIT 1;
            
            -- Only proceed if we found the dashboard config
            IF dashboard_config_id IS NOT NULL THEN
                -- Insert sample dashboard widgets
                INSERT INTO public.dashboard_widgets (
                    id,
                    dashboard_config_id,
                    widget_type,
                    title,
                    position_x,
                    position_y,
                    width,
                    height,
                    widget_config,
                    is_visible
                ) VALUES 
                    (gen_random_uuid(), dashboard_config_id, 'kpi_card'::public.dashboard_widget_type, 'Today''s Calories', 0, 0, 1, 1, '{"target": 2000}'::jsonb, true),
                    (gen_random_uuid(), dashboard_config_id, 'weight_tracker'::public.dashboard_widget_type, 'Weight Progress', 1, 0, 1, 1, '{}'::jsonb, true),
                    (gen_random_uuid(), dashboard_config_id, 'meal_summary'::public.dashboard_widget_type, 'Today''s Meals', 0, 1, 2, 1, '{}'::jsonb, true),
                    (gen_random_uuid(), dashboard_config_id, 'chart_line'::public.dashboard_widget_type, 'Weekly Progress', 0, 2, 2, 2, '{"time_range": "weekly"}'::jsonb, true)
                ON CONFLICT (id) DO NOTHING;
            END IF;
        END;
        
--        -- Insert sample recipes for the recipe management feature (using correct column names)
--        INSERT INTO public.recipes (
--            id,
--            title,
--            description,
--            instructions,
--            prep_time_minutes,
--            cook_time_minutes,
--            servings,
--            difficulty,
--            category,
--            image_url,
--            total_calories,
--            total_protein_g,
--            total_carbs_g,
--            total_fat_g,
--            created_by,
--            is_public
--        ) VALUES
--            (gen_random_uuid(), 'Mediterranean Quinoa Bowl', 'A healthy and nutritious quinoa bowl with Mediterranean flavors', 'Cook quinoa, mix with vegetables, add olive oil dressing', 15, 20, 2, 'easy'::public.recipe_difficulty, 'lunch'::public.recipe_category, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400', 420, 15, 65, 12, demo_user_id, true),
--            (gen_random_uuid(), 'Protein Smoothie Bowl', 'A refreshing protein-packed smoothie bowl perfect for breakfast', 'Blend fruits with protein powder, top with nuts and seeds', 10, 0, 1, 'easy'::public.recipe_difficulty, 'breakfast'::public.recipe_category, 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400', 350, 25, 35, 8, demo_user_id, true),
--            (gen_random_uuid(), 'Grilled Salmon with Vegetables', 'Perfectly seasoned grilled salmon with roasted vegetables', 'Season salmon, grill for 6-8 minutes per side, roast vegetables', 20, 25, 2, 'medium'::public.recipe_difficulty, 'dinner'::public.recipe_category, 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400', 485, 35, 15, 28, demo_user_id, true)
--        ON CONFLICT (id) DO NOTHING;
        
        -- Add sample recipe tags
        INSERT INTO public.recipe_tags (
            recipe_id,
            tag_name
        ) 
        SELECT r.id, tag
        FROM public.recipes r
        CROSS JOIN (VALUES ('healthy'), ('protein'), ('mediterranean'), ('quick'), ('nutritious')) AS tags(tag)
        WHERE r.created_by = demo_user_id
        ON CONFLICT (recipe_id, tag_name) DO NOTHING;
        
    END IF;
END $$;

COMMIT;