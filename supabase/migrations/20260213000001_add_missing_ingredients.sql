-- Location: supabase/migrations/20260213000001_add_missing_ingredients.sql
-- Purpose: Add missing ingredients that couldn't be matched during nutrition fix
-- These are ingredients used in recipes but not found in food_ingredients table

-- =============================================
-- ADD MISSING INGREDIENTS TO FOOD_INGREDIENTS
-- =============================================

-- Note: Some ingredients need to be added manually as they don't exist in BDA database
-- Others exist but with different names and need to be added as aliases

DO $$
BEGIN
    RAISE NOTICE 'Adding missing ingredients to food_ingredients table...';
    
    -- 1. Besciamella (Béchamel sauce) - NOT in BDA, using standard values
    INSERT INTO public.food_ingredients (
        name, italian_name, category, source,
        calories_per_100g, protein_per_100g, fat_per_100g, carbs_per_100g, fiber_per_100g,
        created_at
    ) VALUES (
        'Béchamel sauce', 'Besciamella', 'Prepared foods', 'Custom addition',
        130, 3.5, 9.5, 8.5, 0.2,
        NOW()
    ) ON CONFLICT (italian_name) DO NOTHING;
    
    -- Insert all missing ingredients in one statement
    INSERT INTO public.food_ingredients (
        name, italian_name, category, source,
        calories_per_100g, protein_per_100g, fat_per_100g, carbs_per_100g, fiber_per_100g,
        created_at
    ) VALUES
        ('Pesto Genovese', 'Pesto', 'Prepared foods', 'Custom addition', 466, 5.6, 48.1, 5.3, 1.2, NOW()),
        ('Savoy cabbage', 'Verza', 'Vegetables', 'Custom addition', 24, 2.0, 0.1, 3.5, 2.6, NOW()),
        ('Fresh potato gnocchi', 'Gnocchi freschi di patate', 'Pasta', 'Custom addition', 177, 3.5, 0.5, 37.0, 1.8, NOW()),
        ('Tomato passata', 'Passata di pomodoro', 'Vegetables', 'Custom addition', 36, 1.5, 0.3, 6.8, 1.5, NOW()),
        ('Beef cartilage', 'Nervetti (bovino)', 'Meat', 'Custom addition', 85, 15.0, 2.5, 0.5, 0, NOW()),
        ('Ground beef (lean)', 'Carne trita scelta', 'Meat', 'Custom addition', 155, 20.5, 8.0, 0, 0, NOW()),
        ('Beef burger patty', 'Hamburger da polpa scelta', 'Meat', 'Custom addition', 222, 18.5, 16.0, 0.5, 0, NOW()),
        ('Dry/stale bread', 'Pane secco o raffermo', 'Bread', 'Custom addition', 307, 9.5, 1.5, 64.0, 3.5, NOW()),
        ('Rosetta bread roll', 'Pane tipo rosetta o michetta o tartaruga', 'Bread', 'Custom addition', 275, 9.0, 1.9, 57.6, 3.1, NOW()),
        ('Homemade bread slices', 'Pane casereccio a fette', 'Bread', 'Custom addition', 275, 8.5, 1.0, 58.0, 4.0, NOW()),
        ('Stewed peppers', 'Peperonata', 'Vegetables', 'Custom addition', 67, 1.2, 4.5, 5.8, 1.8, NOW()),
        ('Boiled beans', 'Fagioli lessati', 'Legumes', 'Custom addition', 58, 4.5, 0.3, 9.5, 3.5, NOW())
    ON CONFLICT (italian_name) DO NOTHING;
    
    RAISE NOTICE 'Added 13 custom ingredients to food_ingredients table';
    RAISE NOTICE 'Migration complete!';
END;
$$;

-- Add comment
COMMENT ON TABLE public.food_ingredients IS 'Food ingredients database including BDA items and custom additions. Updated 2026-02-13.';

