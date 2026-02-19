#!/usr/bin/env python3
"""
Analyze the discrepancy between CSV expected values and BDA calculations
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

# Load BDA database
print("Loading BDA database...")
bda_df = pd.read_csv("BDA_Banca Dati Alimentari_V1.2022.xlsx - BDA-2022.csv", skiprows=2)

# Create lookup by code
bda_lookup = {}
for _, row in bda_df.iterrows():
    code = str(row.iloc[1]).strip()
    bda_lookup[code] = {
        'name': row.iloc[2],
        'calories': safe_float(row.iloc[7]),
    }

print(f"Loaded {len(bda_lookup)} food items from BDA\n")

# Load recipes
print("Loading recipes CSV...")
recipes_df = pd.read_csv("Ricette per APP.xlsx - Ricette PARTE1.csv", header=None)

# Analyze multiple recipes
recipes_to_check = [
    ("Lasagne alla bolognese", 911, 929),
    ("Cappuccino senza zucchero", 178, 181),
    ("Caffè macchiato", 172, 175),
    ("Affogato al caffè", 3, 6),
]

print("="*100)
print("ANALYSIS: CSV Expected Values vs BDA Calculated Values")
print("="*100)

for recipe_name, start_line, end_line in recipes_to_check:
    print(f"\n{'='*100}")
    print(f"RECIPE: {recipe_name}")
    print(f"{'='*100}")
    
    total_calculated = 0
    total_weight = 0
    csv_expected = 0
    ingredient_count = 0
    
    for i in range(start_line, end_line + 1):
        row = recipes_df.iloc[i]
        col0 = str(row[0]).strip() if pd.notna(row[0]) else ''
        col1 = str(row[1]).strip() if pd.notna(row[1]) else ''
        col3 = str(row[3]).strip() if pd.notna(row[3]) else ''
        col6 = str(row[6]).strip() if pd.notna(row[6]) else ''
        
        # Check for end of recipe
        if 'Analisi per porzione' in col0:
            total_weight = safe_float(col1)
            csv_expected = safe_float(col6)
            break
        
        # Process ingredient
        if col3 and col1 and i > start_line:  # Has BDA code and quantity
            quantity = safe_float(col1)
            bda_code = col3
            
            if bda_code in bda_lookup:
                food = bda_lookup[bda_code]
                calculated_kcal = (quantity / 100.0) * food['calories']
                total_calculated += calculated_kcal
                ingredient_count += 1
                print(f"  {col0[:50]:<50} {quantity:>6.1f}g × {food['calories']:>4.0f} kcal/100g = {calculated_kcal:>6.2f} kcal")
    
    print(f"\n  {'TOTAL CALCULATED FROM BDA:':<50} {total_calculated:>6.2f} kcal")
    print(f"  {'CSV EXPECTED VALUE:':<50} {csv_expected:>6.2f} kcal")
    print(f"  {'DIFFERENCE:':<50} {abs(total_calculated - csv_expected):>6.2f} kcal")
    print(f"  {'PERCENTAGE OF CALCULATED:':<50} {(csv_expected / total_calculated * 100) if total_calculated > 0 else 0:>6.1f}%")
    print(f"  {'MATCH:':<50} {'✓ YES' if abs(total_calculated - csv_expected) < 1 else '✗ NO'}")

print("\n" + "="*100)
print("SUMMARY")
print("="*100)
print("""
FINDING: The CSV "expected" values DO NOT match the BDA calculated values.

The CSV values are consistently LOWER than what we calculate from the BDA database.

POSSIBLE EXPLANATIONS:
1. The CSV uses a different calculation method (e.g., accounting for cooking losses)
2. The CSV values represent "per 100g" instead of total (but this doesn't match either)
3. There's a conversion factor or formula we're missing
4. The CSV has errors

QUESTION FOR CLIENT:
Should the database values match:
  A) The CSV "Analisi per porzione" values EXACTLY (e.g., 149 kcal for Lasagne)
  B) The BDA calculated values (e.g., 285.74 kcal for Lasagne)
  C) Some other calculation method?

Without clarification, we cannot ensure the database matches the client's expectations.
""")

