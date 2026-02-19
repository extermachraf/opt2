-- Migration: Add fiber support to meal_foods table and update existing data
-- This enables fiber tracking in the meal diary

-- Add fiber_g column to meal_foods table
ALTER TABLE public.meal_foods 
ADD COLUMN fiber_g NUMERIC DEFAULT 0.0;

-- Add comment for documentation
COMMENT ON COLUMN public.meal_foods.fiber_g IS 'Fiber content in grams for this meal food entry';

-- Update existing meal_foods records to calculate fiber_g based on their food_items or recipes
-- This ensures existing data shows fiber information

-- Update meal_foods entries that reference food_items
UPDATE public.meal_foods 
SET fiber_g = COALESCE(
  (
    SELECT 
      ((meal_foods.quantity_grams / 100.0) * COALESCE(fi.fiber_per_100g, 0))
    FROM public.food_items fi
    WHERE fi.id = meal_foods.food_item_id
  ), 0.0
)
WHERE food_item_id IS NOT NULL;

-- Update meal_foods entries that reference recipes
UPDATE public.meal_foods 
SET fiber_g = COALESCE(
  (
    SELECT 
      CASE 
        WHEN r.servings > 0 THEN
          -- Calculate fiber per serving, then scale by portion (quantity_grams / average_serving_weight)
          (COALESCE(r.total_fiber_g, 0) / r.servings) * (meal_foods.quantity_grams / 250.0)
        ELSE
          -- Fallback if servings is 0
          (COALESCE(r.total_fiber_g, 0) * (meal_foods.quantity_grams / 250.0))
      END
    FROM public.recipes r
    WHERE r.id = meal_foods.recipe_id
  ), 0.0
)
WHERE recipe_id IS NOT NULL;

-- Create index for better query performance on fiber_g column
CREATE INDEX IF NOT EXISTS idx_meal_foods_fiber_g ON public.meal_foods(fiber_g);

-- Update the calculate_recipe_nutrition function to include fiber
CREATE OR REPLACE FUNCTION public.calculate_recipe_nutrition()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.recipes
  SET 
    total_calories = COALESCE(ingredients_totals.total_cal, 0),
    total_protein_g = COALESCE(ingredients_totals.total_prot, 0),
    total_carbs_g = COALESCE(ingredients_totals.total_carbs, 0),
    total_fat_g = COALESCE(ingredients_totals.total_fat, 0),
    total_fiber_g = COALESCE(ingredients_totals.total_fiber, 0),
    updated_at = CURRENT_TIMESTAMP
  FROM (
    SELECT 
      ri.recipe_id,
      SUM(ri.calories) as total_cal,
      SUM(ri.protein_g) as total_prot,
      SUM(ri.carbs_g) as total_carbs,
      SUM(ri.fat_g) as total_fat,
      SUM(ri.fiber_g) as total_fiber
    FROM public.recipe_ingredients ri
    GROUP BY ri.recipe_id
  ) AS ingredients_totals
  WHERE recipes.id = ingredients_totals.recipe_id;
END;
$$;

-- Recalculate all recipe nutrition to ensure fiber totals are correct
SELECT public.calculate_recipe_nutrition();

-- Add constraint to ensure fiber_g is not negative
ALTER TABLE public.meal_foods 
ADD CONSTRAINT meal_foods_fiber_g_non_negative 
CHECK (fiber_g >= 0);

-- Grant necessary permissions
GRANT SELECT, UPDATE ON public.meal_foods TO authenticated;