#!/usr/bin/env python3
"""
Find missing ingredients in BDA database
"""

import pandas as pd

# Load BDA database
bda_df = pd.read_csv("BDA_Banca Dati Alimentari_V1.2022.xlsx - BDA-2022.csv", skiprows=2)

# Missing ingredients to search for
missing_ingredients = [
    'Gnocchi freschi di patate',
    'Pomodori Maturi',
    'Besciamella',
    'Passata di pomodoro',
    'Pesto',
    'Verza',
    'Parmigiano grattuggiato',
    'Caffe',
    'Carne trita scelta',
    'Manzo, tagli di carne magra',
    'Nervetti',
    'Olive Nere',
    'Pane secco',
    'Mozzarella',
    'Tonno',
    'Peperoni',
]

print("="*80)
print("SEARCHING FOR MISSING INGREDIENTS IN BDA DATABASE")
print("="*80)

for ingredient in missing_ingredients:
    print(f"\n{'='*80}")
    print(f"Searching for: {ingredient}")
    print("="*80)
    
    # Search in name column (index 2)
    search_terms = ingredient.lower().split()
    
    found = False
    for term in search_terms:
        if len(term) < 4:  # Skip short words
            continue
            
        matches = bda_df[bda_df.iloc[:, 2].astype(str).str.lower().str.contains(term, na=False)]
        
        if len(matches) > 0:
            found = True
            print(f"\nMatches for '{term}':")
            for idx, row in matches.iterrows():
                code = row.iloc[1]
                name = row.iloc[2]
                calories = row.iloc[7]
                protein = row.iloc[9]
                fat = row.iloc[12]
                carbs = row.iloc[16]
                fiber = row.iloc[19]
                
                print(f"  Code: {code}")
                print(f"  Name: {name}")
                print(f"  Calories: {calories} kcal/100g")
                print(f"  Protein: {protein}g/100g")
                print(f"  Fat: {fat}g/100g")
                print(f"  Carbs: {carbs}g/100g")
                print(f"  Fiber: {fiber}g/100g")
                print()
    
    if not found:
        print(f"  NOT FOUND in BDA database - needs manual entry")

print("\n" + "="*80)
print("SEARCH COMPLETE")
print("="*80)

