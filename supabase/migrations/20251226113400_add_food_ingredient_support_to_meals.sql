-- Location: supabase/migrations/20251226113400_add_food_ingredient_support_to_meals.sql
-- Schema Analysis: Existing meal_foods table references food_items with UUID foreign key
-- Integration Type: Extension - Add support for Food Ingredients table references
-- Dependencies: meal_foods, food_items, "Food Ingredients"
-- Fix: Add unique constraint on "Codice Alimento" to allow foreign key reference

-- Step 1: Add unique constraint on "Codice Alimento" to enable foreign key reference
-- This is necessary because the table has a composite primary key but we only want to reference one column
ALTER TABLE public."Food Ingredients"
ADD CONSTRAINT "unique_codice_alimento" UNIQUE ("Codice Alimento");

-- Step 2: Add new column to meal_foods to support Food Ingredients table
ALTER TABLE public.meal_foods
ADD COLUMN IF NOT EXISTS food_ingredient_code TEXT;

-- Step 3: Add foreign key constraint now that unique constraint exists
ALTER TABLE public.meal_foods
ADD CONSTRAINT fk_food_ingredient_code 
FOREIGN KEY (food_ingredient_code) 
REFERENCES public."Food Ingredients"("Codice Alimento") 
ON DELETE SET NULL;

-- Step 4: Add index for the new column to improve query performance
CREATE INDEX IF NOT EXISTS idx_meal_foods_food_ingredient_code 
ON public.meal_foods(food_ingredient_code);

-- Step 5: Add check constraint to ensure either food_item_id, food_ingredient_code, or recipe_id is set (but not multiple)
ALTER TABLE public.meal_foods
DROP CONSTRAINT IF EXISTS check_food_source;

ALTER TABLE public.meal_foods
ADD CONSTRAINT check_food_source CHECK (
    (food_item_id IS NOT NULL AND food_ingredient_code IS NULL AND recipe_id IS NULL) OR
    (food_item_id IS NULL AND food_ingredient_code IS NOT NULL AND recipe_id IS NULL) OR
    (food_item_id IS NULL AND food_ingredient_code IS NULL AND recipe_id IS NOT NULL)
);

-- Step 6: Update RLS policies to handle all food types
DROP POLICY IF EXISTS "users_access_own_meal_foods" ON public.meal_foods;

CREATE POLICY "users_access_own_meal_foods"
ON public.meal_foods
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.meal_entries me
        WHERE me.id = meal_foods.meal_entry_id
        AND me.user_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.meal_entries me
        WHERE me.id = meal_foods.meal_entry_id
        AND me.user_id = auth.uid()
    )
);

-- Step 7: Create a helper function to get food data from all three sources
CREATE OR REPLACE FUNCTION public.get_meal_food_details(meal_food_uuid UUID)
RETURNS TABLE(
    source_type TEXT,
    food_name TEXT,
    calories_per_100g INTEGER,
    protein_per_100g NUMERIC,
    carbs_per_100g NUMERIC,
    fat_per_100g NUMERIC,
    fiber_per_100g NUMERIC
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN 'food_item'::TEXT
            WHEN mf.food_ingredient_code IS NOT NULL THEN 'food_ingredient'::TEXT
            WHEN mf.recipe_id IS NOT NULL THEN 'recipe'::TEXT
            ELSE 'unknown'::TEXT
        END as source_type,
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN fi.name
            WHEN mf.food_ingredient_code IS NOT NULL THEN fing."Nome Alimento ITA"
            WHEN mf.recipe_id IS NOT NULL THEN r.title
            ELSE 'Unknown'::TEXT
        END as food_name,
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN fi.calories_per_100g
            WHEN mf.food_ingredient_code IS NOT NULL THEN 
                COALESCE(
                    NULLIF(fing."Energia, Ric con fibra (kcal)", 0)::INTEGER,
                    0
                )
            WHEN mf.recipe_id IS NOT NULL THEN 
                CASE 
                    WHEN r.servings > 0 THEN (r.total_calories / r.servings)::INTEGER
                    ELSE 0
                END
            ELSE 0
        END as calories_per_100g,
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN fi.protein_per_100g
            WHEN mf.food_ingredient_code IS NOT NULL THEN 
                COALESCE(
                    NULLIF(fing."Proteine totali", 0)::NUMERIC,
                    0
                )
            WHEN mf.recipe_id IS NOT NULL THEN r.total_protein_g
            ELSE 0
        END as protein_per_100g,
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN fi.carbs_per_100g
            WHEN mf.food_ingredient_code IS NOT NULL THEN
                CASE 
                    WHEN fing."Carboidrati disponibili (MSE)" IS NOT NULL 
                        AND fing."Carboidrati disponibili (MSE)" ~ '^[0-9]+\.?[0-9]*$'
                    THEN fing."Carboidrati disponibili (MSE)"::NUMERIC
                    ELSE 0
                END
            WHEN mf.recipe_id IS NOT NULL THEN r.total_carbs_g
            ELSE 0
        END as carbs_per_100g,
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN fi.fat_per_100g
            WHEN mf.food_ingredient_code IS NOT NULL THEN 
                COALESCE(
                    NULLIF(fing."Lipidi totali", 0)::NUMERIC,
                    0
                )
            WHEN mf.recipe_id IS NOT NULL THEN r.total_fat_g
            ELSE 0
        END as fat_per_100g,
        CASE
            WHEN mf.food_item_id IS NOT NULL THEN fi.fiber_per_100g
            WHEN mf.food_ingredient_code IS NOT NULL THEN
                CASE 
                    WHEN fing."Fibra alimentare totale" IS NOT NULL 
                        AND fing."Fibra alimentare totale" ~ '^[0-9]+\.?[0-9]*$'
                    THEN fing."Fibra alimentare totale"::NUMERIC
                    ELSE 0
                END
            WHEN mf.recipe_id IS NOT NULL THEN r.total_fiber_g
            ELSE 0
        END as fiber_per_100g
    FROM public.meal_foods mf
    LEFT JOIN public.food_items fi ON mf.food_item_id = fi.id
    LEFT JOIN public."Food Ingredients" fing ON mf.food_ingredient_code = fing."Codice Alimento"
    LEFT JOIN public.recipes r ON mf.recipe_id = r.id
    WHERE mf.id = meal_food_uuid;
END;
$$;

COMMENT ON FUNCTION public.get_meal_food_details IS 'Helper function to retrieve food nutritional data from food_items, Food Ingredients, or recipes tables';

-- Step 8: Add comment to document the fix
COMMENT ON CONSTRAINT "unique_codice_alimento" ON public."Food Ingredients" IS 
'Unique constraint added to enable foreign key references from meal_foods table. Required because Food Ingredients has a composite primary key.';