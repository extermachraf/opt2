# NUTRITION CALCULATION BUG REPORT
## Client Issue Investigation - NutriVita App

**Date:** 2026-02-13  
**Database:** OPT 2 (jnukglbwreegcluvwgad)  
**Status:** ✅ ROOT CAUSE IDENTIFIED

---

## 🔴 PROBLEM SUMMARY

The client reported two critical issues:

1. **Lasagne Recipe**: Shows incorrect and inconsistent kcal and macronutrient values in "Add Meal" section compared to "Recipes" section. Calories calculated as if each ingredient had a weight of 100g.

2. **Orzo Bollito Recipe**: Shows 0g carbohydrates, while the database ingredient "ORZO, PERLATO" contains 70.7g carbs per 100g.

---

## 🔍 INVESTIGATION FINDINGS

### Issue #1: Lasagne alla bolognese - DATABASE BUG ✅ CONFIRMED

**Database Analysis:**
```
Recipe ID: d7571dd7-1877-4961-bbd0-b255acd0d1eb
Title: Lasagne alla bolognese
Total Calories in DB: 4647 kcal
Total Protein: 11.15g
Total Carbs: 2.10g
Total Fat: 9.38g
Servings: 2
```

**Problem Identified:**

The `recipe_ingredients` table stores **calories per 100g** instead of **calculated calories for the actual quantity**.

**Example from Lasagne:**
| Ingredient | Quantity (g) | Stored Calories | Should Be |
|------------|--------------|-----------------|-----------|
| Pasta All'uovo, Secca | 30g | 375 kcal | 112.5 kcal (30/100 × 375) |
| Bovino, Scamone | 40g | 119 kcal | 47.6 kcal (40/100 × 119) |
| Olio Extravergine | 5g | 899 kcal | 45.0 kcal (5/100 × 899) |
| Burro | 2.6g | 758 kcal | 19.7 kcal (2.6/100 × 758) |

**Result:**
- **Stored Total:** 4647 kcal (WRONG - sum of kcal/100g values)
- **Correct Total:** ~286 kcal (for actual quantities)
- **Per 100g:** Should be ~114 kcal/100g, but shows 1859 kcal/100g

**Root Cause:** The recipe import/migration script stored the `calories_per_100g` value directly in the `calories` column of `recipe_ingredients` table, instead of calculating:
```
calories = (quantity_grams / 100) × calories_per_100g
```

---

### Issue #2: Orzo Bollito - DATABASE BUG ✅ CONFIRMED

**Database Analysis:**
```
Recipe: Minestrone di verdure senza patate e legumi con orzo
Ingredient: Orzo, Perlato
Quantity: 40g
Stored Calories: 337 kcal
Stored Protein: 0g ❌
Stored Carbs: 0g ❌
Stored Fat: 0g ❌
```

**BDA Database (Correct Values):**
```
Code: 4_1
Name: ORZO, PERLATO
Calories per 100g: 337 kcal ✅
Protein per 100g: 10.4g ✅
Carbs per 100g: 70.7g ✅
Fat per 100g: 1.1g ✅
```

**Problem Identified:**

The `recipe_ingredients` table has **ALL macronutrients set to 0** for most ingredients, even though:
1. The calories are stored (incorrectly as per 100g)
2. The BDA database contains the correct macronutrient values

**Root Cause:** The recipe import script only populated the `calories` field and left `protein_g`, `carbs_g`, `fat_g`, and `fiber_g` as 0.

---

## 🎯 ROOT CAUSE ANALYSIS

### Location: Database Migration Script
**File:** `supabase/migrations/20250924105400_add_extended_italian_recipe_collection.sql`

**Problem in the INSERT logic:**

The migration script that imported recipes from the CSV file:
1. ✅ Correctly read ingredient quantities from CSV
2. ❌ Stored `calories_per_100g` directly instead of calculating actual calories
3. ❌ Did NOT populate macronutrient fields (protein, carbs, fat, fiber)
4. ❌ The `calculate_recipe_nutrition()` function sums these incorrect values

