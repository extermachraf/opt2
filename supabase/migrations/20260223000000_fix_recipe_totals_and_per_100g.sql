-- Location: supabase/migrations/20260223000000_fix_recipe_totals_and_per_100g.sql
-- Purpose: Fix recipe totals and per_100g calculations
-- Issue: Recipe totals (total_calories, total_weight_g, calories_per_100g) don't match
--        the sum of their ingredients
-- Formula:
--   total_calories = SUM(ingredient calories)
--   total_weight_g = SUM(ingredient weight_grams)
--   calories_per_100g = (total_calories / total_weight_g) * 100
--   Same logic for protein, carbs, fat, fiber

-- =============================================
-- STEP 1: Recalculate all recipe totals
-- =============================================

UPDATE recipes r
SET
    total_weight_g = COALESCE(ing_totals.total_weight, 0),
    total_calories = COALESCE(ing_totals.total_calories, 0),
    total_protein_g = COALESCE(ing_totals.total_protein, 0),
    total_carbs_g = COALESCE(ing_totals.total_carbs, 0),
    total_fat_g = COALESCE(ing_totals.total_fat, 0),
    total_fiber_g = COALESCE(ing_totals.total_fiber, 0),
    -- Calculate calories per 100g (only this column exists in the table)
    calories_per_100g = CASE
        WHEN COALESCE(ing_totals.total_weight, 0) > 0
        THEN ROUND((COALESCE(ing_totals.total_calories, 0) / ing_totals.total_weight * 100)::numeric, 0)
        ELSE 0
    END
FROM (
    SELECT
        recipe_id,
        SUM(weight_grams) as total_weight,
        ROUND(SUM(COALESCE(calories, 0))::numeric, 0) as total_calories,
        ROUND(SUM(COALESCE(protein_g, 0))::numeric, 2) as total_protein,
        ROUND(SUM(COALESCE(carbs_g, 0))::numeric, 2) as total_carbs,
        ROUND(SUM(COALESCE(fat_g, 0))::numeric, 2) as total_fat,
        ROUND(SUM(COALESCE(fiber_g, 0))::numeric, 2) as total_fiber
    FROM recipe_ingredients
    GROUP BY recipe_id
) ing_totals
WHERE r.id = ing_totals.recipe_id;

-- =============================================
-- STEP 2: Delete "fake recipes" (single ingredients with no actual recipe ingredients)
-- These are items like "Aceto", "Burro", "Patate" etc that were incorrectly imported
-- =============================================

-- First identify recipes with no ingredients
DELETE FROM recipes
WHERE id NOT IN (
    SELECT DISTINCT recipe_id FROM recipe_ingredients
);

-- =============================================
-- STEP 3: Add comments to track this fix
-- =============================================

COMMENT ON TABLE recipes IS 'Recipes with corrected nutrition totals. total_calories/protein/etc = sum of ingredients. per_100g values = (total / total_weight_g) * 100. Fixed on 2026-02-23.';

