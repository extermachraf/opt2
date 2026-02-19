-- Location: supabase/migrations/20260113151112_add_missing_italian_recipes.sql
-- Purpose: Add 118 missing Italian recipes from Excel file
-- Generated: 2026-01-13T15:11:12.375517

-- =============================================
-- ADD MISSING ITALIAN RECIPES
-- =============================================

DO $$
DECLARE
    system_user_id UUID;
    recipe_id UUID;
    
BEGIN
    -- Try to get the first user as system user, otherwise use null
    SELECT id INTO system_user_id FROM public.user_profiles LIMIT 1;
    
    RAISE NOTICE 'Starting insertion of 118 recipes...';
    

    -- Recipe 1: Biscotto frollino 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Biscotto frollino ',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1823.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farina Di Frumento, Tipo 00',
        7.0,
        'g',
        7.0,
        348.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        3.5,
        'g',
        3.5,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchero (Saccarosio)',
        3.0,
        'g',
        3.0,
        392.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Tuorlo',
        3.0,
        'g',
        3.0,
        325.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.01,
        'g',
        0.01,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 2: Bollito magro a cubettini freddo con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Bollito magro a cubettini freddo con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1037.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitellone, 15-18 Mesi, Tagli Di Carne Magra, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        108.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 3: Bollito misto
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Bollito misto',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        705.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitellone, 15-18 Mesi, Tagli Di Carne Magra, Senza Grasso Visibile',
        30.0,
        'g',
        30.0,
        108.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitellone, 15-18 Mesi, Pancia, Biancostato, Punta Di Petto, Senza Grasso Visibile',
        30.0,
        'g',
        30.0,
        171.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Lingua',
        20.0,
        'g',
        20.0,
        232.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gallina',
        20.0,
        'g',
        20.0,
        194.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 4: Bollito, tagli magri
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Bollito, tagli magri',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        106.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitellone, 15-18 Mesi, Noce, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        106.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 5: Brasato
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Brasato',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2024.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Manzo, tagli di carne magra',
        100.0,
        'g',
        100.0,
        108.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        20.0,
        'g',
        20.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        25.0,
        'g',
        25.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        5.0,
        'g',
        5.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        5.0,
        'g',
        5.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Alloro, Secco',
        0.5,
        'g',
        0.5,
        341.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cannella',
        0.1,
        'g',
        0.1,
        301.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Rosmarino, Fresco',
        0.5,
        'g',
        0.5,
        111.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 6: Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1512.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bresaola',
        50.0,
        'g',
        50.0,
        151.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        10.0,
        'g',
        10.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Rucola',
        10.0,
        'g',
        10.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Succo Di Limone',
        7.0,
        'g',
        7.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Da Insalata',
        10.0,
        'g',
        10.0,
        19.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 7: Broccoli lessati o al vapore, conditi con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Broccoli lessati o al vapore, conditi con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        932.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Broccolo A Testa',
        200.0,
        'g',
        200.0,
        33.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 8: Bruschetta
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Bruschetta',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1582.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane casereccio a fette',
        50.0,
        'g',
        50.0,
        275.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Origano, Secco Macinato',
        1.0,
        'g',
        1.0,
        408.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 9: Caffelatte (parz. screm.)
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Caffelatte (parz. screm.)',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        48.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte parzialmente scremato ',
        125.0,
        'g',
        125.0,
        46.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Caffe'' Moka, In Tazza',
        30.0,
        'g',
        30.0,
        2.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 10: Caffè "marocchino"
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Caffè "marocchino"',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        479.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Caffè',
        30.0,
        'g',
        30.0,
        2.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte intero',
        10.0,
        'g',
        10.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cacao Amaro, In Polvere',
        5.0,
        'g',
        5.0,
        413.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 11: Caffè macchiato
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Caffè macchiato',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        66.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Caffè espresso',
        30.0,
        'g',
        30.0,
        2.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte intero',
        8.0,
        'g',
        8.0,
        64.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 12: Cappuccino senza zucchero
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cappuccino senza zucchero',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        66.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte intero',
        125.0,
        'g',
        125.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Caffe'' Moka, In Tazza',
        40.0,
        'g',
        40.0,
        2.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 13: Caprese
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Caprese',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1490.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mozzarella (vaccina)',
        100.0,
        'g',
        100.0,
        253.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Da Insalata',
        200.0,
        'g',
        200.0,
        19.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        2.0,
        'g',
        2.0,
        49.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 14: Carciofi in padella con aglio e prezzemolo
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carciofi in padella con aglio e prezzemolo',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1007.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carciofi',
        200.0,
        'g',
        200.0,
        33.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 15: Carciofi, in pinzimonio
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carciofi, in pinzimonio',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        932.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carciofi',
        200.0,
        'g',
        200.0,
        33.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 16: Carote alla julienne, con olio e limone
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carote alla julienne, con olio e limone',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        953.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        200.0,
        'g',
        200.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Limone',
        5.0,
        'g',
        5.0,
        15.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 17: Carote lessate o al vapore, con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carote lessate o al vapore, con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        938.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        200.0,
        'g',
        200.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 18: Carpaccio di manzo condito con scaglie di parmigiano e rucola
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carpaccio di manzo condito con scaglie di parmigiano e rucola',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1693.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Manzo, tagli di carne magra',
        100.0,
        'g',
        100.0,
        108.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        15.0,
        'g',
        15.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva',
        10.0,
        'g',
        10.0,
        900.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Rucola',
        10.0,
        'g',
        10.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 19: Carpaccio di pesce spada, condito
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carpaccio di pesce spada, condito',
        'dinner'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1323.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesce Spada',
        150.0,
        'g',
        150.0,
        109.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Limone',
        10.0,
        'g',
        10.0,
        15.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        4.0,
        'g',
        4.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Main Course');
    

    -- Recipe 20: Carpaccio di spigola o branzino, condito
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Carpaccio di spigola o branzino, condito',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1296.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Spigola Ica',
        150.0,
        'g',
        150.0,
        82.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Limone',
        10.0,
        'g',
        10.0,
        15.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        4.0,
        'g',
        4.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 21: Cavolfiore lessato o al vapore, con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cavolfiore lessato o al vapore, con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        929.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cavolfiore',
        200.0,
        'g',
        200.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 22: Cavolini di Bruxelles lessati o al vapore, con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cavolini di Bruxelles lessati o al vapore, con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        947.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cavoli Di Bruxelles',
        200.0,
        'g',
        200.0,
        48.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 23: Cavolo cappuccio in insalata, tagliato finemente, con extravergne
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cavolo cappuccio in insalata, tagliato finemente, con extravergne',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1195.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cavolo Cappuccio Verde',
        80.0,
        'g',
        80.0,
        22.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aceto',
        5.0,
        'g',
        5.0,
        4.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 24: Ceci in umido con sugo al pomodoro
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Ceci in umido con sugo al pomodoro',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1626.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Ceci, Secchi',
        50.0,
        'g',
        50.0,
        363.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        70.0,
        'g',
        60.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        17.0,
        'g',
        17.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 25: Cicoria o catalogna cotta e condita
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cicoria o catalogna cotta e condita',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1199.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cicoria Catalogna',
        200.0,
        'g',
        200.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 26: Cime di Rapa
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cime di Rapa',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        899.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 27: Cioccolata calda
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cioccolata calda',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1218.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte intero',
        125.0,
        'g',
        125.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cacao Amaro, In Polvere',
        7.0,
        'g',
        7.0,
        413.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Patate, Fecola',
        4.0,
        'g',
        4.0,
        349.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchero (Saccarosio)',
        7.0,
        'g',
        7.0,
        392.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 28: Cipolle al forno
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cipolle al forno',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1285.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        200.0,
        'g',
        200.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Erbe Aromatiche (FOGLIE)',
        1.0,
        'g',
        1.0,
        88.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 29: Cipolle lessate, condite con extravergine 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cipolle lessate, condite con extravergine ',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1227.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        200.0,
        'g',
        200.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 30: Coniglio arrosto
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Coniglio arrosto',
        'dinner'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2079.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Coniglio, Carne Semigrassa',
        100.0,
        'g',
        100.0,
        138.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pancetta Di Maiale',
        5.0,
        'g',
        5.0,
        661.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Rosmarino, Fresco',
        2.0,
        'g',
        2.0,
        111.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Main Course');
    

    -- Recipe 31: Coscia di pollo arrosto (con pelle)
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Coscia di pollo arrosto (con pelle)',
        'dinner'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1112.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pollo, Fuso (COSCIA), Con Pelle',
        100.0,
        'g',
        100.0,
        125.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Erbe Aromatiche (FOGLIE)',
        1.0,
        'g',
        1.0,
        88.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Main Course');
    

    -- Recipe 32: Coscia di pollo arrosto (senza pelle)
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Coscia di pollo arrosto (senza pelle)',
        'dinner'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1094.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pollo, Fuso (COSCIA), Senza Pelle',
        100.0,
        'g',
        100.0,
        107.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Erbe Aromatiche (FOGLIE)',
        1.0,
        'g',
        1.0,
        88.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Main Course');
    

    -- Recipe 33: Coscia di tacchino al forno
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Coscia di tacchino al forno',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1113.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Tacchino, coscia',
        100.0,
        'g',
        100.0,
        126.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Erbe Aromatiche (FOGLIE)',
        1.0,
        'g',
        1.0,
        88.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 34: Coste o biete lessate con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Coste o biete lessate con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        918.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Coste o biete lessate con extravergine',
        200.0,
        'g',
        200.0,
        19.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 35: Costine di maiale ai ferri
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Costine di maiale ai ferri',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        268.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Suino, Carne Grassa, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        268.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 36: Cotoletta alla milanese
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Cotoletta alla milanese',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1339.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitello, 4 Mesi, Carne Magra, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        92.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane Grattugiato',
        13.0,
        'g',
        13.0,
        361.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Intero',
        25.0,
        'g',
        25.0,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        15.0,
        'g',
        15.0,
        758.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 37: Crema di ceci 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crema di ceci ',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1565.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Ceci, Secchi',
        50.0,
        'g',
        50.0,
        363.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 38: Crema di fagioli cannellini 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crema di fagioli cannellini ',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1547.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli, Secchi',
        50.0,
        'g',
        50.0,
        345.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 39: Crema di piselli
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crema di piselli',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1689.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Piselli Surgelati',
        150.0,
        'g',
        150.0,
        70.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        0.5,
        'g',
        0.5,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 40: Crema di piselli con patate
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crema di piselli con patate',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1769.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Piselli Surgelati',
        150.0,
        'g',
        150.0,
        70.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Patate',
        70.0,
        'g',
        70.0,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 41: Crema di zucca
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crema di zucca',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1753.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucca Gialla',
        200.0,
        'g',
        200.0,
        19.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Salvia, Fresca',
        2.0,
        'g',
        2.0,
        145.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 42: Crema porri e patate
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crema porri e patate',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1879.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Porri',
        100.0,
        'g',
        100.0,
        35.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Patate',
        200.0,
        'g',
        200.0,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        1.0,
        'g',
        1.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Salvia, Fresca',
        2.0,
        'g',
        2.0,
        145.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 43: Crostata alla marmellata 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Crostata alla marmellata ',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2037.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farina Di Frumento, Tipo 00',
        25.0,
        'g',
        25.0,
        348.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        13.0,
        'g',
        13.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchero (Saccarosio)',
        11.0,
        'g',
        11.0,
        392.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Tuorlo',
        19.0,
        'g',
        19.0,
        325.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Marmellata ',
        32.0,
        'g',
        32.0,
        214.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 44: Fagioli all'uccelletto 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fagioli all''uccelletto ',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1740.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli, Secchi',
        50.0,
        'g',
        50.0,
        345.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        70.0,
        'g',
        70.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Salvia, Fresca',
        2.0,
        'g',
        2.0,
        145.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 45: Fagioli con nervetti
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fagioli con nervetti',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1329.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli, Secchi',
        50.0,
        'g',
        50.0,
        345.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Nervetti (bovino)',
        50.0,
        'g',
        50.0,
        85.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 46: Fagioli in umido con sugo al pomodoro
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fagioli in umido con sugo al pomodoro',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1608.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli, Secchi',
        50.0,
        'g',
        50.0,
        345.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        15.0,
        'g',
        15.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        70.0,
        'g',
        70.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 47: Fagiolini in padella
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fagiolini in padella',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1003.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cornetti o fagiolini',
        200.0,
        'g',
        200.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        50.0,
        'g',
        50.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 48: Fagiolini lessati e conditi
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fagiolini lessati e conditi',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1193.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cornetti o fagiolini',
        200.0,
        'g',
        200.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 49: Farro bollito condito con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Farro bollito condito con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1252.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farro',
        80.0,
        'g',
        80.0,
        353.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 50: Fegato alla veneta
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fegato alla veneta',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1546.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Fegato',
        100.0,
        'g',
        100.0,
        142.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        10.0,
        'g',
        10.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farina Di Frumento, Tipo 00',
        4.0,
        'g',
        4.0,
        348.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        40.0,
        'g',
        40.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 51: Filetti di merluzzo con pomodori, olive e capperi
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Filetti di merluzzo con pomodori, olive e capperi',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1623.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Merluzzo',
        150.0,
        'g',
        150.0,
        71.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        15.0,
        'g',
        15.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olive Nere',
        15.0,
        'g',
        15.0,
        240.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        150.0,
        'g',
        150.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        3.0,
        'g',
        3.0,
        49.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 52: Filetto di manzo ai ferri
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Filetto di manzo ai ferri',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1296.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitellone, 15-18 Mesi, Filetto, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        127.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 53: Finocchi gratinati
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Finocchi gratinati',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2725.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Finocchio',
        200.0,
        'g',
        200.0,
        13.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        10.0,
        'g',
        10.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        67.93478260869566,
        'g',
        67.93478260869566,
        46.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        4.076086956521739,
        'g',
        4.076086956521739,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        1.9021739130434783,
        'g',
        1.9021739130434783,
        321.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        0.9510869565217391,
        'g',
        0.9510869565217391,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        0.1358695652173913,
        'g',
        0.1358695652173913,
        442.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 54: Finocchi in insalata 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Finocchi in insalata ',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1182.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Finocchio',
        200.0,
        'g',
        200.0,
        13.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 55: Finocchi in insalata con arance
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Finocchi in insalata con arance',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1219.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Finocchio',
        150.0,
        'g',
        150.0,
        13.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Arance',
        50.0,
        'g',
        50.0,
        37.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 56: Finocchi in padella
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Finocchi in padella',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        957.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Finocchio',
        200.0,
        'g',
        200.0,
        13.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 57: Fragole con gelato fiordilatte
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fragole con gelato fiordilatte',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        248.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fragole',
        150.0,
        'g',
        150.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gelato Fior Di Latte',
        100.0,
        'g',
        100.0,
        218.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 58: Fragole zucchero e limone
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Fragole zucchero e limone',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        428.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fragole',
        150.0,
        'g',
        150.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchero (Saccarosio)',
        5.0,
        'g',
        5.0,
        392.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Succo Di Limone, Fresco',
        5.0,
        'g',
        5.0,
        6.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 59: Frittata
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Frittata',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1414.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Intero',
        50.0,
        'g',
        50.0,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        5.0,
        'g',
        5.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.15,
        'g',
        0.15,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 60: Frittata con porri
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Frittata con porri',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1449.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Intero',
        50.0,
        'g',
        50.0,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Porri',
        40.0,
        'g',
        40.0,
        35.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        5.0,
        'g',
        5.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.15,
        'g',
        0.15,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 61: Funghi misti trifolati
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Funghi misti trifolati',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1079.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Funghi Porcini',
        50.0,
        'g',
        50.0,
        32.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Funghi Chiodini',
        50.0,
        'g',
        50.0,
        29.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Funghi Gallinacci',
        50.0,
        'g',
        50.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Funghi Prataioli, Coltivati',
        50.0,
        'g',
        50.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        1.0,
        'g',
        1.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 62: Gelato alle creme
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gelato alle creme',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        436.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gelato Al Cioccolato',
        50.0,
        'g',
        50.0,
        218.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gelato alla panna',
        50.0,
        'g',
        50.0,
        218.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 63: Gnocchi di patate al gorgonzola
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gnocchi di patate al gorgonzola',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2540.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        146.41288433382138,
        'g',
        146.41288433382138,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        43.92386530014641,
        'g',
        43.92386530014641,
        323.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        8.931185944363104,
        'g',
        8.931185944363104,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        0.7320644216691069,
        'g',
        0.7320644216691069,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gorgonzola',
        45.0,
        'g',
        45.0,
        324.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        10.0,
        'g',
        10.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte Di Vacca, Intero Pastorizzato',
        13.0,
        'g',
        13.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        5.0,
        'g',
        5.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Panna, 20% Di Lipidi (da Cucina)',
        12.0,
        'g',
        12.0,
        206.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 64: Gnocchi di patate al pesto
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gnocchi di patate al pesto',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        3794.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        146.41288433382138,
        'g',
        146.41288433382138,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        43.92386530014641,
        'g',
        43.92386530014641,
        323.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        8.931185944363104,
        'g',
        8.931185944363104,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        0.7320644216691069,
        'g',
        0.7320644216691069,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        5.535055350553505,
        'g',
        5.535055350553505,
        49.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        5.535055350553505,
        'g',
        5.535055350553505,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        5.535055350553505,
        'g',
        5.535055350553505,
        900.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        3.321033210332103,
        'g',
        3.321033210332103,
        379.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        7.749077490774908,
        'g',
        7.749077490774908,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        1.6605166051660516,
        'g',
        1.6605166051660516,
        604.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pesto',
        0.6642066420664207,
        'g',
        0.6642066420664207,
        45.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 65: Gnocchi di patate al pomodoro
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gnocchi di patate al pomodoro',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1881.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        146.41288433382138,
        'g',
        146.41288433382138,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        43.92386530014641,
        'g',
        43.92386530014641,
        323.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        8.931185944363104,
        'g',
        8.931185944363104,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        0.7320644216691069,
        'g',
        0.7320644216691069,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        15.0,
        'g',
        15.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        50.0,
        'g',
        50.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 66: Gnocchi di patate al ragù
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gnocchi di patate al ragù',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2368.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        146.41288433382138,
        'g',
        146.41288433382138,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        43.92386530014641,
        'g',
        43.92386530014641,
        323.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        8.931185944363104,
        'g',
        8.931185944363104,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        0.7320644216691069,
        'g',
        0.7320644216691069,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carne trita scelta',
        50.0,
        'g',
        50.0,
        155.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        15.0,
        'g',
        15.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        15.0,
        'g',
        15.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        15.0,
        'g',
        15.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        60.0,
        'g',
        60.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 67: Gnocchi di patate con burro e salvia
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gnocchi di patate con burro e salvia',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1821.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        146.41288433382138,
        'g',
        146.41288433382138,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        43.92386530014641,
        'g',
        43.92386530014641,
        323.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        8.931185944363104,
        'g',
        8.931185944363104,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        0.7320644216691069,
        'g',
        0.7320644216691069,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Salvia, Fresca',
        5.0,
        'g',
        5.0,
        145.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        10.0,
        'g',
        10.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 68: Gnocchi di patate olio e parmigiano
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Gnocchi di patate olio e parmigiano',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1817.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        146.41288433382138,
        'g',
        146.41288433382138,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        43.92386530014641,
        'g',
        43.92386530014641,
        323.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        8.931185944363104,
        'g',
        8.931185944363104,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gnocchi freschi di patate',
        0.7320644216691069,
        'g',
        0.7320644216691069,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 69: Hamburger di manzo da polpa scelta
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Hamburger di manzo da polpa scelta',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1054.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carne trita scelta',
        100.0,
        'g',
        100.0,
        155.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 70: Insalata di baccalà con prezzemolo e olive
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di baccalà con prezzemolo e olive',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1264.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Baccala'', Ammollato',
        150.0,
        'g',
        150.0,
        95.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olive Nere',
        7.0,
        'g',
        7.0,
        240.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 71: Insalata di fagioli con cipolle
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di fagioli con cipolle',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1302.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli, Secchi',
        50.0,
        'g',
        50.0,
        345.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        100.0,
        'g',
        100.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 72: Insalata di fagioli e pomodori
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di fagioli e pomodori',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1293.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli, Secchi',
        50.0,
        'g',
        50.0,
        345.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        18.0,
        'g',
        18.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        120.0,
        'g',
        120.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 73: Insalata di farro con verdure a cubetti saltate o grigliate
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di farro con verdure a cubetti saltate o grigliate',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1408.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farro',
        80.0,
        'g',
        80.0,
        353.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Melanzane',
        20.0,
        'g',
        20.0,
        20.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Da Insalata',
        20.0,
        'g',
        20.0,
        19.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        10.0,
        'g',
        10.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Peperoni Dolci',
        20.0,
        'g',
        20.0,
        26.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        3.0,
        'g',
        3.0,
        49.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 74: Insalata di farro riso e orzo con dadini di verdure
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di farro riso e orzo con dadini di verdure',
        'lunch'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2043.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Orzo',
        25.0,
        'g',
        25.0,
        337.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Riso',
        25.0,
        'g',
        25.0,
        365.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farro',
        30.0,
        'g',
        30.0,
        353.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        30.0,
        'g',
        30.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cetrioli',
        30.0,
        'g',
        30.0,
        15.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        30.0,
        'g',
        30.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 75: Insalata di farro riso e orzo con piselli e olio a crudo
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di farro riso e orzo con piselli e olio a crudo',
        'lunch'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2411.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Riso, Brillato',
        25.0,
        'g',
        25.0,
        365.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Orzo',
        25.0,
        'g',
        25.0,
        337.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farro',
        30.0,
        'g',
        30.0,
        353.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Piselli Surgelati',
        50.0,
        'g',
        50.0,
        70.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 76: Insalata di gamberetti con olio, prezzemolo e limone
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di gamberetti con olio, prezzemolo e limone',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1006.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gamberetti',
        150.0,
        'g',
        150.0,
        71.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Succo Di Limone, Fresco',
        5.0,
        'g',
        5.0,
        6.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 77: Insalata di mare
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di mare',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1421.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Calamaro',
        40.0,
        'g',
        40.0,
        68.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gamberetti',
        20.0,
        'g',
        20.0,
        71.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Polpo',
        30.0,
        'g',
        30.0,
        57.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cozza O Mitilo',
        20.0,
        'g',
        20.0,
        84.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Vongola',
        20.0,
        'g',
        20.0,
        72.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Seppia',
        20.0,
        'g',
        20.0,
        72.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        30.0,
        'g',
        30.0,
        23.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 78: Insalata di polpo con patate
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di polpo con patate',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1342.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Polpo',
        150.0,
        'g',
        150.0,
        57.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Patate',
        200.0,
        'g',
        200.0,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Succo Di Limone, Fresco',
        5.0,
        'g',
        5.0,
        6.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 79: Insalata di riso 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata di riso ',
        'lunch'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1965.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Riso',
        80.0,
        'g',
        80.0,
        365.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Piselli Surgelati',
        20.0,
        'g',
        20.0,
        70.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cetriolini Sott''aceto',
        20.0,
        'g',
        20.0,
        17.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolline Sott''aceto',
        20.0,
        'g',
        20.0,
        26.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Intero',
        20.0,
        'g',
        20.0,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        20.0,
        'g',
        20.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        20.0,
        'g',
        20.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Tonno Sott''olio, Sgocciolato',
        20.0,
        'g',
        20.0,
        192.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prosciutto Cotto',
        15.0,
        'g',
        15.0,
        215.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 80: Insalata fredda di ceci con extravergine
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata fredda di ceci con extravergine',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1562.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Ceci, Secchi',
        50.0,
        'g',
        50.0,
        363.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        4.0,
        'g',
        4.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 81: Insalata fredda di ceci con peperonata
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata fredda di ceci con peperonata',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1598.5866290018832,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Ceci, Secchi',
        50.0,
        'g',
        50.0,
        363.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Peperonata',
        100.0,
        'g',
        100.0,
        66.58662900188324
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 82: Insalata mista con carote e pomodori, condita
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata mista con carote e pomodori, condita',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1003.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Radicchio Rosso',
        40.0,
        'g',
        40.0,
        18.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Lattuga',
        40.0,
        'g',
        40.0,
        22.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        40.0,
        'g',
        40.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        60.0,
        'g',
        60.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aceto',
        5.0,
        'g',
        5.0,
        4.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 83: Insalata, condita
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Insalata, condita',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        922.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Insalata Ns',
        80.0,
        'g',
        80.0,
        19.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aceto',
        5.0,
        'g',
        5.0,
        4.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 84: Involtini di carne con spinaci
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Involtini di carne con spinaci',
        'dinner'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1691.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Manzo, tagli di carne magra',
        100.0,
        'g',
        100.0,
        108.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fontina',
        20.0,
        'g',
        20.0,
        343.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Spinaci',
        70.0,
        'g',
        70.0,
        35.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        25.0,
        'g',
        25.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Main Course');
    

    -- Recipe 85: Involtini di pollo con prosciutto e formaggio
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Involtini di pollo con prosciutto e formaggio',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1827.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pollo, Petto, Senza Pelle',
        100.0,
        'g',
        100.0,
        100.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prosciutto Cotto',
        20.0,
        'g',
        20.0,
        215.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fontina',
        20.0,
        'g',
        20.0,
        343.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 86: Lasagne alla bolognese
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Lasagne alla bolognese',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        4647.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pasta All''uovo, Secca',
        30.0,
        'g',
        30.0,
        375.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitellone, 15-18 Mesi, Scamone, Senza Grasso Visibile',
        40.0,
        'g',
        40.0,
        119.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        67.93478260869566,
        'g',
        67.93478260869566,
        46.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        4.076086956521739,
        'g',
        4.076086956521739,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        1.9021739130434783,
        'g',
        1.9021739130434783,
        321.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        0.9510869565217391,
        'g',
        0.9510869565217391,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Besciamella',
        0.1358695652173913,
        'g',
        0.1358695652173913,
        442.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Suino, Leggero, Lombo, Senza Grasso Visibile',
        10.0,
        'g',
        10.0,
        146.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        19.0,
        'g',
        19.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        10.0,
        'g',
        10.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        8.0,
        'g',
        8.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        40.0,
        'g',
        40.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        5.0,
        'g',
        5.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano grattuggiato',
        10.0,
        'g',
        10.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        2.6,
        'g',
        2.6,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 87: Latte macchiato
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Latte macchiato',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        66.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Latte intero',
        125.0,
        'g',
        125.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Caffè',
        30.0,
        'g',
        30.0,
        2.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 88: Lattuga, condita
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Lattuga, condita',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        925.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Lattuga',
        80.0,
        'g',
        80.0,
        22.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aceto',
        5.0,
        'g',
        5.0,
        4.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 89: Lenticchie in umido con sugo al pomodoro
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Lenticchie in umido con sugo al pomodoro',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1645.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Lenticchie, Secche',
        50.0,
        'g',
        50.0,
        352.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        18.0,
        'g',
        18.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        72.0,
        'g',
        72.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Peperoncini Piccanti',
        0.3,
        'g',
        0.3,
        30.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 90: Lonza di maiale in padella
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Lonza di maiale in padella',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1414.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Suino, Leggero, Bistecca, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        157.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Erbe Aromatiche (FOGLIE)',
        2.0,
        'g',
        2.0,
        88.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 91: Macedonia
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Macedonia',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        755.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mele, Senza Buccia',
        30.0,
        'g',
        30.0,
        57.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pera, Senza Buccia',
        30.0,
        'g',
        30.0,
        43.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Kiwi',
        30.0,
        'g',
        30.0,
        48.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mandarini',
        20.0,
        'g',
        20.0,
        76.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Banana',
        20.0,
        'g',
        20.0,
        69.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uva',
        20.0,
        'g',
        20.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchero (Saccarosio)',
        5.0,
        'g',
        5.0,
        392.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Succo Di Limone',
        5.0,
        'g',
        5.0,
        6.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 92: Macedonia con due palline di gelato
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Macedonia con due palline di gelato',
        'dessert'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        575.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mele, Senza Buccia',
        30.0,
        'g',
        30.0,
        57.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pera, Senza Buccia',
        30.0,
        'g',
        30.0,
        43.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Banana',
        20.0,
        'g',
        20.0,
        69.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Kiwi',
        30.0,
        'g',
        30.0,
        48.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uva',
        20.0,
        'g',
        20.0,
        64.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mandarini',
        20.0,
        'g',
        20.0,
        76.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Gelato alla panna',
        100.0,
        'g',
        100.0,
        218.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Dessert');
    

    -- Recipe 93: Mela cotta con cannella
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Mela cotta con cannella',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        737.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mele, Con Buccia',
        150.0,
        'g',
        150.0,
        44.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchero (Saccarosio)',
        5.0,
        'g',
        5.0,
        392.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cannella',
        2.0,
        'g',
        2.0,
        301.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 94: Melanzane al pomodoro
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Melanzane al pomodoro',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1049.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Melanzane',
        200.0,
        'g',
        200.0,
        20.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        5.0,
        'g',
        5.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        80.0,
        'g',
        80.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        5.0,
        'g',
        5.0,
        49.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 95: Melanzane grigliate
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Melanzane grigliate',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        964.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Melanzane',
        200.0,
        'g',
        200.0,
        20.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 96: Melanzane in carrozza
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Melanzane in carrozza',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1697.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Melanzane',
        200.0,
        'g',
        200.0,
        20.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mozzarella (vaccina)',
        80.0,
        'g',
        80.0,
        253.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        25.0,
        'g',
        25.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Uovo Di Gallina, Intero',
        20.0,
        'g',
        20.0,
        128.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farina Di Frumento, Tipo 00',
        10.0,
        'g',
        10.0,
        348.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        2.0,
        'g',
        2.0,
        49.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 97: Merluzzo al vapore con olio
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Merluzzo al vapore con olio',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1000.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Merluzzo',
        150.0,
        'g',
        150.0,
        71.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        3.0,
        'g',
        3.0,
        30.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 98: Minestrone di verdure con patate e legumi
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Minestrone di verdure con patate e legumi',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1980.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Vegetale',
        125.0,
        'g',
        125.0,
        6.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Verza',
        30.0,
        'g',
        30.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        50.0,
        'g',
        50.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        50.0,
        'g',
        50.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        50.0,
        'g',
        50.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        20.0,
        'g',
        20.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fagioli lessati',
        25.0,
        'g',
        25.0,
        58.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Piselli Surgelati',
        25.0,
        'g',
        25.0,
        70.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Patate',
        50.0,
        'g',
        50.0,
        80.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 99: Minestrone di verdure senza patate e legumi
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Minestrone di verdure senza patate e legumi',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1785.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        40.0,
        'g',
        40.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Verza',
        30.0,
        'g',
        30.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        50.0,
        'g',
        50.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        20.0,
        'g',
        20.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 100: Minestrone di verdure senza patate e legumi con orzo
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Minestrone di verdure senza patate e legumi con orzo',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2122.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        30.0,
        'g',
        30.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Verza',
        30.0,
        'g',
        30.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        30.0,
        'g',
        30.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        20.0,
        'g',
        20.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        20.0,
        'g',
        20.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Orzo, Perlato',
        40.0,
        'g',
        40.0,
        337.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 101: Minestrone di verdure senza patate e legumi con pastina 
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Minestrone di verdure senza patate e legumi con pastina ',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2147.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        30.0,
        'g',
        30.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Verza',
        30.0,
        'g',
        30.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        30.0,
        'g',
        30.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        20.0,
        'g',
        20.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        20.0,
        'g',
        20.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pasta Di Semola',
        40.0,
        'g',
        40.0,
        362.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 102: Minestrone di verdure senza patate e legumi con riso
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Minestrone di verdure senza patate e legumi con riso',
        'lunch'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2150.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        30.0,
        'g',
        30.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Verza',
        30.0,
        'g',
        30.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        30.0,
        'g',
        30.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        20.0,
        'g',
        20.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        20.0,
        'g',
        20.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Riso, Brillato',
        40.0,
        'g',
        40.0,
        365.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        2.0,
        'g',
        2.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 103: Nervetti a cubetti
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Nervetti a cubetti',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        85.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Nervetti (bovino)',
        100.0,
        'g',
        50.0,
        85.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 104: Nodino di vitello ai ferri
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Nodino di vitello ai ferri',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1261.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Bovino, Vitello, 4 Mesi, Carne Magra, Senza Grasso Visibile',
        100.0,
        'g',
        100.0,
        92.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 105: Orata al forno, sfilettata
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Orata al forno, sfilettata',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1058.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Orata D''allevamento, Filetti',
        150.0,
        'g',
        150.0,
        159.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 106: Orecchiette con i broccoli
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Orecchiette con i broccoli',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1815.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pasta Di Semola',
        80.0,
        'g',
        80.0,
        362.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Broccolo A Testa',
        150.0,
        'g',
        150.0,
        33.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Acciughe O Alici Sott''olio',
        5.0,
        'g',
        5.0,
        206.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 107: Ortaggi misti, conditi
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Ortaggi misti, conditi',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1030.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        40.0,
        'g',
        40.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        35.0,
        'g',
        35.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cetrioli',
        35.0,
        'g',
        35.0,
        15.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Finocchio',
        30.0,
        'g',
        30.0,
        13.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Peperoni Dolci',
        30.0,
        'g',
        30.0,
        26.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Ravanelli',
        30.0,
        'g',
        30.0,
        13.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aceto',
        5.0,
        'g',
        5.0,
        4.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 108: Orzo bollito con olio a crudo
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Orzo bollito con olio a crudo',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1236.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Orzo, Perlato',
        80.0,
        'g',
        80.0,
        337.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 109: Pancotto bianco
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Pancotto bianco',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1728.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Vegetale',
        125.0,
        'g',
        125.0,
        6.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane secco o raffermo',
        50.0,
        'g',
        50.0,
        307.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Burro',
        10.0,
        'g',
        10.0,
        758.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano grattuggiato',
        10.0,
        'g',
        10.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 110: Pancotto rosso
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Pancotto rosso',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1944.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        75.0,
        'g',
        75.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane secco o raffermo',
        50.0,
        'g',
        50.0,
        307.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano grattuggiato',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        3.0,
        'g',
        3.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 111: Panino con hamburger
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Panino con hamburger',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        956.0308250226655,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane Comune',
        50.0,
        'g',
        50.0,
        282.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Hamburger da polpa scelta',
        100.0,
        'g',
        100.0,
        222.03082502266545
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cheddar',
        25.0,
        'g',
        25.0,
        381.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        50.0,
        'g',
        50.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Lattuga',
        10.0,
        'g',
        10.0,
        22.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        10.0,
        'g',
        10.0,
        28.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 112: Panino rosetta con prosciutto cotto
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Panino rosetta con prosciutto cotto',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        497.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane tipo rosetta o michetta o tartaruga',
        50.0,
        'g',
        50.0,
        282.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prosciutto Cotto',
        25.0,
        'g',
        25.0,
        215.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 113: Panino rosetta con prosciutto cotto e fontina
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Panino rosetta con prosciutto cotto e fontina',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        840.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane tipo rosetta o michetta o tartaruga',
        50.0,
        'g',
        50.0,
        282.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prosciutto Cotto',
        25.0,
        'g',
        25.0,
        215.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Fontina',
        25.0,
        'g',
        25.0,
        343.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 114: Panino rosetta con salame
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Panino rosetta con salame',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        666.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane tipo rosetta o michetta o tartaruga',
        50.0,
        'g',
        50.0,
        282.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Salame Brianza',
        25.0,
        'g',
        25.0,
        384.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 115: Panzanella
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Panzanella',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1601.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane secco o raffermo',
        50.0,
        'g',
        50.0,
        307.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        100.0,
        'g',
        100.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        10.0,
        'g',
        10.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        2.0,
        'g',
        2.0,
        49.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aceto',
        5.0,
        'g',
        5.0,
        4.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        10.0,
        'g',
        10.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 116: Pappa al pomodoro
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Pappa al pomodoro',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1611.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        180.0,
        'g',
        180.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pane secco o raffermo',
        50.0,
        'g',
        50.0,
        307.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        3.0,
        'g',
        3.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        3.0,
        'g',
        3.0,
        49.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 117: Parmigiana di melanzane
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Parmigiana di melanzane',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        2335.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Melanzane',
        200.0,
        'g',
        200.0,
        20.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Mozzarella (vaccina)',
        50.0,
        'g',
        50.0,
        253.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Passata di pomodoro',
        85.0,
        'g',
        85.0,
        36.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        15.0,
        'g',
        15.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        20.0,
        'g',
        20.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Basilico, Fresco',
        2.0,
        'g',
        2.0,
        49.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Farina Di Frumento, Tipo 00',
        10.0,
        'g',
        10.0,
        348.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        25.0,
        'g',
        25.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sale Da Cucina',
        0.3,
        'g',
        0.3,
        0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    -- Recipe 118: Passato di verdure senza patate e legumi
    INSERT INTO public.recipes (
        id, title, category, difficulty, prep_time_minutes, cook_time_minutes,
        servings, is_public, is_verified, created_by,
        total_calories, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g
    ) VALUES (
        gen_random_uuid(),
        'Passato di verdure senza patate e legumi',
        'snack'::public.recipe_category,
        'easy'::public.recipe_difficulty,
        15, -- default prep time
        0,  -- default cook time
        2,  -- default servings
        true,
        true,
        system_user_id,
        1785.0,
        0,
        0,
        0,
        0
    ) RETURNING id INTO recipe_id;
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Brodo Di Carne E Verdura',
        125.0,
        'g',
        125.0,
        5.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pomodori Maturi',
        30.0,
        'g',
        30.0,
        21.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Verza',
        30.0,
        'g',
        30.0,
        24.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Zucchine',
        30.0,
        'g',
        30.0,
        14.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Aglio, Fresco',
        2.0,
        'g',
        2.0,
        45.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Carote',
        40.0,
        'g',
        40.0,
        39.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Cipolle',
        30.0,
        'g',
        30.0,
        28.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Prezzemolo, Fresco',
        1.0,
        'g',
        1.0,
        30.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Sedano',
        40.0,
        'g',
        40.0,
        23.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Parmigiano',
        5.0,
        'g',
        5.0,
        387.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Olio Di Oliva Extravergine',
        10.0,
        'g',
        10.0,
        899.0
    );
    
    INSERT INTO public.recipe_ingredients (
        recipe_id, ingredient_name, quantity, unit, weight_grams, calories
    ) VALUES (
        recipe_id,
        'Pepe Nero',
        0.1,
        'g',
        0.1,
        270.0
    );
    
    INSERT INTO public.recipe_tags (recipe_id, tag_name)
    VALUES (recipe_id, 'Italian');
    

    RAISE NOTICE 'Successfully inserted % recipes', 118;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting recipes: %', SQLERRM;
        RAISE;
END $$;

-- Verify insertion
DO $$
DECLARE
    recipe_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO recipe_count FROM public.recipes;
    RAISE NOTICE 'Total recipes in database: %', recipe_count;
END $$;
