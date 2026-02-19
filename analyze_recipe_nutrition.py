#!/usr/bin/env python3
"""
Recipe Nutrition Analysis Script
Analyzes discrepancies between recipe calculations in CSV files and database
"""

import pandas as pd
import json
import sys
from decimal import Decimal, ROUND_HALF_UP

# Configuration
BDA_FILE = "BDA_Banca Dati Alimentari_V1.2022.xlsx - BDA-2022.csv"
RECIPES_FILE = "Ricette per APP.xlsx - Ricette PARTE1.csv"

def safe_float(value):
    """Convert string to float, handling comma decimal separator"""
    if pd.isna(value):
        return 0.0
    try:
        return float(str(value).replace(',', '.'))
    except (ValueError, AttributeError):
        return 0.0

def load_bda_database():
    """Load the BDA food database"""
    print("📊 Loading BDA Food Database...")
    df = pd.read_csv(BDA_FILE, skiprows=2)  # Skip header rows

    # Create a lookup dictionary by food code
    bda_lookup = {}
    for _, row in df.iterrows():
        code = str(row.iloc[1]).strip()  # Codice Alimento
        bda_lookup[code] = {
            'name_ita': row.iloc[2],
            'name_eng': row.iloc[3],
            'calories': safe_float(row.iloc[7]),
            'protein': safe_float(row.iloc[9]),
            'fat': safe_float(row.iloc[12]),
            'carbs': safe_float(row.iloc[16]),
            'fiber': safe_float(row.iloc[19]),
        }

    print(f"✅ Loaded {len(bda_lookup)} food items from BDA database")
    return bda_lookup

def parse_recipes(bda_lookup):
    """Parse recipes from CSV file"""
    print("\n📖 Parsing Recipes...")

    df = pd.read_csv(RECIPES_FILE, header=None)

    recipes = []
    current_recipe = None

    for i, row in df.iterrows():
        # Skip header rows
        if i < 2:
            continue

        # Get values
        col0 = str(row[0]).strip() if pd.notna(row[0]) else ''
        col1 = str(row[1]).strip() if pd.notna(row[1]) else ''
        col3 = str(row[3]).strip() if pd.notna(row[3]) else ''
        col4 = str(row[4]).strip() if pd.notna(row[4]) else ''
        col5 = str(row[5]).strip() if pd.notna(row[5]) else ''
        col6 = str(row[6]).strip() if pd.notna(row[6]) else ''

        # Check if this is a recipe title (has name in col0, empty col3)
        if col0 and not col3 and not col1:
            # Save previous recipe
            if current_recipe and current_recipe.get('ingredients'):
                recipes.append(current_recipe)

            # Start new recipe
            current_recipe = {
                'name': col0,
                'ingredients': [],
                'line_number': i + 1
            }

        # Check if this is an ingredient (has BDA code in col3)
        elif current_recipe and col3 and col1:
            try:
                quantity = safe_float(col1)
                bda_code = col3
                expected_weight = safe_float(col5) if col5 else quantity
                expected_kcal = safe_float(col6) if col6 else 0

                current_recipe['ingredients'].append({
                    'name': col0,
                    'quantity': quantity,
                    'bda_code': bda_code,
                    'bda_name': col4,
                    'expected_weight': expected_weight,
                    'expected_kcal': expected_kcal
                })
            except (ValueError, IndexError) as e:
                pass

        # Check if this is the analysis line
        elif current_recipe and col0 and 'Analisi per' in col0:
            try:
                if 'porzione' in col0:
                    current_recipe['total_weight'] = safe_float(col1)
                    current_recipe['expected_total_kcal'] = safe_float(col6)
            except (ValueError, IndexError):
                pass

    # Add last recipe
    if current_recipe and current_recipe.get('ingredients'):
        recipes.append(current_recipe)

    print(f"✅ Parsed {len(recipes)} recipes")
    return recipes

