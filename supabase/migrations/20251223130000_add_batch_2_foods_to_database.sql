-- ============================================================================
-- FOOD NUTRITION DATABASE - BATCH 2 (5 NEW FOODS)
-- ============================================================================
-- Add new food items to existing comprehensive food database
-- This migration adds 5 additional foods: 2 potato products and 3 asparagus varieties

-- FOOD 6: POTATO CHIPS OR CRISPS, PLAIN, salted
INSERT INTO public.food_items (
    food_code,
    name,
    italian_name,
    english_name,
    category,
    edible_portion_percent,
    calories_per_100g,
    energy_kj,
    protein_per_100g,
    carbs_per_100g,
    fat_per_100g,
    fiber_per_100g,
    water_g,
    iron_mg,
    calcium_mg,
    sodium_per_100g,
    potassium_mg,
    phosphorus_mg,
    zinc_mg,
    is_verified
) VALUES (
    '382_1',
    'PATATINE, IN SACCHETTO, salate',
    'PATATINE, IN SACCHETTO, salate',
    'POTATO CHIPS OR CRISPS, PLAIN, salted',
    '1001'::public.food_category_code,
    100,
    540,
    2254,
    7.0,
    51.2,
    34.6,
    4.5,
    1.9,
    1.63,
    24,
    594,
    1275,
    165,
    1.1,
    true
);

-- FOOD 7: BATATAS or SWEETPOTATOES
INSERT INTO public.food_items (
    food_code,
    name,
    italian_name,
    english_name,
    scientific_name,
    category,
    edible_portion_percent,
    calories_per_100g,
    energy_kj,
    protein_per_100g,
    carbs_per_100g,
    fat_per_100g,
    fiber_per_100g,
    water_g,
    iron_mg,
    calcium_mg,
    sodium_per_100g,
    potassium_mg,
    phosphorus_mg,
    zinc_mg,
    is_verified
) VALUES (
    '50399_1',
    'PATATE, DOLCI',
    'PATATE, DOLCI',
    'BATATAS or SWEETPOTATOES',
    'Ipomaea batatas',
    '1001'::public.food_category_code,
    84,
    92,
    391,
    1.2,
    21.3,
    0.3,
    2.3,
    73.7,
    0.7,
    24,
    40,
    370,
    50,
    0.3,
    true
);

-- FOOD 8: ASPARAGUS, wild from wood
INSERT INTO public.food_items (
    food_code,
    name,
    italian_name,
    english_name,
    scientific_name,
    category,
    edible_portion_percent,
    calories_per_100g,
    energy_kj,
    protein_per_100g,
    carbs_per_100g,
    fat_per_100g,
    fiber_per_100g,
    water_g,
    iron_mg,
    calcium_mg,
    sodium_per_100g,
    potassium_mg,
    phosphorus_mg,
    zinc_mg,
    vitamin_c_mg,
    is_verified
) VALUES (
    '303_1',
    'ASPARAGI, di bosco',
    'ASPARAGI, di bosco',
    'ASPARAGUS, wild from wood',
    'Asparagus officinalis',
    '2001'::public.food_category_code,
    57,
    40,
    170,
    4.6,
    4.0,
    0.2,
    2.6,
    89.3,
    1.1,
    25,
    5,
    198,
    90,
    0.9,
    23,
    true
);

-- FOOD 9: ASPARAGUS, wild from field
INSERT INTO public.food_items (
    food_code,
    name,
    italian_name,
    english_name,
    scientific_name,
    category,
    edible_portion_percent,
    calories_per_100g,
    energy_kj,
    protein_per_100g,
    carbs_per_100g,
    fat_per_100g,
    fiber_per_100g,
    water_g,
    iron_mg,
    calcium_mg,
    sodium_per_100g,
    potassium_mg,
    phosphorus_mg,
    zinc_mg,
    vitamin_c_mg,
    is_verified
) VALUES (
    '304_1',
    'ASPARAGI, di campo',
    'ASPARAGI, di campo',
    'ASPARAGUS, wild from field',
    'Asparagus officinalis',
    '2001'::public.food_category_code,
    87,
    33,
    138,
    3.6,
    3.3,
    0.2,
    2.1,
    91.4,
    1.2,
    25,
    2,
    240,
    77,
    0.3,
    18,
    true
);

-- FOOD 10: ASPARAGUS, greenhouse
INSERT INTO public.food_items (
    food_code,
    name,
    italian_name,
    english_name,
    scientific_name,
    category,
    edible_portion_percent,
    calories_per_100g,
    energy_kj,
    protein_per_100g,
    carbs_per_100g,
    fat_per_100g,
    fiber_per_100g,
    water_g,
    iron_mg,
    calcium_mg,
    sodium_per_100g,
    potassium_mg,
    phosphorus_mg,
    zinc_mg,
    vitamin_c_mg,
    is_verified
) VALUES (
    '305_1',
    'ASPARAGI, di serra',
    'ASPARAGI, di serra',
    'ASPARAGUS, greenhouse',
    'Asparagus officinalis',
    '2001'::public.food_category_code,
    52,
    28,
    120,
    3.0,
    3.0,
    0.1,
    2.1,
    92.0,
    1.0,
    24,
    2,
    278,
    65,
    0.8,
    24,
    true
);

-- ============================================================================
-- VERIFICATION QUERIES (Optional - for testing)
-- ============================================================================

-- Verify all new foods were inserted
DO $$
DECLARE
    inserted_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO inserted_count 
    FROM public.food_items 
    WHERE food_code IN ('382_1', '50399_1', '303_1', '304_1', '305_1');
    
    IF inserted_count = 5 THEN
        RAISE NOTICE 'SUCCESS: All 5 new foods have been successfully added to the database';
    ELSE
        RAISE WARNING 'WARNING: Only % of 5 foods were inserted', inserted_count;
    END IF;
END $$;

-- Display the new foods for verification
-- SELECT 
--     food_code,
--     name,
--     italian_name,
--     english_name,
--     category,
--     calories_per_100g,
--     protein_per_100g
-- FROM public.food_items 
-- WHERE food_code IN ('382_1', '50399_1', '303_1', '304_1', '305_1')
-- ORDER BY food_code;