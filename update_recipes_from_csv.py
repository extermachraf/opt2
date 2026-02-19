#!/usr/bin/env python3
"""
Update recipes table with EXACT values from CSV "Analisi per porzione" lines
This will make the database match the CSV files exactly.

NOTE: This script generates SQL that you can run via Supabase API
"""

import pandas as pd

def safe_float(value):
    """Convert string to float, handling comma decimal separator"""
    if pd.isna(value):
        return 0.0
    try:
        return float(str(value).replace(',', '.'))
    except (ValueError, AttributeError):
        return 0.0

# Load recipes CSV
print("Loading recipes CSV...")
recipes_df = pd.read_csv("Ricette per APP.xlsx - Ricette PARTE1.csv", header=None)

print(f"Loaded {len(recipes_df)} lines from CSV\n")

# Parse recipes and their "Analisi per porzione" values
recipes_data = []
current_recipe = None
in_recipe = False

for i, row in recipes_df.iterrows():
    col0 = str(row[0]).strip() if pd.notna(row[0]) else ''
    col1 = str(row[1]).strip() if pd.notna(row[1]) else ''
    col6 = str(row[6]).strip() if pd.notna(row[6]) else ''
    
    # Check if this is a recipe title (no comma in col1, no BDA code in col3)
    if col0 and not col1 and i > 0:
        # This might be a recipe title
        current_recipe = col0
        in_recipe = True
        continue
    
    # Check for "Analisi per porzione" line
    if 'Analisi per porzione' in col0 and current_recipe:
        total_weight = safe_float(col1)
        total_kcal = safe_float(col6)
        
        recipes_data.append({
            'title': current_recipe,
            'total_weight_g': total_weight,
            'total_calories': int(total_kcal),
            'csv_line': i + 1
        })
        
        print(f"Found: {current_recipe}")
        print(f"  Weight: {total_weight}g")
        print(f"  Calories: {total_kcal} kcal (from CSV line {i+1})")
        print()
        
        current_recipe = None
        in_recipe = False

print(f"\n{'='*80}")
print(f"SUMMARY: Found {len(recipes_data)} recipes with 'Analisi per porzione' values")
print(f"{'='*80}\n")

# Generate SQL update statements
print("Generating SQL UPDATE statements...\n")
print("-- SQL to update recipes with CSV values (calories, weight, and calories_per_100g)")
print("-- Copy and paste this into Supabase SQL editor or use via API\n")

sql_statements = []

for recipe_data in recipes_data:
    recipe_title = recipe_data['title'].replace("'", "''")  # Escape single quotes
    csv_calories = recipe_data['total_calories']
    csv_weight = recipe_data['total_weight_g']

    # Calculate calories per 100g
    calories_per_100g = 0
    if csv_weight > 0:
        calories_per_100g = int((csv_calories / csv_weight) * 100)

    sql = f"UPDATE recipes SET total_calories = {csv_calories}, total_weight_g = {csv_weight}, calories_per_100g = {calories_per_100g} WHERE LOWER(title) = LOWER('{recipe_title}');"
    sql_statements.append(sql)
    print(f"{recipe_title}: {csv_calories} kcal, {csv_weight}g, {calories_per_100g} kcal/100g")

# Save to file
with open('update_recipes_with_weight.sql', 'w', encoding='utf-8') as f:
    f.write("-- Update recipes with CSV 'Analisi per porzione' values\n")
    f.write("-- Updates: total_calories, total_weight_g, and calories_per_100g\n")
    f.write("-- Generated automatically from Ricette PARTE1.csv\n\n")

    # First, add the columns if they don't exist
    f.write("-- Add columns if they don't exist\n")
    f.write("ALTER TABLE recipes ADD COLUMN IF NOT EXISTS total_weight_g DECIMAL(10,2);\n")
    f.write("ALTER TABLE recipes ADD COLUMN IF NOT EXISTS calories_per_100g INTEGER;\n\n")

    f.write("DO $$\n")
    f.write("BEGIN\n")
    f.write("  RAISE NOTICE 'Updating recipes with CSV values (calories, weight, calories_per_100g)...';\n\n")
    for sql in sql_statements:
        f.write(f"  {sql}\n")
    f.write("\n  RAISE NOTICE 'Updated % recipes', (SELECT COUNT(*) FROM recipes WHERE total_weight_g > 0);\n")
    f.write("END $$;\n")

print(f"\n{'='*80}")
print(f"SQL GENERATED")
print(f"{'='*80}")
print(f"✅ Generated {len(sql_statements)} UPDATE statements")
print(f"✅ Saved to: update_recipes_with_weight.sql")
print(f"\nThis will update:")
print(f"  - total_calories (from CSV)")
print(f"  - total_weight_g (from CSV)")
print(f"  - calories_per_100g (calculated)")
print(f"\nYou can now run this SQL via Supabase API or SQL editor")
print(f"{'='*80}")

