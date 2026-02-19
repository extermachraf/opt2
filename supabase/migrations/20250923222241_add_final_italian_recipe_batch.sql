-- Migration: Add final batch of Italian recipes
-- Generated at: 2025-09-23 22:22:41
-- Description: Adding comprehensive collection of Italian recipes with detailed ingredients and nutritional data

-- Create default user profile for system-generated recipes
DO $$
DECLARE
    system_user_id UUID := '9b1cd123-6145-4763-89ac-6e629a4b4b6c';
BEGIN
    -- Check if system user exists, create if not
    IF NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE id = system_user_id) THEN
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            recovery_sent_at,
            last_sign_in_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            confirmation_token,
            email_change,
            email_change_token_new,
            recovery_token
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            system_user_id,
            'authenticated',
            'authenticated',
            'system@nutrivita.app',
            '$2a$10$DummyHashForSystemUser',
            NOW(),
            NOW(),
            NOW(),
            '{"provider": "system", "providers": ["system"]}',
            '{"system_user": true}',
            NOW(),
            NOW(),
            '',
            '',
            '',
            ''
        ) ON CONFLICT (id) DO NOTHING;

        INSERT INTO public.user_profiles (
            id,
            full_name,
            role,
            created_at,
            updated_at
        ) VALUES (
            system_user_id,
            'NutriVita System',
            'patient'::public.user_role,
            NOW(),
            NOW()
        ) ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- Insert recipes
