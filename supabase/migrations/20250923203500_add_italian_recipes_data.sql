-- Schema Analysis: Complete recipe management system exists (recipes, recipe_ingredients, food_items, recipe_tags)
-- Integration Type: Data addition - inserting Italian recipe collection
-- Dependencies: recipes, recipe_ingredients, food_items, recipe_tags tables

-- Add Italian recipes collection to existing recipe management system
DO $$
DECLARE
    -- System user for verified recipes
    system_user_id UUID := '9b1cd123-6145-4763-89ac-6e629a4b4b6c'; -- Using existing system user

    -- Recipe IDs
    recipe_1_id UUID := gen_random_uuid();
    recipe_2_id UUID := gen_random_uuid();
    recipe_3_id UUID := gen_random_uuid();
    recipe_4_id UUID := gen_random_uuid();
    recipe_5_id UUID := gen_random_uuid();
    recipe_6_id UUID := gen_random_uuid();
    recipe_7_id UUID := gen_random_uuid();
    recipe_8_id UUID := gen_random_uuid();
    recipe_9_id UUID := gen_random_uuid();
    recipe_10_id UUID := gen_random_uuid();
    recipe_11_id UUID := gen_random_uuid();
    recipe_12_id UUID := gen_random_uuid();
    recipe_13_id UUID := gen_random_uuid();
    recipe_14_id UUID := gen_random_uuid();
    recipe_15_id UUID := gen_random_uuid();
    recipe_16_id UUID := gen_random_uuid();
    recipe_17_id UUID := gen_random_uuid();
    recipe_18_id UUID := gen_random_uuid();
    recipe_19_id UUID := gen_random_uuid();
    recipe_20_id UUID := gen_random_uuid();
    recipe_21_id UUID := gen_random_uuid();
    recipe_22_id UUID := gen_random_uuid();
    recipe_23_id UUID := gen_random_uuid();
    recipe_24_id UUID := gen_random_uuid();
    recipe_25_id UUID := gen_random_uuid();
    recipe_26_id UUID := gen_random_uuid();
    recipe_27_id UUID := gen_random_uuid();
    recipe_28_id UUID := gen_random_uuid();
    recipe_29_id UUID := gen_random_uuid();
    recipe_30_id UUID := gen_random_uuid();
    recipe_31_id UUID := gen_random_uuid();
    recipe_32_id UUID := gen_random_uuid();
    recipe_33_id UUID := gen_random_uuid();
    recipe_34_id UUID := gen_random_uuid();
    recipe_35_id UUID := gen_random_uuid();
    recipe_36_id UUID := gen_random_uuid();
    recipe_37_id UUID := gen_random_uuid();
    recipe_38_id UUID := gen_random_uuid();
    recipe_39_id UUID := gen_random_uuid();
    recipe_40_id UUID := gen_random_uuid();
    recipe_41_id UUID := gen_random_uuid();
    recipe_42_id UUID := gen_random_uuid();
    recipe_43_id UUID := gen_random_uuid();
    recipe_44_id UUID := gen_random_uuid();
    recipe_45_id UUID := gen_random_uuid();
    recipe_46_id UUID := gen_random_uuid();
    recipe_47_id UUID := gen_random_uuid();
    recipe_48_id UUID := gen_random_uuid();
    recipe_49_id UUID := gen_random_uuid();
    recipe_50_id UUID := gen_random_uuid();

