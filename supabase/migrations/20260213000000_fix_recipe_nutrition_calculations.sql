-- Location: supabase/migrations/20260213000000_fix_recipe_nutrition_calculations.sql
-- Purpose: Fix incorrect nutrition calculations in recipe_ingredients and recipes tables
-- Issue: Migration 20250924105400 stored calories_per_100g instead of calculated values
--        and left macronutrients as 0 instead of calculating them
-- Impact: ALL recipes (~175) and ALL recipe ingredients (~1000+)

-- =============================================
-- FIX RECIPE NUTRITION CALCULATIONS
-- =============================================

-- Step 1: Create a temporary function to match ingredient names to food_ingredients
CREATE OR REPLACE FUNCTION public.match_ingredient_to_food(ingredient_name_param TEXT)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    food_id UUID;
BEGIN
    -- Try exact match on italian_name first
    SELECT id INTO food_id
    FROM public.food_ingredients
    WHERE LOWER(TRIM(italian_name)) = LOWER(TRIM(ingredient_name_param))
    LIMIT 1;
    
    IF food_id IS NOT NULL THEN
        RETURN food_id;
    END IF;
    
    -- Try exact match on name
    SELECT id INTO food_id
    FROM public.food_ingredients
    WHERE LOWER(TRIM(name)) = LOWER(TRIM(ingredient_name_param))
    LIMIT 1;
    
    IF food_id IS NOT NULL THEN
        RETURN food_id;
    END IF;
    
    -- Try partial match on italian_name
    SELECT id INTO food_id
    FROM public.food_ingredients
    WHERE LOWER(italian_name) LIKE '%' || LOWER(TRIM(ingredient_name_param)) || '%'
    LIMIT 1;
    
    IF food_id IS NOT NULL THEN
        RETURN food_id;
    END IF;
    
    -- Try partial match on name
    SELECT id INTO food_id
    FROM public.food_ingredients
    WHERE LOWER(name) LIKE '%' || LOWER(TRIM(ingredient_name_param)) || '%'
    LIMIT 1;
    
    RETURN food_id;
END;
$$;

-- Step 2: Update recipe_ingredients with correct calculated values
DO $$
DECLARE
    ingredient_record RECORD;
    food_record RECORD;
    matched_food_id UUID;
    multiplier NUMERIC;
    updated_count INTEGER := 0;
    skipped_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting recipe_ingredients nutrition fix...';
    
    -- Loop through all recipe ingredients
    FOR ingredient_record IN 
        SELECT id, ingredient_name, weight_grams, calories
        FROM public.recipe_ingredients
        ORDER BY id
    LOOP
        -- Try to match ingredient to food_ingredients table
        matched_food_id := public.match_ingredient_to_food(ingredient_record.ingredient_name);
        
        IF matched_food_id IS NOT NULL THEN
            -- Get food nutrition data
            SELECT 
                calories_per_100g,
                protein_per_100g,
                carbs_per_100g,
                fat_per_100g,
                fiber_per_100g
            INTO food_record
            FROM public.food_ingredients
            WHERE id = matched_food_id;
            
            -- Calculate multiplier
            multiplier := ingredient_record.weight_grams / 100.0;
            
            -- Update with correct calculated values
            UPDATE public.recipe_ingredients
            SET
                calories = ROUND((food_record.calories_per_100g * multiplier)::NUMERIC, 2),
                protein_g = ROUND((food_record.protein_per_100g * multiplier)::NUMERIC, 2),
                carbs_g = ROUND((food_record.carbs_per_100g * multiplier)::NUMERIC, 2),
                fat_g = ROUND((food_record.fat_per_100g * multiplier)::NUMERIC, 2),
                fiber_g = ROUND((food_record.fiber_per_100g * multiplier)::NUMERIC, 2)
            WHERE id = ingredient_record.id;
            
            updated_count := updated_count + 1;
            
            IF updated_count % 50 = 0 THEN
                RAISE NOTICE 'Updated % ingredients...', updated_count;
            END IF;
        ELSE
            skipped_count := skipped_count + 1;
            RAISE NOTICE 'Could not match ingredient: % (ID: %)', ingredient_record.ingredient_name, ingredient_record.id;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Recipe ingredients update complete!';
    RAISE NOTICE 'Updated: % ingredients', updated_count;
    RAISE NOTICE 'Skipped: % ingredients (no match found)', skipped_count;
END;
$$;

-- Step 3: Recalculate recipe totals
DO $$
DECLARE
    recipe_record RECORD;
    updated_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting recipe totals recalculation...';
    
    FOR recipe_record IN SELECT id, title FROM public.recipes ORDER BY id
    LOOP
        UPDATE public.recipes
        SET 
            total_calories = COALESCE((
                SELECT ROUND(SUM(calories)::NUMERIC, 0)
                FROM public.recipe_ingredients
                WHERE recipe_id = recipe_record.id
            ), 0),
            total_protein_g = COALESCE((
                SELECT ROUND(SUM(protein_g)::NUMERIC, 2)
                FROM public.recipe_ingredients
                WHERE recipe_id = recipe_record.id
            ), 0),
            total_carbs_g = COALESCE((
                SELECT ROUND(SUM(carbs_g)::NUMERIC, 2)
                FROM public.recipe_ingredients
                WHERE recipe_id = recipe_record.id
            ), 0),
            total_fat_g = COALESCE((
                SELECT ROUND(SUM(fat_g)::NUMERIC, 2)
                FROM public.recipe_ingredients
                WHERE recipe_id = recipe_record.id
            ), 0),
            total_fiber_g = COALESCE((
                SELECT ROUND(SUM(fiber_g)::NUMERIC, 2)
                FROM public.recipe_ingredients
                WHERE recipe_id = recipe_record.id
            ), 0)
        WHERE id = recipe_record.id;
        
        updated_count := updated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Recipe totals recalculation complete!';
    RAISE NOTICE 'Updated: % recipes', updated_count;
END;
$$;

-- Step 4: Clean up temporary function
DROP FUNCTION IF EXISTS public.match_ingredient_to_food(TEXT);

-- Step 5: Add comment to track this fix
COMMENT ON TABLE public.recipe_ingredients IS 'Recipe ingredients with nutrition calculated as (weight_grams/100) × nutrition_per_100g. Fixed on 2026-02-13.';
COMMENT ON TABLE public.recipes IS 'Recipes with totals calculated by summing ingredient values. Fixed on 2026-02-13.';

-- Done!
RAISE NOTICE '========================================';
RAISE NOTICE 'RECIPE NUTRITION FIX COMPLETE!';
RAISE NOTICE '========================================';

