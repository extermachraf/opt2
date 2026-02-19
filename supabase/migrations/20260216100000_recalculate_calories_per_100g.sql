-- Location: supabase/migrations/20260216100000_recalculate_calories_per_100g.sql
-- Purpose: Recalculate calories_per_100g for all recipes based on total_calories and total_weight_g
-- Issue: calories_per_100g values are incorrect - need to use formula: (total_calories / total_weight_g) * 100
-- Impact: All recipes with total_weight_g > 0

DO $$
DECLARE
    recipe_record RECORD;
    calculated_per_100g INTEGER;
    updated_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting calories_per_100g recalculation...';
    
    -- Loop through all recipes that have total_weight_g
    FOR recipe_record IN 
        SELECT id, title, total_calories, total_weight_g, calories_per_100g
        FROM public.recipes 
        WHERE total_weight_g > 0
        ORDER BY title
    LOOP
        -- Calculate correct calories per 100g
        calculated_per_100g := ROUND((recipe_record.total_calories::NUMERIC / recipe_record.total_weight_g) * 100);
        
        -- Update if different from current value
        IF calculated_per_100g != COALESCE(recipe_record.calories_per_100g, 0) THEN
            UPDATE public.recipes
            SET calories_per_100g = calculated_per_100g
            WHERE id = recipe_record.id;
            
            RAISE NOTICE 'Updated: % | Total: % kcal, Weight: % g | Old: % kcal/100g → New: % kcal/100g',
                recipe_record.title,
                recipe_record.total_calories,
                recipe_record.total_weight_g,
                COALESCE(recipe_record.calories_per_100g, 0),
                calculated_per_100g;
            
            updated_count := updated_count + 1;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Recalculation complete! Updated % recipes', updated_count;
    
    -- Show summary statistics
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '- Total recipes with weight data: %', (SELECT COUNT(*) FROM public.recipes WHERE total_weight_g > 0);
    RAISE NOTICE '- Recipes updated: %', updated_count;
    RAISE NOTICE '- Recipes unchanged: %', (SELECT COUNT(*) FROM public.recipes WHERE total_weight_g > 0) - updated_count;
END;
$$;

-- Add comment to track this fix
COMMENT ON COLUMN public.recipes.calories_per_100g IS 'Calories per 100g calculated as (total_calories / total_weight_g) * 100. Recalculated on 2026-02-16.';

