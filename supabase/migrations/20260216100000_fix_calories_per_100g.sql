-- Fix calories_per_100g calculation for all recipes
-- Issue: calories_per_100g is incorrect (e.g., Lasagne shows 59 instead of 156)
-- Correct formula: (total_calories / total_weight_g) * 100

DO $$
DECLARE
    updated_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Fixing calories_per_100g for all recipes...';
    
    -- Update all recipes that have total_weight_g > 0
    UPDATE public.recipes
    SET calories_per_100g = ROUND((total_calories::NUMERIC / total_weight_g) * 100)
    WHERE total_weight_g > 0 AND total_weight_g IS NOT NULL;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    
    RAISE NOTICE 'Updated % recipes with correct calories_per_100g', updated_count;
END;
$$;

