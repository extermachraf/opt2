-- Fix check constraint name mismatch causing food ingredient save errors
-- Error: "meal_foods_item_type_check" constraint violation
-- Root Cause: Old constraint name conflicts with new check_food_source constraint

-- Step 1: Drop the old constraint with the mismatched name
ALTER TABLE public.meal_foods
DROP CONSTRAINT IF EXISTS meal_foods_item_type_check;

-- Step 2: Drop the current constraint to recreate it properly
ALTER TABLE public.meal_foods
DROP CONSTRAINT IF EXISTS check_food_source;

-- Step 3: Recreate the constraint with correct logic for all three food sources
-- This ensures exactly ONE of the three food source columns is non-null
ALTER TABLE public.meal_foods
ADD CONSTRAINT check_food_source CHECK (
    -- Only food_item_id is set
    (food_item_id IS NOT NULL AND food_ingredient_code IS NULL AND recipe_id IS NULL) OR
    -- Only food_ingredient_code is set
    (food_item_id IS NULL AND food_ingredient_code IS NOT NULL AND recipe_id IS NULL) OR
    -- Only recipe_id is set
    (food_item_id IS NULL AND food_ingredient_code IS NULL AND recipe_id IS NOT NULL)
);

-- Step 4: Add helpful comment to document the fix
COMMENT ON CONSTRAINT check_food_source ON public.meal_foods IS 
'Ensures exactly one food source is specified: food_item_id, food_ingredient_code, or recipe_id. 
This constraint fixes the meal_foods_item_type_check error when adding food ingredients to meals.';