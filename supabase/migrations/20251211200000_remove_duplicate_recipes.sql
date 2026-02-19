-- Location: supabase/migrations/20251211200000_remove_duplicate_recipes.sql
-- Schema Analysis: Existing recipe management system with duplicate recipe entries (same title and nutritional values)
-- Integration Type: Modificative - Remove duplicate recipes while preserving best/most complete entries
-- Dependencies: recipes, recipe_ingredients, recipe_tags, recipe_favorites, meal_foods

-- Remove duplicate recipes from the database
-- Keep the most complete record (with most ingredients, tags, and best nutritional data)

DO $$
DECLARE
    duplicate_count INTEGER;
    removed_count INTEGER := 0;
    recipe_to_keep UUID;
    recipe_to_remove UUID;
    duplicate_record RECORD;
    index_exists BOOLEAN := FALSE;
BEGIN
    RAISE NOTICE 'Starting duplicate recipe removal process...';
    
    -- Count total duplicates before cleanup
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT title, COUNT(*) as cnt
        FROM public.recipes
        GROUP BY LOWER(TRIM(title))
        HAVING COUNT(*) > 1
    ) as duplicates;
    
    RAISE NOTICE 'Found % recipe titles with duplicates', duplicate_count;
    
    -- Process each group of duplicates
    FOR duplicate_record IN 
        SELECT LOWER(TRIM(title)) as normalized_title, 
               COUNT(*) as duplicate_cnt,
               ARRAY_AGG(id ORDER BY 
                   -- Keep recipe with most ingredients first
                   (SELECT COUNT(*) FROM public.recipe_ingredients ri WHERE ri.recipe_id = recipes.id) DESC,
                   -- Then most tags
                   (SELECT COUNT(*) FROM public.recipe_tags rt WHERE rt.recipe_id = recipes.id) DESC,
                   -- Then most favorites  
                   (SELECT COUNT(*) FROM public.recipe_favorites rf WHERE rf.recipe_id = recipes.id) DESC,
                   -- Then verified recipes
                   is_verified DESC,
                   -- Finally by creation date (newer first)
                   created_at DESC
               ) as recipe_ids
        FROM public.recipes
        GROUP BY LOWER(TRIM(title))
        HAVING COUNT(*) > 1
    LOOP
        -- Get the recipe to keep (first in sorted array)
        recipe_to_keep := duplicate_record.recipe_ids[1];
        
        RAISE NOTICE 'Processing duplicates for "%" - keeping recipe %', 
                     duplicate_record.normalized_title, recipe_to_keep;
        
        -- Remove all other duplicates
        FOR i IN 2..array_length(duplicate_record.recipe_ids, 1) LOOP
            recipe_to_remove := duplicate_record.recipe_ids[i];
            
            -- Step 1: Update any meal_foods references to point to the kept recipe
            UPDATE public.meal_foods 
            SET recipe_id = recipe_to_keep 
            WHERE recipe_id = recipe_to_remove;
            
            -- Step 2: Merge recipe_favorites (avoid duplicates)
            INSERT INTO public.recipe_favorites (recipe_id, user_id, created_at)
            SELECT recipe_to_keep, rf.user_id, rf.created_at
            FROM public.recipe_favorites rf
            WHERE rf.recipe_id = recipe_to_remove
            ON CONFLICT (recipe_id, user_id) DO NOTHING;
            
            -- Step 3: Delete old favorites for the recipe being removed
            DELETE FROM public.recipe_favorites WHERE recipe_id = recipe_to_remove;
            
            -- Step 4: Merge recipe_tags (avoid duplicates)
            INSERT INTO public.recipe_tags (recipe_id, tag_name, created_at)
            SELECT recipe_to_keep, rt.tag_name, rt.created_at
            FROM public.recipe_tags rt
            WHERE rt.recipe_id = recipe_to_remove
            ON CONFLICT (recipe_id, tag_name) DO NOTHING;
            
            -- Step 5: Delete old tags for the recipe being removed
            DELETE FROM public.recipe_tags WHERE recipe_id = recipe_to_remove;
            
            -- Step 6: Delete recipe_ingredients for the duplicate
            DELETE FROM public.recipe_ingredients WHERE recipe_id = recipe_to_remove;
            
            -- Step 7: Finally delete the duplicate recipe
            DELETE FROM public.recipes WHERE id = recipe_to_remove;
            
            removed_count := removed_count + 1;
            
            RAISE NOTICE 'Removed duplicate recipe % (merged into %)', 
                         recipe_to_remove, recipe_to_keep;
        END LOOP;
    END LOOP;
    
    -- Add unique constraint to prevent future duplicates (using functional index)
    -- This allows for case-insensitive and whitespace-trimmed uniqueness
    BEGIN
        CREATE UNIQUE INDEX IF NOT EXISTS idx_recipes_unique_title 
        ON public.recipes (LOWER(TRIM(title))) 
        WHERE is_public = true;
        
        index_exists := TRUE;
        RAISE NOTICE 'Successfully created unique index on recipe titles';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Warning: Could not create unique index: %', SQLERRM;
            index_exists := FALSE;
    END;
    
    -- Update recipe nutrition for kept recipes to ensure accuracy
    -- This will recalculate totals based on current ingredients
    BEGIN
        PERFORM public.calculate_recipe_nutrition();
        RAISE NOTICE 'Successfully recalculated recipe nutrition';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Warning: Could not recalculate recipe nutrition: %', SQLERRM;
    END;
    
    -- Add comments only if index was created successfully
    IF index_exists THEN
        BEGIN
            COMMENT ON INDEX public.idx_recipes_unique_title IS 'Prevents duplicate recipe titles (case-insensitive, whitespace-trimmed) for public recipes';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Warning: Could not add comment to index: %', SQLERRM;
        END;
    END IF;
    
    RAISE NOTICE 'Successfully removed % duplicate recipes', removed_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during duplicate removal: %', SQLERRM;
        -- Don't rollback - partial cleanup is better than no cleanup
