-- Location: supabase/migrations/20251005040821_add_recipe_support_to_meals.sql
-- Schema Analysis: meal_foods table exists with food_item_id, adding recipe support
-- Integration Type: extension - adding recipe support to existing meal system
-- Dependencies: meal_foods, recipes, meal_entries tables

-- Add recipe_id column to meal_foods table to support recipes in meal entries
ALTER TABLE public.meal_foods
ADD COLUMN recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE;

-- Create index for the new recipe_id column for optimal query performance  
CREATE INDEX idx_meal_foods_recipe_id ON public.meal_foods(recipe_id);

-- Add constraint to ensure either food_item_id OR recipe_id is provided (but not both)
ALTER TABLE public.meal_foods
ADD CONSTRAINT meal_foods_item_type_check 
CHECK (
    (food_item_id IS NOT NULL AND recipe_id IS NULL) OR 
    (food_item_id IS NULL AND recipe_id IS NOT NULL)
);

-- Update RLS policies to include recipe access
-- The existing policy should already cover recipe access since it uses meal_entry access
-- But let's create a helper function to properly handle recipe access in meal foods

CREATE OR REPLACE FUNCTION public.can_access_meal_food_with_recipe(meal_food_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.meal_foods mf
    JOIN public.meal_entries me ON mf.meal_entry_id = me.id
    WHERE mf.id = meal_food_id 
    AND me.user_id = auth.uid()
)
$$;

-- Update the existing RLS policy to use the enhanced function
DROP POLICY IF EXISTS "users_access_own_meal_foods" ON public.meal_foods;

CREATE POLICY "users_access_own_meal_foods"
ON public.meal_foods
FOR ALL
TO authenticated  
USING (public.can_access_meal_food_with_recipe(id))
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.meal_entries me
        WHERE me.id = meal_entry_id 
        AND me.user_id = auth.uid()
    )
);