def analyze_recipe(recipe, bda_lookup):
    """Analyze a single recipe for nutrition calculation errors"""
    print(f"\n{'='*80}")
    print(f"🔍 Analyzing: {recipe['name']}")
    print(f"{'='*80}")
    
    issues = []
    total_calories_calculated = 0
    total_protein_calculated = 0
    total_carbs_calculated = 0
    total_fat_calculated = 0
    total_fiber_calculated = 0
    
    print(f"\n{'Ingredient':<40} {'Qty(g)':<10} {'Kcal/100g':<12} {'Calc Kcal':<12} {'Expected':<12}")
    print("-" * 90)
    
    for ing in recipe['ingredients']:
        bda_code = ing['bda_code']
        quantity = ing['quantity']
        
        if bda_code not in bda_lookup:
            issues.append(f"❌ BDA code '{bda_code}' not found for ingredient '{ing['name']}'")
            continue
        
        food_data = bda_lookup[bda_code]
        
        # Calculate nutrition per actual quantity
        # Formula: (quantity_grams / 100) * nutrition_per_100g
        multiplier = quantity / 100.0
        calc_calories = food_data['calories'] * multiplier
        calc_protein = food_data['protein'] * multiplier
        calc_carbs = food_data['carbs'] * multiplier
        calc_fat = food_data['fat'] * multiplier
        calc_fiber = food_data['fiber'] * multiplier
        
        total_calories_calculated += calc_calories
        total_protein_calculated += calc_protein
        total_carbs_calculated += calc_carbs
        total_fat_calculated += calc_fat
        total_fiber_calculated += calc_fiber
        
        # Check if calculation matches expected
        expected_kcal = ing['expected_kcal']
        
        print(f"{ing['name'][:38]:<40} {quantity:<10.1f} {food_data['calories']:<12.1f} {calc_calories:<12.1f} {expected_kcal:<12.1f}")
        
        # Check for potential issues
        if abs(calc_calories - expected_kcal) > 1:
            issues.append(f"⚠️  '{ing['name']}': Calculated {calc_calories:.1f} kcal but expected {expected_kcal:.1f} kcal")
    
    print("-" * 90)
    print(f"{'TOTAL':<40} {'':<10} {'':<12} {total_calories_calculated:<12.1f}")
    
    # Compare with expected total
    expected_total = recipe.get('expected_total_kcal', 0)
    total_weight = recipe.get('total_weight', 0)
    
    print(f"\n📊 Summary:")
    print(f"   Total Weight: {total_weight:.1f}g")
    print(f"   Calculated Total Calories: {total_calories_calculated:.1f} kcal")
    print(f"   Expected Total Calories: {expected_total:.1f} kcal")
    print(f"   Difference: {abs(total_calories_calculated - expected_total):.1f} kcal")
    
    if total_weight > 0:
        calc_per_100g = (total_calories_calculated / total_weight) * 100
        expected_per_100g = (expected_total / total_weight) * 100 if expected_total > 0 else 0
        print(f"   Calculated per 100g: {calc_per_100g:.1f} kcal/100g")
        print(f"   Expected per 100g: {expected_per_100g:.1f} kcal/100g")
    
    print(f"\n   Macronutrients (Total):")
    print(f"   - Protein: {total_protein_calculated:.2f}g")
    print(f"   - Carbs: {total_carbs_calculated:.2f}g")
    print(f"   - Fat: {total_fat_calculated:.2f}g")
    print(f"   - Fiber: {total_fiber_calculated:.2f}g")
    
    if total_weight > 0:
        print(f"\n   Macronutrients (per 100g):")
        print(f"   - Protein: {(total_protein_calculated / total_weight * 100):.2f}g")
        print(f"   - Carbs: {(total_carbs_calculated / total_weight * 100):.2f}g")
        print(f"   - Fat: {(total_fat_calculated / total_weight * 100):.2f}g")
        print(f"   - Fiber: {(total_fiber_calculated / total_weight * 100):.2f}g")
    
    # Report issues
    if issues:
        print(f"\n⚠️  Issues Found:")
        for issue in issues:
            print(f"   {issue}")
    else:
        print(f"\n✅ No calculation issues found")
    
    return {
        'name': recipe['name'],
        'total_calories_calculated': total_calories_calculated,
        'expected_total_kcal': expected_total,
        'total_protein': total_protein_calculated,
        'total_carbs': total_carbs_calculated,
        'total_fat': total_fat_calculated,
        'total_fiber': total_fiber_calculated,
        'total_weight': total_weight,
        'issues': issues
    }

def main():
    print("🔬 Recipe Nutrition Analysis Tool")
    print("=" * 80)
    
    # Load BDA database
    bda_lookup = load_bda_database()
    
    # Parse recipes
    recipes = parse_recipes(bda_lookup)
    
    # Debug: Print all recipe names
    print("\n📝 All recipes found:")
    for i, recipe in enumerate(recipes[:20], 1):  # Show first 20
        print(f"   {i}. {recipe['name']}")

    # Analyze specific recipes mentioned in the problem
    target_recipes = [
        "Lasagne",
        "Orzo bollito"
    ]

    results = []
    for recipe in recipes:
        # Case-insensitive partial match
        if any(target.lower() in recipe['name'].lower() for target in target_recipes):
            result = analyze_recipe(recipe, bda_lookup)
            results.append(result)

    # Final summary
    print(f"\n\n{'='*80}")
    print("📋 ANALYSIS COMPLETE")
    print(f"{'='*80}")
    print(f"\nAnalyzed {len(results)} target recipes")

    return results

if __name__ == "__main__":
    main()

