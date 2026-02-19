-- Add More Italian Recipes Data Migration
-- Adding additional Italian recipes with proper ingredients and nutritional data

-- First ensure we have a system user for public recipes
DO $$
DECLARE
    system_user_id UUID := '9b1cd123-6145-4763-89ac-6e629a4b4b6c';
BEGIN
    -- Insert system user if not exists (for public recipes)
    INSERT INTO public.user_profiles (id, full_name, email, role, created_at)
    VALUES (
        system_user_id,
        'System User',
        'system@nutrivita.app',
        'patient',
        NOW()
    ) ON CONFLICT (id) DO NOTHING;
END $$;

-- Insert new Italian recipes with proper categorization and nutritional data
INSERT INTO public.recipes (id, title, description, instructions, category, difficulty, prep_time_minutes, cook_time_minutes, servings, is_public, is_verified, created_by, total_calories, total_protein_g, total_fat_g, total_carbs_g, total_fiber_g) VALUES
-- Vegetables and Side Dishes
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'Cavolfiore lessato o al vapore, con extravergine', 'Traditional Italian steamed cauliflower with extra virgin olive oil', 'Steam cauliflower until tender. Drizzle with extra virgin olive oil and season with salt to taste.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 15, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 100, 3, 10, 6, 3),
('b2c3d4e5-f6a7-8901-2345-678901bcdefa', 'Cavolini di Bruxelles lessati o al vapore, con extravergine', 'Brussels sprouts steamed with extra virgin olive oil', 'Steam Brussels sprouts until tender. Drizzle with olive oil and season with salt.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 12, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 98, 4, 10, 10, 4),
('c3d4e5f6-a7b8-9012-3456-789012cdefab', 'Cavolo cappuccio in insalata, tagliato finemente, con extravergine', 'Finely shredded red cabbage salad with extra virgin olive oil', 'Finely shred red cabbage. Dress with olive oil, vinegar, salt and pepper. Let marinate for 30 minutes.', 'snack'::recipe_category, 'easy'::recipe_difficulty, 35, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 92, 1, 10, 4, 2),
('d4e5f6a7-b8c9-0123-4567-890123defabc', 'Ceci in umido con sugo al pomodoro', 'Chickpeas stewed in tomato sauce', 'Soak chickpeas overnight. Cook with onions, tomato passata, olive oil, and herbs until tender.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 20, 60, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 200, 8, 10, 32, 6),
('e5f6a7b8-c9d0-1234-5678-901234efabcd', 'Cicoria o catalogna cotta e condita', 'Cooked chicory with olive oil and seasonings', 'Boil chicory until tender. Drain and sauté with olive oil, garlic, and seasonings.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 15, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 95, 3, 10, 6, 4),

-- Beverages
('f6a7b8c9-d0e1-2345-6789-012345fabcde', 'Cioccolata calda', 'Traditional Italian hot chocolate', 'Heat milk with cocoa powder, potato starch, and sugar. Whisk until thick and creamy.', 'beverage'::recipe_category, 'medium'::recipe_difficulty, 5, 10, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 135, 5, 3, 24, 1),

-- Meat Dishes
('a7b8c9d0-e1f2-3456-7890-123456abcdef', 'Coniglio arrosto', 'Traditional Italian roasted rabbit', 'Season rabbit with herbs and olive oil. Roast in oven with pancetta and rosemary until tender.', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 20, 90, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 180, 25, 12, 2, 0),
('b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'Coscia di pollo arrosto (con pelle)', 'Roasted chicken thigh with skin', 'Season chicken thigh and roast with herbs and olive oil until golden and cooked through.', 'dinner'::recipe_category, 'easy'::recipe_difficulty, 10, 45, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 175, 20, 14, 1, 0),
('c9d0e1f2-a3b4-5678-9012-345678cdef01', 'Coscia di pollo arrosto (senza pelle)', 'Roasted chicken thigh without skin', 'Season skinless chicken thigh and roast with herbs and olive oil.', 'dinner'::recipe_category, 'easy'::recipe_difficulty, 10, 40, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 150, 22, 10, 1, 0),
('d0e1f2a3-b4c5-6789-0123-456789def012', 'Coscia di tacchino al forno', 'Oven-baked turkey thigh', 'Season turkey thigh with herbs and olive oil. Bake until golden and tender.', 'dinner'::recipe_category, 'easy'::recipe_difficulty, 15, 75, 3, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 165, 23, 11, 2, 0),

-- Side Dishes
('e1f2a3b4-c5d6-7890-1234-567890ef0123', 'Coste o biete lessate con extravergine', 'Boiled chard with extra virgin olive oil', 'Boil chard stems and leaves until tender. Dress with olive oil and salt.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 5, 10, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 85, 2, 10, 4, 3),
('f2a3b4c5-d6e7-8901-2345-678901f01234', 'Costine di maiale ai ferri', 'Grilled pork ribs', 'Season pork ribs with salt and grill until cooked through and slightly charred.', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 10, 25, 3, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 268, 25, 20, 0, 0),
('a3b4c5d6-e7f8-9012-3456-789012012345', 'Cotoletta alla milanese', 'Classic Milanese veal cutlet', 'Bread veal cutlet with egg and breadcrumbs. Pan-fry in butter until golden.', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 20, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 280, 28, 18, 8, 1),

-- Soups
('b4c5d6e7-f8a9-0123-4567-890123123456', 'Crema di ceci', 'Creamy chickpea soup', 'Cook chickpeas with onions and broth. Blend until smooth and season with pepper.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 15, 45, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 210, 9, 11, 28, 5),
('c5d6e7f8-a9b0-1234-5678-901234234567', 'Crema di fagioli cannellini', 'Creamy cannellini bean soup', 'Cook cannellini beans with onions and broth. Blend until creamy and season.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 15, 50, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 220, 10, 11, 30, 6),
('d6e7f8a9-b0c1-2345-6789-012345345678', 'Crema di piselli', 'Pea soup with parmesan', 'Cook frozen peas with onions and broth. Blend until smooth, finish with parmesan.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 25, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 145, 8, 11, 18, 4),
('e7f8a9b0-c1d2-3456-7890-123456456789', 'Crema di piselli con patate', 'Pea and potato cream soup', 'Cook peas and potatoes with onions and broth. Blend until smooth, finish with herbs and parmesan.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 15, 30, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 185, 9, 11, 25, 5),
('f8a9b0c1-d2e3-4567-8901-234567567890', 'Crema di zucca', 'Creamy pumpkin soup', 'Cook pumpkin with onions and broth. Blend until smooth, finish with sage and parmesan.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 15, 35, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 125, 6, 11, 16, 3),
('a9b0c1d2-e3f4-5678-9012-345678678901', 'Crema porri e patate', 'Leek and potato cream soup', 'Cook leeks and potatoes with onions and broth. Blend until creamy, finish with herbs.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 20, 40, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 195, 7, 11, 28, 4),

-- Desserts
('b0c1d2e3-f4a5-6789-0123-456789789012', 'Crostata alla marmellata', 'Traditional Italian jam tart', 'Make pastry with flour, butter, sugar and egg yolk. Fill with jam and bake until golden.', 'dessert'::recipe_category, 'medium'::recipe_difficulty, 30, 40, 8, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 320, 6, 15, 48, 2),

-- Legume Dishes
('c1d2e3f4-a5b6-7890-1234-567890890123', 'Fagioli all''uccelletto', 'Tuscan-style beans in tomato sauce', 'Cook dried beans then stew with tomato passata, garlic, olive oil, and sage.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 20, 40, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 195, 11, 10, 28, 7),
('d2e3f4a5-b6c7-8901-2345-678901901234', 'Fagioli con nervetti', 'Beans with veal cartilage', 'Traditional dish combining cooked beans with boiled veal cartilage and olive oil.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 25, 120, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 220, 15, 10, 30, 8),
('e3f4a5b6-c7d8-9012-3456-789012012345', 'Fagioli in umido con sugo al pomodoro', 'Stewed beans in tomato sauce', 'Cook beans with onions, tomato passata, olive oil, and fresh parsley.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 20, 45, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 205, 11, 10, 29, 8),
('f4a5b6c7-d8e9-0123-4567-890123123456', 'Fagiolini in padella', 'Pan-fried green beans', 'Sauté green beans with olive oil, garlic, parsley, and vegetable broth until tender.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 20, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 115, 3, 10, 12, 4),
('a5b6c7d8-e9f0-4567-8901-234567234567', 'Fagiolini lessati e conditi', 'Boiled green beans with olive oil', 'Boil green beans until tender. Drain and season with olive oil, salt and pepper.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 5, 10, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 108, 2, 10, 5, 3),
('b6c7d8e9-f0a1-5678-9012-345678345678', 'Farro bollito condito con extravergine', 'Boiled farro with extra virgin olive oil', 'Cook farro until tender. Drain and dress with olive oil and salt.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 25, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 372, 11, 10, 70, 8),
('c7d8e9f0-a1b2-6789-0123-456789456789', 'Fegato alla veneta', 'Venetian-style liver with onions', 'Sauté liver with onions, butter and flour until golden. A classic Venetian dish.', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 15, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 255, 24, 14, 6, 1),
('d8e9f0a1-b2c3-7890-1234-567890567890', 'Filetti di merluzzo con pomodori, olive e capperi', 'Cod fillets with tomatoes, olives and capers', 'Pan-fry cod with fresh tomatoes, black olives, capers, garlic and herbs.', 'dinner'::recipe_category, 'medium'::recipe_difficulty, 15, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 195, 32, 11, 8, 3),
('e9f0a1b2-c3d4-8901-2345-678901678901', 'Filetto di manzo ai ferri', 'Grilled beef fillet', 'Season beef fillet and grill to perfection with olive oil and seasonings.', 'dinner'::recipe_category, 'easy'::recipe_difficulty, 5, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 217, 25, 12, 0, 0),
('f0a1b2c3-d4e5-9012-3456-789012789012', 'Finocchi gratinati', 'Gratin fennel with béchamel', 'Bake fennel with béchamel sauce and parmesan until golden and bubbly.', 'lunch'::recipe_category, 'medium'::recipe_difficulty, 20, 35, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 158, 8, 12, 12, 3),
('01b2c3d4-e5f6-0123-4567-890123890123', 'Finocchi in insalata', 'Raw fennel salad', 'Thinly slice fennel and dress with olive oil, salt and pepper.', 'snack'::recipe_category, 'easy'::recipe_difficulty, 10, 0, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 116, 1, 10, 5, 3),
('12c3d4e5-f6a7-1234-5678-901234901234', 'Finocchi in insalata con arance', 'Fennel and orange salad', 'Combine sliced fennel and orange segments with olive oil dressing.', 'snack'::recipe_category, 'easy'::recipe_difficulty, 15, 0, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 129, 1, 10, 12, 3),
('23d4e5f6-a7b8-2345-6789-012345012345', 'Finocchi in padella', 'Pan-fried fennel', 'Sauté fennel slices with olive oil and garlic until tender and golden.', 'lunch'::recipe_category, 'easy'::recipe_difficulty, 10, 15, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 117, 1, 10, 6, 3),
('34e5f6a7-b8c9-3456-7890-123456123456', 'Fragole con gelato fiordilatte', 'Strawberries with vanilla ice cream', 'Fresh strawberries served with creamy vanilla ice cream.', 'dessert'::recipe_category, 'easy'::recipe_difficulty, 5, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 263, 6, 11, 36, 2),
('45f6a7b8-c9d0-4567-8901-234567234567', 'Fragole zucchero e limone', 'Strawberries with sugar and lemon', 'Fresh strawberries macerated with sugar and fresh lemon juice.', 'dessert'::recipe_category, 'easy'::recipe_difficulty, 10, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 66, 1, 0, 16, 2),
('56a7b8c9-d0e1-5678-9012-345678345678', 'Frittata', 'Italian omelet with parmesan', 'Beat eggs with parmesan and cook in olive oil until set and golden.', 'breakfast'::recipe_category, 'easy'::recipe_difficulty, 5, 8, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 183, 12, 15, 1, 0),
('67b8c9d0-e1f2-6789-0123-456789456789', 'Frittata con porri', 'Leek frittata', 'Italian-style omelet with sautéed leeks and parmesan cheese.', 'breakfast'::recipe_category, 'easy'::recipe_difficulty, 10, 12, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 197, 12, 15, 2, 1);

-- Insert recipe ingredients for the new recipes
INSERT INTO public.recipe_ingredients (id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, fat_g, carbs_g, fiber_g) VALUES
-- Cavolfiore lessato o al vapore, con extravergine
(gen_random_uuid(), 'a1b2c3d4-e5f6-7890-1234-567890abcdef', 'CAVOLFIORE', 200, 'g', 200, 60, 3, 0, 6, 3),
(gen_random_uuid(), 'a1b2c3d4-e5f6-7890-1234-567890abcdef', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Cavolini di Bruxelles lessati o al vapore, con extravergine
(gen_random_uuid(), 'b2c3d4e5-f6a7-8901-2345-678901bcdefa', 'CAVOLI DI BRUXELLES', 200, 'g', 200, 96, 4, 0, 10, 4),
(gen_random_uuid(), 'b2c3d4e5-f6a7-8901-2345-678901bcdefa', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Cavolo cappuccio in insalata, tagliato finemente, con extravergine
(gen_random_uuid(), 'c3d4e5f6-a7b8-9012-3456-789012cdefab', 'CAVOLO CAPPUCCIO ROSSO', 80, 'g', 80, 18, 1, 0, 4, 2),
(gen_random_uuid(), 'c3d4e5f6-a7b8-9012-3456-789012cdefab', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),
(gen_random_uuid(), 'c3d4e5f6-a7b8-9012-3456-789012cdefab', 'ACETO', 5, 'ml', 5, 1, 0, 0, 0, 0),

-- Ceci in umido con sugo al pomodoro
(gen_random_uuid(), 'd4e5f6a7-b8c9-0123-4567-890123defabc', 'CECI, secchi', 50, 'g', 50, 182, 8, 3, 32, 6),
(gen_random_uuid(), 'd4e5f6a7-b8c9-0123-4567-890123defabc', 'PASSATA DI POMODORO', 70, 'g', 70, 25, 1, 0, 5, 1),
(gen_random_uuid(), 'd4e5f6a7-b8c9-0123-4567-890123defabc', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),
(gen_random_uuid(), 'd4e5f6a7-b8c9-0123-4567-890123defabc', 'CIPOLLE', 17, 'g', 17, 5, 0, 0, 1, 0),
(gen_random_uuid(), 'd4e5f6a7-b8c9-0123-4567-890123defabc', 'PREZZEMOLO, fresco', 3, 'g', 3, 1, 0, 0, 0, 0),

-- Cicoria o catalogna cotta e condita
(gen_random_uuid(), 'e5f6a7b8-c9d0-1234-5678-901234efabcd', 'CICORIA CATALOGNA', 200, 'g', 200, 60, 3, 0, 6, 4),
(gen_random_uuid(), 'e5f6a7b8-c9d0-1234-5678-901234efabcd', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Cioccolata calda
(gen_random_uuid(), 'f6a7b8c9-d0e1-2345-6789-012345fabcde', 'LATTE DI VACCA, INTERO PASTORIZZATO', 125, 'ml', 125, 80, 5, 4, 6, 0),
(gen_random_uuid(), 'f6a7b8c9-d0e1-2345-6789-012345fabcde', 'CACAO AMARO, in polvere', 7, 'g', 7, 29, 2, 1, 2, 1),
(gen_random_uuid(), 'f6a7b8c9-d0e1-2345-6789-012345fabcde', 'PATATE, FECOLA', 4, 'g', 4, 14, 0, 0, 3, 0),
(gen_random_uuid(), 'f6a7b8c9-d0e1-2345-6789-012345fabcde', 'ZUCCHERO (Saccarosio)', 7, 'g', 7, 27, 0, 0, 7, 0),

-- Coniglio arrosto
(gen_random_uuid(), 'a7b8c9d0-e1f2-3456-7890-123456abcdef', 'CONIGLIO, CARNE SEMIGRASSA', 100, 'g', 100, 138, 20, 6, 0, 0),
(gen_random_uuid(), 'a7b8c9d0-e1f2-3456-7890-123456abcdef', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),
(gen_random_uuid(), 'a7b8c9d0-e1f2-3456-7890-123456abcdef', 'PANCETTA DI MAIALE', 5, 'g', 5, 33, 1, 3, 0, 0),
(gen_random_uuid(), 'a7b8c9d0-e1f2-3456-7890-123456abcdef', 'ROSMARINO, fresco', 2, 'g', 2, 2, 0, 0, 0, 0),

-- Coscia di pollo arrosto (con pelle)
(gen_random_uuid(), 'b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'POLLO, FUSO (COSCIA), con pelle', 100, 'g', 100, 125, 18, 6, 0, 0),
(gen_random_uuid(), 'b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'ERBE AROMATICHE (FOGLIE)', 1, 'g', 1, 1, 0, 0, 0, 0),
(gen_random_uuid(), 'b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Coscia di pollo arrosto (senza pelle)
(gen_random_uuid(), 'c9d0e1f2-a3b4-5678-9012-345678cdef01', 'POLLO, FUSO (COSCIA), senza pelle', 100, 'g', 100, 107, 20, 3, 0, 0),
(gen_random_uuid(), 'c9d0e1f2-a3b4-5678-9012-345678cdef01', 'ERBE AROMATICHE (FOGLIE)', 1, 'g', 1, 1, 0, 0, 0, 0),
(gen_random_uuid(), 'c9d0e1f2-a3b4-5678-9012-345678cdef01', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Coscia di tacchino al forno
(gen_random_uuid(), 'd0e1f2a3-b4c5-6789-0123-456789def012', 'TACCHINO, FUSO (COSCIA), con pelle', 100, 'g', 100, 126, 20, 5, 0, 0),
(gen_random_uuid(), 'd0e1f2a3-b4c5-6789-0123-456789def012', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),
(gen_random_uuid(), 'd0e1f2a3-b4c5-6789-0123-456789def012', 'ERBE AROMATICHE (FOGLIE)', 1, 'g', 1, 1, 0, 0, 0, 0),

-- Coste o biete lessate con extravergine
(gen_random_uuid(), 'e1f2a3b4-c5d6-7890-1234-567890ef0123', 'BIETA', 200, 'g', 200, 38, 2, 0, 4, 3),
(gen_random_uuid(), 'e1f2a3b4-c5d6-7890-1234-567890ef0123', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Costine di maiale ai ferri
(gen_random_uuid(), 'f2a3b4c5-d6e7-8901-2345-678901f01234', 'SUINO, CARNE GRASSA, senza grasso visibile', 100, 'g', 100, 268, 25, 20, 0, 0),

-- Cotoletta alla milanese
(gen_random_uuid(), 'a3b4c5d6-e7f8-9012-3456-789012012345', 'BOVINO, VITELLO, 4 MESI, CARNE MAGRA, senza grasso visibile', 100, 'g', 100, 92, 20, 1, 0, 0),
(gen_random_uuid(), 'a3b4c5d6-e7f8-9012-3456-789012012345', 'PANE GRATTUGIATO', 13, 'g', 13, 47, 2, 1, 8, 1),
(gen_random_uuid(), 'a3b4c5d6-e7f8-9012-3456-789012012345', 'UOVO DI GALLINA, INTERO', 25, 'g', 25, 32, 3, 2, 0, 0),
(gen_random_uuid(), 'a3b4c5d6-e7f8-9012-3456-789012012345', 'BURRO', 15, 'g', 15, 114, 0, 12, 0, 0),

-- Add ingredients for soup recipes
-- Crema di ceci
(gen_random_uuid(), 'b4c5d6e7-f8a9-0123-4567-890123123456', 'CECI, secchi', 50, 'g', 50, 182, 8, 3, 32, 6),
(gen_random_uuid(), 'b4c5d6e7-f8a9-0123-4567-890123123456', 'BRODO DI CARNE E VERDURA', 125, 'ml', 125, 6, 1, 0, 1, 0),
(gen_random_uuid(), 'b4c5d6e7-f8a9-0123-4567-890123123456', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),
(gen_random_uuid(), 'b4c5d6e7-f8a9-0123-4567-890123123456', 'CIPOLLE', 30, 'g', 30, 8, 0, 0, 2, 0),

-- Fagiolini lessati e conditi
(gen_random_uuid(), 'a5b6c7d8-e9f0-4567-8901-234567234567', 'FAGIOLINI', 200, 'g', 200, 48, 2, 0, 5, 3),
(gen_random_uuid(), 'a5b6c7d8-e9f0-4567-8901-234567234567', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Farro bollito condito con extravergine
(gen_random_uuid(), 'b6c7d8e9-f0a1-5678-9012-345678345678', 'FARRO', 80, 'g', 80, 282, 11, 2, 70, 8),
(gen_random_uuid(), 'b6c7d8e9-f0a1-5678-9012-345678345678', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Fegato alla veneta
(gen_random_uuid(), 'c7d8e9f0-a1b2-6789-0123-456789456789', 'BOVINO, FEGATO', 100, 'g', 100, 142, 20, 4, 5, 0),
(gen_random_uuid(), 'c7d8e9f0-a1b2-6789-0123-456789456789', 'BURRO', 10, 'g', 10, 76, 0, 8, 0, 0),
(gen_random_uuid(), 'c7d8e9f0-a1b2-6789-0123-456789456789', 'FARINA DI FRUMENTO, TIPO 00', 4, 'g', 4, 14, 1, 0, 3, 0),
(gen_random_uuid(), 'c7d8e9f0-a1b2-6789-0123-456789456789', 'CIPOLLE', 40, 'g', 40, 11, 0, 0, 3, 1),

-- Filetti di merluzzo con pomodori, olive e capperi
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'MERLUZZO', 150, 'g', 150, 107, 23, 1, 0, 0),
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'CIPOLLE', 15, 'g', 15, 4, 0, 0, 1, 0),
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'OLIVE NERE', 15, 'g', 15, 36, 0, 4, 2, 1),
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'POMODORI MATURI', 150, 'g', 150, 32, 2, 0, 5, 2),
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'AGLIO, fresco', 5, 'g', 5, 2, 0, 0, 1, 0),
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),
(gen_random_uuid(), 'd8e9f0a1-b2c3-7890-1234-567890567890', 'BASILICO, fresco', 3, 'g', 3, 1, 0, 0, 0, 0),

-- Filetto di manzo ai ferri
(gen_random_uuid(), 'e9f0a1b2-c3d4-8901-2345-678901678901', 'BOVINO, VITELLONE, 15-18 MESI, filetto, senza grasso visibile', 100, 'g', 100, 127, 23, 3, 0, 0),
(gen_random_uuid(), 'e9f0a1b2-c3d4-8901-2345-678901678901', 'OLIO DI OLIVA EXTRAVERGINE', 10, 'ml', 10, 90, 0, 10, 0, 0),

-- Frittata
(gen_random_uuid(), '56a7b8c9-d0e1-5678-9012-345678345678', 'UOVO DI GALLINA, INTERO', 50, 'g', 50, 64, 6, 5, 0, 0),
(gen_random_uuid(), '56a7b8c9-d0e1-5678-9012-345678345678', 'OLIO DI OLIVA EXTRAVERGINE', 5, 'ml', 5, 45, 0, 5, 0, 0),
(gen_random_uuid(), '56a7b8c9-d0e1-5678-9012-345678345678', 'PARMIGIANO', 5, 'g', 5, 19, 1, 1, 0, 0),

-- Frittata con porri
(gen_random_uuid(), '67b8c9d0-e1f2-6789-0123-456789456789', 'UOVO DI GALLINA, INTERO', 50, 'g', 50, 64, 6, 5, 0, 0),
(gen_random_uuid(), '67b8c9d0-e1f2-6789-0123-456789456789', 'PORRI', 40, 'g', 40, 14, 1, 0, 2, 1),
(gen_random_uuid(), '67b8c9d0-e1f2-6789-0123-456789456789', 'OLIO DI OLIVA EXTRAVERGINE', 5, 'ml', 5, 45, 0, 5, 0, 0),
(gen_random_uuid(), '67b8c9d0-e1f2-6789-0123-456789456789', 'PARMIGIANO', 5, 'g', 5, 19, 1, 1, 0, 0);

-- Insert recipe tags for all new recipes
INSERT INTO public.recipe_tags (recipe_id, tag_name) VALUES
-- Vegetable dishes
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'Italian'),
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'Vegetables'),
('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'Healthy'),
('b2c3d4e5-f6a7-8901-2345-678901bcdefa', 'Italian'),
('b2c3d4e5-f6a7-8901-2345-678901bcdefa', 'Vegetables'),
('c3d4e5f6-a7b8-9012-3456-789012cdefab', 'Italian'),
('c3d4e5f6-a7b8-9012-3456-789012cdefab', 'Salad'),
('c3d4e5f6-a7b8-9012-3456-789012cdefab', 'Raw'),
('d4e5f6a7-b8c9-0123-4567-890123defabc', 'Italian'),
('d4e5f6a7-b8c9-0123-4567-890123defabc', 'Legumes'),
('d4e5f6a7-b8c9-0123-4567-890123defabc', 'Protein'),
('e5f6a7b8-c9d0-1234-5678-901234efabcd', 'Italian'),
('e5f6a7b8-c9d0-1234-5678-901234efabcd', 'Vegetables'),

-- Beverages
('f6a7b8c9-d0e1-2345-6789-012345fabcde', 'Italian'),
('f6a7b8c9-d0e1-2345-6789-012345fabcde', 'Hot Drink'),
('f6a7b8c9-d0e1-2345-6789-012345fabcde', 'Chocolate'),

-- Meat dishes
('a7b8c9d0-e1f2-3456-7890-123456abcdef', 'Italian'),
('a7b8c9d0-e1f2-3456-7890-123456abcdef', 'Roasted'),
('a7b8c9d0-e1f2-3456-7890-123456abcdef', 'Rabbit'),
('b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'Italian'),
('b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'Chicken'),
('b8c9d0e1-f2a3-4567-8901-234567bcdef0', 'Roasted'),
('c9d0e1f2-a3b4-5678-9012-345678cdef01', 'Italian'),
('c9d0e1f2-a3b4-5678-9012-345678cdef01', 'Chicken'),
('c9d0e1f2-a3b4-5678-9012-345678cdef01', 'Lean'),
('d0e1f2a3-b4c5-6789-0123-456789def012', 'Italian'),
('d0e1f2a3-b4c5-6789-0123-456789def012', 'Turkey'),
('d0e1f2a3-b4c5-6789-0123-456789def012', 'Baked'),

-- Side dishes and more
('e1f2a3b4-c5d6-7890-1234-567890ef0123', 'Italian'),
('e1f2a3b4-c5d6-7890-1234-567890ef0123', 'Vegetables'),
('e1f2a3b4-c5d6-7890-1234-567890ef0123', 'Chard'),
('f2a3b4c5-d6e7-8901-2345-678901f01234', 'Italian'),
('f2a3b4c5-d6e7-8901-2345-678901f01234', 'Pork'),
('f2a3b4c5-d6e7-8901-2345-678901f01234', 'Grilled'),
('a3b4c5d6-e7f8-9012-3456-789012012345', 'Italian'),
('a3b4c5d6-e7f8-9012-3456-789012012345', 'Veal'),
('a3b4c5d6-e7f8-9012-3456-789012012345', 'Milanese'),
('a3b4c5d6-e7f8-9012-3456-789012012345', 'Breaded'),

-- Soup tags
('b4c5d6e7-f8a9-0123-4567-890123123456', 'Italian'),
('b4c5d6e7-f8a9-0123-4567-890123123456', 'Soup'),
('b4c5d6e7-f8a9-0123-4567-890123123456', 'Chickpeas'),
('c5d6e7f8-a9b0-1234-5678-901234234567', 'Italian'),
('c5d6e7f8-a9b0-1234-5678-901234234567', 'Soup'),
('c5d6e7f8-a9b0-1234-5678-901234234567', 'Beans'),
('d6e7f8a9-b0c1-2345-6789-012345345678', 'Italian'),
('d6e7f8a9-b0c1-2345-6789-012345345678', 'Soup'),
('d6e7f8a9-b0c1-2345-6789-012345345678', 'Peas'),
('e7f8a9b0-c1d2-3456-7890-123456456789', 'Italian'),
('e7f8a9b0-c1d2-3456-7890-123456456789', 'Soup'),
('e7f8a9b0-c1d2-3456-7890-123456456789', 'Peas'),
('e7f8a9b0-c1d2-3456-7890-123456456789', 'Potatoes'),
('f8a9b0c1-d2e3-4567-8901-234567567890', 'Italian'),
('f8a9b0c1-d2e3-4567-8901-234567567890', 'Soup'),
('f8a9b0c1-d2e3-4567-8901-234567567890', 'Pumpkin'),
('a9b0c1d2-e3f4-5678-9012-345678678901', 'Italian'),
('a9b0c1d2-e3f4-5678-9012-345678678901', 'Soup'),
('a9b0c1d2-e3f4-5678-9012-345678678901', 'Leeks'),
('a9b0c1d2-e3f4-5678-9012-345678678901', 'Potatoes'),

-- Dessert tags
('b0c1d2e3-f4a5-6789-0123-456789789012', 'Italian'),
('b0c1d2e3-f4a5-6789-0123-456789789012', 'Dessert'),
('b0c1d2e3-f4a5-6789-0123-456789789012', 'Tart'),
('b0c1d2e3-f4a5-6789-0123-456789789012', 'Jam'),

-- Bean dishes
('c1d2e3f4-a5b6-7890-1234-567890890123', 'Italian'),
('c1d2e3f4-a5b6-7890-1234-567890890123', 'Tuscan'),
('c1d2e3f4-a5b6-7890-1234-567890890123', 'Beans'),
('c1d2e3f4-a5b6-7890-1234-567890890123', 'Sage'),
('d2e3f4a5-b6c7-8901-2345-678901901234', 'Italian'),
('d2e3f4a5-b6c7-8901-2345-678901901234', 'Traditional'),
('d2e3f4a5-b6c7-8901-2345-678901901234', 'Beans'),
('e3f4a5b6-c7d8-9012-3456-789012012345', 'Italian'),
('e3f4a5b6-c7d8-9012-3456-789012012345', 'Beans'),
('e3f4a5b6-c7d8-9012-3456-789012012345', 'Tomato'),
('f4a5b6c7-d8e9-0123-4567-890123123456', 'Italian'),
('f4a5b6c7-d8e9-0123-4567-890123123456', 'Green Beans'),
('f4a5b6c7-d8e9-0123-4567-890123123456', 'Pan-fried'),
('a5b6c7d8-e9f0-4567-8901-234567234567', 'Italian'),
('a5b6c7d8-e9f0-4567-8901-234567234567', 'Green Beans'),
('a5b6c7d8-e9f0-4567-8901-234567234567', 'Boiled'),

-- Grains
('b6c7d8e9-f0a1-5678-9012-345678345678', 'Italian'),
('b6c7d8e9-f0a1-5678-9012-345678345678', 'Grains'),
('b6c7d8e9-f0a1-5678-9012-345678345678', 'Farro'),

-- Fegato alla veneta
('c7d8e9f0-a1b2-6789-0123-456789456789', 'Italian'),
('c7d8e9f0-a1b2-6789-0123-456789456789', 'Venetian'),
('c7d8e9f0-a1b2-6789-0123-456789456789', 'Liver'),
('c7d8e9f0-a1b2-6789-0123-456789456789', 'Traditional'),

-- Filetti di merluzzo con pomodori, olive e capperi
('d8e9f0a1-b2c3-7890-1234-567890567890', 'Italian'),
('d8e9f0a1-b2c3-7890-1234-567890567890', 'Fish'),
('d8e9f0a1-b2c3-7890-1234-567890567890', 'Cod'),
('d8e9f0a1-b2c3-7890-1234-567890567890', 'Mediterranean'),

-- Filetto di manzo ai ferri
('e9f0a1b2-c3d4-8901-2345-678901678901', 'Italian'),
('e9f0a1b2-c3d4-8901-2345-678901678901', 'Beef'),
('e9f0a1b2-c3d4-8901-2345-678901678901', 'Grilled'),
('e9f0a1b2-c3d4-8901-2345-678901678901', 'Fillet'),

-- Frittata
('56a7b8c9-d0e1-5678-9012-345678345678', 'Italian'),
('56a7b8c9-d0e1-5678-9012-345678345678', 'Eggs'),
('56a7b8c9-d0e1-5678-9012-345678345678', 'Breakfast'),

-- Frittata con porri
('67b8c9d0-e1f2-6789-0123-456789456789', 'Italian'),
('67b8c9d0-e1f2-6789-0123-456789456789', 'Eggs'),
('67b8c9d0-e1f2-6789-0123-456789456789', 'Leeks'),
('67b8c9d0-e1f2-6789-0123-456789456789', 'Breakfast');

-- Create indexes for better performance on new data
CREATE INDEX IF NOT EXISTS idx_recipes_title_search ON public.recipes USING gin(to_tsvector('italian', title));
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_name_search ON public.recipe_ingredients USING gin(to_tsvector('italian', ingredient_name));

-- Update recipe statistics
UPDATE public.recipes SET 
    total_calories = (
        SELECT COALESCE(SUM(calories), 0) 
        FROM public.recipe_ingredients 
        WHERE recipe_id = recipes.id
    ),
    total_protein_g = (
        SELECT COALESCE(SUM(protein_g), 0) 
        FROM public.recipe_ingredients 
        WHERE recipe_id = recipes.id
    ),
    total_fat_g = (
        SELECT COALESCE(SUM(fat_g), 0) 
        FROM public.recipe_ingredients 
        WHERE recipe_id = recipes.id
    ),
    total_carbs_g = (
        SELECT COALESCE(SUM(carbs_g), 0) 
        FROM public.recipe_ingredients 
        WHERE recipe_id = recipes.id
    ),
    total_fiber_g = (
        SELECT COALESCE(SUM(fiber_g), 0) 
        FROM public.recipe_ingredients 
        WHERE recipe_id = recipes.id
    )
WHERE created_at >= '2025-09-23 20:50:00';

-- Add helpful comments
COMMENT ON TABLE public.recipes IS 'Recipe management table with Italian cuisine focus - contains authentic Italian recipes with proper nutritional calculations';
COMMENT ON TABLE public.recipe_ingredients IS 'Ingredients for recipes with detailed nutritional information per ingredient';
COMMENT ON TABLE public.recipe_tags IS 'Tags for categorizing and filtering recipes by cuisine type, cooking method, ingredients, etc.';

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Successfully added additional Italian recipes with ingredients and tags';
    RAISE NOTICE 'Total recipes in database: %', (SELECT COUNT(*) FROM public.recipes);
    RAISE NOTICE 'Total ingredients in database: %', (SELECT COUNT(*) FROM public.recipe_ingredients);
    RAISE NOTICE 'Total tags in database: %', (SELECT COUNT(*) FROM public.recipe_tags);
END $$;