INSERT INTO public.recipes (
    id,
    title,
    description,
    category,
    difficulty,
    prep_time_minutes,
    cook_time_minutes,
    servings,
    is_public,
    is_verified,
    created_by,
    created_at,
    updated_at
) VALUES
-- Panino rosetta con prosciutto cotto e fontina
('a1b2c3d4-e5f6-4000-8000-100000000001', 'Panino rosetta con prosciutto cotto e fontina', 'Delicious Italian sandwich with cooked ham and fontina cheese', 'snack'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 0, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Panino rosetta con salame  
('a1b2c3d4-e5f6-4000-8000-100000000002', 'Panino rosetta con salame', 'Traditional Italian sandwich with salami', 'snack'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 0, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Panzanella
('a1b2c3d4-e5f6-4000-8000-100000000003', 'Panzanella', 'Classic Tuscan bread salad with tomatoes and vegetables', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 15, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pappa al pomodoro
('a1b2c3d4-e5f6-4000-8000-100000000004', 'Pappa al pomodoro', 'Traditional Tuscan tomato and bread soup', 'lunch'::public.recipe_category, 'medium'::public.recipe_difficulty, 10, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Parmigiana di melanzane
('a1b2c3d4-e5f6-4000-8000-100000000005', 'Parmigiana di melanzane', 'Classic Sicilian eggplant dish with tomato and cheese', 'lunch'::public.recipe_category, 'hard'::public.recipe_difficulty, 30, 45, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Passato di verdure senza patate e legumi
('a1b2c3d4-e5f6-4000-8000-100000000006', 'Passato di verdure senza patate e legumi', 'Healthy vegetable soup without potatoes or legumes', 'lunch'::public.recipe_category, 'medium'::public.recipe_difficulty, 15, 30, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta al pesto
('a1b2c3d4-e5f6-4000-8000-100000000007', 'Pasta al pesto', 'Classic Ligurian pasta with basil pesto sauce', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 10, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta al pomodoro
('a1b2c3d4-e5f6-4000-8000-100000000008', 'Pasta al pomodoro', 'Simple Italian pasta with tomato sauce', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta al ragù
('a1b2c3d4-e5f6-4000-8000-100000000009', 'Pasta al ragù', 'Traditional pasta with meat sauce', 'lunch'::public.recipe_category, 'medium'::public.recipe_difficulty, 15, 120, 4, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta al tonno
('a1b2c3d4-e5f6-4000-8000-100000000010', 'Pasta al tonno', 'Italian pasta with tuna and tomato sauce', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta all''arrabbiata
('a1b2c3d4-e5f6-4000-8000-100000000011', 'Pasta all''arrabbiata', 'Spicy Roman pasta dish with tomatoes and chili', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta all''uovo in brodo
('a1b2c3d4-e5f6-4000-8000-100000000012', 'Pasta all''uovo in brodo', 'Egg pasta in broth', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 10, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta alla carbonara
('a1b2c3d4-e5f6-4000-8000-100000000013', 'Pasta alla carbonara', 'Roman pasta dish with eggs, cheese, and pancetta', 'lunch'::public.recipe_category, 'medium'::public.recipe_difficulty, 10, 10, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta alla Norma
('a1b2c3d4-e5f6-4000-8000-100000000014', 'Pasta alla Norma', 'Sicilian pasta with eggplant, tomatoes, and ricotta salata', 'lunch'::public.recipe_category, 'medium'::public.recipe_difficulty, 15, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta alle verdure
('a1b2c3d4-e5f6-4000-8000-100000000015', 'Pasta alle verdure', 'Healthy pasta with mixed vegetables', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 10, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta allo scoglio
('a1b2c3d4-e5f6-4000-8000-100000000016', 'Pasta allo scoglio', 'Seafood pasta with mixed shellfish', 'lunch'::public.recipe_category, 'hard'::public.recipe_difficulty, 20, 30, 3, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta con burro e parmigiano
('a1b2c3d4-e5f6-4000-8000-100000000017', 'Pasta con burro e parmigiano', 'Simple pasta with butter and parmesan cheese', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 10, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta con gamberetti e zucchine
('a1b2c3d4-e5f6-4000-8000-100000000018', 'Pasta con gamberetti e zucchine', 'Pasta with shrimp and zucchini', 'lunch'::public.recipe_category, 'medium'::public.recipe_difficulty, 15, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta con le sarde
('a1b2c3d4-e5f6-4000-8000-100000000019', 'Pasta con le sarde', 'Sicilian pasta with sardines and wild fennel', 'lunch'::public.recipe_category, 'hard'::public.recipe_difficulty, 25, 30, 3, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW()),

-- Pasta con olio extravergine e parmigiano
('a1b2c3d4-e5f6-4000-8000-100000000020', 'Pasta con olio extravergine e parmigiano', 'Simple pasta with extra virgin olive oil and parmesan', 'lunch'::public.recipe_category, 'easy'::public.recipe_difficulty, 5, 10, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW(), NOW());

-- Insert recipe ingredients
INSERT INTO public.recipe_ingredients (
    id,
    recipe_id,
    ingredient_name,
    quantity,
    unit,
    weight_grams,
    calories,
    protein_g,
    carbs_g,
    fat_g,
    fiber_g,
    created_at
) VALUES
-- Panino rosetta con prosciutto cotto e fontina
('b1b2c3d4-e5f6-4000-8000-100000000001', 'a1b2c3d4-e5f6-4000-8000-100000000001', 'PANE COMUNE, pezzatura da 250g', 50.0, 'g', 50, 141, 4.4, 32.5, 0.5, 1.8, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000002', 'a1b2c3d4-e5f6-4000-8000-100000000001', 'PROSCIUTTO COTTO', 25.0, 'g', 25, 54, 5.0, 0.4, 3.8, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000003', 'a1b2c3d4-e5f6-4000-8000-100000000001', 'FONTINA', 25.0, 'g', 25, 86, 6.2, 0.5, 6.9, 0.0, NOW()),

-- Panino rosetta con salame
('b1b2c3d4-e5f6-4000-8000-100000000004', 'a1b2c3d4-e5f6-4000-8000-100000000002', 'PANE COMUNE, pezzatura da 250g', 50.0, 'g', 50, 141, 4.4, 32.5, 0.5, 1.8, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000005', 'a1b2c3d4-e5f6-4000-8000-100000000002', 'SALAME BRIANZA', 25.0, 'g', 25, 96, 5.8, 0.3, 8.1, 0.0, NOW()),

-- Panzanella
('b1b2c3d4-e5f6-4000-8000-100000000006', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'PANE TOSTATO', 50.0, 'g', 50, 154, 5.5, 30.0, 2.0, 2.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000007', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'POMODORI MATURI', 100.0, 'g', 100, 21, 1.0, 3.5, 0.2, 1.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000008', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'CIPOLLE', 10.0, 'g', 10, 3, 0.1, 0.6, 0.0, 0.1, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000009', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'BASILICO, fresco', 2.0, 'g', 2, 1, 0.1, 0.1, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000010', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000011', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'ACETO', 5.0, 'ml', 5, 0, 0.0, 0.0, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000012', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'SEDANO', 10.0, 'g', 10, 2, 0.1, 0.3, 0.0, 0.1, NOW()),

-- Pappa al pomodoro
('b1b2c3d4-e5f6-4000-8000-100000000013', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'PASSATA DI POMODORO', 180.0, 'g', 180, 65, 3.6, 12.6, 0.4, 2.5, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000014', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'PANE TOSTATO', 50.0, 'g', 50, 154, 5.5, 30.0, 2.0, 2.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000015', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'BRODO DI CARNE E VERDURA', 125.0, 'ml', 125, 6, 1.3, 0.3, 0.1, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000016', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000017', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'AGLIO, fresco', 3.0, 'g', 3, 1, 0.1, 0.2, 0.0, 0.0, NOW()),

-- Parmigiana di melanzane
('b1b2c3d4-e5f6-4000-8000-100000000018', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'MELANZANE', 200.0, 'g', 200, 40, 2.4, 6.2, 0.4, 3.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000019', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'MOZZARELLA DI VACCA', 50.0, 'g', 50, 127, 9.4, 1.0, 9.5, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000020', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'PASSATA DI POMODORO', 85.0, 'g', 85, 31, 1.7, 6.0, 0.2, 1.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000021', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'CIPOLLE', 15.0, 'g', 15, 4, 0.2, 0.9, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000022', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'PARMIGIANO', 20.0, 'g', 20, 77, 7.7, 0.6, 5.1, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000023', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'AGLIO, fresco', 2.0, 'g', 2, 1, 0.1, 0.2, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000024', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'BASILICO, fresco', 2.0, 'g', 2, 1, 0.1, 0.1, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000025', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'FARINA DI FRUMENTO, TIPO 00', 10.0, 'g', 10, 35, 1.1, 7.0, 0.1, 0.3, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000026', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'OLIO DI OLIVA EXTRAVERGINE', 25.0, 'g', 25, 225, 0.0, 0.0, 25.0, 0.0, NOW()),

-- Passato di verdure senza patate e legumi
('b1b2c3d4-e5f6-4000-8000-100000000027', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'BRODO DI CARNE E VERDURA', 125.0, 'ml', 125, 6, 1.3, 0.3, 0.1, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000028', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'POMODORI MATURI', 30.0, 'g', 30, 6, 0.3, 1.1, 0.1, 0.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000029', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'VERZA', 30.0, 'g', 30, 7, 0.6, 1.2, 0.1, 0.8, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000030', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'ZUCCHINE', 30.0, 'g', 30, 4, 0.4, 0.6, 0.1, 0.3, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000031', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'AGLIO, fresco', 2.0, 'g', 2, 1, 0.1, 0.2, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000032', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'CAROTE', 40.0, 'g', 40, 16, 0.4, 3.1, 0.1, 1.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000033', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'CIPOLLE', 30.0, 'g', 30, 8, 0.3, 1.8, 0.0, 0.3, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000034', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'PREZZEMOLO, fresco', 1.0, 'g', 1, 0, 0.0, 0.1, 0.0, 0.1, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000035', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'SEDANO', 40.0, 'g', 40, 9, 0.4, 1.2, 0.1, 0.6, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000036', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000037', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),

-- Pasta al pesto  
('b1b2c3d4-e5f6-4000-8000-100000000038', 'a1b2c3d4-e5f6-4000-8000-100000000007', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),

-- Pasta al pomodoro
('b1b2c3d4-e5f6-4000-8000-100000000039', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000040', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000041', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'CIPOLLE', 15.0, 'g', 15, 4, 0.2, 0.9, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000042', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'PASSATA DI POMODORO', 65.0, 'g', 65, 23, 1.3, 4.6, 0.1, 0.9, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000043', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW()),

-- Pasta al ragù
('b1b2c3d4-e5f6-4000-8000-100000000044', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000045', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE GRASSA, senza grasso visibile', 50.0, 'g', 50, 78, 11.0, 0.0, 3.5, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000046', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'CAROTE', 15.0, 'g', 15, 6, 0.2, 1.2, 0.0, 0.5, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000047', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'CIPOLLE', 15.0, 'g', 15, 4, 0.2, 0.9, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000048', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'SEDANO', 15.0, 'g', 15, 3, 0.2, 0.5, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000049', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000050', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'PASSATA DI POMODORO', 60.0, 'g', 60, 22, 1.2, 4.2, 0.1, 0.8, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000051', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW()),

-- Pasta al tonno
('b1b2c3d4-e5f6-4000-8000-100000000052', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000053', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000054', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'CIPOLLE', 15.0, 'g', 15, 4, 0.2, 0.9, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000055', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'TONNO SOTT''OLIO, sgocciolato', 60.0, 'g', 60, 115, 13.8, 0.0, 6.9, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000056', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'PASSATA DI POMODORO', 65.0, 'g', 65, 23, 1.3, 4.6, 0.1, 0.9, NOW()),

-- Pasta all'arrabbiata
('b1b2c3d4-e5f6-4000-8000-100000000057', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000058', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000059', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'CIPOLLE', 10.0, 'g', 10, 3, 0.1, 0.6, 0.0, 0.1, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000060', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'POMODORI MATURI', 80.0, 'g', 80, 17, 0.8, 2.8, 0.2, 1.1, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000061', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'AGLIO, fresco', 5.0, 'g', 5, 2, 0.2, 0.3, 0.0, 0.1, NOW()),

-- Pasta all'uovo in brodo
('b1b2c3d4-e5f6-4000-8000-100000000062', 'a1b2c3d4-e5f6-4000-8000-100000000012', 'PASTA ALL''UOVO, secca', 40.0, 'g', 40, 150, 5.6, 28.4, 2.2, 1.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000063', 'a1b2c3d4-e5f6-4000-8000-100000000012', 'BRODO DI CARNE E VERDURA', 200.0, 'ml', 200, 10, 2.0, 0.4, 0.2, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000064', 'a1b2c3d4-e5f6-4000-8000-100000000012', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW()),

-- Pasta alla carbonara
('b1b2c3d4-e5f6-4000-8000-100000000065', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000066', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'PANCETTA DI MAIALE', 30.0, 'g', 30, 198, 6.0, 0.1, 19.8, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000067', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'UOVO DI GALLINA, TUORLO', 30.0, 'g', 30, 98, 4.9, 0.2, 8.7, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000068', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'PECORINO', 10.0, 'g', 10, 39, 3.9, 0.3, 2.6, 0.0, NOW()),

-- Pasta alla Norma
('b1b2c3d4-e5f6-4000-8000-100000000069', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000070', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'POMODORI MATURI', 150.0, 'g', 150, 32, 1.5, 5.3, 0.3, 2.1, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000071', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'OLIO DI OLIVA EXTRAVERGINE', 20.0, 'g', 20, 180, 0.0, 0.0, 20.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000072', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'MELANZANE', 150.0, 'g', 150, 30, 1.8, 4.7, 0.3, 2.3, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000073', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'RICOTTA SALATA', 20.0, 'g', 20, 42, 4.2, 0.8, 2.8, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000074', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'AGLIO, fresco', 2.0, 'g', 2, 1, 0.1, 0.2, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000075', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'BASILICO, fresco', 2.0, 'g', 2, 1, 0.1, 0.1, 0.0, 0.0, NOW()),

-- Pasta alle verdure
('b1b2c3d4-e5f6-4000-8000-100000000076', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000077', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'SPINACI', 53.0, 'g', 53, 19, 1.9, 1.6, 0.3, 1.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000078', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'BIETA', 53.0, 'g', 53, 10, 0.8, 1.1, 0.1, 0.7, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000079', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'CICORIA CATALOGNA', 54.0, 'g', 54, 16, 1.3, 1.6, 0.1, 1.6, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000080', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000081', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW()),

-- Pasta allo scoglio
('b1b2c3d4-e5f6-4000-8000-100000000082', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000083', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000084', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'COZZA o MITILO', 25.0, 'g', 25, 21, 3.6, 0.6, 0.5, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000085', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'VONGOLA', 25.0, 'g', 25, 18, 3.3, 0.6, 0.3, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000086', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'SEPPIA', 25.0, 'g', 25, 18, 4.1, 0.2, 0.3, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000087', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'GAMBERO', 25.0, 'g', 25, 18, 4.3, 0.2, 0.2, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000088', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'CALAMARO', 25.0, 'g', 25, 17, 3.4, 0.2, 0.2, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000089', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'AGLIO, fresco', 3.0, 'g', 3, 1, 0.1, 0.2, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000090', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'PREZZEMOLO, fresco', 3.0, 'g', 3, 1, 0.1, 0.2, 0.0, 0.1, NOW()),

-- Pasta con burro e parmigiano
('b1b2c3d4-e5f6-4000-8000-100000000091', 'a1b2c3d4-e5f6-4000-8000-100000000017', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000092', 'a1b2c3d4-e5f6-4000-8000-100000000017', 'BURRO', 10.0, 'g', 10, 76, 0.1, 0.1, 8.4, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000093', 'a1b2c3d4-e5f6-4000-8000-100000000017', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW()),

-- Pasta con gamberetti e zucchine
('b1b2c3d4-e5f6-4000-8000-100000000094', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000095', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000096', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'CIPOLLE', 15.0, 'g', 15, 4, 0.2, 0.9, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000097', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'ZUCCHINE', 65.0, 'g', 65, 9, 0.9, 1.3, 0.1, 0.7, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000098', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'GAMBERO', 50.0, 'g', 50, 36, 8.6, 0.4, 0.4, 0.0, NOW()),

-- Pasta con le sarde
('b1b2c3d4-e5f6-4000-8000-100000000099', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000100', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'SARDA', 75.0, 'g', 75, 97, 14.3, 0.0, 4.2, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000101', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'ACCIUGHE o ALICI SOTT''OLIO', 5.0, 'g', 5, 10, 1.3, 0.0, 0.6, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000102', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'UVA SULTANINA/UVETTA, UVA SECCA', 7.0, 'g', 7, 21, 0.2, 5.0, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000103', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'PINOLI', 5.0, 'g', 5, 30, 1.2, 0.2, 3.0, 0.3, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000104', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'CIPOLLE', 18.0, 'g', 18, 5, 0.2, 1.1, 0.0, 0.2, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000105', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'AGLIO, fresco', 2.0, 'g', 2, 1, 0.1, 0.2, 0.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000106', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000107', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'PREZZEMOLO, fresco', 3.0, 'g', 3, 1, 0.1, 0.2, 0.0, 0.1, NOW()),

-- Pasta con olio extravergine e parmigiano
('b1b2c3d4-e5f6-4000-8000-100000000108', 'a1b2c3d4-e5f6-4000-8000-100000000020', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.4, 58.4, 1.2, 2.4, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000109', 'a1b2c3d4-e5f6-4000-8000-100000000020', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 0.0, 10.0, 0.0, NOW()),
('b1b2c3d4-e5f6-4000-8000-100000000110', 'a1b2c3d4-e5f6-4000-8000-100000000020', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.9, 0.2, 1.3, 0.0, NOW());

-- Insert recipe tags
INSERT INTO public.recipe_tags (
    id,
    recipe_id,
    tag_name,
    created_at
) VALUES
-- Tags for Panino rosetta con prosciutto cotto e fontina
('c1b2c3d4-e5f6-4000-8000-100000000001', 'a1b2c3d4-e5f6-4000-8000-100000000001', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000002', 'a1b2c3d4-e5f6-4000-8000-100000000001', 'Sandwich', NOW()),

-- Tags for Panino rosetta con salame
('c1b2c3d4-e5f6-4000-8000-100000000003', 'a1b2c3d4-e5f6-4000-8000-100000000002', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000004', 'a1b2c3d4-e5f6-4000-8000-100000000002', 'Sandwich', NOW()),

-- Tags for Panzanella
('c1b2c3d4-e5f6-4000-8000-100000000005', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000006', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'Tuscan', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000007', 'a1b2c3d4-e5f6-4000-8000-100000000003', 'Salad', NOW()),

-- Tags for Pappa al pomodoro
('c1b2c3d4-e5f6-4000-8000-100000000008', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000009', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'Tuscan', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000010', 'a1b2c3d4-e5f6-4000-8000-100000000004', 'Soup', NOW()),

-- Tags for Parmigiana di melanzane
('c1b2c3d4-e5f6-4000-8000-100000000011', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000012', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'Sicilian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000013', 'a1b2c3d4-e5f6-4000-8000-100000000005', 'Baked', NOW()),

-- Tags for Passato di verdure
('c1b2c3d4-e5f6-4000-8000-100000000014', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000015', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'Soup', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000016', 'a1b2c3d4-e5f6-4000-8000-100000000006', 'Healthy', NOW()),

-- Tags for Pasta al pesto
('c1b2c3d4-e5f6-4000-8000-100000000017', 'a1b2c3d4-e5f6-4000-8000-100000000007', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000018', 'a1b2c3d4-e5f6-4000-8000-100000000007', 'Ligurian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000019', 'a1b2c3d4-e5f6-4000-8000-100000000007', 'Pasta', NOW()),

-- Tags for Pasta al pomodoro
('c1b2c3d4-e5f6-4000-8000-100000000020', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000021', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'Pasta', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000022', 'a1b2c3d4-e5f6-4000-8000-100000000008', 'Classic', NOW()),

-- Tags for Pasta al ragù
('c1b2c3d4-e5f6-4000-8000-100000000023', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000024', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'Pasta', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000025', 'a1b2c3d4-e5f6-4000-8000-100000000009', 'Meat', NOW()),

-- Tags for Pasta al tonno
('c1b2c3d4-e5f6-4000-8000-100000000026', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000027', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'Pasta', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000028', 'a1b2c3d4-e5f6-4000-8000-100000000010', 'Seafood', NOW()),

-- Tags for Pasta all'arrabbiata
('c1b2c3d4-e5f6-4000-8000-100000000029', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000030', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'Roman', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000031', 'a1b2c3d4-e5f6-4000-8000-100000000011', 'Spicy', NOW()),

-- Tags for Pasta all'uovo in brodo
('c1b2c3d4-e5f6-4000-8000-100000000032', 'a1b2c3d4-e5f6-4000-8000-100000000012', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000033', 'a1b2c3d4-e5f6-4000-8000-100000000012', 'Soup', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000034', 'a1b2c3d4-e5f6-4000-8000-100000000012', 'Comfort', NOW()),

-- Tags for Pasta alla carbonara
('c1b2c3d4-e5f6-4000-8000-100000000035', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000036', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'Roman', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000037', 'a1b2c3d4-e5f6-4000-8000-100000000013', 'Classic', NOW()),

-- Tags for Pasta alla Norma
('c1b2c3d4-e5f6-4000-8000-100000000038', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000039', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'Sicilian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000040', 'a1b2c3d4-e5f6-4000-8000-100000000014', 'Vegetarian', NOW()),

-- Tags for Pasta alle verdure
('c1b2c3d4-e5f6-4000-8000-100000000041', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000042', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'Healthy', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000043', 'a1b2c3d4-e5f6-4000-8000-100000000015', 'Vegetarian', NOW()),

-- Tags for Pasta allo scoglio
('c1b2c3d4-e5f6-4000-8000-100000000044', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000045', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'Seafood', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000046', 'a1b2c3d4-e5f6-4000-8000-100000000016', 'Special', NOW()),

-- Tags for Pasta con burro e parmigiano
('c1b2c3d4-e5f6-4000-8000-100000000047', 'a1b2c3d4-e5f6-4000-8000-100000000017', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000048', 'a1b2c3d4-e5f6-4000-8000-100000000017', 'Simple', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000049', 'a1b2c3d4-e5f6-4000-8000-100000000017', 'Classic', NOW()),

-- Tags for Pasta con gamberetti e zucchine
('c1b2c3d4-e5f6-4000-8000-100000000050', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000051', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'Seafood', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000052', 'a1b2c3d4-e5f6-4000-8000-100000000018', 'Healthy', NOW()),

-- Tags for Pasta con le sarde
('c1b2c3d4-e5f6-4000-8000-100000000053', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000054', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'Sicilian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000055', 'a1b2c3d4-e5f6-4000-8000-100000000019', 'Traditional', NOW()),

-- Tags for Pasta con olio extravergine e parmigiano
('c1b2c3d4-e5f6-4000-8000-100000000056', 'a1b2c3d4-e5f6-4000-8000-100000000020', 'Italian', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000057', 'a1b2c3d4-e5f6-4000-8000-100000000020', 'Simple', NOW()),
('c1b2c3d4-e5f6-4000-8000-100000000058', 'a1b2c3d4-e5f6-4000-8000-100000000020', 'Classic', NOW());

-- Update recipe nutrition totals (calculated by triggers)
SELECT public.calculate_recipe_nutrition(id) FROM public.recipes WHERE id IN (
    'a1b2c3d4-e5f6-4000-8000-100000000001',
    'a1b2c3d4-e5f6-4000-8000-100000000002',
    'a1b2c3d4-e5f6-4000-8000-100000000003',
    'a1b2c3d4-e5f6-4000-8000-100000000004',
    'a1b2c3d4-e5f6-4000-8000-100000000005',
    'a1b2c3d4-e5f6-4000-8000-100000000006',
    'a1b2c3d4-e5f6-4000-8000-100000000007',
    'a1b2c3d4-e5f6-4000-8000-100000000008',
    'a1b2c3d4-e5f6-4000-8000-100000000009',
    'a1b2c3d4-e5f6-4000-8000-100000000010',
    'a1b2c3d4-e5f6-4000-8000-100000000011',
    'a1b2c3d4-e5f6-4000-8000-100000000012',
    'a1b2c3d4-e5f6-4000-8000-100000000013',
    'a1b2c3d4-e5f6-4000-8000-100000000014',
    'a1b2c3d4-e5f6-4000-8000-100000000015',
    'a1b2c3d4-e5f6-4000-8000-100000000016',
    'a1b2c3d4-e5f6-4000-8000-100000000017',
    'a1b2c3d4-e5f6-4000-8000-100000000018',
    'a1b2c3d4-e5f6-4000-8000-100000000019',
    'a1b2c3d4-e5f6-4000-8000-100000000020'
);

COMMIT;