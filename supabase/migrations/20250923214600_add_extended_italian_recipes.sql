-- ================================================
-- ADD EXTENDED ITALIAN RECIPES - BATCH 4
-- ================================================
-- Migration: 20250923214600_add_extended_italian_recipes
-- Description: Adding more authentic Italian recipes with detailed ingredient data and nutritional information
-- Type: Data Addition to Existing Recipe Management System

-- Set schema
SET search_path TO public;

-- Ensure required extensions are available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- RECIPE DATA INSERTION
-- ================================================

-- Insert new recipes
INSERT INTO public.recipes (
    id,
    title, 
    category,
    difficulty,
    prep_time_minutes,
    cook_time_minutes,
    servings,
    is_public,
    is_verified,
    created_by,
    created_at,
    description,
    instructions
) VALUES 
-- Batch 4 - Extended Italian Recipes
('1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'Insalata di farro con verdure a cubetti saltate o grigliate', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 20, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Healthy farro salad with mixed grilled vegetables - a nutritious Italian grain dish perfect for lunch', 'Cook farro until tender. Grill vegetables until golden. Mix together with herbs and olive oil.'),
('2b3c4d5e-6f78-90ab-cdef-123456789012', 'Insalata di farro riso e orzo con dadini di verdure', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 15, 30, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Mixed grain salad with farro, rice, and barley combined with fresh vegetable cubes', 'Cook grains separately. Dice vegetables finely. Combine with olive oil and seasonings.'),
('3c4d5e6f-7890-abcd-ef12-345678901234', 'Insalata di farro riso e orzo con piselli e olio a crudo', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Light grain salad with peas and raw olive oil - simple and nutritious', 'Cook grains and peas. Mix with raw olive oil and parmigiano.'),
('4d5e6f78-90ab-cdef-1234-567890123456', 'Insalata di gamberetti con olio, prezzemolo e limone', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 15, 5, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Fresh shrimp salad with olive oil, parsley and lemon - light seafood dish', 'Cook shrimp briefly. Toss with olive oil, lemon juice and fresh parsley.'),
('5e6f7890-abcd-ef12-3456-789012345678', 'Insalata di mare', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 30, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Traditional seafood salad with mixed shellfish and fish - classic Italian antipasto', 'Cook each seafood separately. Combine with celery, olive oil, and herbs.'),
('6f78901a-bcde-f123-4567-890123456789', 'Insalata di polpo con patate', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 20, 45, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Classic octopus and potato salad - traditional Mediterranean dish', 'Boil octopus until tender. Cook potatoes separately. Combine with lemon and olive oil.'),
('7890abcd-ef12-3456-7890-ab1234567890', 'Insalata di riso', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 20, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Italian rice salad with vegetables, eggs, and tuna - perfect summer dish', 'Cook rice. Add diced vegetables, hard-boiled egg, and tuna. Dress with olive oil.'),
('890abcde-f123-4567-890a-b12345678901', 'Insalata fredda di ceci con extravergine', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Cold chickpea salad with extra virgin olive oil and fresh herbs', 'Drain cooked chickpeas. Mix with olive oil, parsley, and seasonings.'),
('90abcdef-1234-5678-90ab-123456789012', 'Insalata fredda di ceci con peperonata', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 15, 10, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Cold chickpea salad with bell pepper stew - hearty vegetarian dish', 'Prepare peperonata separately. Mix with cooked chickpeas and olive oil.'),
('0abcdef1-2345-6789-0abc-def123456789', 'Insalata mista con carote e pomodori, condita', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Mixed salad with carrots and tomatoes - fresh and colorful', 'Mix fresh greens with diced carrots and tomatoes. Dress with olive oil and vinegar.'),
('abcdef12-3456-789a-bcde-f12345678901', 'Insalata, condita', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 5, 0, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Simple dressed salad - basic Italian green salad', 'Mix fresh salad greens with olive oil, vinegar, and salt.'),
('bcdef123-4567-89ab-cdef-123456789012', 'Involtini di carne con spinaci', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 25, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Beef rolls stuffed with spinach and fontina cheese - elegant main course', 'Flatten beef slices. Fill with spinach and cheese. Roll and cook in tomato sauce.'),
('cdef1234-5678-9abc-def1-234567890123', 'Involtini di pollo con prosciutto e formaggio', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 20, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Chicken rolls with prosciutto and fontina - delicious poultry dish', 'Flatten chicken breast. Fill with prosciutto and cheese. Roll and pan-fry.'),
('def12345-6789-abcd-ef12-345678901234', 'Lasagne alla bolognese', 'dinner'::recipe_category, 'hard'::recipe_difficulty, 45, 60, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Classic Bolognese lasagna with meat sauce and bechamel - traditional comfort food', 'Layer pasta with meat sauce, bechamel, and cheese. Bake until golden.'),
('ef123456-789a-bcde-f123-456789012345', 'Latte macchiato', 'beverage'::recipe_category, 'easy'::recipe_difficulty, 2, 3, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Italian coffee drink with steamed milk - morning favorite', 'Heat milk and add to strong espresso coffee.'),
('f1234567-89ab-cdef-1234-567890123456', 'Lattuga, condita', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 5, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Simple dressed lettuce salad - fresh and crisp', 'Clean lettuce leaves. Dress with olive oil, vinegar, and salt.'),
('12345678-9abc-def1-2345-678901234567', 'Lenticchie in umido con sugo al pomodoro', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 15, 35, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Stewed lentils in tomato sauce - hearty legume dish', 'Cook lentils with onions and tomato sauce. Season with herbs.'),
('23456789-abcd-ef12-3456-789012345678', 'Lonza di maiale in padella', 'dinner'::recipe_category, 'easy'::recipe_difficulty, 10, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Pan-fried pork loin with herbs - simple meat dish', 'Season pork loin and pan-fry with herbs until golden.'),
('3456789a-bcde-f123-4567-890123456789', 'Macedonia', 'dessert'::recipe_category, 'easy'::recipe_difficulty, 15, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Italian fruit salad with sugar and lemon - fresh dessert', 'Dice various fruits. Mix with sugar and lemon juice.'),
('456789ab-cdef-1234-5678-901234567890', 'Macedonia con due palline di gelato', 'dessert'::recipe_category, 'easy'::recipe_difficulty, 15, 0, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), 'Fruit salad with two scoops of ice cream - indulgent dessert', 'Prepare fruit salad and serve with chocolate ice cream.');

-- ================================================
-- RECIPE INGREDIENTS DATA
-- ================================================

-- Insert recipe ingredients for each recipe
-- Recipe 1: Insalata di farro con verdure a cubetti saltate o grigliate
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('a1a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'FARRO', 80.0, 'g', 80, 282.4, 2.0, 67.2, 12.0, 7.2),
('a2a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'MELANZANE', 20.0, 'g', 20, 4.0, 0.02, 0.6, 0.2, 0.6),
('a3a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'ZUCCHINE', 30.0, 'g', 30, 4.2, 0.09, 0.9, 0.4, 0.3),
('a4a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'POMODORI DA INSALATA', 20.0, 'g', 20, 3.8, 0.04, 0.7, 0.2, 0.2),
('a5a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'CIPOLLE', 10.0, 'g', 10, 2.8, 0.01, 0.6, 0.1, 0.1),
('a6a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'PEPERONI DOLCI', 20.0, 'g', 20, 5.2, 0.06, 1.1, 0.2, 0.4),
('a7a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('a8a2b3c4-5e6f-7890-abcd-ef1234567890', '1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'BASILICO, fresco', 3.0, 'g', 3, 1.47, 0.02, 0.06, 0.09, 0.12);

-- Recipe 2: Insalata di farro riso e orzo con dadini di verdure  
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('b1b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'ORZO, PERLATO', 25.0, 'g', 25, 84.25, 0.5, 17.0, 2.8, 1.0),
('b2b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'RISO, BRILLATO', 25.0, 'g', 25, 91.25, 0.5, 20.0, 1.8, 0.3),
('b3b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'FARRO', 30.0, 'g', 30, 105.9, 0.75, 25.2, 4.5, 2.7),
('b4b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('b5b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'ZUCCHINE', 30.0, 'g', 30, 4.2, 0.09, 0.9, 0.4, 0.3),
('b6b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'CAROTE', 30.0, 'g', 30, 11.7, 0.06, 2.7, 0.3, 0.9),
('b7b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'CETRIOLI', 30.0, 'g', 30, 4.5, 0.03, 1.05, 0.21, 0.15),
('b8b3c4d5-6f78-90ab-cdef-123456789012', '2b3c4d5e-6f78-90ab-cdef-123456789012', 'POMODORI MATURI', 30.0, 'g', 30, 6.3, 0.06, 1.2, 0.27, 0.36);

-- Recipe 3: Insalata di farro riso e orzo con piselli e olio a crudo
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('c1c4d5e6-7890-abcd-ef12-345678901234', '3c4d5e6f-7890-abcd-ef12-345678901234', 'RISO, BRILLATO', 25.0, 'g', 25, 91.25, 0.5, 20.0, 1.8, 0.3),
('c2c4d5e6-7890-abcd-ef12-345678901234', '3c4d5e6f-7890-abcd-ef12-345678901234', 'ORZO, PERLATO', 25.0, 'g', 25, 84.25, 0.5, 17.0, 2.8, 1.0),
('c3c4d5e6-7890-abcd-ef12-345678901234', '3c4d5e6f-7890-abcd-ef12-345678901234', 'FARRO', 30.0, 'g', 30, 105.9, 0.75, 25.2, 4.5, 2.7),
('c4c4d5e6-7890-abcd-ef12-345678901234', '3c4d5e6f-7890-abcd-ef12-345678901234', 'PISELLI SURGELATI', 50.0, 'g', 50, 35.0, 0.5, 6.0, 3.0, 2.5),
('c5c4d5e6-7890-abcd-ef12-345678901234', '3c4d5e6f-7890-abcd-ef12-345678901234', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('c6c4d5e6-7890-abcd-ef12-345678901234', '3c4d5e6f-7890-abcd-ef12-345678901234', 'PARMIGIANO', 5.0, 'g', 5, 19.35, 1.45, 0.05, 1.9, 0.0);

-- Recipe 4: Insalata di gamberetti con olio, prezzemolo e limone
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('d1d5e6f7-890a-bcde-f123-456789012345', '4d5e6f78-90ab-cdef-1234-567890123456', 'GAMBERO', 150.0, 'g', 150, 106.5, 1.05, 0.0, 21.75, 0.0),
('d2d5e6f7-890a-bcde-f123-456789012345', '4d5e6f78-90ab-cdef-1234-567890123456', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('d3d5e6f7-890a-bcde-f123-456789012345', '4d5e6f78-90ab-cdef-1234-567890123456', 'PREZZEMOLO, fresco', 3.0, 'g', 3, 0.9, 0.02, 0.18, 0.09, 0.1),
('d4d5e6f7-890a-bcde-f123-456789012345', '4d5e6f78-90ab-cdef-1234-567890123456', 'SUCCO DI LIMONE, fresco', 5.0, 'ml', 5, 0.3, 0.01, 0.05, 0.02, 0.01);

-- Recipe 5: Insalata di mare
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('e1e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'CALAMARO', 40.0, 'g', 40, 27.2, 0.8, 0.24, 5.32, 0.0),
('e2e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'GAMBERO', 20.0, 'g', 20, 14.2, 0.14, 0.0, 2.9, 0.0),
('e3e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'POLPO', 30.0, 'g', 30, 17.1, 0.3, 0.72, 3.3, 0.0),
('e4e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'COZZA o MITILO', 20.0, 'g', 20, 16.8, 0.7, 0.7, 2.2, 0.0),
('e5e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'VONGOLA', 20.0, 'g', 20, 14.4, 0.54, 0.7, 2.2, 0.0),
('e6e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'SEPPIA', 20.0, 'g', 20, 14.4, 0.14, 0.14, 2.88, 0.0),
('e7e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('e8e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'PREZZEMOLO, fresco', 2.0, 'g', 2, 0.6, 0.01, 0.12, 0.06, 0.07),
('e9e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'AGLIO, fresco', 2.0, 'g', 2, 0.9, 0.01, 0.2, 0.04, 0.01),
('e0e6f789-0abc-def1-2345-678901234567', '5e6f7890-abcd-ef12-3456-789012345678', 'SEDANO', 30.0, 'g', 30, 6.9, 0.06, 1.5, 0.21, 0.48);

-- Recipe 6: Insalata di polpo con patate
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('f1f6789a-bcde-f123-4567-890123456789', '6f78901a-bcde-f123-4567-890123456789', 'POLPO', 150.0, 'g', 150, 85.5, 1.5, 3.6, 16.5, 0.0),
('f2f6789a-bcde-f123-4567-890123456789', '6f78901a-bcde-f123-4567-890123456789', 'PATATE', 200.0, 'g', 200, 160.0, 0.2, 36.0, 4.0, 2.8),
('f3f6789a-bcde-f123-4567-890123456789', '6f78901a-bcde-f123-4567-890123456789', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('f4f6789a-bcde-f123-4567-890123456789', '6f78901a-bcde-f123-4567-890123456789', 'PREZZEMOLO, fresco', 2.0, 'g', 2, 0.6, 0.01, 0.12, 0.06, 0.07),
('f5f6789a-bcde-f123-4567-890123456789', '6f78901a-bcde-f123-4567-890123456789', 'SUCCO DI LIMONE, fresco', 5.0, 'ml', 5, 0.3, 0.01, 0.05, 0.02, 0.01);

-- Recipe 7: Insalata di riso
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('17890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'RISO, BRILLATO', 80.0, 'g', 80, 292.0, 1.6, 64.0, 5.76, 0.96),
('27890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'PISELLI SURGELATI', 20.0, 'g', 20, 14.0, 0.2, 2.4, 1.2, 1.0),
('37890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'CETRIOLINI SOTT''ACETO', 20.0, 'g', 20, 3.4, 0.02, 0.8, 0.1, 0.3),
('47890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'CIPOLLINE SOTT''ACETO', 20.0, 'g', 20, 5.2, 0.02, 1.2, 0.1, 0.2),
('57890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'UOVO DI GALLINA, INTERO', 20.0, 'g', 20, 25.6, 1.82, 0.14, 2.54, 0.0),
('67890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'ZUCCHINE', 20.0, 'g', 20, 2.8, 0.06, 0.6, 0.27, 0.2),
('77890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'CAROTE', 20.0, 'g', 20, 7.8, 0.04, 1.8, 0.2, 0.6),
('87890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'TONNO SOTT''OLIO, sgocciolato', 20.0, 'g', 20, 38.4, 1.4, 0.0, 5.6, 0.0),
('97890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'PROSCIUTTO COTTO', 15.0, 'g', 15, 32.25, 1.2, 0.15, 4.8, 0.0),
('07890abc-def1-2345-6789-012345678901', '7890abcd-ef12-3456-7890-ab1234567890', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0);

-- Recipe 8: Insalata fredda di ceci con extravergine
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1890abcd-ef12-3456-789a-b12345678901', '890abcde-f123-4567-890a-b12345678901', 'CECI, secchi', 50.0, 'g', 50, 181.5, 3.0, 30.0, 9.5, 6.0),
('2890abcd-ef12-3456-789a-b12345678901', '890abcde-f123-4567-890a-b12345678901', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('3890abcd-ef12-3456-789a-b12345678901', '890abcde-f123-4567-890a-b12345678901', 'PREZZEMOLO, fresco', 4.0, 'g', 4, 1.2, 0.01, 0.24, 0.12, 0.13);

-- Recipe 9: Insalata fredda di ceci con peperonata
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('190abcde-f123-4567-890a-b12345678901', '90abcdef-1234-5678-90ab-123456789012', 'CECI, secchi', 50.0, 'g', 50, 181.5, 3.0, 30.0, 9.5, 6.0),
('290abcde-f123-4567-890a-b12345678901', '90abcdef-1234-5678-90ab-123456789012', 'PEPERONATA', 100.0, 'g', 100, 66.59, 2.5, 12.0, 2.0, 3.0),
('390abcde-f123-4567-890a-b12345678901', '90abcdef-1234-5678-90ab-123456789012', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0);

-- Recipe 10: Insalata mista con carote e pomodori, condita
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('10abcdef-1234-5678-9abc-def123456789', '0abcdef1-2345-6789-0abc-def123456789', 'RADICCHIO ROSSO', 40.0, 'g', 40, 7.2, 0.04, 1.6, 0.56, 1.2),
('20abcdef-1234-5678-9abc-def123456789', '0abcdef1-2345-6789-0abc-def123456789', 'LATTUGA', 40.0, 'g', 40, 8.8, 0.12, 1.4, 0.56, 0.8),
('30abcdef-1234-5678-9abc-def123456789', '0abcdef1-2345-6789-0abc-def123456789', 'CAROTE', 40.0, 'g', 40, 15.6, 0.08, 3.6, 0.4, 1.2),
('40abcdef-1234-5678-9abc-def123456789', '0abcdef1-2345-6789-0abc-def123456789', 'POMODORI MATURI', 60.0, 'g', 60, 12.6, 0.12, 2.4, 0.54, 0.72),
('50abcdef-1234-5678-9abc-def123456789', '0abcdef1-2345-6789-0abc-def123456789', 'ACETO', 5.0, 'ml', 5, 0.2, 0.0, 0.0, 0.0, 0.0),
('60abcdef-1234-5678-9abc-def123456789', '0abcdef1-2345-6789-0abc-def123456789', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0);

-- Continue with remaining recipes (11-20)...
-- Recipe 11: Insalata, condita
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1abcdef1-2345-6789-0abc-def123456789', 'abcdef12-3456-789a-bcde-f12345678901', 'INSALATA NS', 80.0, 'g', 80, 15.2, 0.24, 2.4, 1.04, 1.6),
('2abcdef1-2345-6789-0abc-def123456789', 'abcdef12-3456-789a-bcde-f12345678901', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('3abcdef1-2345-6789-0abc-def123456789', 'abcdef12-3456-789a-bcde-f12345678901', 'ACETO', 5.0, 'ml', 5, 0.2, 0.0, 0.0, 0.0, 0.0);

-- Recipe 12: Involtini di carne con spinaci
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1bcdef12-3456-789a-bcde-f12345678901', 'bcdef123-4567-89ab-cdef-123456789012', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', 100.0, 'g', 100, 108.0, 2.0, 0.0, 22.0, 0.0),
('2bcdef12-3456-789a-bcde-f12345678901', 'bcdef123-4567-89ab-cdef-123456789012', 'FONTINA', 20.0, 'g', 20, 68.6, 5.4, 0.4, 5.0, 0.0),
('3bcdef12-3456-789a-bcde-f12345678901', 'bcdef123-4567-89ab-cdef-123456789012', 'SPINACI', 70.0, 'g', 70, 24.5, 0.28, 2.1, 2.1, 1.75),
('4bcdef12-3456-789a-bcde-f12345678901', 'bcdef123-4567-89ab-cdef-123456789012', 'PASSATA DI POMODORO', 25.0, 'g', 25, 9.0, 0.05, 1.75, 0.45, 0.25),
('5bcdef12-3456-789a-bcde-f12345678901', 'bcdef123-4567-89ab-cdef-123456789012', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0);

-- Recipe 13: Involtini di pollo con prosciutto e formaggio
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1cdef123-4567-89ab-cdef-123456789012', 'cdef1234-5678-9abc-def1-234567890123', 'POLLO, PETTO, senza pelle', 100.0, 'g', 100, 100.0, 0.8, 0.0, 23.0, 0.0),
('2cdef123-4567-89ab-cdef-123456789012', 'cdef1234-5678-9abc-def1-234567890123', 'PROSCIUTTO COTTO', 20.0, 'g', 20, 43.0, 1.6, 0.2, 6.4, 0.0),
('3cdef123-4567-89ab-cdef-123456789012', 'cdef1234-5678-9abc-def1-234567890123', 'FONTINA', 20.0, 'g', 20, 68.6, 5.4, 0.4, 5.0, 0.0),
('4cdef123-4567-89ab-cdef-123456789012', 'cdef1234-5678-9abc-def1-234567890123', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0);

-- Recipe 14: Lasagne alla bolognese
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'PASTA ALL''UOVO, secca', 30.0, 'g', 30, 112.5, 1.5, 21.0, 4.2, 0.9),
('2def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'BOVINO, VITELLONE, 15-18 MESI, scamone, senza grasso visibile', 40.0, 'g', 40, 47.6, 1.2, 0.0, 8.8, 0.0),
('3def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'SUINO, LEGGERO, lombo, senza grasso visibile', 10.0, 'g', 10, 14.6, 0.7, 0.0, 2.0, 0.0),
('4def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'CIPOLLE', 19.0, 'g', 19, 5.32, 0.02, 1.14, 0.19, 0.19),
('5def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'CAROTE', 10.0, 'g', 10, 3.9, 0.02, 0.9, 0.1, 0.3),
('6def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'SEDANO', 8.0, 'g', 8, 1.84, 0.01, 0.4, 0.056, 0.128),
('7def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'PASSATA DI POMODORO', 40.0, 'g', 40, 14.4, 0.08, 2.8, 0.72, 0.4),
('8def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'OLIO DI OLIVA EXTRAVERGINE', 5.0, 'ml', 5, 44.95, 5.0, 0.0, 0.0, 0.0),
('9def1234-5678-9abc-def1-234567890123', 'def12345-6789-abcd-ef12-345678901234', 'PARMIGIANO', 10.0, 'g', 10, 38.7, 2.9, 0.1, 3.8, 0.0);

-- Recipe 15: Latte macchiato
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1ef12345-6789-abcd-ef12-345678901234', 'ef123456-789a-bcde-f123-456789012345', 'LATTE DI VACCA, INTERO PASTORIZZATO', 125.0, 'ml', 125, 80.0, 4.0, 6.0, 4.0, 0.0),
('2ef12345-6789-abcd-ef12-345678901234', 'ef123456-789a-bcde-f123-456789012345', 'CAFFE'' MOKA, in tazza', 30.0, 'ml', 30, 0.6, 0.0, 0.0, 0.0, 0.0);

-- Recipe 16: Lattuga, condita
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('1f123456-789a-bcde-f123-456789012345', 'f1234567-89ab-cdef-1234-567890123456', 'LATTUGA', 80.0, 'g', 80, 17.6, 0.24, 2.8, 1.12, 1.6),
('2f123456-789a-bcde-f123-456789012345', 'f1234567-89ab-cdef-1234-567890123456', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('3f123456-789a-bcde-f123-456789012345', 'f1234567-89ab-cdef-1234-567890123456', 'ACETO', 5.0, 'ml', 5, 0.2, 0.0, 0.0, 0.0, 0.0);

-- Recipe 17: Lenticchie in umido con sugo al pomodoro
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('11234567-89ab-cdef-1234-567890123456', '12345678-9abc-def1-2345-678901234567', 'LENTICCHIE, secche', 50.0, 'g', 50, 176.0, 0.5, 30.0, 12.0, 6.0),
('21234567-89ab-cdef-1234-567890123456', '12345678-9abc-def1-2345-678901234567', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('31234567-89ab-cdef-1234-567890123456', '12345678-9abc-def1-2345-678901234567', 'CIPOLLE', 18.0, 'g', 18, 5.04, 0.02, 1.08, 0.18, 0.18),
('41234567-89ab-cdef-1234-567890123456', '12345678-9abc-def1-2345-678901234567', 'PASSATA DI POMODORO', 72.0, 'g', 72, 25.92, 0.14, 5.04, 1.3, 0.72),
('51234567-89ab-cdef-1234-567890123456', '12345678-9abc-def1-2345-678901234567', 'PREZZEMOLO, fresco', 3.0, 'g', 3, 0.9, 0.02, 0.18, 0.09, 0.1);

-- Recipe 18: Lonza di maiale in padella
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('12345678-9abc-def1-2345-678901234567', '23456789-abcd-ef12-3456-789012345678', 'SUINO, LEGGERO, bistecca, senza grasso visibile', 100.0, 'g', 100, 157.0, 6.6, 0.0, 24.0, 0.0),
('22345678-9abc-def1-2345-678901234567', '23456789-abcd-ef12-3456-789012345678', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'ml', 10, 89.9, 10.0, 0.0, 0.0, 0.0),
('32345678-9abc-def1-2345-678901234567', '23456789-abcd-ef12-3456-789012345678', 'ERBE AROMATICHE (FOGLIE)', 2.0, 'g', 2, 1.76, 0.02, 0.3, 0.1, 0.2);

-- Recipe 19: Macedonia
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('13456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'MELE, senza buccia', 30.0, 'g', 30, 17.1, 0.03, 4.2, 0.09, 0.6),
('23456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'PERA, senza buccia', 30.0, 'g', 30, 12.9, 0.03, 3.0, 0.12, 1.05),
('33456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'KIWI', 30.0, 'g', 30, 14.4, 0.15, 3.48, 0.33, 0.9),
('43456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'MANDARINI', 20.0, 'g', 20, 15.2, 0.06, 3.8, 0.2, 0.34),
('53456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'BANANA', 20.0, 'g', 20, 13.8, 0.06, 4.6, 0.22, 0.52),
('63456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'UVA', 20.0, 'g', 20, 12.8, 0.02, 3.2, 0.14, 0.18),
('73456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'ZUCCHERO (Saccarosio)', 5.0, 'g', 5, 19.6, 0.0, 5.0, 0.0, 0.0),
('83456789-abcd-ef12-3456-789012345678', '3456789a-bcde-f123-4567-890123456789', 'SUCCO DI LIMONE, fresco', 5.0, 'ml', 5, 0.3, 0.01, 0.05, 0.02, 0.01);

-- Recipe 20: Macedonia con due palline di gelato
INSERT INTO public.recipe_ingredients (
    id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, fat_g, carbs_g, protein_g, fiber_g
) VALUES 
('156789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'MELE, senza buccia', 30.0, 'g', 30, 17.1, 0.03, 4.2, 0.09, 0.6),
('256789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'PERA, senza buccia', 30.0, 'g', 30, 12.9, 0.03, 3.0, 0.12, 1.05),
('356789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'BANANA', 20.0, 'g', 20, 13.8, 0.06, 4.6, 0.22, 0.52),
('456789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'KIWI', 30.0, 'g', 30, 14.4, 0.15, 3.48, 0.33, 0.9),
('556789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'UVA', 20.0, 'g', 20, 12.8, 0.02, 3.2, 0.14, 0.18),
('656789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'MANDARINI', 20.0, 'g', 20, 15.2, 0.06, 3.8, 0.2, 0.34),
('756789ab-cdef-1234-5678-901234567890', '456789ab-cdef-1234-5678-901234567890', 'GELATO AL CIOCCOLATO', 100.0, 'g', 100, 218.0, 11.0, 28.0, 4.0, 2.0);

-- ================================================
-- RECIPE TAGS INSERTION
-- ================================================

-- Insert recipe tags for categorization and search functionality
INSERT INTO public.recipe_tags (recipe_id, tag_name) VALUES
-- Recipe 1: Insalata di farro con verdure
('1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'Italian'),
('1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'Healthy'),
('1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'Grain'),
('1a2b3c4d-5e6f-7890-abcd-ef1234567890', 'Vegetables'),

-- Recipe 2: Insalata di farro riso e orzo con dadini di verdure
('2b3c4d5e-6f78-90ab-cdef-123456789012', 'Italian'),
('2b3c4d5e-6f78-90ab-cdef-123456789012', 'Mixed Grains'),
('2b3c4d5e-6f78-90ab-cdef-123456789012', 'Healthy'),
('2b3c4d5e-6f78-90ab-cdef-123456789012', 'Salad'),

-- Recipe 3: Insalata di farro riso e orzo con piselli
('3c4d5e6f-7890-abcd-ef12-345678901234', 'Italian'),
('3c4d5e6f-7890-abcd-ef12-345678901234', 'Grain'),
('3c4d5e6f-7890-abcd-ef12-345678901234', 'Peas'),
('3c4d5e6f-7890-abcd-ef12-345678901234', 'Simple'),

-- Recipe 4: Insalata di gamberetti
('4d5e6f78-90ab-cdef-1234-567890123456', 'Italian'),
('4d5e6f78-90ab-cdef-1234-567890123456', 'Seafood'),
('4d5e6f78-90ab-cdef-1234-567890123456', 'Shrimp'),
('4d5e6f78-90ab-cdef-1234-567890123456', 'Light'),

-- Recipe 5: Insalata di mare
('5e6f7890-abcd-ef12-3456-789012345678', 'Italian'),
('5e6f7890-abcd-ef12-3456-789012345678', 'Seafood'),
('5e6f7890-abcd-ef12-3456-789012345678', 'Mixed Seafood'),
('5e6f7890-abcd-ef12-3456-789012345678', 'Traditional'),

-- Recipe 6: Insalata di polpo con patate
('6f78901a-bcde-f123-4567-890123456789', 'Italian'),
('6f78901a-bcde-f123-4567-890123456789', 'Octopus'),
('6f78901a-bcde-f123-4567-890123456789', 'Potato'),
('6f78901a-bcde-f123-4567-890123456789', 'Mediterranean'),

-- Recipe 7: Insalata di riso
('7890abcd-ef12-3456-7890-ab1234567890', 'Italian'),
('7890abcd-ef12-3456-7890-ab1234567890', 'Rice'),
('7890abcd-ef12-3456-7890-ab1234567890', 'Summer'),
('7890abcd-ef12-3456-7890-ab1234567890', 'Complete'),

-- Recipe 8: Insalata fredda di ceci con extravergine
('890abcde-f123-4567-890a-b12345678901', 'Italian'),
('890abcde-f123-4567-890a-b12345678901', 'Chickpeas'),
('890abcde-f123-4567-890a-b12345678901', 'Cold'),
('890abcde-f123-4567-890a-b12345678901', 'Protein'),

-- Recipe 9: Insalata fredda di ceci con peperonata
('90abcdef-1234-5678-90ab-123456789012', 'Italian'),
('90abcdef-1234-5678-90ab-123456789012', 'Chickpeas'),
('90abcdef-1234-5678-90ab-123456789012', 'Bell Peppers'),
('90abcdef-1234-5678-90ab-123456789012', 'Vegetarian'),

-- Recipe 10: Insalata mista con carote e pomodori
('0abcdef1-2345-6789-0abc-def123456789', 'Italian'),
('0abcdef1-2345-6789-0abc-def123456789', 'Mixed Salad'),
('0abcdef1-2345-6789-0abc-def123456789', 'Fresh'),
('0abcdef1-2345-6789-0abc-def123456789', 'Colorful'),

-- Recipe 11: Insalata condita
('abcdef12-3456-789a-bcde-f12345678901', 'Italian'),
('abcdef12-3456-789a-bcde-f12345678901', 'Simple'),
('abcdef12-3456-789a-bcde-f12345678901', 'Green Salad'),
('abcdef12-3456-789a-bcde-f12345678901', 'Basic'),

-- Recipe 12: Involtini di carne con spinaci
('bcdef123-4567-89ab-cdef-123456789012', 'Italian'),
('bcdef123-4567-89ab-cdef-123456789012', 'Beef'),
('bcdef123-4567-89ab-cdef-123456789012', 'Spinach'),
('bcdef123-4567-89ab-cdef-123456789012', 'Elegant'),

-- Recipe 13: Involtini di pollo con prosciutto
('cdef1234-5678-9abc-def1-234567890123', 'Italian'),
('cdef1234-5678-9abc-def1-234567890123', 'Chicken'),
('cdef1234-5678-9abc-def1-234567890123', 'Prosciutto'),
('cdef1234-5678-9abc-def1-234567890123', 'Cheese'),

-- Recipe 14: Lasagne alla bolognese
('def12345-6789-abcd-ef12-345678901234', 'Italian'),
('def12345-6789-abcd-ef12-345678901234', 'Pasta'),
('def12345-6789-abcd-ef12-345678901234', 'Bolognese'),
('def12345-6789-abcd-ef12-345678901234', 'Classic'),

-- Recipe 15: Latte macchiato
('ef123456-789a-bcde-f123-456789012345', 'Italian'),
('ef123456-789a-bcde-f123-456789012345', 'Coffee'),
('ef123456-789a-bcde-f123-456789012345', 'Milk'),
('ef123456-789a-bcde-f123-456789012345', 'Beverage'),

-- Recipe 16: Lattuga condita
('f1234567-89ab-cdef-1234-567890123456', 'Italian'),
('f1234567-89ab-cdef-1234-567890123456', 'Lettuce'),
('f1234567-89ab-cdef-1234-567890123456', 'Simple'),
('f1234567-89ab-cdef-1234-567890123456', 'Fresh'),

-- Recipe 17: Lenticchie in umido
('12345678-9abc-def1-2345-678901234567', 'Italian'),
('12345678-9abc-def1-2345-678901234567', 'Lentils'),
('12345678-9abc-def1-2345-678901234567', 'Tomato'),
('12345678-9abc-def1-2345-678901234567', 'Hearty'),

-- Recipe 18: Lonza di maiale in padella
('23456789-abcd-ef12-3456-789012345678', 'Italian'),
('23456789-abcd-ef12-3456-789012345678', 'Pork'),
('23456789-abcd-ef12-3456-789012345678', 'Pan-fried'),
('23456789-abcd-ef12-3456-789012345678', 'Herbs'),

-- Recipe 19: Macedonia
('3456789a-bcde-f123-4567-890123456789', 'Italian'),
('3456789a-bcde-f123-4567-890123456789', 'Fruit'),
('3456789a-bcde-f123-4567-890123456789', 'Dessert'),
('3456789a-bcde-f123-4567-890123456789', 'Fresh'),

-- Recipe 20: Macedonia con gelato
('456789ab-cdef-1234-5678-901234567890', 'Italian'),
('456789ab-cdef-1234-5678-901234567890', 'Fruit'),
('456789ab-cdef-1234-5678-901234567890', 'Ice Cream'),
('456789ab-cdef-1234-5678-901234567890', 'Indulgent');

-- ================================================
-- REFRESH MATERIALIZED VIEWS (if any)
-- ================================================

-- Force trigger execution to update recipe nutritional totals
SELECT public.calculate_recipe_nutrition('1a2b3c4d-5e6f-7890-abcd-ef1234567890');
SELECT public.calculate_recipe_nutrition('2b3c4d5e-6f78-90ab-cdef-123456789012');
SELECT public.calculate_recipe_nutrition('3c4d5e6f-7890-abcd-ef12-345678901234');
SELECT public.calculate_recipe_nutrition('4d5e6f78-90ab-cdef-1234-567890123456');
SELECT public.calculate_recipe_nutrition('5e6f7890-abcd-ef12-3456-789012345678');
SELECT public.calculate_recipe_nutrition('6f78901a-bcde-f123-4567-890123456789');
SELECT public.calculate_recipe_nutrition('7890abcd-ef12-3456-7890-ab1234567890');
SELECT public.calculate_recipe_nutrition('890abcde-f123-4567-890a-b12345678901');
SELECT public.calculate_recipe_nutrition('90abcdef-1234-5678-90ab-123456789012');
SELECT public.calculate_recipe_nutrition('0abcdef1-2345-6789-0abc-def123456789');
SELECT public.calculate_recipe_nutrition('abcdef12-3456-789a-bcde-f12345678901');
SELECT public.calculate_recipe_nutrition('bcdef123-4567-89ab-cdef-123456789012');
SELECT public.calculate_recipe_nutrition('cdef1234-5678-9abc-def1-234567890123');
SELECT public.calculate_recipe_nutrition('def12345-6789-abcd-ef12-345678901234');
SELECT public.calculate_recipe_nutrition('ef123456-789a-bcde-f123-456789012345');
SELECT public.calculate_recipe_nutrition('f1234567-89ab-cdef-1234-567890123456');
SELECT public.calculate_recipe_nutrition('12345678-9abc-def1-2345-678901234567');
SELECT public.calculate_recipe_nutrition('23456789-abcd-ef12-3456-789012345678');
SELECT public.calculate_recipe_nutrition('3456789a-bcde-f123-4567-890123456789');
SELECT public.calculate_recipe_nutrition('456789ab-cdef-1234-5678-901234567890');

-- ================================================
-- COMPLETION NOTIFICATION
-- ================================================

-- Log completion
DO $$ 
BEGIN 
    RAISE NOTICE 'Migration 20250923214600_add_extended_italian_recipes completed successfully';
    RAISE NOTICE 'Added 20 new authentic Italian recipes with detailed nutritional information';
    RAISE NOTICE 'Enhanced recipe database with comprehensive ingredient data and recipe tags for better categorization';
END $$;

-- Final verification count
SELECT 
    'VERIFICATION: Current recipe count' AS status,
    COUNT(*) AS total_recipes,
    COUNT(CASE WHEN is_verified = true THEN 1 END) AS verified_recipes,
    COUNT(CASE WHEN is_public = true THEN 1 END) AS public_recipes
FROM public.recipes;