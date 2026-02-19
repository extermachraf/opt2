#!/usr/bin/env python3
"""
Simple Recipe Nutrition Checker
Checks for the specific issues reported by the client
"""

import pandas as pd
import json

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

def main():
    print("="*80)
    print("RECIPE NUTRITION ANALYSIS - CLIENT ISSUE INVESTIGATION")
    print("="*80)
    
    # Load BDA database
    print("\n[1/3] Loading BDA Food Database...")
    bda_df = pd.read_csv(BDA_FILE, skiprows=2)
    
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
    print(f"   Loaded {len(bda_lookup)} food items")
    
    # Check specific ingredients mentioned in the problem
    print("\n[2/3] Checking specific ingredients mentioned in problem...")
    print("\n--- ORZO (Barley) ---")
    orzo_code = "4_1"
    if orzo_code in bda_lookup:
        orzo = bda_lookup[orzo_code]
        print(f"   Code: {orzo_code}")
        print(f"   Name: {orzo['name']}")
        print(f"   Carbs per 100g: {orzo['carbs']}g")
        print(f"   Protein per 100g: {orzo['protein']}g")
        print(f"   Fat per 100g: {orzo['fat']}g")
        print(f"   Calories per 100g: {orzo['calories']} kcal")
        print(f"\n   FINDING: Orzo DOES contain {orzo['carbs']}g carbs per 100g")
        print(f"   If recipe shows 0g carbs, this is a DATABASE or CODE BUG")
    
    # Load recipes
    print("\n[3/3] Analyzing specific recipes...")
    recipes_df = pd.read_csv(RECIPES_FILE, header=None)
    
    # Find and analyze "Lasagne alla bolognese"
    print("\n" + "="*80)
    print("RECIPE 1: Lasagne alla bolognese")
    print("="*80)
    
    in_lasagne = False
    lasagne_ingredients = []
    lasagne_total_weight = 0
    lasagne_expected_kcal = 0
    
    for i, row in recipes_df.iterrows():
        col0 = str(row[0]).strip() if pd.notna(row[0]) else ''
        
        if 'Lasagne alla bolognese' in col0:
            in_lasagne = True
            print(f"\nFound at line {i+1}")
            continue
        
        if in_lasagne:
            col1 = str(row[1]).strip() if pd.notna(row[1]) else ''
            col3 = str(row[3]).strip() if pd.notna(row[3]) else ''
            col5 = str(row[5]).strip() if pd.notna(row[5]) else ''
            col6 = str(row[6]).strip() if pd.notna(row[6]) else ''
            
            if 'Analisi per porzione' in col0:
                lasagne_total_weight = safe_float(col1)
                lasagne_expected_kcal = safe_float(col6)
                break
            
            if col3 and col1:  # Has BDA code and quantity
                quantity = safe_float(col1)
                bda_code = col3
                
                if bda_code in bda_lookup:
                    food = bda_lookup[bda_code]
                    # CRITICAL: Check if calculation assumes 100g for each ingredient
                    calc_kcal_per_100g = food['calories']  # This would be WRONG
                    calc_kcal_correct = (quantity / 100.0) * food['calories']  # This is CORRECT
                    
                    lasagne_ingredients.append({
                        'name': col0,
                        'quantity': quantity,
                        'kcal_per_100g': food['calories'],
                        'kcal_if_100g_assumed': calc_kcal_per_100g,
                        'kcal_correct': calc_kcal_correct
                    })
    
    # Analyze Lasagne
    print("\nIngredients:")
    print(f"{'Name':<40} {'Qty(g)':<10} {'Kcal/100g':<12} {'If 100g':<12} {'Correct':<12}")
    print("-"*90)
    
    total_if_100g = 0
    total_correct = 0
    
    for ing in lasagne_ingredients:
        print(f"{ing['name'][:38]:<40} {ing['quantity']:<10.1f} {ing['kcal_per_100g']:<12.1f} "
              f"{ing['kcal_if_100g_assumed']:<12.1f} {ing['kcal_correct']:<12.1f}")
        total_if_100g += ing['kcal_if_100g_assumed']
        total_correct += ing['kcal_correct']
    
    print("-"*90)
    print(f"{'TOTAL':<40} {'':<10} {'':<12} {total_if_100g:<12.1f} {total_correct:<12.1f}")
    
    print(f"\nExpected total from CSV: {lasagne_expected_kcal:.1f} kcal")
    print(f"Total weight: {lasagne_total_weight:.1f}g")
    print(f"\nPer 100g:")
    if lasagne_total_weight > 0:
        print(f"   If using 100g assumption: {(total_if_100g/lasagne_total_weight)*100:.1f} kcal/100g")
        print(f"   Correct calculation: {(total_correct/lasagne_total_weight)*100:.1f} kcal/100g")
        print(f"   Expected from CSV: {(lasagne_expected_kcal/lasagne_total_weight)*100:.1f} kcal/100g")
    
    print("\n" + "="*80)
    print("DIAGNOSIS:")
    print("="*80)
    
    if abs(total_if_100g - (lasagne_expected_kcal * lasagne_total_weight / 100)) < 50:
        print("\nPROBLEM IDENTIFIED: CODE BUG - Treating each ingredient as 100g")
        print("The system is calculating as if EVERY ingredient weighs 100g,")
        print("instead of using the actual ingredient quantities!")
        print("\nThis is a CODE BUG in the recipe calculation logic.")
    elif abs(total_correct - lasagne_expected_kcal) < 10:
        print("\nCSV calculations appear CORRECT.")
        print("Problem may be in how the app displays or calculates recipe nutrition.")
    else:
        print("\nUnclear - needs further investigation")
    
    print("\n" + "="*80)
    print("END OF ANALYSIS")
    print("="*80)

if __name__ == "__main__":
    main()