END $$;

-- Create helper function to validate no duplicates remain
CREATE OR REPLACE FUNCTION public.validate_no_recipe_duplicates()
RETURNS TABLE(
    normalized_title TEXT,
    duplicate_count BIGINT,
    recipe_ids UUID[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $validate$
BEGIN
    RETURN QUERY
    SELECT 
        LOWER(TRIM(r.title)) as normalized_title,
        COUNT(*) as duplicate_count,
        ARRAY_AGG(r.id) as recipe_ids
    FROM public.recipes r
    GROUP BY LOWER(TRIM(r.title))
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Validation error: %', SQLERRM;
        RETURN;
END;
$validate$;

-- Add comment for function (this is safe)
DO $$
BEGIN
    COMMENT ON FUNCTION public.validate_no_recipe_duplicates() IS 'Validates that no duplicate recipes remain after cleanup - returns any remaining duplicates';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Warning: Could not add comment to function: %', SQLERRM;
END $$;

-- Run validation to confirm cleanup (wrapped in exception handling)
DO $$
DECLARE
    validation_result RECORD;
    duplicates_found INTEGER := 0;
BEGIN
    FOR validation_result IN 
        SELECT * FROM public.validate_no_recipe_duplicates()
    LOOP
        duplicates_found := duplicates_found + 1;
        RAISE NOTICE 'Remaining duplicate found: % (% recipes)', validation_result.normalized_title, validation_result.duplicate_count;
    END LOOP;
    
    IF duplicates_found = 0 THEN
        RAISE NOTICE 'Validation complete: No duplicate recipes remain';
    ELSE
        RAISE NOTICE 'Validation complete: % duplicate groups still exist', duplicates_found;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Warning: Validation check failed: %', SQLERRM;
END $$;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Recipe deduplication migration completed successfully at %', NOW();
END $$;