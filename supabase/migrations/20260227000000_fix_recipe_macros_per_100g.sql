-- Migration: Fix recipe macro calculations
-- Problem: recipe_ingredients stored raw per-100g values from food_ingredients
--          instead of scaling by actual weight_grams.
--          This caused wrong total_protein_g/carbs_g/fat_g/fiber_g in recipes table.
-- Fix:
--   1. Add protein_per_100g / carbs_per_100g / fat_per_100g / fiber_per_100g to recipes
--   2. Recalculate recipe_ingredients macros = food_ingredient.macro_per_100g * weight_grams / 100
--      using case-insensitive exact match, then fuzzy (ILIKE) match as fallback
--   3. Recalculate recipes totals (total_protein_g etc.) from corrected ingredients
--   4. Populate the new per-100g columns on recipes

BEGIN;

-- ============================================================
-- STEP 1: Add per-100g macro columns to recipes (if not exist)
-- ============================================================
ALTER TABLE public.recipes
    ADD COLUMN IF NOT EXISTS protein_per_100g  NUMERIC(8,2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS carbs_per_100g    NUMERIC(8,2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS fat_per_100g      NUMERIC(8,2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS fiber_per_100g    NUMERIC(8,2) DEFAULT 0;

-- ============================================================
-- STEP 2: Fix recipe_ingredients — exact case-insensitive match
-- ============================================================
UPDATE public.recipe_ingredients ri
SET
    calories = ROUND((fi.calories_per_100g * ri.weight_grams / 100.0)::NUMERIC, 2),
    protein_g = ROUND((fi.protein_per_100g  * ri.weight_grams / 100.0)::NUMERIC, 2),
    carbs_g   = ROUND((fi.carbs_per_100g    * ri.weight_grams / 100.0)::NUMERIC, 2),
    fat_g     = ROUND((fi.fat_per_100g      * ri.weight_grams / 100.0)::NUMERIC, 2),
    fiber_g   = ROUND((fi.fiber_per_100g    * ri.weight_grams / 100.0)::NUMERIC, 2)
FROM public.food_ingredients fi
WHERE LOWER(TRIM(ri.ingredient_name)) = LOWER(TRIM(fi.name));

-- ============================================================
-- STEP 3: Fuzzy fallback — for unmatched names try ILIKE
--         Only updates rows whose macros are still all-zero
--         (meaning Step 2 didn't touch them)
-- ============================================================
UPDATE public.recipe_ingredients ri
SET
    calories  = ROUND((fi.calories_per_100g * ri.weight_grams / 100.0)::NUMERIC, 2),
    protein_g = ROUND((fi.protein_per_100g  * ri.weight_grams / 100.0)::NUMERIC, 2),
    carbs_g   = ROUND((fi.carbs_per_100g    * ri.weight_grams / 100.0)::NUMERIC, 2),
    fat_g     = ROUND((fi.fat_per_100g      * ri.weight_grams / 100.0)::NUMERIC, 2),
    fiber_g   = ROUND((fi.fiber_per_100g    * ri.weight_grams / 100.0)::NUMERIC, 2)
FROM (
    SELECT DISTINCT ON (ri2.id)
        ri2.id AS ri_id,
        fi2.calories_per_100g,
        fi2.protein_per_100g,
        fi2.carbs_per_100g,
        fi2.fat_per_100g,
        fi2.fiber_per_100g
    FROM public.recipe_ingredients ri2
    JOIN public.food_ingredients fi2
        ON fi2.name ILIKE '%' || TRIM(ri2.ingredient_name) || '%'
        OR TRIM(ri2.ingredient_name) ILIKE '%' || fi2.name || '%'
    WHERE ri2.protein_g = 0 AND ri2.carbs_g = 0 AND ri2.fat_g = 0
      AND ri2.weight_grams > 0
    ORDER BY ri2.id, LENGTH(fi2.name) ASC  -- prefer shorter (more specific) match
) sub
WHERE ri.id = sub.ri_id;

-- ============================================================
-- STEP 4: Recalculate recipe totals from fixed ingredients
-- ============================================================
UPDATE public.recipes r
SET
    total_calories = COALESCE((
        SELECT ROUND(SUM(ri.calories)::NUMERIC, 0)
        FROM public.recipe_ingredients ri WHERE ri.recipe_id = r.id
    ), 0),
    total_protein_g = COALESCE((
        SELECT ROUND(SUM(ri.protein_g)::NUMERIC, 2)
        FROM public.recipe_ingredients ri WHERE ri.recipe_id = r.id
    ), 0),
    total_carbs_g = COALESCE((
        SELECT ROUND(SUM(ri.carbs_g)::NUMERIC, 2)
        FROM public.recipe_ingredients ri WHERE ri.recipe_id = r.id
    ), 0),
    total_fat_g = COALESCE((
        SELECT ROUND(SUM(ri.fat_g)::NUMERIC, 2)
        FROM public.recipe_ingredients ri WHERE ri.recipe_id = r.id
    ), 0),
    total_fiber_g = COALESCE((
        SELECT ROUND(SUM(ri.fiber_g)::NUMERIC, 2)
        FROM public.recipe_ingredients ri WHERE ri.recipe_id = r.id
    ), 0);

-- ============================================================
-- STEP 5: Populate per-100g columns on recipes
--         protein_per_100g = total_protein_g / total_weight_g * 100
-- ============================================================
UPDATE public.recipes
SET
    calories_per_100g = CASE WHEN total_weight_g > 0
        THEN ROUND((total_calories  / total_weight_g * 100)::NUMERIC, 0) ELSE 0 END,
    protein_per_100g  = CASE WHEN total_weight_g > 0
        THEN ROUND((total_protein_g / total_weight_g * 100)::NUMERIC, 2) ELSE 0 END,
    carbs_per_100g    = CASE WHEN total_weight_g > 0
        THEN ROUND((total_carbs_g   / total_weight_g * 100)::NUMERIC, 2) ELSE 0 END,
    fat_per_100g      = CASE WHEN total_weight_g > 0
        THEN ROUND((total_fat_g     / total_weight_g * 100)::NUMERIC, 2) ELSE 0 END,
    fiber_per_100g    = CASE WHEN total_weight_g > 0
        THEN ROUND((total_fiber_g   / total_weight_g * 100)::NUMERIC, 2) ELSE 0 END;

COMMIT;