**Expected Behavior:**
```sql
INSERT INTO recipe_ingredients (
    recipe_id, ingredient_name, quantity, weight_grams,
    calories, protein_g, carbs_g, fat_g, fiber_g
) VALUES (
    recipe_id,
    'Pasta All''uovo',
    30,  -- quantity
    30,  -- weight_grams
    (30.0 / 100.0) * 375,  -- 112.5 kcal (CORRECT)
    (30.0 / 100.0) * 13.0, -- protein
    (30.0 / 100.0) * 69.6, -- carbs
    (30.0 / 100.0) * 3.0,  -- fat
    (30.0 / 100.0) * 3.3   -- fiber
);
```

**Actual Behavior:**
```sql
INSERT INTO recipe_ingredients (
    recipe_id, ingredient_name, quantity, weight_grams,
    calories, protein_g, carbs_g, fat_g, fiber_g
) VALUES (
    recipe_id,
    'Pasta All''uovo',
    30,   -- quantity
    30,   -- weight_grams
    375,  -- ❌ WRONG: This is per 100g, not for 30g
    0,    -- ❌ WRONG: Should be calculated
    0,    -- ❌ WRONG: Should be calculated
    0,    -- ❌ WRONG: Should be calculated
    0     -- ❌ WRONG: Should be calculated
);
```

---

## 📊 IMPACT ASSESSMENT

### Affected Data:
- **All recipes** in the database (estimated 175+ recipes)
- **All recipe ingredients** (estimated 1000+ ingredient entries)

### User Impact:
- ❌ Recipe calories shown are 10-20x higher than actual
- ❌ Macronutrients (protein, carbs, fat) show as 0g or incorrect
- ❌ Meal diary entries using recipes have incorrect nutrition data
- ❌ Daily nutrition summaries are incorrect when recipes are used
- ❌ Progress tracking and goals are affected

---

## ✅ SOLUTION REQUIRED

### 1. Fix the Database (CRITICAL - DO FIRST)

**Update all recipe_ingredients to calculate correct values:**

```sql
-- This will need to be done by matching ingredients to BDA database
-- Pseudocode:
UPDATE recipe_ingredients ri
SET 
    calories = (ri.weight_grams / 100.0) * bda.calories_per_100g,
    protein_g = (ri.weight_grams / 100.0) * bda.protein_per_100g,
    carbs_g = (ri.weight_grams / 100.0) * bda.carbs_per_100g,
    fat_g = (ri.weight_grams / 100.0) * bda.fat_per_100g,
    fiber_g = (ri.weight_grams / 100.0) * bda.fiber_per_100g
FROM food_ingredients bda
WHERE ri.ingredient_name = bda.italian_name
  OR ri.ingredient_name = bda.name;
```

### 2. Recalculate Recipe Totals

```sql
-- After fixing ingredients, recalculate recipe totals
UPDATE recipes r
SET 
    total_calories = (SELECT SUM(calories) FROM recipe_ingredients WHERE recipe_id = r.id),
    total_protein_g = (SELECT SUM(protein_g) FROM recipe_ingredients WHERE recipe_id = r.id),
    total_carbs_g = (SELECT SUM(carbs_g) FROM recipe_ingredients WHERE recipe_id = r.id),
    total_fat_g = (SELECT SUM(fat_g) FROM recipe_ingredients WHERE recipe_id = r.id),
    total_fiber_g = (SELECT SUM(fiber_g) FROM recipe_ingredients WHERE recipe_id = r.id);
```

### 3. Fix the Code (PREVENT FUTURE ISSUES)

**File:** `lib/presentation/add_meal/add_meal.dart`

The code at lines 127-151 appears correct - it divides by servings. The issue is the DATABASE data is wrong.

---

## 🚨 CONCLUSION

**THIS IS A DATABASE BUG, NOT A CODE BUG.**

The application code correctly displays and calculates nutrition based on the database values. However, the database contains incorrect values because the migration script that imported recipes from CSV files:

1. Stored calories_per_100g instead of calculated calories for actual quantities
2. Did not populate macronutrient fields at all (left as 0)

**Action Required:** Create a database migration script to fix all existing recipe data.

**DO NOT modify the application code** - it is working correctly with the data it receives.