BEGIN
    -- Insert Italian recipes
    INSERT INTO public.recipes (id, title, category, servings, difficulty, prep_time_minutes, cook_time_minutes, is_public, is_verified, created_by) VALUES
        (recipe_1_id, 'Cavolfiore lessato o al vapore, con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 15, true, true, system_user_id),
        (recipe_2_id, 'Cavolini di Bruxelles lessati o al vapore, con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 15, true, true, system_user_id),
        (recipe_3_id, 'Cavolo cappuccio in insalata, tagliato finemente, con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 10, 0, true, true, system_user_id),
        (recipe_4_id, 'Ceci in umido con sugo al pomodoro', 'lunch'::public.recipe_category, 3, 'medium'::public.recipe_difficulty, 15, 30, true, true, system_user_id),
        (recipe_5_id, 'Cicoria o catalogna cotta e condita', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 10, true, true, system_user_id),
        (recipe_6_id, 'Cioccolata calda', 'beverage'::public.recipe_category, 1, 'easy'::public.recipe_difficulty, 5, 10, true, true, system_user_id),
        (recipe_7_id, 'Cipolle al forno', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 10, 45, true, true, system_user_id),
        (recipe_8_id, 'Cipolle lessate, condite con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 20, true, true, system_user_id),
        (recipe_9_id, 'Coniglio arrosto', 'dinner'::public.recipe_category, 4, 'hard'::public.recipe_difficulty, 20, 60, true, true, system_user_id),
        (recipe_10_id, 'Coscia di pollo arrosto (con pelle)', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 10, 45, true, true, system_user_id),
        (recipe_11_id, 'Coscia di pollo arrosto (senza pelle)', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 10, 45, true, true, system_user_id),
        (recipe_12_id, 'Coscia di tacchino al forno', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 15, 50, true, true, system_user_id),
        (recipe_13_id, 'Coste o biete lessate con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 15, true, true, system_user_id),
        (recipe_14_id, 'Costine di maiale ai ferri', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 5, 20, true, true, system_user_id),
        (recipe_15_id, 'Cotoletta alla milanese', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 15, 10, true, true, system_user_id),
        (recipe_16_id, 'Crema di ceci', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 30, true, true, system_user_id),
        (recipe_17_id, 'Crema di fagioli cannellini', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 30, true, true, system_user_id),
        (recipe_18_id, 'Crema di piselli', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 10, 25, true, true, system_user_id),
        (recipe_19_id, 'Crema di piselli con patate', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 30, true, true, system_user_id),
        (recipe_20_id, 'Crema di zucca', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 25, true, true, system_user_id),
        (recipe_21_id, 'Crema porri e patate', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 20, 35, true, true, system_user_id),
        (recipe_22_id, 'Crostata alla marmellata', 'dessert'::public.recipe_category, 8, 'medium'::public.recipe_difficulty, 30, 40, true, true, system_user_id),
        (recipe_23_id, 'Fagioli all''uccelletto', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 25, true, true, system_user_id),
        (recipe_24_id, 'Fagioli con nervetti', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 20, 30, true, true, system_user_id),
        (recipe_25_id, 'Fagioli in umido con sugo al pomodoro', 'lunch'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 30, true, true, system_user_id),
        (recipe_26_id, 'Fagiolini in padella', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 10, 15, true, true, system_user_id),
        (recipe_27_id, 'Alici marinate', 'lunch'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 30, 0, true, true, system_user_id),
        (recipe_28_id, 'Arrosticini di agnello', 'dinner'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 15, 20, true, true, system_user_id),
        (recipe_29_id, 'Arrosto di vitello', 'dinner'::public.recipe_category, 6, 'hard'::public.recipe_difficulty, 20, 90, true, true, system_user_id),
        (recipe_30_id, 'Asparagi lessati e conditi', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 12, true, true, system_user_id),
        (recipe_31_id, 'Banana zucchero e limone', 'dessert'::public.recipe_category, 1, 'easy'::public.recipe_difficulty, 5, 0, true, true, system_user_id),
        (recipe_32_id, 'Besciamella', 'supplement'::public.recipe_category, 4, 'medium'::public.recipe_difficulty, 5, 10, true, true, system_user_id),
        (recipe_33_id, 'Biscotto frollino', 'snack'::public.recipe_category, 10, 'medium'::public.recipe_difficulty, 20, 15, true, true, system_user_id),
        (recipe_34_id, 'Bistecca alla pizzaiola', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 10, 15, true, true, system_user_id),
        (recipe_35_id, 'Bistecca di cavallo ai ferri', 'dinner'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 10, true, true, system_user_id),
        (recipe_36_id, 'Bistecca di manzo ai ferri', 'dinner'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 10, true, true, system_user_id),
        (recipe_37_id, 'Bollito magro a cubettini freddo con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 10, 0, true, true, system_user_id),
        (recipe_38_id, 'Bollito misto', 'dinner'::public.recipe_category, 4, 'hard'::public.recipe_difficulty, 30, 120, true, true, system_user_id),
        (recipe_39_id, 'Bollito, tagli magri', 'dinner'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 10, 90, true, true, system_user_id),
        (recipe_40_id, 'Brasato', 'dinner'::public.recipe_category, 4, 'hard'::public.recipe_difficulty, 25, 120, true, true, system_user_id),
        (recipe_41_id, 'Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 10, 0, true, true, system_user_id),
        (recipe_42_id, 'Broccoli lessati o al vapore, conditi con extravergine', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 12, true, true, system_user_id),
        (recipe_43_id, 'Bruschetta', 'snack'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 5, true, true, system_user_id),
        (recipe_44_id, 'Caffelatte (parz. screm.)', 'beverage'::public.recipe_category, 1, 'easy'::public.recipe_difficulty, 2, 3, true, true, system_user_id),
        (recipe_45_id, 'Caffe marocchino', 'beverage'::public.recipe_category, 1, 'easy'::public.recipe_difficulty, 3, 2, true, true, system_user_id),
        (recipe_46_id, 'Caffe macchiato', 'beverage'::public.recipe_category, 1, 'easy'::public.recipe_difficulty, 2, 1, true, true, system_user_id),
        (recipe_47_id, 'Cappuccino senza zucchero', 'beverage'::public.recipe_category, 1, 'easy'::public.recipe_difficulty, 3, 2, true, true, system_user_id),
        (recipe_48_id, 'Caprese', 'lunch'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 10, 0, true, true, system_user_id),
        (recipe_49_id, 'Carciofi in padella con aglio e prezzemolo', 'lunch'::public.recipe_category, 2, 'medium'::public.recipe_difficulty, 15, 20, true, true, system_user_id),
        (recipe_50_id, 'Carciofi, in pinzimonio', 'snack'::public.recipe_category, 2, 'easy'::public.recipe_difficulty, 5, 0, true, true, system_user_id);

    -- Insert recipe ingredients for all recipes
    
    -- Recipe 1: Cavolfiore lessato o al vapore, con extravergine
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_1_id, 'CAVOLFIORE', 200, 'g', 200, 30, 3, 6, 0.3, 2),
        (recipe_1_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 2: Cavolini di Bruxelles lessati o al vapore, con extravergine
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_2_id, 'CAVOLI DI BRUXELLES', 200, 'g', 200, 48, 3.4, 9, 0.3, 4);

    -- Recipe 3: Cavolo cappuccio in insalata, tagliato finemente, con extravergne
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_3_id, 'CAVOLO CAPPUCCIO ROSSO', 80, 'g', 80, 22, 1.4, 5, 0.1, 2),
        (recipe_3_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_3_id, 'ACETO', 5, 'ml', 5, 4, 0, 0.04, 0, 0);

    -- Recipe 4: Ceci in umido con sugo al pomodoro
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_4_id, 'CECI, secchi', 50, 'g', 50, 363, 20, 63, 6, 15),
        (recipe_4_id, 'PASSATA DI POMODORO', 70, 'g', 60, 36, 2, 7, 0.4, 1.5),
        (recipe_4_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_4_id, 'CIPOLLE', 17, 'g', 17, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_4_id, 'PREZZEMOLO, fresco', 3, 'g', 3, 30, 3, 6, 0.8, 3);

    -- Recipe 5: Cicoria o catalogna cotta e condita
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_5_id, 'CICORIA CATALOGNA', 200, 'g', 200, 30, 1.4, 5, 0.7, 4),
        (recipe_5_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 6: Cioccolata calda
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_6_id, 'LATTE DI VACCA, INTERO PASTORIZZATO', 125, 'ml', 125, 64, 3.3, 4.8, 3.6, 0),
        (recipe_6_id, 'CACAO AMARO, in polvere', 7, 'g', 7, 413, 25, 11, 25, 37),
        (recipe_6_id, 'PATATE, FECOLA', 4, 'g', 4, 349, 1, 83, 1, 0.9),
        (recipe_6_id, 'ZUCCHERO (Saccarosio)', 7, 'g', 7, 392, 0, 100, 0, 0);

    -- Recipe 7: Cipolle al forno
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_7_id, 'CIPOLLE', 200, 'g', 200, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_7_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 8: Cipolle lessate, condite con extravergine
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_8_id, 'CIPOLLE', 200, 'g', 200, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_8_id, 'PREZZEMOLO, fresco', 3, 'g', 3, 30, 3, 6, 0.8, 3),
        (recipe_8_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 9: Coniglio arrosto
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_9_id, 'CONIGLIO, CARNE SEMIGRASSA', 100, 'g', 100, 138, 20, 0, 6, 0),
        (recipe_9_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_9_id, 'PANCETTA DI MAIALE', 5, 'g', 5, 661, 9, 0, 69, 0),
        (recipe_9_id, 'ROSMARINO, fresco', 2, 'g', 2, 111, 1.5, 20, 5, 14);

    -- Recipe 10: Coscia di pollo arrosto (con pelle)
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_10_id, 'POLLO, FUSO (COSCIA), con pelle', 100, 'g', 100, 125, 18, 0, 6, 0),
        (recipe_10_id, 'ERBE AROMATICHE (FOGLIE)', 1, 'g', 1, 88, 10, 18, 2, 8),
        (recipe_10_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 11: Coscia di pollo arrosto (senza pelle)
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_11_id, 'POLLO, FUSO (COSCIA), senza pelle', 100, 'g', 100, 107, 18, 0, 4, 0),
        (recipe_11_id, 'ERBE AROMATICHE (FOGLIE)', 1, 'g', 1, 88, 10, 18, 2, 8),
        (recipe_11_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 12: Coscia di tacchino al forno
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_12_id, 'TACCHINO, FUSO (COSCIA), con pelle', 100, 'g', 100, 126, 18, 0, 6, 0),
        (recipe_12_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 13: Coste o biete lessate con extravergine
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_13_id, 'BIETA', 200, 'g', 200, 19, 1.8, 3.7, 0.2, 1.6),
        (recipe_13_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 14: Costine di maiale ai ferri
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_14_id, 'SUINO, CARNE GRASSA, senza grasso visibile', 100, 'g', 100, 268, 16, 0, 23, 0);

    -- Recipe 15: Cotoletta alla milanese
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_15_id, 'BOVINO, VITELLO, 4 MESI, CARNE MAGRA, senza grasso visibile', 100, 'g', 100, 92, 20, 0, 2, 0),
        (recipe_15_id, 'PANE GRATTUGIATO', 13, 'g', 13, 361, 12, 72, 3, 4),
        (recipe_15_id, 'UOVO DI GALLINA, INTERO', 25, 'g', 25, 128, 13, 1, 9, 0);

    -- Recipe 16: Crema di ceci
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_16_id, 'CECI, secchi', 50, 'g', 50, 363, 20, 63, 6, 15),
        (recipe_16_id, 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 5, 1, 0, 0, 0),
        (recipe_16_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_16_id, 'CIPOLLE', 30, 'g', 30, 28, 1.1, 6.5, 0.1, 1.7);

    -- Recipe 17: Crema di fagioli cannellini
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_17_id, 'FAGIOLI, secchi', 50, 'g', 50, 345, 23, 60, 2, 15),
        (recipe_17_id, 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 5, 1, 0, 0, 0),
        (recipe_17_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_17_id, 'CIPOLLE', 30, 'g', 30, 28, 1.1, 6.5, 0.1, 1.7);

    -- Recipe 18: Crema di piselli
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_18_id, 'PISELLI SURGELATI', 150, 'g', 150, 70, 5.5, 12, 0.2, 6),
        (recipe_18_id, 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 5, 1, 0, 0, 0),
        (recipe_18_id, 'CIPOLLE', 30, 'g', 30, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_18_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 19: Crema di piselli con patate
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_19_id, 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 5, 1, 0, 0, 0),
        (recipe_19_id, 'PISELLI SURGELATI', 150, 'g', 150, 70, 5.5, 12, 0.2, 6),
        (recipe_19_id, 'PATATE', 70, 'g', 70, 80, 2, 18, 0.1, 2),
        (recipe_19_id, 'CIPOLLE', 30, 'g', 30, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_19_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_19_id, 'PREZZEMOLO, fresco', 2, 'g', 2, 30, 3, 6, 0.8, 3),
        (recipe_19_id, 'PARMIGIANO', 5, 'g', 5, 387, 33, 0, 28, 0);

    -- Recipe 20: Crema di zucca
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_20_id, 'ZUCCA GIALLA', 200, 'g', 200, 19, 1.1, 3.5, 0.1, 0.5),
        (recipe_20_id, 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 5, 1, 0, 0, 0),
        (recipe_20_id, 'CIPOLLE', 30, 'g', 30, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_20_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 21: Crema porri e patate
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_21_id, 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 5, 1, 0, 0, 0),
        (recipe_21_id, 'PORRI', 100, 'g', 100, 35, 1.5, 8, 0.3, 1.8),
        (recipe_21_id, 'PATATE', 200, 'g', 200, 80, 2, 18, 0.1, 2),
        (recipe_21_id, 'CIPOLLE', 30, 'g', 30, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_21_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 22: Crostata alla marmellata
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_22_id, 'FARINA DI FRUMENTO, TIPO 00', 25, 'g', 25, 348, 11, 74, 1, 2.2),
        (recipe_22_id, 'BURRO', 13, 'g', 13, 758, 1, 1, 84, 0),
        (recipe_22_id, 'ZUCCHERO (Saccarosio)', 11, 'g', 11, 392, 0, 100, 0, 0),
        (recipe_22_id, 'UOVO DI GALLINA, TUORLO', 19, 'g', 19, 325, 16, 1, 28, 0),
        (recipe_22_id, 'MARMELLATA (ALBIC.,FICHI,MELE COT.,PESCHE, PRUGNE)', 32, 'g', 32, 214, 0.6, 55, 0, 1);

    -- Recipe 23: Fagioli all'uccelletto
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_23_id, 'FAGIOLI, secchi', 50, 'g', 50, 345, 23, 60, 2, 15),
        (recipe_23_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_23_id, 'AGLIO, fresco', 5, 'g', 5, 45, 6.4, 10, 0.5, 2.1),
        (recipe_23_id, 'PASSATA DI POMODORO', 70, 'g', 70, 36, 2, 7, 0.4, 1.5);

    -- Recipe 24: Fagioli con nervetti
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_24_id, 'FAGIOLI, secchi', 50, 'g', 50, 345, 23, 60, 2, 15),
        (recipe_24_id, 'NERVETTI (bovino)', 50, 'g', 50, 85, 18, 0, 2, 0),
        (recipe_24_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 25: Fagioli in umido con sugo al pomodoro
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_25_id, 'FAGIOLI, secchi', 50, 'g', 50, 345, 23, 60, 2, 15),
        (recipe_25_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_25_id, 'CIPOLLE', 15, 'g', 15, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_25_id, 'PASSATA DI POMODORO', 70, 'g', 70, 36, 2, 7, 0.4, 1.5),
        (recipe_25_id, 'PREZZEMOLO, fresco', 2, 'g', 2, 30, 3, 6, 0.8, 3);

    -- Recipe 26: Fagiolini in padella
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_26_id, 'FAGIOLINI', 200, 'g', 200, 24, 1.8, 4.3, 0.1, 2.9),
        (recipe_26_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_26_id, 'BRODO DI CARNE E VERDURA', 50, 'ml', 50, 5, 1, 0, 0, 0),
        (recipe_26_id, 'AGLIO, fresco', 5, 'g', 5, 45, 6.4, 10, 0.5, 2.1),
        (recipe_26_id, 'PREZZEMOLO, fresco', 2, 'g', 2, 30, 3, 6, 0.8, 3);

    -- Recipe 27: Alici marinate
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_27_id, 'ACCIUGHE o ALICI', 150, 'g', 150, 96, 17, 1, 2, 0),
        (recipe_27_id, 'OLIO DI SEMI DI MAIS', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_27_id, 'ACETO', 9, 'ml', 9, 4, 0, 0.04, 0, 0);

    -- Recipe 28: Arrosticini di agnello
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_28_id, 'AGNELLO, CARNE SEMIGRASSA', 100, 'g', 100, 211, 18, 0, 16, 0),
        (recipe_28_id, 'ROSMARINO, secco', 1, 'g', 1, 366, 5, 65, 15, 42),
        (recipe_28_id, 'ALLORO, secco', 1, 'g', 1, 341, 8, 75, 8, 26);

    -- Recipe 29: Arrosto di vitello
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_29_id, 'BOVINO, VITELLONE, 15-18 MESI, sottofesa, senza grasso visibile', 100, 'g', 100, 111, 21, 0, 3, 0),
        (recipe_29_id, 'BRODO VEGETALE', 50, 'ml', 50, 6, 0.2, 1.5, 0, 0),
        (recipe_29_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_29_id, 'ROSMARINO, fresco', 3, 'g', 3, 111, 1.5, 20, 5, 14);

    -- Recipe 30: Asparagi lessati e conditi
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_30_id, 'ASPARAGI DI CAMPO', 200, 'g', 200, 33, 3.6, 4, 0.2, 2),
        (recipe_30_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 31: Banana zucchero e limone
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_31_id, 'BANANA', 150, 'g', 150, 69, 1.3, 16, 0.2, 2.6),
        (recipe_31_id, 'ZUCCHERO (Saccarosio)', 5, 'g', 5, 392, 0, 100, 0, 0),
        (recipe_31_id, 'SUCCO DI LIMONE, fresco', 5, 'ml', 5, 6, 0.1, 1.5, 0, 0);

    -- Recipe 32: Besciamella
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_32_id, 'BURRO', 8, 'g', 8, 758, 1, 1, 84, 0),
        (recipe_32_id, 'FARINA DI FRUMENTO, TIPO 00', 8, 'g', 8, 348, 11, 74, 1, 2.2),
        (recipe_32_id, 'LATTE DI VACCA, INTERO PASTORIZZATO', 85, 'ml', 85, 64, 3.3, 4.8, 3.6, 0);

    -- Recipe 33: Biscotto frollino
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_33_id, 'FARINA DI FRUMENTO, TIPO 00', 7, 'g', 7, 348, 11, 74, 1, 2.2);

    -- Recipe 34: Bistecca alla pizzaiola
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_34_id, 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', 100, 'g', 100, 108, 21, 0, 3, 0),
        (recipe_34_id, 'POMODORI, PELATI, IN SCATOLA CON LIQUIDO', 80, 'g', 80, 22, 1.6, 4, 0.2, 1.1),
        (recipe_34_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_34_id, 'AGLIO, fresco', 1, 'g', 1, 45, 6.4, 10, 0.5, 2.1);

    -- Recipe 35: Bistecca di cavallo ai ferri
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_35_id, 'CAVALLO, senza grasso visibile', 100, 'g', 100, 145, 28, 0, 4, 0),
        (recipe_35_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 36: Bistecca di manzo ai ferri
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_36_id, 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', 100, 'g', 100, 108, 21, 0, 3, 0),
        (recipe_36_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 37: Bollito magro a cubettini freddo con extravergine
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_37_id, 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', 100, 'g', 100, 108, 21, 0, 3, 0),
        (recipe_37_id, 'PREZZEMOLO, fresco', 2, 'g', 2, 30, 3, 6, 0.8, 3),
        (recipe_37_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 38: Bollito misto
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_38_id, 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', 30, 'g', 30, 108, 21, 0, 3, 0),
        (recipe_38_id, 'BOVINO, VITELLONE, 15-18 MESI, pancia, biancostato, punta di petto, senza grasso visibile', 30, 'g', 30, 171, 19, 0, 10, 0),
        (recipe_38_id, 'BOVINO, LINGUA', 20, 'g', 20, 232, 16, 1, 18, 0),
        (recipe_38_id, 'GALLINA', 20, 'g', 20, 194, 19, 0, 13, 0);

    -- Recipe 39: Bollito, tagli magri
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_39_id, 'BOVINO, VITELLONE, 15-18 MESI, noce, senza grasso visibile', 100, 'g', 100, 106, 21, 0, 2, 0);

    -- Recipe 40: Brasato
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_40_id, 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', 100, 'g', 100, 108, 21, 0, 3, 0),
        (recipe_40_id, 'CAROTE', 20, 'g', 20, 39, 1.1, 9, 0.2, 2.8),
        (recipe_40_id, 'CIPOLLE', 25, 'g', 25, 28, 1.1, 6.5, 0.1, 1.7),
        (recipe_40_id, 'SEDANO', 5, 'g', 5, 23, 0.7, 4, 0.2, 1.8),
        (recipe_40_id, 'BURRO', 5, 'g', 5, 758, 1, 1, 84, 0),
        (recipe_40_id, 'AGLIO, fresco', 5, 'g', 5, 45, 6.4, 10, 0.5, 2.1);

    -- Recipe 41: Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_41_id, 'BRESAOLA', 50, 'g', 50, 151, 32, 2, 3, 0),
        (recipe_41_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_41_id, 'PARMIGIANO', 10, 'g', 10, 387, 33, 0, 28, 0),
        (recipe_41_id, 'RUCOLA', 10, 'g', 10, 28, 2.6, 3.7, 0.7, 1.6),
        (recipe_41_id, 'SUCCO DI LIMONE', 7, 'ml', 7, 28, 1.1, 8.4, 0.3, 0.5),
        (recipe_41_id, 'POMODORI DA INSALATA', 10, 'g', 10, 19, 0.9, 3.5, 0.2, 1);

    -- Recipe 42: Broccoli lessati o al vapore, conditi con extravergine
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_42_id, 'BROCCOLO A TESTA', 200, 'g', 200, 33, 4.3, 4, 0.5, 3.1),
        (recipe_42_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 43: Bruschetta
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_43_id, 'PANE, TIPO 1, pezzatura > 500g', 50, 'g', 50, 275, 8.1, 56, 1, 3.8),
        (recipe_43_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 44: Caffelatte (parz. screm.)
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_44_id, 'LATTE DI VACCA, PARZIALMENTE SCREMATO PASTORIZZATO', 125, 'ml', 125, 46, 3.5, 5, 1.5, 0),
        (recipe_44_id, 'CAFFE MOKA, in tazza', 30, 'ml', 30, 2, 0.1, 0, 0, 0);

    -- Recipe 45: Caffè "marocchino"
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_45_id, 'CAFFE MOKA, in tazza', 30, 'ml', 30, 2, 0.1, 0, 0, 0),
        (recipe_45_id, 'LATTE DI VACCA, INTERO PASTORIZZATO', 10, 'ml', 10, 64, 3.3, 4.8, 3.6, 0),
        (recipe_45_id, 'CACAO AMARO, in polvere', 5, 'g', 5, 413, 25, 11, 25, 37);

    -- Recipe 46: Caffè macchiato
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_46_id, 'CAFFE BAR, in tazza', 30, 'ml', 30, 2, 0.1, 0, 0, 0),
        (recipe_46_id, 'LATTE DI VACCA, INTERO PASTORIZZATO', 8, 'ml', 8, 64, 3.3, 4.8, 3.6, 0);

    -- Recipe 47: Cappuccino senza zucchero
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_47_id, 'LATTE DI VACCA, INTERO PASTORIZZATO', 125, 'ml', 125, 64, 3.3, 4.8, 3.6, 0),
        (recipe_47_id, 'CAFFE MOKA, in tazza', 40, 'ml', 40, 2, 0.1, 0, 0, 0);

    -- Recipe 48: Caprese
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_48_id, 'MOZZARELLA DI VACCA', 100, 'g', 100, 253, 19, 1, 19, 0),
        (recipe_48_id, 'POMODORI DA INSALATA', 200, 'g', 200, 19, 0.9, 3.5, 0.2, 1),
        (recipe_48_id, 'BASILICO, fresco', 2, 'g', 2, 49, 2.5, 4, 0.8, 4),
        (recipe_48_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Recipe 49: Carciofi in padella con aglio e prezzemolo
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_49_id, 'CARCIOFI', 200, 'g', 200, 33, 2.7, 5, 0.2, 5),
        (recipe_49_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0),
        (recipe_49_id, 'AGLIO, fresco', 5, 'g', 5, 45, 6.4, 10, 0.5, 2.1),
        (recipe_49_id, 'PREZZEMOLO, fresco', 3, 'g', 3, 30, 3, 6, 0.8, 3);

    -- Recipe 50: Carciofi, in pinzimonio
    INSERT INTO public.recipe_ingredients (recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g) VALUES
        (recipe_50_id, 'CARCIOFI', 200, 'g', 200, 33, 2.7, 5, 0.2, 5),
        (recipe_50_id, 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 899, 0, 0, 100, 0);

    -- Insert recipe tags for all recipes
    INSERT INTO public.recipe_tags (recipe_id, tag_name) VALUES
        -- Common Italian tags
        (recipe_1_id, 'Italian'), (recipe_2_id, 'Italian'), (recipe_3_id, 'Italian'), (recipe_4_id, 'Italian'),
        (recipe_5_id, 'Italian'), (recipe_6_id, 'Italian'), (recipe_7_id, 'Italian'), (recipe_8_id, 'Italian'),
        (recipe_9_id, 'Italian'), (recipe_10_id, 'Italian'), (recipe_11_id, 'Italian'), (recipe_12_id, 'Italian'),
        (recipe_13_id, 'Italian'), (recipe_14_id, 'Italian'), (recipe_15_id, 'Italian'), (recipe_16_id, 'Italian'),
        (recipe_17_id, 'Italian'), (recipe_18_id, 'Italian'), (recipe_19_id, 'Italian'), (recipe_20_id, 'Italian'),
        (recipe_21_id, 'Italian'), (recipe_22_id, 'Italian'), (recipe_23_id, 'Italian'), (recipe_24_id, 'Italian'),
        (recipe_25_id, 'Italian'), (recipe_26_id, 'Italian'), (recipe_27_id, 'Italian'), (recipe_28_id, 'Italian'),
        (recipe_29_id, 'Italian'), (recipe_30_id, 'Italian'), (recipe_31_id, 'Italian'), (recipe_32_id, 'Italian'),
        (recipe_33_id, 'Italian'), (recipe_34_id, 'Italian'), (recipe_35_id, 'Italian'), (recipe_36_id, 'Italian'),
        (recipe_37_id, 'Italian'), (recipe_38_id, 'Italian'), (recipe_39_id, 'Italian'), (recipe_40_id, 'Italian'),
        (recipe_41_id, 'Italian'), (recipe_42_id, 'Italian'), (recipe_43_id, 'Italian'), (recipe_44_id, 'Italian'),
        (recipe_45_id, 'Italian'), (recipe_46_id, 'Italian'), (recipe_47_id, 'Italian'), (recipe_48_id, 'Italian'),
        (recipe_49_id, 'Italian'), (recipe_50_id, 'Italian'),

        -- Vegetable dishes
        (recipe_1_id, 'Vegetable'), (recipe_2_id, 'Vegetable'), (recipe_3_id, 'Vegetable'), (recipe_5_id, 'Vegetable'),
        (recipe_7_id, 'Vegetable'), (recipe_8_id, 'Vegetable'), (recipe_13_id, 'Vegetable'), (recipe_30_id, 'Vegetable'),
        (recipe_42_id, 'Vegetable'), (recipe_49_id, 'Vegetable'), (recipe_50_id, 'Vegetable'),

        -- Meat dishes
        (recipe_9_id, 'Meat'), (recipe_10_id, 'Meat'), (recipe_11_id, 'Meat'), (recipe_12_id, 'Meat'),
        (recipe_14_id, 'Meat'), (recipe_15_id, 'Meat'), (recipe_28_id, 'Meat'), (recipe_29_id, 'Meat'),
        (recipe_34_id, 'Meat'), (recipe_35_id, 'Meat'), (recipe_36_id, 'Meat'), (recipe_37_id, 'Meat'),
        (recipe_38_id, 'Meat'), (recipe_39_id, 'Meat'), (recipe_40_id, 'Meat'), (recipe_41_id, 'Meat'),

        -- Seafood
        (recipe_27_id, 'Seafood'),

        -- Legumes
        (recipe_4_id, 'Legumes'), (recipe_16_id, 'Legumes'), (recipe_17_id, 'Legumes'), (recipe_18_id, 'Legumes'),
        (recipe_19_id, 'Legumes'), (recipe_23_id, 'Legumes'), (recipe_24_id, 'Legumes'), (recipe_25_id, 'Legumes'),
        (recipe_26_id, 'Legumes'),

        -- Healthy options
        (recipe_1_id, 'Healthy'), (recipe_2_id, 'Healthy'), (recipe_3_id, 'Healthy'), (recipe_4_id, 'Healthy'),
        (recipe_5_id, 'Healthy'), (recipe_13_id, 'Healthy'), (recipe_16_id, 'Healthy'), (recipe_17_id, 'Healthy'),
        (recipe_18_id, 'Healthy'), (recipe_27_id, 'Healthy'), (recipe_30_id, 'Healthy'), (recipe_42_id, 'Healthy'),

        -- Traditional
        (recipe_15_id, 'Traditional'), (recipe_22_id, 'Traditional'), (recipe_23_id, 'Traditional'),
        (recipe_38_id, 'Traditional'), (recipe_40_id, 'Traditional'), (recipe_43_id, 'Traditional'),
        (recipe_48_id, 'Traditional'),

        -- Coffee/Beverages
        (recipe_44_id, 'Coffee'), (recipe_45_id, 'Coffee'), (recipe_46_id, 'Coffee'), (recipe_47_id, 'Coffee');

    RAISE NOTICE 'Successfully added % Italian recipes with ingredients and tags', 50;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding Italian recipes: %', SQLERRM;
        ROLLBACK;
END $$;