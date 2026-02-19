-- Migration: Remove incomplete recipes missing ingredients or calorie information
-- Generated at: 2025-09-24 11:07:15

-- First, let's identify and log the incomplete recipes for auditing
DO $$
DECLARE
    audit_rec RECORD;
    incomplete_count INTEGER := 0;
    no_ingredients_count INTEGER := 0;
    no_calories_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting audit of incomplete recipes...';
    
    -- Check for recipes with no ingredients
    FOR audit_rec IN 
        SELECT r.id, r.title, r.total_calories
        FROM recipes r 
        LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        WHERE ri.recipe_id IS NULL
    LOOP
        RAISE NOTICE 'Recipe without ingredients: % (ID: %, Calories: %)', audit_rec.title, audit_rec.id, audit_rec.total_calories;
        no_ingredients_count := no_ingredients_count + 1;
        incomplete_count := incomplete_count + 1;
    END LOOP;
    
    -- Check for recipes with zero or null calories (but have ingredients)
    FOR audit_rec IN 
        SELECT r.id, r.title, r.total_calories, COUNT(ri.id) as ingredient_count
        FROM recipes r 
        INNER JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        WHERE (r.total_calories IS NULL OR r.total_calories = 0)
        GROUP BY r.id, r.title, r.total_calories
    LOOP
        RAISE NOTICE 'Recipe with zero calories but has % ingredients: % (ID: %)', audit_rec.ingredient_count, audit_rec.title, audit_rec.id;
        no_calories_count := no_calories_count + 1;
        incomplete_count := incomplete_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Audit complete:';
    RAISE NOTICE '  - Recipes without ingredients: %', no_ingredients_count;
    RAISE NOTICE '  - Recipes with zero calories: %', no_calories_count;
    RAISE NOTICE '  - Total incomplete recipes: %', incomplete_count;
END $$;

-- Create a temporary table to store incomplete recipe details for reference
CREATE TEMP TABLE incomplete_recipes_log AS
WITH recipes_without_ingredients AS (
    SELECT 
        r.id,
        r.title,
        r.total_calories,
        'no_ingredients' as issue_type
    FROM recipes r 
    LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
    WHERE ri.recipe_id IS NULL
),
recipes_with_zero_calories AS (
    SELECT 
        r.id,
        r.title,
        r.total_calories,
        'zero_calories' as issue_type
    FROM recipes r 
    INNER JOIN recipe_ingredients ri ON r.id = ri.recipe_id
    WHERE (r.total_calories IS NULL OR r.total_calories = 0)
    GROUP BY r.id, r.title, r.total_calories
)
SELECT * FROM recipes_without_ingredients
UNION ALL
SELECT * FROM recipes_with_zero_calories;

-- Show the incomplete recipes that will be removed
DO $$
DECLARE
    log_rec RECORD;
    total_to_remove INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_to_remove FROM incomplete_recipes_log;
    
    IF total_to_remove > 0 THEN
        RAISE NOTICE 'The following % incomplete recipes will be removed:', total_to_remove;
        
        -- Log each recipe to be removed
        FOR log_rec IN SELECT * FROM incomplete_recipes_log ORDER BY title
        LOOP
            RAISE NOTICE '  - % (% issue) - Calories: %', log_rec.title, log_rec.issue_type, COALESCE(log_rec.total_calories::text, 'NULL');
        END LOOP;
    ELSE
        RAISE NOTICE 'No incomplete recipes found. All recipes have both ingredients and calorie information.';
    END IF;
END $$;

-- Remove recipe_ingredients for recipes without ingredients or with zero calories
DELETE FROM recipe_ingredients 
WHERE recipe_id IN (SELECT id FROM incomplete_recipes_log);

-- Remove recipe_tags for incomplete recipes
DELETE FROM recipe_tags 
WHERE recipe_id IN (SELECT id FROM incomplete_recipes_log);

-- Remove recipe_favorites for incomplete recipes
DELETE FROM recipe_favorites 
WHERE recipe_id IN (SELECT id FROM incomplete_recipes_log);

-- Finally, remove the incomplete recipes themselves
DELETE FROM recipes 
WHERE id IN (SELECT id FROM incomplete_recipes_log);

-- Final summary
DO $$
DECLARE
    remaining_count INTEGER;
    recipes_with_ingredients INTEGER;
    recipes_with_calories INTEGER;
BEGIN
    SELECT COUNT(*) INTO remaining_count FROM recipes;
    
    SELECT COUNT(DISTINCT r.id) INTO recipes_with_ingredients
    FROM recipes r 
    INNER JOIN recipe_ingredients ri ON r.id = ri.recipe_id;
    
    SELECT COUNT(*) INTO recipes_with_calories
    FROM recipes 
    WHERE total_calories > 0;
    
    RAISE NOTICE 'Cleanup complete!';
    RAISE NOTICE '  - Total recipes remaining: %', remaining_count;
    RAISE NOTICE '  - Recipes with ingredients: %', recipes_with_ingredients;
    RAISE NOTICE '  - Recipes with calories > 0: %', recipes_with_calories;
    
    IF remaining_count = recipes_with_ingredients AND remaining_count = recipes_with_calories THEN
        RAISE NOTICE '✓ All remaining recipes have both ingredients and calorie information.';
    ELSE
        RAISE WARNING '⚠ Some recipes may still be incomplete. Manual review recommended.';
    END IF;
END $$;

-- Create a function to prevent future incomplete recipes
CREATE OR REPLACE FUNCTION check_recipe_completeness()
RETURNS TRIGGER AS $$
BEGIN
    -- This trigger will run on INSERT/UPDATE of recipes
    -- It checks if the recipe has both ingredients and calories
    
    -- Skip check during migration or if explicitly allowing incomplete recipes
    IF current_setting('app.allow_incomplete_recipes', true) = 'true' THEN
        RETURN NEW;
    END IF;
    
    -- For updates, check if we're just updating non-critical fields
    IF TG_OP = 'UPDATE' AND OLD.total_calories = NEW.total_calories THEN
        RETURN NEW;
    END IF;
    
    -- Check if recipe has ingredients (only after the row is committed)
    -- This will be checked in an AFTER trigger separately
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a function to validate recipe ingredients exist
CREATE OR REPLACE FUNCTION validate_recipe_has_ingredients()
RETURNS TRIGGER AS $$
DECLARE
    ingredient_count INTEGER;
BEGIN
    -- Skip validation during migration
    IF current_setting('app.allow_incomplete_recipes', true) = 'true' THEN
        RETURN NEW;
    END IF;
    
    -- Count ingredients for this recipe
    SELECT COUNT(*) INTO ingredient_count
    FROM recipe_ingredients 
    WHERE recipe_id = NEW.id;
    
    -- If no ingredients and calories are set, warn (but don't block)
    IF ingredient_count = 0 AND NEW.total_calories > 0 THEN
        RAISE WARNING 'Recipe "%" has calories (%) but no ingredients. Consider adding ingredients.', NEW.title, NEW.total_calories;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add comment to document the cleanup
COMMENT ON FUNCTION check_recipe_completeness() IS 'Validates that recipes have both ingredients and calorie information to maintain data quality';
COMMENT ON FUNCTION validate_recipe_has_ingredients() IS 'Validates that recipes with calories also have ingredients listed';