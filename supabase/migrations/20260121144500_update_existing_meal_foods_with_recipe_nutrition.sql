-- Location: supabase/migrations/20260121144500_update_existing_meal_foods_with_recipe_nutrition.sql
-- Purpose: Update existing meal_foods entries that reference recipes with correct nutritional values
-- Generated: 2026-01-21T14:45:00

-- This migration fixes meal_foods entries that were created before recipes had correct nutritional values
-- It recalculates nutrition based on the updated recipe data

DO $$
DECLARE
    meal_food_record RECORD;
    recipe_servings INT;
    recipe_total_calories DOUBLE PRECISION;
    recipe_total_protein DOUBLE PRECISION;
    recipe_total_carbs DOUBLE PRECISION;
    recipe_total_fat DOUBLE PRECISION;
    recipe_total_fiber DOUBLE PRECISION;
    calc_calories_per_serving DOUBLE PRECISION;
    calc_protein_per_serving DOUBLE PRECISION;
    calc_carbs_per_serving DOUBLE PRECISION;
    calc_fat_per_serving DOUBLE PRECISION;
    calc_fiber_per_serving DOUBLE PRECISION;
BEGIN
    RAISE NOTICE 'Updating existing meal_foods entries with correct recipe nutrition...';
    
    -- Loop through all meal_foods that reference recipes
    FOR meal_food_record IN 
        SELECT mf.id, mf.recipe_id, mf.quantity_grams
        FROM public.meal_foods mf
        WHERE mf.recipe_id IS NOT NULL
    LOOP
        -- Get the recipe data using explicit column references
        SELECT 
            r.servings,
            r.total_calories,
            r.total_protein_g,
            r.total_carbs_g,
            r.total_fat_g,
            r.total_fiber_g
        INTO 
            recipe_servings,
            recipe_total_calories,
            recipe_total_protein,
            recipe_total_carbs,
            recipe_total_fat,
            recipe_total_fiber
        FROM public.recipes r
        WHERE r.id = meal_food_record.recipe_id;
        
        -- Skip if recipe not found
        IF NOT FOUND THEN
            RAISE NOTICE 'Recipe not found for meal_food id: %', meal_food_record.id;
            CONTINUE;
        END IF;
        
        -- Get servings (default to 1 if null or 0)
        recipe_servings := COALESCE(NULLIF(recipe_servings, 0), 1);
        
        -- Calculate per serving values
        calc_calories_per_serving := recipe_total_calories / recipe_servings;
        calc_protein_per_serving := recipe_total_protein / recipe_servings;
        calc_carbs_per_serving := recipe_total_carbs / recipe_servings;
        calc_fat_per_serving := recipe_total_fat / recipe_servings;
        calc_fiber_per_serving := recipe_total_fiber / recipe_servings;
        
        -- Update the meal_food entry with correct values
        UPDATE public.meal_foods
        SET 
            calories = calc_calories_per_serving,
            protein_g = calc_protein_per_serving,
            carbs_g = calc_carbs_per_serving,
            fat_g = calc_fat_per_serving,
            fiber_g = calc_fiber_per_serving
        WHERE id = meal_food_record.id;
        
        RAISE NOTICE 'Updated meal_food id: % (recipe: %, calories: %, protein: %g, carbs: %g, fat: %g, fiber: %g)',
            meal_food_record.id,
            meal_food_record.recipe_id,
            calc_calories_per_serving,
            calc_protein_per_serving,
            calc_carbs_per_serving,
            calc_fat_per_serving,
            calc_fiber_per_serving;
    END LOOP;
    
    RAISE NOTICE 'Finished updating meal_foods entries!';
END $$;
