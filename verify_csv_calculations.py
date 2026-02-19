#!/usr/bin/env python3
"""
Verify that recipe calculations match CSV exactly
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
        'protein': safe_float(row.iloc[9]),
        'fat': safe_float(row.iloc[12]),
        'carbs': safe_float(row.iloc[16]),
        'fiber': safe_float(row.iloc[19]),
    }

print(f"Loaded {len(bda_lookup)} food items from BDA\n")

# Load recipes
print("Loading recipes CSV...")
recipes_df = pd.read_csv("Ricette per APP.xlsx - Ricette PARTE1.csv", header=None)

print("\n" + "="*80)
print("VERIFYING: Lasagne alla bolognese")
print("="*80)

in_lasagne = False
ingredients = []
expected_total_kcal = 0
expected_total_weight = 0

for i, row in recipes_df.iterrows():
    col0 = str(row[0]).strip() if pd.notna(row[0]) else ''
    
    if 'Lasagne alla bolognese' in col0:
        in_lasagne = True
        print(f"\nFound recipe at line {i+1}")
        continue
    
    if in_lasagne:
        col1 = str(row[1]).strip() if pd.notna(row[1]) else ''
        col3 = str(row[3]).strip() if pd.notna(row[3]) else ''
        col5 = str(row[5]).strip() if pd.notna(row[5]) else ''
        col6 = str(row[6]).strip() if pd.notna(row[6]) else ''
        
        # Check for end of recipe
        if 'Analisi per porzione' in col0:
            expected_total_weight = safe_float(col1)
            expected_total_kcal = safe_float(col6)
            print(f"\nExpected from CSV:")
            print(f"  Total weight: {expected_total_weight}g")
            print(f"  Total calories: {expected_total_kcal} kcal")
            break
        
        # Process ingredient
        if col3 and col1:  # Has BDA code and quantity
            quantity = safe_float(col1)
            bda_code = col3
            csv_kcal = safe_float(col6)
            
            if bda_code in bda_lookup:
                food = bda_lookup[bda_code]
                
                # Calculate what it SHOULD be
                calculated_kcal = (quantity / 100.0) * food['calories']
                
                ingredients.append({
                    'name': col0,
                    'quantity': quantity,
                    'bda_code': bda_code,
                    'csv_kcal': csv_kcal,
                    'bda_kcal_per_100g': food['calories'],
                    'calculated_kcal': calculated_kcal,
                    'match': abs(csv_kcal - calculated_kcal) < 0.5
                })

# Display results
print("\n" + "="*80)
print("INGREDIENT ANALYSIS")
print("="*80)
print(f"{'Ingredient':<45} {'Qty(g)':<8} {'CSV kcal':<10} {'Calc kcal':<10} {'Match':<6}")
print("-"*90)

total_csv_kcal = 0
total_calculated_kcal = 0
mismatches = 0

for ing in ingredients:
    match_symbol = "✓" if ing['match'] else "✗"
    if not ing['match']:
        mismatches += 1
    
    print(f"{ing['name'][:43]:<45} {ing['quantity']:<8.2f} {ing['csv_kcal']:<10.1f} {ing['calculated_kcal']:<10.2f} {match_symbol:<6}")
    total_csv_kcal += ing['csv_kcal']
    total_calculated_kcal += ing['calculated_kcal']

print("-"*90)
print(f"{'TOTAL':<45} {'':<8} {total_csv_kcal:<10.1f} {total_calculated_kcal:<10.2f}")

print("\n" + "="*80)
print("SUMMARY")
print("="*80)
print(f"Expected total from CSV: {expected_total_kcal} kcal")
print(f"Sum of CSV ingredient kcals: {total_csv_kcal} kcal")
print(f"Sum of calculated kcals: {total_calculated_kcal:.2f} kcal")
print(f"Mismatches: {mismatches} out of {len(ingredients)} ingredients")

print("\n" + "="*80)
print("CONCLUSION")
print("="*80)

if abs(total_csv_kcal - expected_total_kcal) < 1:
    print("✓ CSV ingredient sum MATCHES expected total")
else:
    print(f"✗ CSV ingredient sum ({total_csv_kcal}) DOES NOT MATCH expected total ({expected_total_kcal})")
    print(f"  Difference: {abs(total_csv_kcal - expected_total_kcal):.1f} kcal")

if abs(total_calculated_kcal - expected_total_kcal) < 1:
    print("✓ Calculated sum MATCHES expected total")
else:
    print(f"✗ Calculated sum ({total_calculated_kcal:.2f}) DOES NOT MATCH expected total ({expected_total_kcal})")
    print(f"  Difference: {abs(total_calculated_kcal - expected_total_kcal):.2f} kcal")

print("\n" + "="*80)

