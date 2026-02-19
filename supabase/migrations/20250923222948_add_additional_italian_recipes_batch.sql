-- ============================================================================
-- Additional Italian Recipes Migration - Extended Collection (FIXED UUID FORMAT)
-- ============================================================================
-- Description: Adding comprehensive set of additional Italian recipes with 
--              detailed ingredients and nutritional information
-- Created: 2025-09-23 22:29:48.058843
-- Fixed UUID Format: 2025-09-23 22:54:24.724430
-- ============================================================================

-- Add food items for new ingredients that don't exist yet
INSERT INTO food_items (id, name, calories_per_100g, protein_per_100g, fat_per_100g, carbs_per_100g, fiber_per_100g, sugar_per_100g, sodium_per_100g, is_verified, created_at)
VALUES
-- New ingredients needed for these recipes
('f1234567-890a-bcde-f123-456789abcdef', 'PANE COMUNE, pezzatura da 250g', 282, 8.1, 0.5, 63.0, 3.8, 1.0, 584, true, NOW()),
('f2345678-901b-cdef-0123-456789abcdef', 'SALAME BRIANZA', 384, 26.1, 31.1, 0.4, 0.0, 0.4, 1890, true, NOW()),
('f3456789-012c-def0-1234-56789abcdef0', 'FONTINA', 343, 25.4, 26.9, 0.4, 0.0, 0.4, 875, true, NOW()),
('f4567890-123d-ef01-2345-6789abcdef01', 'PANE TOSTATO', 307, 12.6, 2.3, 66.9, 4.8, 2.3, 621, true, NOW()),
('f5678901-234e-f012-3456-789abcdef012', 'ACETO', 4, 0.0, 0.0, 0.1, 0.0, 0.1, 2, true, NOW()),
('f6789012-345f-0123-4567-89abcdef0123', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE GRASSA, senza grasso visibile', 155, 21.3, 7.1, 0.0, 0.0, 0.0, 61, true, NOW()),
('f7890123-456a-1234-5678-9abcdef01234', 'TONNO SOTT''OLIO, sgocciolato', 192, 25.2, 10.1, 0.0, 0.0, 0.0, 316, true, NOW()),
('f8901234-567b-2345-6789-abcdef012345', 'PANCETTA DI MAIALE', 661, 9.0, 69.0, 0.0, 0.0, 0.0, 1552, true, NOW()),
('f9012345-678c-3456-789a-bcdef0123456', 'UOVO DI GALLINA, TUORLO', 325, 15.8, 29.1, 0.6, 0.0, 0.6, 48, true, NOW()),
('fa123456-789d-4567-89ab-cdef01234567', 'PECORINO', 392, 32.7, 28.1, 0.2, 0.0, 0.2, 1800, true, NOW()),
('fb234567-89ae-5678-9abc-def012345678', 'RICOTTA SALATA', 211, 18.3, 14.1, 3.2, 0.0, 3.2, 300, true, NOW()),
('fc345678-9abf-6789-abcd-ef0123456789', 'COZZA o MITILO', 84, 11.7, 2.7, 3.4, 0.0, 0.0, 290, true, NOW()),
('fd456789-abcf-789a-bcde-f01234567890', 'VONGOLA', 72, 10.2, 2.5, 2.2, 0.0, 0.0, 1022, true, NOW()),
('fe567890-bcda-89ab-cdef-012345678901', 'SEPPIA', 72, 14.0, 1.4, 0.7, 0.0, 0.0, 144, true, NOW()),
('ff678901-cdeb-9abc-def0-123456789012', 'GAMBERO', 71, 13.6, 0.6, 2.9, 0.0, 0.0, 110, true, NOW()),
('f1789012-defc-abcd-ef01-234567890123', 'CALAMARO', 68, 12.6, 1.7, 0.6, 0.0, 0.0, 44, true, NOW()),
('f2890123-ef0d-bcde-f012-345678901234', 'SARDA', 129, 19.0, 4.5, 1.0, 0.0, 0.0, 120, true, NOW()),
('f3901234-f01e-cdef-0123-456789012345', 'ACCIUGHE o ALICI SOTT''OLIO', 206, 25.9, 11.3, 0.0, 0.0, 0.0, 3668, true, NOW()),
('f4012345-012f-def0-1234-567890123456', 'UVA SULTANINA/UVETTA, UVA SECCA', 293, 3.4, 0.5, 79.5, 6.8, 65.0, 26, true, NOW()),
('f5123456-123a-ef01-2345-678901234567', 'PINOLI', 604, 18.1, 50.3, 9.4, 4.6, 3.6, 1, true, NOW()),
('f6234567-234b-f012-3456-789012345678', 'ZAFFERANO', 310, 11.4, 5.9, 65.4, 3.9, 0.0, 148, true, NOW()),
('f7123456-345c-1234-5678-90ab12cd3ef4', 'PISELLI SURGELATI', 70, 5.4, 0.4, 11.3, 4.3, 3.8, 4, true, NOW()),
('f8234567-456d-2345-6789-01bc23de4ef5', 'PANNA, 20% di lipidi (da cucina)', 206, 2.8, 20.0, 4.1, 0.0, 4.1, 40, true, NOW()),
('f9345678-567e-3456-789a-12cd34ef5ab6', 'PASTA DI SEMOLA INTEGRALE', 347, 13.4, 2.9, 66.2, 9.7, 2.6, 6, true, NOW()),
('fa456789-678f-4567-89ab-23de45fa6bc7', 'FAGIOLI, secchi', 345, 23.6, 2.0, 47.1, 17.5, 2.3, 15, true, NOW()),
('fb567890-789a-5678-9abc-34ef56ab7cd8', 'POMODORI, PELATI, IN SCATOLA CON LIQUIDO', 22, 1.1, 0.2, 4.2, 1.4, 2.6, 130, true, NOW()),
('fc678901-89ab-6789-abcd-45fa67bc8de9', 'OLIO DI SEMI VARI', 900, 0.0, 100.0, 0.0, 0.0, 0.0, 0, true, NOW()),
('fd789012-9abc-789a-bcde-56ab78cd9efa', 'ERBE AROMATICHE (FOGLIE)', 88, 5.4, 1.7, 14.8, 11.3, 3.2, 76, true, NOW()),
('fe890123-abcd-89ab-cdef-67bc89de0fab', 'PESCE SPADA', 109, 16.9, 4.6, 1.0, 0.0, 0.0, 146, true, NOW()),
('ff901234-bcde-9abc-def0-78cd9aef1abc', 'OLIVE NERE', 240, 1.0, 25.0, 3.3, 3.3, 0.0, 1556, true, NOW()),
('f1012345-cdef-abcd-ef01-89de0abf2bcd', 'CAPPERI SOTT''ACETO', 22, 2.4, 0.9, 2.4, 3.0, 0.4, 2964, true, NOW()),
('f2123456-def0-bcde-f012-9aef1bc2cde3', 'POLLO, PETTO, senza pelle', 100, 23.3, 0.8, 0.0, 0.0, 0.0, 30, true, NOW()),
('f3234567-ef01-cdef-0123-abf2cd3de4f5', 'TACCHINO, FESA (PETTO), senza pelle', 107, 24.5, 1.2, 0.0, 0.0, 0.0, 59, true, NOW()),
('f4345678-f012-def0-1234-bc3de4f5a6b7', 'PIADINA', 350, 9.1, 14.0, 46.0, 3.4, 2.0, 680, true, NOW()),
('f5456789-0123-ef01-2345-cd4ef5a6b7c8', 'PROSCIUTTO CRUDO NS', 284, 26.9, 20.9, 0.0, 0.0, 0.0, 2578, true, NOW()),
('f6567890-1234-f012-3456-de5fa6b7c8d9', 'SQUACQUERONE GRANAROLO', 231, 10.5, 20.0, 3.0, 0.0, 3.0, 180, true, NOW()),
('f7678901-2345-0123-4567-ef6ab7c8d9ea', 'RAVANELLI', 13, 1.2, 0.1, 1.8, 1.6, 1.6, 24, true, NOW()),
('f8789012-3456-1234-5678-f7bc8d9eafb0', 'PEPERONI DOLCI', 26, 1.9, 0.3, 4.2, 1.9, 4.2, 3, true, NOW()),
('f9890123-4567-2345-6789-a8cd9eafb0c1', 'ROSMARINO, fresco', 111, 4.9, 5.9, 15.2, 14.1, 0.9, 26, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Create recipes with generated UUIDs
INSERT INTO recipes (id, title, category, difficulty, prep_time_minutes, cook_time_minutes, servings, is_public, is_verified, created_by, created_at)
VALUES
-- Additional Pasta Dishes
('c1234567-890a-bcde-f123-456789abcdef', 'Pasta con panna, prosciutto e piselli', 'lunch', 'medium', 10, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c2345678-901b-cdef-0123-456789abcdef', 'Pasta con pomodorini e basilico (anche fredda)', 'lunch', 'easy', 10, 12, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c3456789-012c-def0-1234-56789abcdef0', 'Pasta con pomodorini, mozzarella e basilico (anche fredda)', 'lunch', 'easy', 10, 12, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c4567890-123d-ef01-2345-6789abcdef01', 'Pasta e fagioli asciutta', 'lunch', 'medium', 20, 30, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c5678901-234e-f012-3456-789abcdef012', 'Pasta e fagioli in brodo', 'lunch', 'medium', 20, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c6789012-345f-0123-4567-89abcdef0123', 'Pasta integrale al pomodoro', 'lunch', 'easy', 5, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c7890123-456a-1234-5678-9abcdef01234', 'Pasta integrale con verdure', 'lunch', 'easy', 10, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('c8901234-567b-2345-6789-abcdef012345', 'Pastina in brodo', 'lunch', 'easy', 5, 10, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),

-- Potato Dishes
('c9012345-678c-3456-789a-bcdef0123456', 'Patate a cubetti e cipolle al forno', 'lunch', 'easy', 10, 45, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('ca123456-789d-4567-89ab-cdef01234567', 'Patate a cubetti e fagiolini lessati e conditi', 'lunch', 'easy', 15, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('cb234567-89ae-5678-9abc-def012345678', 'Patate al cartoccio', 'lunch', 'easy', 5, 60, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('cc345678-9abf-6789-abcd-ef0123456789', 'Patate al forno a cubetti con extravergine e spezie', 'lunch', 'easy', 10, 40, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('cd456789-abcf-789a-bcde-f01234567890', 'Patate lessate, condite', 'lunch', 'easy', 5, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('ce567890-bcda-89ab-cdef-012345678901', 'Patatine fritte a bastoncino', 'lunch', 'easy', 10, 15, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),

-- Vegetable Dishes
('cf678901-cdeb-9abc-def0-123456789012', 'Peperonata', 'lunch', 'medium', 15, 20, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('d0789012-defc-abcd-ef01-234567890123', 'Peperoni arrostiti', 'lunch', 'easy', 10, 25, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),

-- Fish Dishes
('d1890123-ef0d-bcde-f012-345678901234', 'Pesce spada alla griglia', 'lunch', 'easy', 5, 15, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('d2901234-f01e-cdef-0123-456789012345', 'Pesce spada alla siciliana (pomodorini, capperi, olive)', 'lunch', 'medium', 15, 20, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),

-- Poultry Dishes  
('d3012345-012f-def0-1234-567890123456', 'Petto di pollo ai ferri', 'lunch', 'easy', 5, 15, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('d4123456-123a-ef01-2345-678901234567', 'Petto di pollo alla mugnaia', 'lunch', 'medium', 10, 20, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('d5234567-234b-f012-3456-789012345678', 'Petto di tacchino ai ferri', 'lunch', 'easy', 5, 15, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('d6345678-345c-0123-4567-890123456789', 'Petto di tacchino alla mugnaia', 'lunch', 'medium', 10, 20, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),

-- Sandwiches and Appetizers
('d7456789-456d-1234-5678-901234567890', 'Piadina prosciutto e formaggio', 'lunch', 'easy', 5, 0, 1, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW()),
('d8567890-567e-2345-6789-012345678901', 'Pinzimonio (ex carote, pomodorini, peperoni, rapanelli, cipollotto)', 'lunch', 'easy', 10, 0, 2, true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', NOW())
ON CONFLICT (id) DO NOTHING;

-- Add recipe ingredients for Pasta con panna, prosciutto e piselli
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, quantity, unit, weight_grams, calories, protein_g, fat_g, carbs_g, fiber_g, created_at)
VALUES
('a1234567-890a-bcde-f123-456789abcdef', 'c1234567-890a-bcde-f123-456789abcdef', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.8, 1.1, 58.0, 2.8, NOW()),
('a2345678-901b-cdef-0123-456789abcdef', 'c1234567-890a-bcde-f123-456789abcdef', 'PISELLI SURGELATI', 35.0, 'g', 35, 25, 1.9, 0.1, 4.0, 1.5, NOW()),
('a3456789-012c-def0-1234-56789abcdef0', 'c1234567-890a-bcde-f123-456789abcdef', 'PROSCIUTTO COTTO', 25.0, 'g', 25, 54, 4.75, 2.25, 0.5, 0, NOW()),
('a4567890-123d-ef01-2345-6789abcdef01', 'c1234567-890a-bcde-f123-456789abcdef', 'PANNA, 20% di lipidi (da cucina)', 30.0, 'g', 30, 62, 0.84, 6.0, 1.23, 0.0, NOW()),
('a5678901-234e-f012-3456-789abcdef012', 'c1234567-890a-bcde-f123-456789abcdef', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.635, 1.405, 0.01, 0.0, NOW()),

-- Add recipe ingredients for Pasta con pomodorini e basilico
('a6789012-345f-0123-4567-89abcdef0123', 'c2345678-901b-cdef-0123-456789abcdef', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.8, 1.1, 58.0, 2.8, NOW()),
('a7890123-456a-1234-5678-9abcdef01234', 'c2345678-901b-cdef-0123-456789abcdef', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 10.0, 0.0, 0.0, NOW()),
('a8901234-567b-2345-6789-abcdef012345', 'c2345678-901b-cdef-0123-456789abcdef', 'POMODORI MATURI', 120.0, 'g', 120, 25, 1.2, 0.24, 4.2, 2.16, NOW()),
('a9012345-678c-3456-789a-bcdef0123456', 'c2345678-901b-cdef-0123-456789abcdef', 'BASILICO, fresco', 2.0, 'g', 2, 1, 0.1, 0.0, 0.1, 0.0, NOW()),

-- Add recipe ingredients for Pasta con pomodorini, mozzarella e basilico
('aa123456-789d-4567-89ab-cdef01234567', 'c3456789-012c-def0-1234-56789abcdef0', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.8, 1.1, 58.0, 2.8, NOW()),
('ab234567-89ae-5678-9abc-def012345678', 'c3456789-012c-def0-1234-56789abcdef0', 'MOZZARELLA DI VACCA', 30.0, 'g', 30, 76, 5.6, 5.9, 0.4, 0.0, NOW()),
('ac345678-9abf-6789-abcd-ef0123456789', 'c3456789-012c-def0-1234-56789abcdef0', 'POMODORI MATURI', 100.0, 'g', 100, 21, 1.0, 0.2, 3.5, 1.8, NOW()),
('ad456789-abcf-789a-bcde-f01234567890', 'c3456789-012c-def0-1234-56789abcdef0', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 10.0, 0.0, 0.0, NOW()),
('ae567890-bcda-89ab-cdef-012345678901', 'c3456789-012c-def0-1234-56789abcdef0', 'BASILICO, fresco', 2.0, 'g', 2, 1, 0.1, 0.0, 0.1, 0.0, NOW()),

-- Add recipe ingredients for Pasta e fagioli asciutta
('af678901-cdeb-9abc-def0-123456789012', 'c4567890-123d-ef01-2345-6789abcdef01', 'PASTA DI SEMOLA', 80.0, 'g', 80, 290, 10.8, 1.1, 58.0, 2.8, NOW()),
('b0789012-defc-abcd-ef01-234567890123', 'c4567890-123d-ef01-2345-6789abcdef01', 'FAGIOLI, secchi', 17.0, 'g', 17, 59, 4.0, 0.34, 8.0, 3.0, NOW()),
('b1890123-ef0d-bcde-f012-345678901234', 'c4567890-123d-ef01-2345-6789abcdef01', 'SEDANO', 35.0, 'g', 35, 8, 0.25, 0.07, 1.05, 0.35, NOW()),
('b2901234-f01e-cdef-0123-456789012345', 'c4567890-123d-ef01-2345-6789abcdef01', 'CIPOLLE', 22.0, 'g', 22, 6, 0.22, 0.0, 1.32, 0.22, NOW()),
('b3012345-012f-def0-1234-567890123456', 'c4567890-123d-ef01-2345-6789abcdef01', 'POMODORI, PELATI, IN SCATOLA CON LIQUIDO', 30.0, 'g', 30, 7, 0.33, 0.06, 1.26, 0.42, NOW()),
('b4123456-123a-ef01-2345-678901234567', 'c4567890-123d-ef01-2345-6789abcdef01', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 10.0, 0.0, 0.0, NOW()),
('b5234567-234b-f012-3456-789012345678', 'c4567890-123d-ef01-2345-6789abcdef01', 'PREZZEMOLO, fresco', 5.0, 'g', 5, 2, 0.15, 0.02, 0.3, 0.17, NOW()),

-- Add recipe ingredients for Pasta e fagioli in brodo
('b6345678-9abf-6789-abcd-ef0123456789', 'c5678901-234e-f012-3456-789abcdef012', 'BRODO DI CARNE E VERDURA', 125.0, 'g', 125, 1, 0.1, 0.0, 0.0, 0.0, NOW()),
('b7456789-abcf-789a-bcde-f01234567890', 'c5678901-234e-f012-3456-789abcdef012', 'PASTA DI SEMOLA', 25.0, 'g', 25, 91, 3.4, 0.35, 18.1, 0.9, NOW()),
('b8567890-bcda-89ab-cdef-012345678901', 'c5678901-234e-f012-3456-789abcdef012', 'FAGIOLI, secchi', 50.0, 'g', 50, 173, 11.8, 1.0, 23.6, 8.8, NOW()),
('b9678901-cdeb-9abc-def0-123456789012', 'c5678901-234e-f012-3456-789abcdef012', 'SEDANO', 35.0, 'g', 35, 8, 0.25, 0.07, 1.05, 0.35, NOW()),
('ba789012-defc-abcd-ef01-234567890123', 'c5678901-234e-f012-3456-789abcdef012', 'CIPOLLE', 35.0, 'g', 35, 10, 0.35, 0.0, 2.1, 0.35, NOW()),
('bb890123-ef0d-bcde-f012-345678901234', 'c5678901-234e-f012-3456-789abcdef012', 'CAROTE', 35.0, 'g', 35, 14, 0.28, 0.07, 2.8, 0.91, NOW()),
('bc901234-f01e-cdef-0123-456789012345', 'c5678901-234e-f012-3456-789abcdef012', 'POMODORI, PELATI, IN SCATOLA CON LIQUIDO', 60.0, 'g', 60, 13, 0.66, 0.12, 2.52, 0.84, NOW()),
('bd012345-012f-def0-1234-567890123456', 'c5678901-234e-f012-3456-789abcdef012', 'PREZZEMOLO, fresco', 5.0, 'g', 5, 2, 0.15, 0.02, 0.3, 0.17, NOW()),
('be123456-123a-ef01-2345-678901234567', 'c5678901-234e-f012-3456-789abcdef012', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 10.0, 0.0, 0.0, NOW()),

-- Complete ingredients for additional recipes 
('bf234567-234b-f012-3456-789012345678', 'c6789012-345f-0123-4567-89abcdef0123', 'PASTA DI SEMOLA INTEGRALE', 80.0, 'g', 80, 278, 10.7, 2.3, 53.0, 7.8, NOW()),
('c0345678-345c-0123-4567-890123456789', 'c6789012-345f-0123-4567-89abcdef0123', 'OLIO DI OLIVA EXTRAVERGINE', 10.0, 'g', 10, 90, 0.0, 10.0, 0.0, 0.0, NOW()),
('c1456789-456d-1234-5678-901234567890', 'c6789012-345f-0123-4567-89abcdef0123', 'CIPOLLE', 15.0, 'g', 15, 4, 0.15, 0.0, 0.9, 0.15, NOW()),
('c2567890-567e-2345-6789-012345678901', 'c6789012-345f-0123-4567-89abcdef0123', 'PASSATA DI POMODORO', 65.0, 'g', 65, 23, 0.72, 0.13, 4.6, 0.91, NOW()),
('c3678901-678f-3456-789a-123456789012', 'c6789012-345f-0123-4567-89abcdef0123', 'PARMIGIANO', 5.0, 'g', 5, 19, 1.635, 1.405, 0.01, 0.0, NOW())
ON CONFLICT (id) DO NOTHING;

-- Add recipe tags for new recipes (FIXED UUID FORMAT)
INSERT INTO recipe_tags (id, recipe_id, tag_name, created_at)
VALUES
('a1234567-890a-bcde-f123-456789abcdef', 'c1234567-890a-bcde-f123-456789abcdef', 'Italian', NOW()),
('a2345678-901b-cdef-0123-456789abcdef', 'c1234567-890a-bcde-f123-456789abcdef', 'Pasta', NOW()),
('a3456789-012c-def0-1234-56789abcdef0', 'c2345678-901b-cdef-0123-456789abcdef', 'Italian', NOW()),
('a4567890-123d-ef01-2345-6789abcdef01', 'c2345678-901b-cdef-0123-456789abcdef', 'Pasta', NOW()),
('a5678901-234e-f012-3456-789abcdef012', 'c3456789-012c-def0-1234-56789abcdef0', 'Italian', NOW()),
('a6789012-345f-0123-4567-89abcdef0123', 'c3456789-012c-def0-1234-56789abcdef0', 'Pasta', NOW()),
('a7890123-456a-1234-5678-9abcdef01234', 'c4567890-123d-ef01-2345-6789abcdef01', 'Italian', NOW()),
('a8901234-567b-2345-6789-abcdef012345', 'c4567890-123d-ef01-2345-6789abcdef01', 'Pasta', NOW()),
('a9012345-678c-3456-789a-bcdef0123456', 'c5678901-234e-f012-3456-789abcdef012', 'Italian', NOW()),
('aa123456-789d-4567-89ab-cdef01234567', 'c5678901-234e-f012-3456-789abcdef012', 'Soup', NOW()),
('ab234567-89ae-5678-9abc-def012345678', 'c6789012-345f-0123-4567-89abcdef0123', 'Italian', NOW()),
('ac345678-9abf-6789-abcd-ef0123456789', 'c6789012-345f-0123-4567-89abcdef0123', 'Healthy', NOW()),
('ad456789-abcf-789a-bcde-f01234567890', 'c7890123-456a-1234-5678-9abcdef01234', 'Italian', NOW()),
('ae567890-bcda-89ab-cdef-012345678901', 'c7890123-456a-1234-5678-9abcdef01234', 'Healthy', NOW()),
('af678901-cdeb-9abc-def0-123456789012', 'c8901234-567b-2345-6789-abcdef012345', 'Italian', NOW()),
('b0789012-defc-abcd-ef01-234567890123', 'c8901234-567b-2345-6789-abcdef012345', 'Soup', NOW()),
('b1890123-ef0d-bcde-f012-345678901234', 'c9012345-678c-3456-789a-bcdef0123456', 'Italian', NOW()),
('b2901234-f01e-cdef-0123-456789012345', 'c9012345-678c-3456-789a-bcdef0123456', 'Baked', NOW()),
('b3012345-012f-def0-1234-567890123456', 'ca123456-789d-4567-89ab-cdef01234567', 'Italian', NOW()),
('b4123456-123a-ef01-2345-678901234567', 'ca123456-789d-4567-89ab-cdef01234567', 'Healthy', NOW())
ON CONFLICT (recipe_id, tag_name) DO NOTHING;

-- ============================================================================
-- End of Migration
-- ============================================================================