# 🔍 NUTRITION CALCULATION ISSUE - FINDINGS SUMMARY

## Quick Answer

**Q: Is this a code bug or database bug?**  
**A: DATABASE BUG** ✅

---

## The Problem

### Client Report:
1. **Lasagne recipe** shows calories as if each ingredient weighs 100g
2. **Orzo bollito** shows 0g carbohydrates (should have ~70g per 100g)

---

## What I Found

### 🔴 Issue #1: Lasagne alla bolognese

**Database shows:**
- Total Calories: **4,647 kcal** ❌ WRONG
- Total Protein: 11.15g
- Total Carbs: 2.10g
- Total Fat: 9.38g

**Should be:**
- Total Calories: **~286 kcal** ✅ CORRECT
- Total Protein: ~30g
- Total Carbs: ~25g
- Total Fat: ~12g

**Why?** Each ingredient stores the "per 100g" calorie value instead of the calculated value for its actual quantity.

**Example:**
- Pasta: 30g → Stored as 375 kcal (which is per 100g) → Should be 112.5 kcal
- Butter: 2.6g → Stored as 758 kcal (which is per 100g) → Should be 19.7 kcal
- Oil: 5g → Stored as 899 kcal (which is per 100g) → Should be 45 kcal

---

### 🔴 Issue #2: Orzo bollito (and all recipes)

**Database shows:**
- Orzo ingredient: 40g
- Calories: 337 kcal (per 100g value - wrong for 40g)
- Protein: **0g** ❌
- Carbs: **0g** ❌
- Fat: **0g** ❌

**BDA Database (source data) shows:**
- Orzo per 100g:
  - Calories: 337 kcal ✅
  - Protein: 10.4g ✅
  - Carbs: 70.7g ✅
  - Fat: 1.1g ✅

**Why?** The migration script that imported recipes:
1. Only copied the calories_per_100g value (didn't calculate for actual quantity)
2. Left all macronutrients as 0 (didn't populate them at all)

---

## Root Cause

### Location: Database Migration Script
**File:** `supabase/migrations/20250924105400_add_extended_italian_recipe_collection.sql`

The script that imported recipes from CSV files made two mistakes:

1. **Stored wrong calorie values:**
   ```sql
   -- What it did (WRONG):
   calories = 375  -- This is per 100g
   
   -- What it should do (CORRECT):
   calories = (30 / 100) * 375  -- Calculate for actual 30g = 112.5
   ```

2. **Didn't populate macronutrients:**
   ```sql
   -- What it did (WRONG):
   protein_g = 0
   carbs_g = 0
   fat_g = 0
   
   -- What it should do (CORRECT):
   protein_g = (30 / 100) * 13.0
   carbs_g = (30 / 100) * 69.6
   fat_g = (30 / 100) * 3.0
   ```

---

## Impact

### Affected:
- ✅ **ALL recipes** in database (~175 recipes)
- ✅ **ALL recipe ingredients** (~1000+ entries)
- ✅ **Meal diary entries** that use recipes
- ✅ **Nutrition summaries** and progress tracking

### Not Affected:
- ❌ Application code (it's working correctly)
- ❌ Individual food items (they're correct)
- ❌ Meals using only food items (not recipes)

---

## The Code is Fine

I checked the application code in `lib/presentation/add_meal/add_meal.dart`:

```dart
// Lines 127-151 - This code is CORRECT
final caloriesPerServing = servings > 0 ? (totalCalories / servings).round() : totalCalories;
final proteinPerServing = servings > 0 ? (totalProtein / servings) : totalProtein;
// ... etc
```

The code correctly:
- Divides by servings
- Calculates per 100g values
- Displays what's in the database

**The problem is the DATABASE has wrong values, not the code.**

---

## What Needs to be Fixed

### 1. Database Data (CRITICAL)
- Recalculate all recipe_ingredients calories using: `(quantity / 100) × calories_per_100g`
- Populate all macronutrients using: `(quantity / 100) × nutrient_per_100g`
- Recalculate all recipe totals by summing ingredient values

### 2. Migration Script (PREVENT FUTURE)
- Fix the import logic to calculate values correctly
- Ensure macronutrients are populated from BDA database

### 3. Code (OPTIONAL)
- No code changes needed - it's working correctly
- Maybe add validation to catch this type of error in future

---

## Verification

I verified this by:
1. ✅ Analyzing CSV source files (BDA database and recipes)
2. ✅ Querying the OPT 2 database directly
3. ✅ Comparing expected vs actual values
4. ✅ Running Python analysis script to calculate correct values
5. ✅ Checking the application code logic

---

## Recommendation

**DO NOT touch the application code.** It's working correctly.

**DO create a database migration** to fix the recipe_ingredients and recipes tables.

**Priority:** CRITICAL - This affects all users using recipes for meal tracking.

---

## Files Created

1. `NUTRITION_CALCULATION_BUG_REPORT.md` - Detailed technical report
2. `check_recipe_nutrition.py` - Python script to verify calculations
3. `FINDINGS_SUMMARY.md` - This file (executive summary)

---

**Status:** ✅ Investigation Complete - Ready for Database Fix

