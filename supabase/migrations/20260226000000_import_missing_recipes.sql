-- Migration: Import 96 missing recipes from Excel (PARTE1 + PARTE2)
-- Generated: 2026-02-26T21:58:29.909Z

BEGIN;

-- Recipe: FARRO, crudo bollito condito con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('c6d4f84d-f6dd-4b84-8e94-783af852b3f2', 'FARRO, crudo bollito condito con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 90.3, 372, 412, 11.68, 55.44, 11.91, 5.2);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7577d090-1395-4707-a824-f74643cca69a', 'c6d4f84d-f6dd-4b84-8e94-783af852b3f2', 'FARRO, crudo', NULL, 80, 'g', 80, 282.4, 11.68, 55.44, 1.92, 5.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a682850e-a72b-4988-8b79-b3964ad0a96c', 'c6d4f84d-f6dd-4b84-8e94-783af852b3f2', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('322a835a-efb3-4e91-95c8-9da894b24217', 'c6d4f84d-f6dd-4b84-8e94-783af852b3f2', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Insalata di FARRO, crudo con verdure a cubetti saltate o grigliate
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'Insalata di FARRO, crudo con verdure a cubetti saltate o grigliate', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 193.3, 394, 204, 12.9, 58.5, 12.09, 6.98);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6ad40694-c72e-43f9-93ec-a274a12d4cfa', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'FARRO, crudo', NULL, 80, 'g', 80, 282.4, 11.68, 55.44, 1.92, 5.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5820c599-f02e-4521-90ca-cb431d134392', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'MELANZANE', NULL, 20, 'g', 20, 4, 0.22, 0.52, 0.02, 0.52);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('afc862db-db6d-4f38-beee-3c4630312fdd', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'ZUCCHINE', NULL, 30, 'g', 30, 4.2, 0.39, 0.42, 0.03, 0.39);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b44af3c5-11b4-480f-8c76-55af4218f1ac', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'POMODORI, DA INSALATA', NULL, 20, 'g', 20, 3.8, 0.24, 0.56, 0.04, 0.22);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d4e1ba64-110d-48cf-9396-973ad7a23e1d', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'CIPOLLE', NULL, 10, 'g', 10, 2.8, 0.1, 0.57, 0.01, 0.11);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d20fcf59-e74f-4f35-8b42-9e947ee14bdf', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'PEPERONI, DOLCI', NULL, 20, 'g', 20, 5.2, 0.18, 0.84, 0.06, 0.38);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b09e371d-4132-4f9a-9001-1dd22106e84a', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bc9894bd-9f84-4118-8775-d6438290fb45', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9635f9df-fd12-4bf4-8114-6df1a48390ba', '1ffcd61f-ba20-47d7-b89a-3c04d2e260a2', 'BASILICO, fresco', NULL, 3, 'g', 3, 1.47, 0.09, 0.15, 0.02, 0.16);

-- Recipe: Insalata di FARRO, crudo riso e orzo con dadini di verdure
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'Insalata di FARRO, crudo riso e orzo con dadini di verdure', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.3, 393, 187, 9.64, 63.61, 11.43, 6.27);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bc170a99-17f1-4459-b918-1c1ba324fd26', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'ORZO, PERLATO, crudo', NULL, 25, 'g', 25, 86.5, 2.35, 18.43, 0.38, 2.3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8e451a0a-1330-4d9d-a9f9-2246ab0cb638', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'RISO, BRILLATO, crudo', NULL, 25, 'g', 25, 83.5, 1.68, 20.1, 0.1, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b16770a3-0b79-4e4f-9ebe-842565ad6650', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'FARRO, crudo', NULL, 30, 'g', 30, 105.9, 4.38, 20.79, 0.72, 1.95);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9c7e1115-be48-4552-a0f8-9e5aaa22c0e8', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c8c2e65f-b5de-4a01-a4bd-59bd8ab08d9d', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'ZUCCHINE', NULL, 30, 'g', 30, 4.2, 0.39, 0.42, 0.03, 0.39);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6f27902a-e249-4cc1-8428-3a78071d202d', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'CAROTE', NULL, 30, 'g', 30, 11.7, 0.33, 2.28, 0, 0.93);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8b85f04a-f34a-4db3-ba1f-95ac24d3a3a5', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'CETRIOLI', NULL, 30, 'g', 30, 4.5, 0.21, 0.54, 0.15, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('98a58032-0ad0-436f-a08d-20fd7ed12781', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'POMODORI, MATURI', NULL, 30, 'g', 30, 6.3, 0.3, 1.05, 0.06, 0.27);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5b73cdfb-ddd8-4d72-b6c8-6113c49a783b', '9285d27c-5641-4c1d-8b04-a04f3bcde59e', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Insalata di FARRO, crudo riso e orzo con piselli e olio a crudo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('27aa163e-c564-4a0d-af01-f470e8eb363e', 'Insalata di FARRO, crudo riso e orzo con piselli e olio a crudo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 145.3, 420, 289, 12.94, 62.97, 12.8, 8.4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c92284d3-aba6-4027-8179-5e961baf33e6', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'RISO, BRILLATO, crudo', NULL, 25, 'g', 25, 83.5, 1.68, 20.1, 0.1, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7227a452-294b-4432-a6d2-6d194d9abfb9', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'ORZO, PERLATO, crudo', NULL, 25, 'g', 25, 86.5, 2.35, 18.43, 0.38, 2.3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6c4bb05f-eda7-4288-a4fa-1c0d595506ec', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'FARRO, crudo', NULL, 30, 'g', 30, 105.9, 4.38, 20.79, 0.72, 1.95);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cbe71c83-2dd4-4d18-8e06-f7024063da19', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'PISELLI SURGELATI', NULL, 50, 'g', 50, 35, 2.85, 3.75, 0.2, 3.9);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7b5ac71b-47c4-436f-bcfb-8ec2353579fc', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0092e0b8-ab8a-4eb3-a3ee-7906c96cc129', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ccfe1321-493c-4f9c-b77c-b1b2573e39e9', '27aa163e-c564-4a0d-af01-f470e8eb363e', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);

-- Recipe: Pasta integrale con verdure
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'Pasta integrale con verdure', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 255.4, 418, 164, 15.79, 56.58, 13.85, 9.03);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3cc5652e-1ec9-490d-8530-98c6c892655a', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'PASTA DI SEMOLA, INTEGRALE, cruda', NULL, 80, 'g', 80, 264, 10.64, 51.84, 1.76, 5.68);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('79440238-5b7d-498e-aeed-7cb2bcc1fb5c', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'SPINACI', NULL, 53, 'g', 53, 18.55, 1.8, 1.59, 0.37, 1.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4a58ea5e-d966-4230-834b-d3b978b6ba50', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'BIETA', NULL, 53, 'g', 53, 10.07, 0.69, 1.48, 0.05, 0.64);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f27b1c08-aa55-4cff-804b-d1225e12a28e', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'CICORIA CATALOGNA', NULL, 54, 'g', 54, 16.2, 0.97, 1.73, 0.27, 1.67);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3049dfcb-0021-465c-8858-e64c0270cb55', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ce10ad85-51fe-4111-92a3-bac2919370c8', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8f72989d-1cc0-4c15-aa59-a769f0a0eeb0', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8ec59658-c572-48ce-9598-821290f5cdad', 'eb2c2c0a-3b78-4472-bd1c-de42a7faec5d', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Pastina in brodo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('cc2df31a-466d-4983-8015-eeb8c3d4bbf8', 'Pastina in brodo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 245, 166, 68, 8.54, 29.22, 2.27, 0.7);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('af4170e7-1171-470c-b11d-c924ab84f2ab', 'cc2df31a-466d-4983-8015-eeb8c3d4bbf8', 'BRODO DI CARNE E VERDURA', NULL, 200, 'g', 200, 10, 1.46, 0.24, 0.38, 0.02);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('616735b2-3682-45e6-955f-7c6e4eb61a3c', 'cc2df31a-466d-4983-8015-eeb8c3d4bbf8', 'PASTA DI SEMOLA, CRUDA', NULL, 40, 'g', 40, 136.4, 5.4, 29.08, 0.48, 0.68);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6e3a3b22-4a77-4ce6-beba-b70c8693c515', 'cc2df31a-466d-4983-8015-eeb8c3d4bbf8', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);

-- Recipe: Patate a cubetti e cipolle al forno
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'Patate a cubetti e cipolle al forno', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 412.4, 307, 74, 6.28, 47.4, 10.4, 5.53);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1c5490f3-a1d7-47c4-8030-db97ee4794c1', '6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'PATATE', NULL, 200, 'g', 200, 160, 4.2, 36, 0.2, 3.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('39152e09-c3ef-40c6-bfe5-0bb07d2ad829', '6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'CIPOLLE', NULL, 200, 'g', 200, 56, 2, 11.4, 0.2, 2.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('03040c89-681c-4a26-9ea0-bef462a5e450', '6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fa203738-bd05-4fe4-8475-9d14fd4436f2', '6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e7c573b3-a4c6-4725-b0ed-bfb495f83501', '6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9af897d0-074a-44c5-a919-2dc6c8b94d17', '6cdbed99-5d10-415f-9e7c-96c2c63ad807', 'PREZZEMOLO, fresco', NULL, 2, 'g', 2, 0.6, 0.07, -0.04, 0.01, 0.1);

-- Recipe: Patate a cubetti e fagiolini lessati e conditi
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('672205ee-6ce2-4a06-b5c8-287be0a43f30', 'Patate a cubetti e fagiolini lessati e conditi', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 414.4, 300, 72, 8.5, 40.97, 10.41, 9.18);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2668c8b6-75e4-49f8-8194-2b392a44e5ca', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'PATATE', NULL, 200, 'g', 200, 160, 4.2, 36, 0.2, 3.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('22c053ba-82d5-45da-93a0-e11d375cc59d', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'FAGIOLINI', NULL, 200, 'g', 200, 48, 4.2, 4.8, 0.2, 5.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('383b3869-541e-4fbe-95ab-3e85160dd3ef', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('92cff053-c962-4549-ad5b-f6b9632defe6', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7c950fee-37f0-4314-abe4-66bf98e2946d', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('56b79cc2-61e5-4de4-9ddf-8c1503c23e82', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'PREZZEMOLO, fresco', NULL, 2, 'g', 2, 0.6, 0.07, -0.04, 0.01, 0.1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dfedfa80-43a7-4572-a9cb-9d83b43d3ec2', '672205ee-6ce2-4a06-b5c8-287be0a43f30', 'AGLIO, fresco', NULL, 2, 'g', 2, 0.9, 0.02, 0.17, 0.01, 0.05);

-- Recipe: Patate al cartoccio
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('09c27c21-578a-4647-8357-7ce97dae9783', 'Patate al cartoccio', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.3, 250, 119, 4.2, 36, 10.19, 3.2);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('da07cd0d-5f0f-4546-ba64-69c886f9a0a7', '09c27c21-578a-4647-8357-7ce97dae9783', 'PATATE', NULL, 200, 'g', 200, 160, 4.2, 36, 0.2, 3.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('543ee284-3312-406d-9c2d-13100b2d3e28', '09c27c21-578a-4647-8357-7ce97dae9783', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('719142a5-1371-474d-bf98-150e4c4666b2', '09c27c21-578a-4647-8357-7ce97dae9783', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Patate al forno a cubetti con extravergine e spezie
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('19293c4d-a24b-4919-854e-f293dfe91792', 'Patate al forno a cubetti con extravergine e spezie', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 214.3, 253, 118, 4.25, 36.44, 10.29, 3.4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('83e564a8-d722-46c8-b16b-014df494108a', '19293c4d-a24b-4919-854e-f293dfe91792', 'PATATE', NULL, 200, 'g', 200, 160, 4.2, 36, 0.2, 3.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4d81b5c5-90aa-42c3-ab5d-129606364c72', '19293c4d-a24b-4919-854e-f293dfe91792', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('09176a6c-d231-4d7b-b369-0ac9d4d44328', '19293c4d-a24b-4919-854e-f293dfe91792', 'ROSMARINO, fresco', NULL, 2, 'g', 2, 2.22, 0.03, 0.27, 0.09, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('03f42227-ca9f-45a3-8f15-e4d42e30038d', '19293c4d-a24b-4919-854e-f293dfe91792', 'AGLIO, fresco', NULL, 2, 'g', 2, 0.9, 0.02, 0.17, 0.01, 0.05);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('00f64573-5ad3-4d95-b979-4a36172d09c1', '19293c4d-a24b-4919-854e-f293dfe91792', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Patate lessate, condite
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('661206d4-2110-4cd5-ba3d-57c5567293cd', 'Patate lessate, condite', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 212.3, 251, 118, 4.27, 35.96, 10.2, 3.3);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ba5f4377-0288-4cca-a7c4-c42d0b29736c', '661206d4-2110-4cd5-ba3d-57c5567293cd', 'PATATE', NULL, 200, 'g', 200, 160, 4.2, 36, 0.2, 3.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('01f22467-cfd1-404c-87bc-ca335933be17', '661206d4-2110-4cd5-ba3d-57c5567293cd', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e90c0558-ad5a-4869-93a0-db6aaa5c13ca', '661206d4-2110-4cd5-ba3d-57c5567293cd', 'PREZZEMOLO, fresco', NULL, 2, 'g', 2, 0.6, 0.07, -0.04, 0.01, 0.1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('42e175a8-1eec-4424-8bdc-399b5ab01668', '661206d4-2110-4cd5-ba3d-57c5567293cd', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Patatine fritte a bastoncino
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('aaf726da-08d2-41d6-9c35-e18236265b1c', 'Patatine fritte a bastoncino', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 225.5, 385, 171, 4.2, 36, 25.2, 3.2);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('001f6b61-72f7-4de8-95be-3e74e7eaf006', 'aaf726da-08d2-41d6-9c35-e18236265b1c', 'PATATE', NULL, 200, 'g', 200, 160, 4.2, 36, 0.2, 3.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cd14fa86-d697-4b10-a787-5eac1c915923', 'aaf726da-08d2-41d6-9c35-e18236265b1c', 'OLIO DI SEMI VARI', NULL, 25, 'g', 25, 225, 0, 0, 25, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8866ce06-edac-4b07-b3e6-6344f3be8565', 'aaf726da-08d2-41d6-9c35-e18236265b1c', 'SALE da cucina', NULL, 0.5, 'g', 0.5, 0, 0, 0, 0, 0);

-- Recipe: Peperonata
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'Peperonata', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 212.4, 141, 67, 1.92, 8.29, 10.59, 3.51);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('affcf2b5-837f-492d-9c43-7697a5ee2b04', '7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'PEPERONI, DOLCI', NULL, 150, 'g', 150, 39, 1.35, 6.3, 0.45, 2.85);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e0fbe83f-f124-4f4b-9982-19833da76d9a', '7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'POMODORI, MATURI', NULL, 50, 'g', 50, 10.5, 0.5, 1.75, 0.1, 0.45);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dd1316d7-9e4d-4719-b293-e10d9124e449', '7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('edb06e4b-4bd1-4b4f-8ee8-9437d8ff2a40', '7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cf198cf4-906b-4c1d-8486-37fffa205a09', '7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2646d982-2d29-4284-a4d2-55676e7439ef', '7fe13e14-6b82-4b15-840e-ca73a2a7864e', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Peperoni arrostiti
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('ec398299-c112-4162-9970-22adbd8d90ac', 'Peperoni arrostiti', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.4, 142, 68, 1.81, 8.44, 10.59, 3.83);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dc3dcf73-57a0-46d4-b2fc-98b9baf494d6', 'ec398299-c112-4162-9970-22adbd8d90ac', 'PEPERONI, DOLCI', NULL, 200, 'g', 200, 52, 1.8, 8.4, 0.6, 3.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('40bd5059-2b6b-4bcb-a64c-559e5092bfea', 'ec398299-c112-4162-9970-22adbd8d90ac', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('44aa3be3-ca3f-447f-b26b-909a3896a801', 'ec398299-c112-4162-9970-22adbd8d90ac', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('51912a16-9bd6-40d1-8159-fd0e0b2603c7', 'ec398299-c112-4162-9970-22adbd8d90ac', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Pesce spada alla griglia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('5760d7f5-db5b-423b-a7bd-8f90e71b40e8', 'Pesce spada alla griglia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 162.4, 255, 157, 25.42, 1.74, 16.34, 0.21);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7d965ec0-aa80-4637-8428-4fae40729a9e', '5760d7f5-db5b-423b-a7bd-8f90e71b40e8', 'PESCE SPADA', NULL, 150, 'g', 150, 163.5, 25.35, 1.5, 6.3, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ae1ee299-d09d-4376-a8a1-6a582bf8c30c', '5760d7f5-db5b-423b-a7bd-8f90e71b40e8', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('799e3b1e-7120-4556-9edd-05453eed6ceb', '5760d7f5-db5b-423b-a7bd-8f90e71b40e8', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2ce6b548-ada1-44c7-b126-95ae0bd4fb5c', '5760d7f5-db5b-423b-a7bd-8f90e71b40e8', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bb62dd41-f758-4fd7-a31a-0b573a84ea4b', '5760d7f5-db5b-423b-a7bd-8f90e71b40e8', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);

-- Recipe: Pesce spada alla siciliana (pomodorini, capperi, olive)
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('344bc7e9-5748-47c9-8509-2d7b54004902', 'Pesce spada alla siciliana (pomodorini, capperi, olive)', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 309.4, 313, 101, 27.04, 6.65, 19.61, 1.75);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('36109c3f-df81-4cc8-8434-65b4e2784142', '344bc7e9-5748-47c9-8509-2d7b54004902', 'PESCE SPADA', NULL, 150, 'g', 150, 163.5, 25.35, 1.5, 6.3, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1044fc62-0d11-4883-a434-9505b7f65699', '344bc7e9-5748-47c9-8509-2d7b54004902', 'OLIVE, NERE', NULL, 12, 'g', 12, 28.8, 0.19, 0.1, 3.01, 0.29);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('45cd4704-edc8-4ef9-9802-677f1ff04ea2', '344bc7e9-5748-47c9-8509-2d7b54004902', 'CAPPERI SOTT''ACETO', NULL, 5, 'g', 5, 1.1, 0.13, 0.11, 0.01, 0.08);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8028d9e4-040c-4351-9d3b-5b1f388461bc', '344bc7e9-5748-47c9-8509-2d7b54004902', 'POMODORI, MATURI', NULL, 125, 'g', 125, 26.25, 1.25, 4.38, 0.25, 1.13);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('602f640b-1b2e-4e66-90a7-d42508b3628c', '344bc7e9-5748-47c9-8509-2d7b54004902', 'AGLIO, fresco', NULL, 5, 'g', 5, 2.25, 0.05, 0.42, 0.03, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6fb89d43-834d-45ed-b77d-3b04ae30ba28', '344bc7e9-5748-47c9-8509-2d7b54004902', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('119b3562-9aff-4ea3-84d6-977134e1242d', '344bc7e9-5748-47c9-8509-2d7b54004902', 'BASILICO, fresco', NULL, 2, 'g', 2, 0.98, 0.06, 0.1, 0.02, 0.1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('69352dbe-ddc4-463f-ba31-7442d6e201bb', '344bc7e9-5748-47c9-8509-2d7b54004902', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0df60f02-4005-4054-aff2-68f7de5272a1', '344bc7e9-5748-47c9-8509-2d7b54004902', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Petto di pollo ai ferri
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('04b10502-7e5c-4f88-84e2-3aea045486bc', 'Petto di pollo ai ferri', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 112.4, 192, 171, 23.37, 0.24, 10.84, 0.21);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('25074bae-db20-4606-97da-2230e7f04d37', '04b10502-7e5c-4f88-84e2-3aea045486bc', 'POLLO, PETTO, senza pelle', NULL, 100, 'g', 100, 100, 23.3, 0, 0.8, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3892a381-47b6-4a5e-bc1c-dcf05e30f856', '04b10502-7e5c-4f88-84e2-3aea045486bc', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('964fe053-02ab-4b8c-b2b4-90da0c0dc04a', '04b10502-7e5c-4f88-84e2-3aea045486bc', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f29fd8a1-d627-4997-b144-a70ff398a46a', '04b10502-7e5c-4f88-84e2-3aea045486bc', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5844e7d1-bf1c-4246-a186-c531d4140bef', '04b10502-7e5c-4f88-84e2-3aea045486bc', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Petto di pollo alla mugnaia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('2bec6c7c-aa93-491b-89fa-081b3165563c', 'Petto di pollo alla mugnaia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 117.4, 194, 165, 24, 3.93, 9.23, 0.32);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f233bd1f-5d32-4c39-b204-f93bb5a1dd05', '2bec6c7c-aa93-491b-89fa-081b3165563c', 'POLLO, PETTO, senza pelle', NULL, 100, 'g', 100, 100, 23.3, 0, 0.8, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('35d90f8b-803f-4641-93d9-7a783aec7708', '2bec6c7c-aa93-491b-89fa-081b3165563c', 'BURRO', NULL, 10, 'g', 10, 75.8, 0.08, 0.11, 8.34, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8e1e5b2f-e683-4c1e-a9c2-549764607480', '2bec6c7c-aa93-491b-89fa-081b3165563c', 'FARINA DI FRUMENTO, TIPO 00', NULL, 5, 'g', 5, 16.15, 0.55, 3.58, 0.04, 0.11);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b2121700-c883-4ee5-a96d-eef8357c241c', '2bec6c7c-aa93-491b-89fa-081b3165563c', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cf423292-4ed1-4906-ac31-3ef3936b69da', '2bec6c7c-aa93-491b-89fa-081b3165563c', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('05520d15-d32d-4df9-8a3b-1557334ce2d9', '2bec6c7c-aa93-491b-89fa-081b3165563c', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Petto di tacchino ai ferri
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('2ab69ae8-8ace-4034-9cdd-f2b924b75d4d', 'Petto di tacchino ai ferri', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 112.4, 199, 177, 24.07, 0.24, 11.24, 0.21);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0498610a-3978-4490-b402-447d4a56145f', '2ab69ae8-8ace-4034-9cdd-f2b924b75d4d', 'TACCHINO, FESA (PETTO), senza pelle', NULL, 100, 'g', 100, 107, 24, 0, 1.2, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('73fd7de7-dd42-4685-b3ab-f6737b742777', '2ab69ae8-8ace-4034-9cdd-f2b924b75d4d', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('82eac1e5-f72e-4f89-8a28-ed5ca08f93ff', '2ab69ae8-8ace-4034-9cdd-f2b924b75d4d', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f5544e05-06ef-4e28-8a2f-f497857d2b97', '2ab69ae8-8ace-4034-9cdd-f2b924b75d4d', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('71cc977c-c236-4731-93de-088eec07a9a1', '2ab69ae8-8ace-4034-9cdd-f2b924b75d4d', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Petto di tacchino alla mugnaia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'Petto di tacchino alla mugnaia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 117.4, 201, 172, 24.7, 3.93, 9.63, 0.32);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1d3a5c1d-5c43-4fc7-bb24-29120ea2ce6c', 'dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'TACCHINO, FESA (PETTO), senza pelle', NULL, 100, 'g', 100, 107, 24, 0, 1.2, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f5ee9f13-200e-412f-b6e7-a91bff58aabe', 'dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'BURRO', NULL, 10, 'g', 10, 75.8, 0.08, 0.11, 8.34, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fe803515-24e6-4194-aa8f-434a3728d063', 'dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'FARINA DI FRUMENTO, TIPO 00', NULL, 5, 'g', 5, 16.15, 0.55, 3.58, 0.04, 0.11);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('63846ec4-7bea-4a72-a332-207621d59195', 'dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('77ce84a3-b6e8-42e2-925f-09131a610110', 'dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cccfbd3a-f7ee-4943-b7d5-516262a2c44a', 'dd2e9257-6eb0-43f7-84a9-cf0e8c340bce', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Piadina prosciutto e formaggio
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('e63ee121-1100-4c7d-8d23-ccb61805bd36', 'Piadina prosciutto e formaggio', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 150, 457, 328, 21.31, 36.42, 25.36, 1.65);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('28c84cfa-6287-418e-a953-d961febdc1e0', 'e63ee121-1100-4c7d-8d23-ccb61805bd36', 'PIADINA', NULL, 75, 'g', 75, 236.25, 5.4, 37.42, 7.88, 1.65);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('edc9d05b-a90b-46ad-b25c-5e706ede5366', 'e63ee121-1100-4c7d-8d23-ccb61805bd36', 'PROSCIUTTO CRUDO, SAN DANIELE', NULL, 25, 'g', 25, 71, 6.66, 0, 4.93, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7aff9813-ee48-4569-b099-2e96e0c25479', 'e63ee121-1100-4c7d-8d23-ccb61805bd36', 'STRACCHINO', NULL, 50, 'g', 50, 150, 9.25, -1, 12.55, 0);

-- Recipe: Pinzimonio (ex carote, pomodorini, peperoni, rapanelli, cipollotto)
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'Pinzimonio (ex carote, pomodorini, peperoni, rapanelli, cipollotto)', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 215.3, 135, 63, 1.96, 7.53, 10.3, 3.27);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e63328f4-4e7f-4622-ba1a-923d8a4646fc', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'POMODORI, MATURI', NULL, 30, 'g', 30, 6.3, 0.3, 1.05, 0.06, 0.27);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b464e980-c9bd-43bc-bdc1-41fe5cf700d5', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'CAROTE', NULL, 30, 'g', 30, 11.7, 0.33, 2.28, 0, 0.93);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5d7b1218-52bb-44fa-85af-d00e01494b4a', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'CETRIOLI', NULL, 20, 'g', 20, 3, 0.14, 0.36, 0.1, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d3a812e6-9205-49fd-a05a-ae070d994126', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'FINOCCHIO', NULL, 30, 'g', 30, 3.9, 0.36, 0.3, 0, 0.66);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('02f28a4b-fd41-4fe4-9248-3ed7e8896e85', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'PEPERONI, DOLCI', NULL, 30, 'g', 30, 7.8, 0.27, 1.26, 0.09, 0.57);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('900045a8-fa59-4fa9-a1c9-00179ee40b9a', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'CIPOLLE', NULL, 30, 'g', 30, 8.4, 0.3, 1.71, 0.03, 0.33);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('38303ffe-6149-4dc6-bada-069acd0d8748', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'RAVANELLI', NULL, 30, 'g', 30, 3.9, 0.24, 0.54, 0.03, 0.39);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bf4230b5-ca88-43e1-a7eb-955159ada89a', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0faab474-cc7a-4f7a-98b9-a7a5531a50e6', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('31d81472-c104-4839-a7b6-27eb4efa37b2', 'c94d6d5e-4383-4c4d-afd2-bcc463980ff1', 'ACETO', NULL, 5, 'g', 5, 0.2, 0.02, 0.03, 0, 0);

-- Recipe: Pizza margherita in teglia - 'al trancio'
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('893332a6-bebb-41da-9dd7-2edc71ea0ab5', 'Pizza margherita in teglia - ''al trancio''', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 150, 419, 279, 8.4, 79.35, 8.4, 5.7);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d66a5674-00d0-4102-93ca-d3924e65dc4f', '893332a6-bebb-41da-9dd7-2edc71ea0ab5', 'PIZZA CON POMODORO E MOZZARELLA', NULL, 150, 'g', 150, 418.5, 8.4, 79.35, 8.4, 5.7);

-- Recipe: QUINOA, cotta bollita con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('418a67c1-2942-4b4a-b2aa-93c52fd07cbb', 'QUINOA, cotta bollita con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 90.3, 391, 224, 12.32, 46.24, 16.47, 9.76);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7e8800db-798f-4d0d-924a-241b346f4188', '418a67c1-2942-4b4a-b2aa-93c52fd07cbb', 'QUINOA, cotta', NULL, 80, 'g', 80, 300.8, 12.32, 46.24, 6.48, 9.76);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fa41d7d3-4e54-4d0c-ab62-ba2955c6b081', '418a67c1-2942-4b4a-b2aa-93c52fd07cbb', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('730584e9-6f84-4cb4-950f-c0baedfd293b', '418a67c1-2942-4b4a-b2aa-93c52fd07cbb', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: QUINOA, cotta con dadini di verdure
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'QUINOA, cotta con dadini di verdure', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 190.3, 413, 118, 13.36, 49.82, 16.68, 11.25);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('350e1c80-b668-4ddb-9469-766237e2afcc', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'QUINOA, cotta', NULL, 80, 'g', 80, 300.8, 12.32, 46.24, 6.48, 9.76);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4c66d019-0873-42d5-acd0-cf703efa2c72', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dd3a4c74-2390-475d-ba82-b9c05bb85fa0', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'ZUCCHINE', NULL, 25, 'g', 25, 3.5, 0.33, 0.35, 0.03, 0.33);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6fbabf8c-9f68-49f8-8bb5-9673a455e1ae', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'CAROTE', NULL, 25, 'g', 25, 9.75, 0.28, 1.9, 0, 0.78);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('edec2635-70d9-458d-bf8d-af1d33b558f9', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'CETRIOLI', NULL, 25, 'g', 25, 3.75, 0.18, 0.45, 0.13, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cd5bbcd4-0098-49c8-b75b-10efc285f861', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'POMODORI, MATURI', NULL, 25, 'g', 25, 5.25, 0.25, 0.88, 0.05, 0.23);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('01cc8763-6065-467c-b769-8ca62425149c', '7154e6f1-6edd-47bd-bc49-5fe94c140a28', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Radicchio rosso alla piastra
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('ced6b01c-b457-498a-beb2-ef2ec13d0d57', 'Radicchio rosso alla piastra', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.3, 126, 60, 2.8, 3.2, 10.19, 6);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5f704032-a6b9-45b0-b291-d760ea40201e', 'ced6b01c-b457-498a-beb2-ef2ec13d0d57', 'RADICCHIO ROSSO', NULL, 200, 'g', 200, 36, 2.8, 3.2, 0.2, 6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('61a8ad49-85bf-4e16-8f95-573ffaaa25ab', 'ced6b01c-b457-498a-beb2-ef2ec13d0d57', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('66f9e76e-2a84-4048-9586-88623a573e37', 'ced6b01c-b457-498a-beb2-ef2ec13d0d57', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Radicchio rosso in insalata, condito
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('28581659-f04a-494a-aaa6-42080f6f2970', 'Radicchio rosso in insalata, condito', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 95.3, 105, 110, 1.14, 1.31, 10.07, 2.4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7445ee95-86fa-4253-91f6-41957a312188', '28581659-f04a-494a-aaa6-42080f6f2970', 'RADICCHIO ROSSO', NULL, 80, 'g', 80, 14.4, 1.12, 1.28, 0.08, 2.4);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a5fe57ef-8f88-4ec5-bbc5-bd9a41eb109d', '28581659-f04a-494a-aaa6-42080f6f2970', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('19b4f820-d466-46c4-8507-7eae13227ed6', '28581659-f04a-494a-aaa6-42080f6f2970', 'ACETO', NULL, 5, 'g', 5, 0.2, 0.02, 0.03, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5c6164ed-5f31-418b-adcb-7539ddbad9ea', '28581659-f04a-494a-aaa6-42080f6f2970', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Radicchio verde in insalata, condito
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('35559022-d36d-49e2-b72f-e0a240db791a', 'Radicchio verde in insalata, condito', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 95.3, 103, 108, 1.54, 0.43, 10.39, 0.8);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2bdb7570-0f75-4fc8-a9fc-1f84cf24af09', '35559022-d36d-49e2-b72f-e0a240db791a', 'RADICCHIO VERDE', NULL, 80, 'g', 80, 12.8, 1.52, 0.4, 0.4, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('341378ae-79b0-4843-b862-ed8510442226', '35559022-d36d-49e2-b72f-e0a240db791a', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0c699c0a-7820-45c3-bd87-703acb988b58', '35559022-d36d-49e2-b72f-e0a240db791a', 'ACETO', NULL, 5, 'g', 5, 0.2, 0.02, 0.03, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c5063fa8-1d19-4b18-93dd-4675aec6d8b5', '35559022-d36d-49e2-b72f-e0a240db791a', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Ratatouille - verdure a cubetti in padella - ex melanzane, peperoni, zucchine e pomodori
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'Ratatouille - verdure a cubetti in padella - ex melanzane, peperoni, zucchine e pomodori', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 226.4, 171, 75, 2.4, 7.22, 14.1, 3.6);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a86d137c-107c-4734-8914-368a331bd833', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'ZUCCHINE', NULL, 40, 'g', 40, 5.6, 0.52, 0.56, 0.04, 0.52);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('120ddbf3-514c-4cf8-97f3-048554842dd7', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'PEPERONI, DOLCI', NULL, 40, 'g', 40, 10.4, 0.36, 1.68, 0.12, 0.76);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f61d0df2-509c-4f0d-bfcb-a58045cedb75', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'MELANZANE', NULL, 40, 'g', 40, 8, 0.44, 1.04, 0.04, 1.04);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cfd343e1-89d2-4500-92f5-78da4b51853f', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'POMODORI, MATURI', NULL, 40, 'g', 40, 8.4, 0.4, 1.4, 0.08, 0.36);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fc909425-c427-45c2-8902-38f61e213b9f', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'CIPOLLE', NULL, 40, 'g', 40, 11.2, 0.4, 2.28, 0.04, 0.44);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5457f4ab-515d-44ad-a104-70809e8970d8', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('74dd98a9-550d-4c9b-941f-6c90d102cb58', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'OLIVE, NERE', NULL, 15, 'g', 15, 36, 0.24, 0.12, 3.77, 0.36);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6bcbc8f2-8590-4318-8848-7975a62e1f9d', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('660e36e4-18de-4775-96bb-795bb2115934', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a16da1ba-f67c-4ff3-9a09-ae36adb6b59f', 'bacdce24-1ad7-42e4-af49-e9d856f94c4b', 'ERBE AROMATICHE (FOGLIE)', NULL, 1, 'g', 1, 0.88, 0.03, 0.1, 0.02, 0.09);

-- Recipe: Ravioli di carne con burro e salvia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('0020d835-3503-4a08-92bb-13b628748f35', 'Ravioli di carne con burro e salvia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 142.3, 457, 321, 18.72, 49.57, 21.09, 2.67);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1faffa8a-5058-45e2-ae12-6c47185ed48d', '0020d835-3503-4a08-92bb-13b628748f35', 'TORTELLINI, freschi, crudi', NULL, 125, 'g', 125, 358.75, 16.88, 49.25, 11.25, 2.38);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b0b434ae-c8fc-4481-94d7-cc97077f65dc', '0020d835-3503-4a08-92bb-13b628748f35', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f38ceb52-0e26-47a7-aff6-c0f296a65c6e', '0020d835-3503-4a08-92bb-13b628748f35', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8a3dca7e-4eb3-4ac0-b41e-59afee7e2b0e', '0020d835-3503-4a08-92bb-13b628748f35', 'BURRO', NULL, 10, 'g', 10, 75.8, 0.08, 0.11, 8.34, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6a8858f3-6810-4902-98d1-8ec8a8f40eef', '0020d835-3503-4a08-92bb-13b628748f35', 'SALVIA, fresca', NULL, 2, 'g', 2, 2.9, 0.08, 0.31, 0.09, 0.29);

-- Recipe: Ravioli di carne con olio e parmigiano
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('e4b5d2d1-bf0a-47d4-a62c-fab7aca44ee6', 'Ravioli di carne con olio e parmigiano', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 142.3, 476, 334, 19.23, 49.11, 23.21, 2.38);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6d0aedb2-2b9b-4fe2-bb9b-115d0ffe12ad', 'e4b5d2d1-bf0a-47d4-a62c-fab7aca44ee6', 'TORTELLINI, freschi, crudi', NULL, 125, 'g', 125, 358.75, 16.88, 49.25, 11.25, 2.38);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9d22067a-1e75-4f49-b71c-781eea6a64e2', 'e4b5d2d1-bf0a-47d4-a62c-fab7aca44ee6', 'PARMIGIANO', NULL, 7, 'g', 7, 27.09, 2.35, -0.14, 1.97, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fef50d31-fc2a-4d15-860c-0994967c05c7', 'e4b5d2d1-bf0a-47d4-a62c-fab7aca44ee6', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1174be3d-eb85-4013-a8bd-fe10b5859980', 'e4b5d2d1-bf0a-47d4-a62c-fab7aca44ee6', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);

-- Recipe: Ravioli di carne con sugo al pomodoro
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('67dd8bed-1162-4467-ad89-3aa5efbc0847', 'Ravioli di carne con sugo al pomodoro', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 240.3, 554, 209, 21.88, 66.61, 22.99, 4.2);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('524f2aad-52b2-4e43-be46-068e16f56e95', '67dd8bed-1162-4467-ad89-3aa5efbc0847', 'TORTELLINI, freschi, crudi', NULL, 125, 'g', 125, 358.75, 16.88, 49.25, 11.25, 2.38);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e78dc9f3-c862-4409-a803-e1b16b738c59', '67dd8bed-1162-4467-ad89-3aa5efbc0847', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b3b05c84-44d1-4585-82b7-77676a50c5aa', '67dd8bed-1162-4467-ad89-3aa5efbc0847', 'CIPOLLE', NULL, 20, 'g', 20, 5.6, 0.2, 1.14, 0.02, 0.22);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ac5d0257-6dbd-4fd2-9c9b-5444a8852a9f', '67dd8bed-1162-4467-ad89-3aa5efbc0847', 'POMODORO, CONSERVA (sostanza secca 30%)', NULL, 80, 'g', 80, 80, 3.12, 16.32, 0.32, 1.6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9df54d2e-47ca-4c13-aa9b-0211f35ffb7b', '67dd8bed-1162-4467-ad89-3aa5efbc0847', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3357cef5-a584-40de-a075-e4f7a4036cbe', '67dd8bed-1162-4467-ad89-3aa5efbc0847', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Ravioli ricotta e spinaci con burro e salvia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'Ravioli ricotta e spinaci con burro e salvia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 142.4, 457, 321, 1.85, 0.36, 9.84, 0.32);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1275ba1b-6ee2-4fbe-9cc4-b35d4e08968d', 'cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'TORTELLINI, freschi, crudi', NULL, 125, 'g', 125, 358.75, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9d2ff847-3b8f-453c-9527-3f76196b3d02', 'cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'BURRO', NULL, 10, 'g', 10, 75.8, 0.08, 0.11, 8.34, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f3daec86-046a-4ccb-a01e-2ec361315d56', 'cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('54dd7ae5-5dbb-46ae-96e2-76fbd2eb0cea', 'cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b61ce39f-2beb-4b04-9aa9-b1dff80d9fd5', 'cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b56f2b65-2f24-4e2b-a622-2e858864efbc', 'cd119d2b-0d5c-4d57-82bc-939b6a8d0568', 'SALVIA, fresca', NULL, 2, 'g', 2, 2.9, 0.08, 0.31, 0.09, 0.29);

-- Recipe: Ravioli ricotta e spinaci con olio e parmigiano
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('3d765061-12b5-4583-8c1f-90519672eb6f', 'Ravioli ricotta e spinaci con olio e parmigiano', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 140.4, 468, 334, 1.69, -0.06, 11.4, 0.03);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('155d3d77-52a8-42b2-b42d-5c4ef16220aa', '3d765061-12b5-4583-8c1f-90519672eb6f', 'TORTELLINI, freschi, crudi', NULL, 125, 'g', 125, 358.75, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bd162e25-436f-4a4a-bfe9-08128746c7ff', '3d765061-12b5-4583-8c1f-90519672eb6f', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e139b4ae-dd58-4bc8-8e30-105f4cf270de', '3d765061-12b5-4583-8c1f-90519672eb6f', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5f1ffd41-1383-4f10-a95c-6e07cc59af12', '3d765061-12b5-4583-8c1f-90519672eb6f', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1bd02deb-752a-4188-b23f-f05a8d827b06', '3d765061-12b5-4583-8c1f-90519672eb6f', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Ravioli ricotta e spinaci con sugo al pomodoro
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'Ravioli ricotta e spinaci con sugo al pomodoro', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 240.4, 554, 209, 5.01, 17.4, 11.74, 1.85);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1ee6112b-ad70-4b52-ac0e-c262d43855cb', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'TORTELLINI, freschi, crudi', NULL, 125, 'g', 125, 358.75, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7d249782-504c-4013-b57f-4a85220f21b3', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'POMODORO, CONSERVA (sostanza secca 30%)', NULL, 80, 'g', 80, 80, 3.12, 16.32, 0.32, 1.6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3fb835f2-39ab-45a5-b5d2-354e68b75e52', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'CIPOLLE', NULL, 20, 'g', 20, 5.6, 0.2, 1.14, 0.02, 0.22);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('671444f2-cd09-4b55-8ff0-e7e738f33bc8', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('94a50391-3aa9-4a8d-bac3-6f071e394d21', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ef7ccc30-c8e5-464f-9810-6fa0164a9f5d', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e53ad03d-5988-4e32-98e9-8c7b7d82edb2', 'ddc93c27-4119-4bbc-97cb-edad4e3d33c1', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: RISO, BASMATI, crudo bollito
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('3ec8afaa-499b-4646-a83f-acb3391303ad', 'RISO, BASMATI, crudo bollito', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 80.3, 294, 366, 7.2, 66.32, 1.52, 1.04);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6d4805ed-fcbe-460a-978e-0cc7a57cecfd', '3ec8afaa-499b-4646-a83f-acb3391303ad', 'RISO, BASMATI, crudo', NULL, 80, 'g', 80, 293.6, 7.2, 66.32, 1.52, 1.04);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('eb48a7fa-860a-4d7a-95b7-d51da6c48190', '3ec8afaa-499b-4646-a83f-acb3391303ad', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Riso bollito con piselli
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'Riso bollito con piselli', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 145.4, 412, 283, 9.9, 68.01, 11.92, 4.73);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('731da5c8-0169-41b4-845f-d34e34973217', 'c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5288c1ea-8ee2-4332-a6f2-a6aa115a35ed', 'c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'PISELLI SURGELATI', NULL, 50, 'g', 50, 35, 2.85, 3.75, 0.2, 3.9);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d0481b7a-3e4d-494e-a060-f1f77a5f88bd', 'c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0fe82df2-cbc4-478d-97f1-d42b627c1495', 'c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4cdfc222-6f9e-4434-80f4-9443c64fb29b', 'c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b4230c9a-023c-4071-ae17-89a073a6ddcf', 'c99a48ce-bc32-4b80-97e3-16b3dbe13046', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Riso con gamberetti e zucchine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('e694d79d-276c-48f7-9859-adff2a1c39f8', 'Riso con gamberetti e zucchine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 220.3, 406, 184, 13.16, 67.54, 10.7, 1.82);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bf789aa7-94b7-48de-9c1b-b9f24ad05474', 'e694d79d-276c-48f7-9859-adff2a1c39f8', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2a4d3141-405f-42b2-985c-ecca2bfd9d53', 'e694d79d-276c-48f7-9859-adff2a1c39f8', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a384f2dd-2c68-4f9a-b262-1153183cc608', 'e694d79d-276c-48f7-9859-adff2a1c39f8', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e9bfd417-c93b-4f29-b684-c6e03912b697', 'e694d79d-276c-48f7-9859-adff2a1c39f8', 'ZUCCHINE', NULL, 65, 'g', 65, 9.1, 0.85, 0.91, 0.07, 0.85);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c67fb133-9661-4931-a9f3-b1135399f6dd', 'e694d79d-276c-48f7-9859-adff2a1c39f8', 'GAMBERO', NULL, 50, 'g', 50, 35.5, 6.8, 1.45, 0.3, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f76dc9c3-6a78-43c3-a7b4-8c6145b84e7e', 'e694d79d-276c-48f7-9859-adff2a1c39f8', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Riso e lenticchie
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('3608ebbb-aac5-4e01-97aa-c58df8c3d854', 'Riso e lenticchie', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 107.4, 417, 388, 9.62, 73.54, 10.74, 3.16);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0e8e9728-0c76-4bd9-9e48-fab292f71c72', '3608ebbb-aac5-4e01-97aa-c58df8c3d854', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b4c6dbe3-8c43-4793-be89-96a6160f425c', '3608ebbb-aac5-4e01-97aa-c58df8c3d854', 'LENTICCHIE, secche', NULL, 17, 'g', 17, 59.84, 4.25, 9.18, 0.43, 2.33);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ff4b0bc6-ff78-4e2c-bded-29b716548425', '3608ebbb-aac5-4e01-97aa-c58df8c3d854', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2939b1da-edc4-4129-88ab-21baccffadd7', '3608ebbb-aac5-4e01-97aa-c58df8c3d854', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f9ff2d1c-5375-4eba-aa89-6dae8c1aed41', '3608ebbb-aac5-4e01-97aa-c58df8c3d854', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Riso in bianco, con extravergine e parmigiano
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('11e92b79-f41c-4c30-8008-f3270fee8483', 'Riso in bianco, con extravergine e parmigiano', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 95.3, 376, 395, 7.04, 64.22, 11.72, 0.8);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cf457431-69af-4439-942d-8979330956fc', '11e92b79-f41c-4c30-8008-f3270fee8483', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('91827949-a75b-4562-a34f-04ceb6287b77', '11e92b79-f41c-4c30-8008-f3270fee8483', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3a0372f7-c4e1-4061-81d1-6a0bc90e4411', '11e92b79-f41c-4c30-8008-f3270fee8483', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('307370fd-2fa7-49f8-8bc9-d4fce9a7c484', '11e92b79-f41c-4c30-8008-f3270fee8483', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Riso in brodo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('9d3562e0-7bb8-48f8-9e2b-a5ec1ee1a5f1', 'Riso in brodo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 245, 163, 72, 5.82, 32.3, 1.95, 0.42);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('801d473a-4e0a-454f-b855-6b5309e916ce', '9d3562e0-7bb8-48f8-9e2b-a5ec1ee1a5f1', 'BRODO DI CARNE E VERDURA', NULL, 200, 'g', 200, 10, 1.46, 0.24, 0.38, 0.02);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d24b70ef-a95d-4f9b-baa0-780192526dd2', '9d3562e0-7bb8-48f8-9e2b-a5ec1ee1a5f1', 'RISO, BRILLATO, crudo', NULL, 40, 'g', 40, 133.6, 2.68, 32.16, 0.16, 0.4);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('97501917-68c7-451f-9e75-21e4b31110b9', '9d3562e0-7bb8-48f8-9e2b-a5ec1ee1a5f1', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);

-- Recipe: Riso integrale bollito con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('7fd274ce-3e19-4c53-b24e-bfbcefbff814', 'Riso integrale bollito con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 90.3, 363, 402, 6, 61.92, 11.51, 1.52);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f404c99a-61b3-490f-af9f-7df8f18a674f', '7fd274ce-3e19-4c53-b24e-bfbcefbff814', 'RISO, INTEGRALE, crudo', NULL, 80, 'g', 80, 272.8, 6, 61.92, 1.52, 1.52);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f8742d71-c163-47d5-bf84-94e75c9d298d', '7fd274ce-3e19-4c53-b24e-bfbcefbff814', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('af378a81-6cbd-4c42-b21b-11520746e051', '7fd274ce-3e19-4c53-b24e-bfbcefbff814', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: RISO, VENERE, CRUDO bollito con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('d9bada25-c21f-4fba-b606-54a002841bc3', 'RISO, VENERE, CRUDO bollito con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 90.3, 218, 414, 2.8, 29.52, 10.23, 1.92);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1aaf59ef-4b04-483f-bc16-7d24275abd65', 'd9bada25-c21f-4fba-b606-54a002841bc3', 'RISO, VENERE, CRUDO', NULL, 80, 'g', 80, 128, 2.8, 29.52, 0.24, 1.92);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a342c3e4-4a4d-42c8-8ed1-8769fef9cc61', 'd9bada25-c21f-4fba-b606-54a002841bc3', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3fa11867-91fd-49b7-9dc7-d3b78521018b', 'd9bada25-c21f-4fba-b606-54a002841bc3', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Riso, orzo e FARRO, CRUDO bolliti con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('0933b7d8-6986-4bfd-aac3-6bc5e391af8c', 'Riso, orzo e FARRO, CRUDO bolliti con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 90.3, 366, 411, 8.41, 59.32, 11.19, 4.5);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3cc7455e-5c44-4d7d-ae9c-e698a6aa6c2b', '0933b7d8-6986-4bfd-aac3-6bc5e391af8c', 'RISO, BRILLATO, crudo', NULL, 25, 'g', 25, 83.5, 1.68, 20.1, 0.1, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('06d6ae0d-b238-4a68-b01d-0806d097b2dd', '0933b7d8-6986-4bfd-aac3-6bc5e391af8c', 'ORZO, PERLATO, CRUDO', NULL, 25, 'g', 25, 86.5, 2.35, 18.43, 0.38, 2.3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('caa4be2d-bddb-4f81-ba3e-034eddede5bc', '0933b7d8-6986-4bfd-aac3-6bc5e391af8c', 'FARRO, CRUDO', NULL, 30, 'g', 30, 105.9, 4.38, 20.79, 0.72, 1.95);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8c118b73-d6f9-460d-a0a7-7bde0efa9710', '0933b7d8-6986-4bfd-aac3-6bc5e391af8c', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('234cfd04-addf-451d-b4c8-7afce0f8e584', '0933b7d8-6986-4bfd-aac3-6bc5e391af8c', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Risotto ai frutti di mare
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('af17fc55-b511-477d-b063-adf72607d33f', 'Risotto ai frutti di mare', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 436.1, 436, 100, 15.29, 68.29, 12.83, -3.78);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('08a5cd57-46b8-450d-8b06-2cf3178dd4b0', 'af17fc55-b511-477d-b063-adf72607d33f', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cae57658-977f-4843-b062-9d6741728c9e', 'af17fc55-b511-477d-b063-adf72607d33f', 'COZZA o MITILO', NULL, 25, 'g', 25, 21, 2.93, 0.85, 0.68, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d9cf0ef6-e3bc-4c42-a8cd-6640f1360136', 'af17fc55-b511-477d-b063-adf72607d33f', 'VONGOLA', NULL, 25, 'g', 25, 18, 2.55, 0.55, 0.63, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('08793b06-3b55-4f28-ae52-7a85aa2c149e', 'af17fc55-b511-477d-b063-adf72607d33f', 'GAMBERO', NULL, 25, 'g', 25, 17.75, 3.4, 0.73, 0.15, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d636db15-d2d5-4627-9eea-6ca321dae43f', 'af17fc55-b511-477d-b063-adf72607d33f', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dd7d6266-d35b-44ca-8ec4-8e45a28e6b13', 'af17fc55-b511-477d-b063-adf72607d33f', 'AGLIO, fresco', NULL, 3, 'g', 3, 1.35, 0.03, 0.25, 0.02, 0.07);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('823e8b9d-81c0-4064-8516-ed007e6c89d6', 'af17fc55-b511-477d-b063-adf72607d33f', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c89e8126-fca7-4ad1-a3f0-c2cdedff1f06', 'af17fc55-b511-477d-b063-adf72607d33f', 'PREZZEMOLO, fresco', NULL, 3, 'g', 3, 0.9, 0.11, -0.06, 0.02, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('48a5e106-4f1b-449f-b757-0ef2c374f715', 'af17fc55-b511-477d-b063-adf72607d33f', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('220ee5bc-61bf-4dff-8298-0a37b689fea9', 'af17fc55-b511-477d-b063-adf72607d33f', 'BRODO VEGETALE', NULL, 250, 'g', 250, 15, 0.75, 0.75, 1, -5);

-- Recipe: Risotto ai funghi
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('18deb1e3-68b0-489c-80a7-d83f60f21a33', 'Risotto ai funghi', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 485, 455, 94, 13.82, 67.23, 15.58, 4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f7c6e116-42ce-4f20-94ad-2cacf7998ec0', '18deb1e3-68b0-489c-80a7-d83f60f21a33', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4e119b0f-1aa1-42df-a651-ca3b959ecccf', '18deb1e3-68b0-489c-80a7-d83f60f21a33', 'FUNGHI, PORCINI', NULL, 120, 'g', 120, 38.4, 4.68, 1.68, 0.84, 3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2ed89a8c-499f-4a4c-b6d8-c8ad0b63d48f', '18deb1e3-68b0-489c-80a7-d83f60f21a33', 'BRODO DI CARNE E VERDURA', NULL, 250, 'g', 250, 12.5, 1.83, 0.3, 0.48, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('05415288-b024-4f5c-ba31-c34fbd5f7918', '18deb1e3-68b0-489c-80a7-d83f60f21a33', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fed953b6-8bfa-41e9-b08c-747f3d4a9481', '18deb1e3-68b0-489c-80a7-d83f60f21a33', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4739b8e9-0845-4fea-943c-0e65f00dc5bd', '18deb1e3-68b0-489c-80a7-d83f60f21a33', 'BURRO', NULL, 15, 'g', 15, 113.7, 0.12, 0.17, 12.51, 0);

-- Recipe: Risotto al radicchio
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('e578dada-9489-4b14-b32f-b841ca4128bd', 'Risotto al radicchio', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 485, 439, 90, 10.82, 67.47, 14.86, 4.6);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('99b54f85-8b3c-4a00-b531-2eba8c99e173', 'e578dada-9489-4b14-b32f-b841ca4128bd', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bac25a67-d8cf-45c3-a2e8-75b755d81b43', 'e578dada-9489-4b14-b32f-b841ca4128bd', 'BRODO DI CARNE E VERDURA', NULL, 250, 'g', 250, 12.5, 1.83, 0.3, 0.48, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cfcc6a12-ddc9-4fe5-a1b7-fb68e6c79188', 'e578dada-9489-4b14-b32f-b841ca4128bd', 'RADICCHIO ROSSO', NULL, 120, 'g', 120, 21.6, 1.68, 1.92, 0.12, 3.6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('88341aa4-d3ba-4d0f-b133-a9a04ded5a61', 'e578dada-9489-4b14-b32f-b841ca4128bd', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('324a1e47-676e-4e3e-a078-ae20ceca781b', 'e578dada-9489-4b14-b32f-b841ca4128bd', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fd19d00e-0393-42ea-881b-432fb159f28f', 'e578dada-9489-4b14-b32f-b841ca4128bd', 'BURRO', NULL, 15, 'g', 15, 113.7, 0.12, 0.17, 12.51, 0);

-- Recipe: Risotto alla milanese
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'Risotto alla milanese', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 390.15, 478, 123, 14.28, 65.91, 18.97, 1.12);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3a530f31-3ef0-45ab-9378-236b5e8a5d1a', '4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5bae9f90-f70e-43a9-8644-d072b35fc3ac', '4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'BRODO DI CARNE E VERDURA', NULL, 250, 'g', 250, 12.5, 1.83, 0.3, 0.48, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4a556a46-87c1-4147-ad50-8426e74aa31f', '4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'CIPOLLE', NULL, 25, 'g', 25, 7, 0.25, 1.43, 0.03, 0.28);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('eea2171b-787a-4dd6-86ee-e95afee8a781', '4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'ZAFFERANO', NULL, 0.15, 'g', 0.15, 0.51, 0.02, 0.09, 0.01, 0.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d8a137aa-92e7-45f4-8521-2c5a9f417928', '4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'BURRO', NULL, 15, 'g', 15, 113.7, 0.12, 0.17, 12.51, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('08a24011-886a-4a34-9ed1-fc93485c5a38', '4f674ff7-9c1a-4aed-abb0-d6fb0e3bdb45', 'PARMIGIANO', NULL, 20, 'g', 20, 77.4, 6.7, -0.4, 5.62, 0);

-- Recipe: Risotto alla parmigiana
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('88ed384d-732b-40c4-95d4-81998ed561f3', 'Risotto alla parmigiana', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 380, 475, 125, 14.16, 65.25, 18.95, 1);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bcd793bd-f448-4665-a766-f5ea71dbedea', '88ed384d-732b-40c4-95d4-81998ed561f3', 'RISO, BRILLATO, crudo', NULL, 80, 'g', 80, 267.2, 5.36, 64.32, 0.32, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d0d665aa-3bba-42ef-b20c-13bb70887977', '88ed384d-732b-40c4-95d4-81998ed561f3', 'BRODO DI CARNE E VERDURA', NULL, 250, 'g', 250, 12.5, 1.83, 0.3, 0.48, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a927afaf-9025-4940-949a-180bb80f09d1', '88ed384d-732b-40c4-95d4-81998ed561f3', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e081c9c9-6b4c-4005-9c0a-aa79ed3b2d3f', '88ed384d-732b-40c4-95d4-81998ed561f3', 'BURRO', NULL, 15, 'g', 15, 113.7, 0.12, 0.17, 12.51, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('37e121f1-af06-48df-bc7a-425562d16b5e', '88ed384d-732b-40c4-95d4-81998ed561f3', 'PARMIGIANO', NULL, 20, 'g', 20, 77.4, 6.7, -0.4, 5.62, 0);

-- Recipe: Roast beef all'inglese con rucola e grana
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('6199ef53-8b7b-467e-ae5c-bb9de4dbf462', 'Roast beef all''inglese con rucola e grana', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 132.3, 229, 173, 24.32, 0.18, 14.46, 0.24);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('aff03d06-c362-4e70-ae68-5f15c7cc2757', '6199ef53-8b7b-467e-ae5c-bb9de4dbf462', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', NULL, 100, 'g', 100, 108, 21.58, 0, 2.38, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ba532e52-1f63-47cf-a201-132568724c64', '6199ef53-8b7b-467e-ae5c-bb9de4dbf462', 'PARMIGIANO', NULL, 7, 'g', 7, 27.09, 2.35, -0.14, 1.97, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('09e74d1a-bcec-4cc7-91d5-0d4b8d66be4f', '6199ef53-8b7b-467e-ae5c-bb9de4dbf462', 'OLIO DI OLIVA', NULL, 10, 'g', 10, 90, 0, 0, 10, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e9f7a5c6-8158-4277-b5e3-495b9ed33459', '6199ef53-8b7b-467e-ae5c-bb9de4dbf462', 'RUCOLA', NULL, 15, 'g', 15, 4.2, 0.39, 0.32, 0.11, 0.24);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b28bf39a-dc28-42fd-9cf0-242d0807244e', '6199ef53-8b7b-467e-ae5c-bb9de4dbf462', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Roast-beef all'inglese
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('bbef475d-f0ec-4b19-83e2-78b5e3e1c7ad', 'Roast-beef all''inglese', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 100.3, 108, 108, 21.58, 0, 2.38, 0);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('51cd40b9-92ff-42f5-b8c8-74876a0e62a1', 'bbef475d-f0ec-4b19-83e2-78b5e3e1c7ad', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', NULL, 100, 'g', 100, 108, 21.58, 0, 2.38, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b7d89500-17be-4301-9228-8e2ee1f21459', 'bbef475d-f0ec-4b19-83e2-78b5e3e1c7ad', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Salmone al forno
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('0117f9d9-fb29-4eac-acc5-234ec6ec005e', 'Salmone al forno', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 150.3, 278, 185, 27.6, 1.5, 18, 0);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3a7f16be-823b-4690-a43a-b646fe5fa6fc', '0117f9d9-fb29-4eac-acc5-234ec6ec005e', 'SALMONE', NULL, 150, 'g', 150, 277.5, 27.6, 1.5, 18, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('19773a17-ed51-4528-b422-1567673378d9', '0117f9d9-fb29-4eac-acc5-234ec6ec005e', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Sauté di cozze e vongole
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('01344216-f919-4944-9206-bc6504c579b2', 'Sauté di cozze e vongole', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 170.4, 211, 124, 16.68, 4.56, 13.96, 0.4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('38c09cfa-a0a6-478f-9726-9759a7780e3f', '01344216-f919-4944-9206-bc6504c579b2', 'COZZA o MITILO', NULL, 75, 'g', 75, 63, 8.78, 2.55, 2.03, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9740e82f-01fb-415f-ae30-40226828561a', '01344216-f919-4944-9206-bc6504c579b2', 'VONGOLA', NULL, 75, 'g', 75, 54, 7.65, 1.65, 1.88, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c413f228-8c8f-43f9-b2dd-14437b99571e', '01344216-f919-4944-9206-bc6504c579b2', 'AGLIO, fresco', NULL, 5, 'g', 5, 2.25, 0.05, 0.42, 0.03, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('eb042dc3-c093-4d95-8435-ad9ba6582f39', '01344216-f919-4944-9206-bc6504c579b2', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fc0acdef-66ec-412a-98e2-ab71310dabf6', '01344216-f919-4944-9206-bc6504c579b2', 'PREZZEMOLO, fresco', NULL, 5, 'g', 5, 1.5, 0.19, -0.1, 0.03, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ae11d4dd-b175-486c-93c0-f86d777918d6', '01344216-f919-4944-9206-bc6504c579b2', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('24e4b47c-2e06-4d1a-b9aa-18aad1eb1783', '01344216-f919-4944-9206-bc6504c579b2', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Scaloppina di vitello al limone
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'Scaloppina di vitello al limone', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 125.4, 206, 164, 21.6, 5.06, 11.06, 0.33);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('396984e8-72b4-41e7-bc8a-5f4f757d11f2', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'BOVINO, VITELLO, 4 MESI, CARNE MAGRA, senza grasso visibile', NULL, 100, 'g', 100, 92, 20.7, 0, 1, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('72f28eff-c29f-4149-b9f8-d72604e8d92e', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b37cea36-e77c-41b4-a11d-e125cc2e8fe6', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'PREZZEMOLO, fresco', NULL, 3, 'g', 3, 0.9, 0.11, -0.06, 0.02, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f2cc3705-3325-4a8a-89f4-12df91a66f8a', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'SUCCO DI LIMONE, fresco', NULL, 5, 'g', 5, 0.3, 0.01, 0.07, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e92f3f32-ee75-4466-bdc3-4bd6b14726a5', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'FARINA DI FRUMENTO, TIPO 00', NULL, 7, 'g', 7, 22.61, 0.77, 5.01, 0.05, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('97d9f1a4-6501-4cdc-bbe3-72ab7fb0cbfe', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('845a41c2-c443-4add-8805-aae6cb0e612d', '4a006f4e-67ce-4683-a9f5-2e5c031b2181', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Scarola cotta, condita
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('44e85d33-e74b-46a0-96df-044521ce7f92', 'Scarola cotta, condita', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 212.4, 127, 60, 3.23, 3.61, 10.4, 3.08);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c86b3534-84ac-4485-8454-dcbc7c98cd15', '44e85d33-e74b-46a0-96df-044521ce7f92', 'SCAROLA', NULL, 200, 'g', 200, 36, 3.2, 3.4, 0.4, 3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3455bdfb-f33d-4ebd-a998-64cda9e93270', '44e85d33-e74b-46a0-96df-044521ce7f92', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('56af2a0f-e980-404a-ba81-2fd77d5b1ff8', '44e85d33-e74b-46a0-96df-044521ce7f92', 'AGLIO, fresco', NULL, 2, 'g', 2, 0.9, 0.02, 0.17, 0.01, 0.05);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('eef45ad2-411f-41a9-a5bd-29afa1fde87d', '44e85d33-e74b-46a0-96df-044521ce7f92', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8273927f-fe96-4079-98af-1070cf64f560', '44e85d33-e74b-46a0-96df-044521ce7f92', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Scarola riccia in insalata, condita
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('6778f813-94eb-4bf2-ba5c-955a5e48b7c5', 'Scarola riccia in insalata, condita', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 95.3, 105, 110, 1.3, 1.39, 10.15, 1.2);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3407a876-1bb1-451a-9dfc-dfd5e5d16662', '6778f813-94eb-4bf2-ba5c-955a5e48b7c5', 'SCAROLA', NULL, 80, 'g', 80, 14.4, 1.28, 1.36, 0.16, 1.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b83deb51-ca35-4fa1-aa7d-241ce6f96579', '6778f813-94eb-4bf2-ba5c-955a5e48b7c5', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1f00c39a-c511-42d6-be33-3f196568863f', '6778f813-94eb-4bf2-ba5c-955a5e48b7c5', 'ACETO', NULL, 5, 'g', 5, 0.2, 0.02, 0.03, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d4991654-55ac-4b50-94fc-38d163c49abc', '6778f813-94eb-4bf2-ba5c-955a5e48b7c5', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Scorzonera o radici amare lessate con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('52e44e8a-7cbd-431b-a6ba-6bd72b14f46f', 'Scorzonera o radici amare lessate con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.3, 196, 93, 2.6, 20.4, 10.59, 6.4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ad24de60-0c29-47fe-8293-4eae2382a720', '52e44e8a-7cbd-431b-a6ba-6bd72b14f46f', 'SCORZONERA', NULL, 200, 'g', 200, 106, 2.6, 20.4, 0.6, 6.4);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c43364ef-fb8a-4131-9b96-dcd7e1369f28', '52e44e8a-7cbd-431b-a6ba-6bd72b14f46f', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('61fd4b40-b148-4708-8de4-32e1b161b8aa', '52e44e8a-7cbd-431b-a6ba-6bd72b14f46f', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Seppie in umido
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'Seppie in umido', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 222.4, 254, 114, 23.28, 12.02, 12.51, 1.44);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1d11fe33-e9a5-4162-881b-df4e7420c0d7', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'SEPPIA', NULL, 150, 'g', 150, 108, 21, 1.05, 2.25, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('81879189-73d4-40b5-be00-43e816c9d3a6', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'POMODORO, CONSERVA (sostanza secca 30%)', NULL, 52, 'g', 52, 52, 2.03, 10.61, 0.21, 1.04);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9d62fabf-99ca-40fb-930e-0693a09b5dc2', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('43a7d19c-cf49-4dc8-a14a-00b5d25ad346', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'PREZZEMOLO, fresco', NULL, 5, 'g', 5, 1.5, 0.19, -0.1, 0.03, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0d0f643e-3909-4f6d-ab37-aba5a96d644b', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'AGLIO, fresco', NULL, 5, 'g', 5, 2.25, 0.05, 0.42, 0.03, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cc13da09-31bd-4394-a75f-a6c5a21292f5', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('93df845a-bd91-436e-83cb-0abd5f57ce21', '06b4cc8b-bdf3-48f0-9271-e99c74b655bb', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Sogliola alla griglia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('316c3525-4884-4a6b-9418-7c06576310e2', 'Sogliola alla griglia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 162.4, 221, 136, 25.42, 1.44, 12.59, 0.21);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b91f22cf-7393-4051-ad78-5f14b816cc30', '316c3525-4884-4a6b-9418-7c06576310e2', 'SOGLIOLA', NULL, 150, 'g', 150, 129, 25.35, 1.2, 2.55, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3c29272e-bd75-482e-8644-593ab28ddc6e', '316c3525-4884-4a6b-9418-7c06576310e2', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c11a530e-940d-4a63-a4ec-a3c33197ffcb', '316c3525-4884-4a6b-9418-7c06576310e2', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('239dddc3-7ce8-4005-b54d-18965252ccf7', '316c3525-4884-4a6b-9418-7c06576310e2', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('aa6d90ae-9333-490b-9c45-0a78fcb85cde', '316c3525-4884-4a6b-9418-7c06576310e2', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);

-- Recipe: Sogliola alla mugnaia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('792fc432-0eea-4704-affc-3a60fe93b7c3', 'Sogliola alla mugnaia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 178.4, 267, 150, 26.37, 6.54, 15.14, 0.34);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b4cd3c24-106d-484d-aaf2-7ce97a316c9b', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'SOGLIOLA', NULL, 150, 'g', 150, 129, 25.35, 1.2, 2.55, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7efc7649-fab3-47ab-9aa7-d6b31fa30547', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'BURRO', NULL, 15, 'g', 15, 113.7, 0.12, 0.17, 12.51, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e70cfe96-30f4-49d2-8d78-b8315df3f726', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'FARINA DI FRUMENTO, TIPO 00', NULL, 7, 'g', 7, 22.61, 0.77, 5.01, 0.05, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('23b1501c-b862-43b5-9451-68ea57e74c81', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'SUCCO DI LIMONE', NULL, 3, 'g', 3, 0.84, 0.01, 0.18, 0.01, 0.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b286e2d3-13d3-4769-9075-8026cf15f020', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'PREZZEMOLO, fresco', NULL, 3, 'g', 3, 0.9, 0.11, -0.06, 0.02, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c694a0e3-48b8-4e20-8aa4-38a27527bd06', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('858d77d7-25e5-414c-bf84-828d8c5fa990', '792fc432-0eea-4704-affc-3a60fe93b7c3', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Sogliola impanata
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('d91c62b7-958a-4e73-99d0-cec167715d1b', 'Sogliola impanata', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 190.9, 317, 166, 27.93, 8.95, 18.85, 0.36);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('298a2146-f4f1-4b7e-9a9e-4838b697c73f', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'SOGLIOLA', NULL, 150, 'g', 150, 129, 25.35, 1.2, 2.55, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('842c077b-b4c6-40c2-8c12-7d8b87c58cc9', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'PANE, GRATTUGIATO', NULL, 10, 'g', 10, 35.7, 1.01, 7.78, 0.21, 0.32);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('84a300da-fdae-4556-a29f-d2ee099406fd', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'UOVO DI GALLINA, INTERO', NULL, 12.5, 'g', 12.5, 16, 1.55, -0.25, 1.09, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6e376f0a-719f-4567-ac1e-9e1547aa6137', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 15, 'g', 15, 134.85, 0, 0, 14.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('58a91325-06fb-44c8-8df2-6cd0bc2b3385', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'SUCCO DI LIMONE', NULL, 3, 'g', 3, 0.84, 0.01, 0.18, 0.01, 0.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fed90874-4b4f-4d96-85fe-c2888639b586', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bc79a204-5fec-4c83-a5e4-e523335b4d04', 'd91c62b7-958a-4e73-99d0-cec167715d1b', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Spaghetti alle vongole
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'Spaghetti alle vongole', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 158.3, 409, 258, 17.14, 59.63, 12.5, 1.68);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('927f697f-4de1-45ac-b7c6-0d6c7995374c', 'fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'PASTA DI SEMOLA, CRUDA', NULL, 80, 'g', 80, 272.8, 10.8, 58.16, 0.96, 1.36);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2e51ef80-2f3c-4219-b742-24a1b9b5e368', 'fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'VONGOLA', NULL, 60, 'g', 60, 43.2, 6.12, 1.32, 1.5, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4c29988a-263c-48cf-bdac-60bdac7fda6c', 'fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c6bf268c-879e-4e85-9078-cfafac723a19', 'fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'AGLIO, fresco', NULL, 3, 'g', 3, 1.35, 0.03, 0.25, 0.02, 0.07);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('46de05c5-1a55-4431-8dbd-297970cae501', 'fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'PREZZEMOLO, fresco', NULL, 5, 'g', 5, 1.5, 0.19, -0.1, 0.03, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a16bfa87-7086-41a3-aa5a-74159ca97b8a', 'fd55e269-339e-49c7-b5fb-16a9f9d276f8', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Spaghetti con aglio, olio extravergine e peperoncino
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'Spaghetti con aglio, olio extravergine e peperoncino', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 98.3, 366, 372, 11, 58.37, 11, 1.65);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d3e1fdc5-2ffd-4750-a3be-2ee919eb8595', 'b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'PASTA DI SEMOLA, CRUDA', NULL, 80, 'g', 80, 272.8, 10.8, 58.16, 0.96, 1.36);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('de921872-a7de-4e45-94f9-57e523c3db12', 'b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b9a3508d-1058-4067-8261-8407dbe79f7f', 'b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'PEPERONCINI, PICCANTI', NULL, 1, 'g', 1, 0.3, 0.02, 0.04, 0.01, 0.02);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('00e9fc3a-6ce2-41a5-8f21-4753d2272b39', 'b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'AGLIO, fresco', NULL, 3, 'g', 3, 1.35, 0.03, 0.25, 0.02, 0.07);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('16330521-4eae-4f68-9541-66848193f9d7', 'b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'PREZZEMOLO, fresco', NULL, 4, 'g', 4, 1.2, 0.15, -0.08, 0.02, 0.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b1039606-c5d3-4520-ae23-1bb836b71bd0', 'b39c53d7-1ac3-4518-bd56-2ac80d05b026', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Spezzatino
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('46f9d31d-5654-46be-8803-54dd0f057505', 'Spezzatino', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.1, 205, 97, 22.66, 3.85, 10.92, 0.72);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2bbe2371-b85f-4c66-88d5-3ae65f220f31', '46f9d31d-5654-46be-8803-54dd0f057505', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', NULL, 100, 'g', 100, 108, 21.58, 0, 2.38, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1fb01340-2974-442f-b8ba-51c5a6e6a714', '46f9d31d-5654-46be-8803-54dd0f057505', 'BURRO', NULL, 10, 'g', 10, 75.8, 0.08, 0.11, 8.34, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d2c79b0a-aec2-41a0-9f01-75cceff449d0', '46f9d31d-5654-46be-8803-54dd0f057505', 'CIPOLLE', NULL, 45, 'g', 45, 12.6, 0.45, 2.57, 0.05, 0.5);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b541942a-43e9-4fe7-b7c1-5d9adda32c0e', '46f9d31d-5654-46be-8803-54dd0f057505', 'BRODO DI CARNE E VERDURA', NULL, 50, 'g', 50, 2.5, 0.37, 0.06, 0.1, 0.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('99c4a370-a5eb-4837-abcd-7f1f4ec247fe', '46f9d31d-5654-46be-8803-54dd0f057505', 'AGLIO, fresco', NULL, 3, 'g', 3, 1.35, 0.03, 0.25, 0.02, 0.07);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('03376dfb-a6b1-4ef6-8c3b-fa35218b3bab', '46f9d31d-5654-46be-8803-54dd0f057505', 'ERBE AROMATICHE (FOGLIE)', NULL, 1, 'g', 1, 0.88, 0.03, 0.1, 0.02, 0.09);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d08508bd-7970-4500-8986-34aa2d82ab6f', '46f9d31d-5654-46be-8803-54dd0f057505', 'FARINA DI FRUMENTO, TIPO 00', NULL, 1, 'g', 1, 3.23, 0.11, 0.72, 0.01, 0.02);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('40cfd583-8ae3-42a3-abc1-0a0992fbebcc', '46f9d31d-5654-46be-8803-54dd0f057505', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Spiedini di carne
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'Spiedini di carne', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 160.3, 248, 155, 18.47, 3.25, 17.81, 0.9);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0cd00d60-3a56-4340-bf88-b959d6b586d7', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', NULL, 30, 'g', 30, 32.4, 6.47, 0, 0.71, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('05fc828a-ccd0-42f4-b91b-9b944003d953', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'SALSICCIA DI SUINO, fresca', NULL, 30, 'g', 30, 91.2, 4.62, 0.18, 8.01, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5eb1d489-bdd5-4c9b-a0b6-4dfc0c23272f', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'SUINO, CARNE SEMIGRASSA, senza grasso visibile', NULL, 30, 'g', 30, 42.3, 5.97, 0, 2.04, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('de7089ec-2d1b-4d89-bc66-2d65704d223b', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'PANCETTA DI MAIALE', NULL, 10, 'g', 10, 66.1, 0.84, 0.1, 6.93, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7570ef94-7cf2-4923-9975-05100ad00757', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'PEPERONI, DOLCI', NULL, 30, 'g', 30, 7.8, 0.27, 1.26, 0.09, 0.57);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8057e578-2b89-44c6-8e35-1b96a1faee99', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'CIPOLLE', NULL, 30, 'g', 30, 8.4, 0.3, 1.71, 0.03, 0.33);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4df406c6-033e-4e02-af1b-f2f502da3247', '8ccfaf44-3640-4f00-ac5e-0a00144d0c10', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Spiedini di pesce
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'Spiedini di pesce', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 223.4, 255, 114, 24.58, 3.24, 15.82, 1.09);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('76a97937-4baf-4e08-a653-7a2f82ab15de', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'MERLUZZO', NULL, 40, 'g', 40, 28.4, 6.8, 0, 0.12, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('99de1b18-7714-430d-af5d-e2651c85884e', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'SALMONE', NULL, 40, 'g', 40, 74, 7.36, 0.4, 4.8, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('40973a39-0d8a-466b-97d5-97e5309406d3', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'SEPPIA', NULL, 40, 'g', 40, 28.8, 5.6, 0.28, 0.6, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9d8391ac-f34a-418f-8df5-fe1841c3cba0', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'GAMBERO', NULL, 30, 'g', 30, 21.3, 4.08, 0.87, 0.18, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('65873ae1-532b-494d-ac7b-229b89214927', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'PEPERONI, DOLCI', NULL, 30, 'g', 30, 7.8, 0.27, 1.26, 0.09, 0.57);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('51ce5181-9054-4e1d-a06b-a28c36e839dd', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'ZUCCHINE', NULL, 30, 'g', 30, 4.2, 0.39, 0.42, 0.03, 0.39);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('abc950b3-056b-40a9-9465-375a65760118', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8a5ebb0a-5559-4418-8679-180f714b7626', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'PREZZEMOLO, fresco', NULL, 2, 'g', 2, 0.6, 0.07, -0.04, 0.01, 0.1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('caac387b-e95f-4f98-bbc1-8b184ff68129', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'SUCCO DI LIMONE, fresco', NULL, 1, 'g', 1, 0.06, 0, 0.01, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b66dd48b-19c2-40cc-bc7f-14fc14d3e261', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b27e45e2-b97d-473b-90e5-aed5ad6afddb', '642fbc5d-aaa6-469e-a6c2-0ebb9de7cdfc', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Spiedini di pollo e tacchino
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'Spiedini di pollo e tacchino', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 160.3, 266, 166, 13.8, 3.07, 8.85, 0.9);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('24bc51a7-58fd-40f4-97fd-9ed6533b9846', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'POLLO, INTERO, senza pelle', NULL, 30, 'g', 30, 33, 5.82, 0, 1.08, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bedb6cfd-527f-4b85-8083-1105f87cf686', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'TACCHINO, INTERO, senza pelle', NULL, 30, 'g', 30, 32.7, 6.57, 0, 0.72, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('22bc4e44-e84c-4b64-8546-dcda427710f8', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'SALSICCIA DI SUINO E BOVINO, fresca', NULL, 30, 'g', 30, 117.9, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9330c3fc-d662-4d81-b628-2957ba6f8af4', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'PANCETTA DI MAIALE', NULL, 10, 'g', 10, 66.1, 0.84, 0.1, 6.93, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('544ccf59-2bfa-46af-9314-5af74218c7ae', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'PEPERONI, DOLCI', NULL, 30, 'g', 30, 7.8, 0.27, 1.26, 0.09, 0.57);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d4f43534-bb5f-497d-8aa8-7515e74c7e76', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'CIPOLLE', NULL, 30, 'g', 30, 8.4, 0.3, 1.71, 0.03, 0.33);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7bd36d04-abdf-4664-a638-003d05ca90a0', 'e36eaa8e-6d1c-4bf5-b224-7c92e6b5a030', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Spigola o branzino al forno
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('2b14b670-7758-4e51-a13c-b3b05f4b72ff', 'Spigola o branzino al forno', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 160.3, 213, 133, 24.75, 0.9, 12.24, 0);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6ebeb7d6-c8a4-4e00-97f6-1b38edb27fd9', '2b14b670-7758-4e51-a13c-b3b05f4b72ff', 'SPIGOLA ICA', NULL, 150, 'g', 150, 123, 24.75, 0.9, 2.25, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3f81de3f-78ca-4100-bf76-c431dc135772', '2b14b670-7758-4e51-a13c-b3b05f4b72ff', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7f561ee4-c244-4c32-b44b-f7c8002e1202', '2b14b670-7758-4e51-a13c-b3b05f4b72ff', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Spigola o branzino alla griglia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('600e68a2-06c7-4e6b-9542-26dc61686190', 'Spigola o branzino alla griglia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 162.4, 215, 132, 24.82, 1.14, 12.29, 0.21);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('312e85e4-b0ef-4bfe-b3ff-0276dbfe91a0', '600e68a2-06c7-4e6b-9542-26dc61686190', 'SPIGOLA ICA', NULL, 150, 'g', 150, 123, 24.75, 0.9, 2.25, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8c68bff1-7803-446a-8540-a69b3bd0b654', '600e68a2-06c7-4e6b-9542-26dc61686190', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dc2426fa-8c2f-4315-8428-32a6d003634b', '600e68a2-06c7-4e6b-9542-26dc61686190', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4e98c6af-d434-4fc2-9161-833e3f2dc599', '600e68a2-06c7-4e6b-9542-26dc61686190', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('594c3b08-8c12-476f-b9bf-056c5348de23', '600e68a2-06c7-4e6b-9542-26dc61686190', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);

-- Recipe: Spinaci lessati con extravergine
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('366dc745-4a66-412b-b0f4-87da08d4ee6f', 'Spinaci lessati con extravergine', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.3, 160, 76, 6.8, 6, 11.39, 3.8);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4244d63a-3907-482a-b42c-67fc84c16899', '366dc745-4a66-412b-b0f4-87da08d4ee6f', 'SPINACI', NULL, 200, 'g', 200, 70, 6.8, 6, 1.4, 3.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d8c81f88-7202-4f41-88a9-14925f9a5d94', '366dc745-4a66-412b-b0f4-87da08d4ee6f', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('de9b8eef-dd24-4c7c-a9c0-4d9b9df61b97', '366dc745-4a66-412b-b0f4-87da08d4ee6f', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Stracciatella alla romana
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('ddcdf18d-23e1-4d0d-95c7-8576bff582c2', 'Stracciatella alla romana', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 266, 136, 51, 12.78, -0.8, 9.24, 0.26);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f095d4e1-05cd-491a-b833-708f71d655a2', 'ddcdf18d-23e1-4d0d-95c7-8576bff582c2', 'BRODO DI CARNE E VERDURA', NULL, 200, 'g', 200, 10, 1.46, 0.24, 0.38, 0.02);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('90087462-5c95-407c-a9ca-a3749be89c19', 'ddcdf18d-23e1-4d0d-95c7-8576bff582c2', 'UOVO DI GALLINA, INTERO', NULL, 50, 'g', 50, 64, 6.2, -1, 4.35, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0a966e4d-4f93-43f1-8721-33d8e862bf3d', 'ddcdf18d-23e1-4d0d-95c7-8576bff582c2', 'PARMIGIANO', NULL, 15, 'g', 15, 58.05, 5.03, -0.3, 4.22, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('828b88fd-1ef3-469f-8384-6884b90fa2dc', 'ddcdf18d-23e1-4d0d-95c7-8576bff582c2', 'NOCE MOSCATA', NULL, 1, 'g', 1, 4.42, 0.09, 0.26, 0.29, 0.24);

-- Recipe: Strudel di mele
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('07d37525-edda-4340-ad21-8aaffc573059', 'Strudel di mele', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 100, 248, 248, 5.79, 38.25, 7.84, 2.17);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5af1570c-3bd4-43b9-b981-f5d330468a92', '07d37525-edda-4340-ad21-8aaffc573059', 'FARINA DI FRUMENTO, TIPO 00', NULL, 21, 'g', 21, 67.83, 2.31, 15.04, 0.15, 0.46);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('67c5d9b4-325d-48ca-bca2-ac2d954f8d96', '07d37525-edda-4340-ad21-8aaffc573059', 'ZUCCHERO (Saccarosio)', NULL, 13, 'g', 13, 50.96, 0, 13.59, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5a88a9cf-50b9-4d89-bd0b-60e6048e330e', '07d37525-edda-4340-ad21-8aaffc573059', 'UOVO DI GALLINA, INTERO', NULL, 4, 'g', 4, 5.12, 0.5, -0.08, 0.35, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('22b3090b-1962-474a-af44-6a669a960378', '07d37525-edda-4340-ad21-8aaffc573059', 'BURRO', NULL, 5, 'g', 5, 37.9, 0.04, 0.06, 4.17, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4bb54b79-0abc-437e-b0af-3b42235aa37d', '07d37525-edda-4340-ad21-8aaffc573059', 'LATTE DI VACCA, INTERO, PASTORIZZATO', NULL, 7, 'g', 7, 4.48, 0.23, 0.34, 0.25, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9d87cb4c-80cf-449e-bb72-e9359b982b73', '07d37525-edda-4340-ad21-8aaffc573059', 'MELE, con buccia', NULL, 35, 'g', 35, 15.4, 0.07, 3.5, -0.7, 0.91);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b8649ddc-c9d1-4dca-b477-944390678f1b', '07d37525-edda-4340-ad21-8aaffc573059', 'PANE, GRATTUGIATO', NULL, 3, 'g', 3, 10.71, 0.3, 2.33, 0.06, 0.1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b55335ab-58cd-47e2-8729-1e5e2178cb10', '07d37525-edda-4340-ad21-8aaffc573059', 'UVA SULTANINA, UVETTA, UVA SECCA', NULL, 4, 'g', 4, 11.72, 0.08, 2.88, 0.02, 0.21);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0476fc4f-1e76-46e2-a58b-6a11c9d44d6b', '07d37525-edda-4340-ad21-8aaffc573059', 'LIMONE, SCORZA', NULL, 0.5, 'g', 0.5, 0.25, 0.01, 0.03, 0, 0.05);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7fea1622-18ee-41b8-b625-f15d97af7385', '07d37525-edda-4340-ad21-8aaffc573059', 'CANNELLA', NULL, 0.5, 'g', 0.5, 1.51, 0.02, 0.28, 0.02, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('204aa6a8-d9ee-4536-a11e-71f31044d84a', '07d37525-edda-4340-ad21-8aaffc573059', 'PINOLI', NULL, 7, 'g', 7, 42.28, 2.23, 0.28, 3.52, 0.32);

-- Recipe: Tagliata di manzo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('76fae57b-53f7-4058-930e-9fd06e1c4a8f', 'Tagliata di manzo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 100.4, 108, 108, 21.59, 0.04, 2.38, 0.03);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('799e717d-c864-4575-9c91-4d5a23b5ee6f', '76fae57b-53f7-4058-930e-9fd06e1c4a8f', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE MAGRA, senza grasso visibile', NULL, 100, 'g', 100, 108, 21.58, 0, 2.38, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b2fcaabf-934a-4a4b-a4bd-ca31d136cebf', '76fae57b-53f7-4058-930e-9fd06e1c4a8f', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e588416d-33be-4910-b9bc-5fb9e2d9d989', '76fae57b-53f7-4058-930e-9fd06e1c4a8f', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Tagliatelle al ragù
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('d2bd917f-34fc-492c-8b08-f6639ecc22a3', 'Tagliatelle al ragù', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 250.4, 537, 215, 25.35, 71.34, 17.69, 4.67);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b375e5c7-97e2-4708-9c69-c2e5d5dfae0e', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'PASTA ALL''UOVO, secca', NULL, 80, 'g', 80, 276.8, 10.4, 56.8, 1.92, 2.56);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5a3a1ac9-35ed-4628-b9f5-2595b58841b5', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE GRASSA, senza grasso visibile', NULL, 50, 'g', 50, 77.5, 10.25, 0, 4.08, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('22d26f8d-ab35-4dcb-86f5-54e0f8c3ea0f', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'CAROTE', NULL, 15, 'g', 15, 5.85, 0.17, 1.14, 0, 0.47);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('aecc9e9a-675b-4e29-aa4c-c2debfe59416', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ad84240d-70ff-4346-8358-fd99f08b4aa2', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'SEDANO', NULL, 15, 'g', 15, 3.45, 0.35, 0.36, 0.03, 0.24);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bf8818ff-cd4c-470b-97e6-c8cd431f9e6e', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c4677c2d-ed9a-41a5-92a5-8dafd3c057bc', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'POMODORO, CONSERVA (sostanza secca 30%)', NULL, 60, 'g', 60, 60, 2.34, 12.24, 0.24, 1.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fd472df7-27f7-4d23-ae6f-23783954fb6a', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('57ae5b0d-0c3c-4274-ba2a-280419544bd3', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('cb935fe8-ca9a-48c2-bd1a-57b6a409e48e', 'd2bd917f-34fc-492c-8b08-f6639ecc22a3', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Tagliolini Cacio e pepe
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('2525aec1-281b-4e0d-b27a-30451e1a4cd2', 'Tagliolini Cacio e pepe', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 120.5, 431, 358, 21.17, 58.43, 13.78, 1.49);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('10ecd3ab-f717-4c26-8500-7423cd374d8e', '2525aec1-281b-4e0d-b27a-30451e1a4cd2', 'PASTA DI SEMOLA, CRUDA', NULL, 80, 'g', 80, 272.8, 10.8, 58.16, 0.96, 1.36);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('73103ded-9ca4-49e6-84fd-b6f9d916f82b', '2525aec1-281b-4e0d-b27a-30451e1a4cd2', 'PECORINO', NULL, 40, 'g', 40, 156.8, 10.32, 0.08, 12.8, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f03260c7-3586-40f8-a933-2f5a3ffb7384', '2525aec1-281b-4e0d-b27a-30451e1a4cd2', 'PEPE NERO', NULL, 0.5, 'g', 0.5, 1.35, 0.05, 0.19, 0.02, 0.13);

-- Recipe: Tartare di manzo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('1019da81-f566-4265-a17d-0581bc11178b', 'Tartare di manzo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 144.4, 282, 180, 21.93, 2.83, 19.95, 2.33);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('212cebf4-10b3-4ebf-a324-fa005b46fae9', '1019da81-f566-4265-a17d-0581bc11178b', 'BOVINO, VITELLONE, 15-18 MESI, TAGLI DI CARNE GRASSA, senza grasso visibile', NULL, 100, 'g', 100, 155, 20.5, 0, 8.15, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('724a4082-7444-4fb2-9952-921e272904ef', '1019da81-f566-4265-a17d-0581bc11178b', 'ACETO', NULL, 8, 'g', 8, 0.32, 0.03, 0.05, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('dafd0265-9749-427b-a103-43f18c261e47', '1019da81-f566-4265-a17d-0581bc11178b', 'SENAPE', NULL, 8, 'g', 8, 31.6, 1.13, 1.94, 1.77, 1.98);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fefaaaad-d0cd-462b-8c07-cbd5912365d9', '1019da81-f566-4265-a17d-0581bc11178b', 'PREZZEMOLO, fresco', NULL, 3, 'g', 3, 0.9, 0.11, -0.06, 0.02, 0.15);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1021991e-9eda-4bcb-ad58-6e6be2352121', '1019da81-f566-4265-a17d-0581bc11178b', 'CIPOLLE', NULL, 15, 'g', 15, 4.2, 0.15, 0.86, 0.02, 0.17);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ebe8f7d3-4ec6-42ba-9654-9fc2463fbc15', '1019da81-f566-4265-a17d-0581bc11178b', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('22a87f39-738b-4cbc-94de-0b7347adf9a1', '1019da81-f566-4265-a17d-0581bc11178b', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e6d6bdf1-fb63-4933-8b0c-f4f94d0dac7a', '1019da81-f566-4265-a17d-0581bc11178b', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Toast
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('b4a9c8ae-1196-4709-a2df-419d2ec85c5f', 'Toast', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 100, 263, 259, 14.2, 24.16, 12.53, 1.6);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f4777e67-b259-4b55-b947-6e68f3fe1e47', 'b4a9c8ae-1196-4709-a2df-419d2ec85c5f', 'PANE, TIPO PANCARRE'', BIANCO', NULL, 50, 'g', 50, 127, 4.05, 23.7, 2.1, 1.6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e4bf73a3-564d-4f63-b1ae-8a54da2aa3c4', 'b4a9c8ae-1196-4709-a2df-419d2ec85c5f', 'PROSCIUTTO COTTO', NULL, 25, 'g', 25, 53.75, 4.95, 0.23, 3.68, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ff0e3550-64c9-4cc3-9eb3-6a063ceecf75', 'b4a9c8ae-1196-4709-a2df-419d2ec85c5f', 'SOTTILETTE', NULL, 25, 'g', 25, 82.5, 5.2, 0.23, 6.75, 0);

-- Recipe: Tonno alla griglia
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('fb574296-d386-4c05-95bd-02d247e17897', 'Tonno alla griglia', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 162.4, 330, 203, 32.32, 0.39, 22.19, 0.21);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('37cf2ac5-7b5e-43fd-818a-7b33e832d485', 'fb574296-d386-4c05-95bd-02d247e17897', 'TONNO', NULL, 150, 'g', 150, 238.5, 32.25, 0.15, 12.15, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('12a20344-2192-4727-b28e-c43ee473a9fd', 'fb574296-d386-4c05-95bd-02d247e17897', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ccd3d69e-6863-4e66-b26c-8a5e90e14d99', 'fb574296-d386-4c05-95bd-02d247e17897', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fbe31684-6296-457e-97b9-db5741a3d9b5', 'fb574296-d386-4c05-95bd-02d247e17897', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c236608b-ec7d-4dbd-b666-d39fe7251b67', 'fb574296-d386-4c05-95bd-02d247e17897', 'ERBE AROMATICHE (FOGLIE)', NULL, 2, 'g', 2, 1.76, 0.06, 0.2, 0.05, 0.18);

-- Recipe: Tonno e fagioli
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('f50e148d-c612-4069-896b-a0729472a985', 'Tonno e fagioli', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 120.1, 361, 301, 24.51, 26.46, 16.3, 8.64);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('47942b5c-f75c-488b-bb45-0799bb581210', 'f50e148d-c612-4069-896b-a0729472a985', 'FAGIOLI, secchi', NULL, 50, 'g', 50, 172.5, 11.8, 25.85, 1.25, 8.5);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('04df45b7-c35a-4327-9260-c74c555d1a0c', 'f50e148d-c612-4069-896b-a0729472a985', 'TONNO, SOTT''OLIO, sgocciolato', NULL, 50, 'g', 50, 96, 12.6, 0, 5.05, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e1b7b8ef-38d6-48b8-8551-b8f36ce8b5d1', 'f50e148d-c612-4069-896b-a0729472a985', 'CIPOLLE', NULL, 10, 'g', 10, 2.8, 0.1, 0.57, 0.01, 0.11);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5777f82c-312b-4970-9c59-a60bee74f5c6', 'f50e148d-c612-4069-896b-a0729472a985', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8d80a4ef-7bf0-4a54-9935-07658f8fba49', 'f50e148d-c612-4069-896b-a0729472a985', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Torta di mele
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('cf286ecf-dc75-49e7-a243-380208447374', 'Torta di mele', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 100, 178, 178, 3.28, 28.54, 6.08, 1.64);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('edc96bf0-d840-496f-bd1a-f1aae923cc90', 'cf286ecf-dc75-49e7-a243-380208447374', 'FARINA DI FRUMENTO, TIPO 00', NULL, 17, 'g', 17, 54.91, 1.87, 12.17, 0.12, 0.37);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4293c3fb-64ed-4297-8660-b4505e7ac4b4', 'cf286ecf-dc75-49e7-a243-380208447374', 'ZUCCHERO (Saccarosio)', NULL, 8, 'g', 8, 31.36, 0, 8.36, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b51abbbb-c40c-4455-83e2-f76526e4e695', 'cf286ecf-dc75-49e7-a243-380208447374', 'UOVO DI GALLINA, INTERO', NULL, 8, 'g', 8, 10.24, 0.99, -0.16, 0.7, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b5056faa-3f11-4dcb-bd82-c43728a12dd9', 'cf286ecf-dc75-49e7-a243-380208447374', 'BURRO', NULL, 6, 'g', 6, 45.48, 0.05, 0.07, 5, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('431cd519-3651-41a9-8aca-e57ff7d58912', 'cf286ecf-dc75-49e7-a243-380208447374', 'LATTE DI VACCA, INTERO, PASTORIZZATO', NULL, 5, 'g', 5, 3.2, 0.17, 0.25, 0.18, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('20e5d311-77aa-4879-bf30-c6ea5fe2d03c', 'cf286ecf-dc75-49e7-a243-380208447374', 'MELE, senza buccia', NULL, 55, 'g', 55, 31.35, 0.17, 7.54, 0.06, 1.1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d609a3c9-50d8-4421-bcd7-e08517a47ada', 'cf286ecf-dc75-49e7-a243-380208447374', 'CANNELLA', NULL, 0.5, 'g', 0.5, 1.51, 0.02, 0.28, 0.02, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('32c4cd43-ba1f-45b8-a041-e2747ff5a844', 'cf286ecf-dc75-49e7-a243-380208447374', 'LIMONE, SCORZA', NULL, 0.5, 'g', 0.5, 0.25, 0.01, 0.03, 0, 0.05);

-- Recipe: Torta margherita classica
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'Torta margherita classica', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 100, 319, 319, 6.88, 44.66, 13.36, 0.53);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('83b3e7db-8f09-43ce-b11f-ac126b3f53ad', '86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'FARINA DI FRUMENTO, TIPO 00', NULL, 19, 'g', 19, 61.37, 2.09, 13.6, 0.13, 0.42);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('77038592-46e8-4b06-8b8b-7af3c8150034', '86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'PATATE, FECOLA', NULL, 6, 'g', 6, 20.94, 0.08, 5.49, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d124d32f-caee-4ee8-a105-293728c9f202', '86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'BURRO', NULL, 12, 'g', 12, 90.96, 0.1, 0.13, 10.01, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d12db777-2d9b-4360-b4b8-0f30ee29cccc', '86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'ZUCCHERO (Saccarosio)', NULL, 25, 'g', 25, 98, 0, 26.13, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8233033d-4f69-4ef6-920d-9032f4e0f917', '86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'UOVO DI GALLINA, INTERO', NULL, 37, 'g', 37, 47.36, 4.59, -0.74, 3.22, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('72299337-44a3-4dc5-93b4-383baffdee99', '86b312c4-488d-4c2c-8354-bbba85ec6ed6', 'LIMONE, SCORZA', NULL, 1, 'g', 1, 0.5, 0.02, 0.05, 0, 0.11);

-- Recipe: Tortellini in brodo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('b6c46e88-def2-4afe-aa2f-905a0fef4551', 'Tortellini in brodo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 265, 202, 76, 11.24, 23.78, 7.19, 1.16);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('bc85cd90-b201-41df-ad5b-46a8f870cfbc', 'b6c46e88-def2-4afe-aa2f-905a0fef4551', 'TORTELLINI, freschi, crudi', NULL, 60, 'g', 60, 172.2, 8.1, 23.64, 5.4, 1.14);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e6430618-1f1c-4516-a96c-be07b98eb244', 'b6c46e88-def2-4afe-aa2f-905a0fef4551', 'BRODO DI CARNE E VERDURA', NULL, 200, 'g', 200, 10, 1.46, 0.24, 0.38, 0.02);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('73cd5d2b-bc7f-42ef-bf64-852f479634e0', 'b6c46e88-def2-4afe-aa2f-905a0fef4551', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);

-- Recipe: Uova strapazzate
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('4223a871-8a72-4901-8382-01f0d8d5ce68', 'Uova strapazzate', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 55.15, 109, 198, 6.2, -1, 9.35, 0);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b2a2736e-408c-4f9e-8266-1e843a21080d', '4223a871-8a72-4901-8382-01f0d8d5ce68', 'UOVO DI GALLINA, INTERO', NULL, 50, 'g', 50, 64, 6.2, -1, 4.35, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('26518e1c-2142-4297-ab71-cbee74a013e5', '4223a871-8a72-4901-8382-01f0d8d5ce68', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 5, 'g', 5, 44.95, 0, 0, 5, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('90756bea-c585-41fc-83d6-8b6e4b760016', '4223a871-8a72-4901-8382-01f0d8d5ce68', 'SALE da cucina', NULL, 0.15, 'g', 0.15, 0, 0, 0, 0, 0);

-- Recipe: Uovo sodo
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('b1873423-ea7c-4c7b-9d9c-4c798b5d7887', 'Uovo sodo', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 50, 64, 128, 6.2, -1, 4.35, 0);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8d36acec-c6c0-4153-a6c2-7c4a3c293cbe', 'b1873423-ea7c-4c7b-9d9c-4c798b5d7887', 'UOVO DI GALLINA, INTERO', NULL, 50, 'g', 50, 64, 6.2, -1, 4.35, 0);

-- Recipe: Verdura cotta, condita
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'Verdura cotta, condita', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 215.3, 146, 68, 4.34, 6.03, 10.86, 4.13);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8c1cff67-ed60-4b20-86c4-f3cb279dac9b', '5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'SPINACI', NULL, 66, 'g', 66, 23.1, 2.24, 1.98, 0.46, 1.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('59684f0a-d2bd-434b-bd5a-876339c1102a', '5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'BIETA', NULL, 67, 'g', 67, 12.73, 0.87, 1.88, 0.07, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('1b041716-8128-4bee-bb17-da97ad52762e', '5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'CICORIA CATALOGNA', NULL, 67, 'g', 67, 20.1, 1.21, 2.14, 0.34, 2.08);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e3573351-b014-4bd0-8352-3e20f627e23e', '5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a30e432b-fc1e-4a17-952b-b50f8823b45c', '5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'ACETO', NULL, 5, 'g', 5, 0.2, 0.02, 0.03, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6154297c-1d71-4d9b-b959-9704db202554', '5a1eb4be-ecf1-44ad-8dfd-845cee8e7de7', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Verdura cruda mista, condita
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('4bb4e2bc-c260-40f7-bf51-62e28545801b', 'Verdura cruda mista, condita', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 195.3, 127, 65, 2.46, 4.54, 10.36, 3.56);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('92c56ebc-7f0b-428f-b5a4-c32cf72b1e4e', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'INSALATA, NS', NULL, 80, 'g', 80, 15.2, 1.2, 1.2, 0.24, 1.68);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ed7e40cc-483c-4088-a367-c6b249fe693b', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'POMODORI, DA INSALATA', NULL, 16, 'g', 16, 3.04, 0.19, 0.45, 0.03, 0.18);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('622d4c22-97cd-428d-bb22-c459adbda47a', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'SEDANO', NULL, 16, 'g', 16, 3.68, 0.37, 0.38, 0.03, 0.26);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('82409e5f-86f1-4f78-870d-a0f2f708a69f', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'PEPERONI, DOLCI', NULL, 17, 'g', 17, 4.42, 0.15, 0.71, 0.05, 0.32);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('143046b1-7f78-4a03-a6d2-91a5fbb5f268', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'RAVANELLI', NULL, 17, 'g', 17, 2.21, 0.14, 0.31, 0.02, 0.22);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b1905add-e8b3-434d-8c8d-4c3ff2939418', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'CAROTE', NULL, 17, 'g', 17, 6.63, 0.19, 1.29, 0, 0.53);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3e5c5f1e-78ea-4bef-ba67-eaa9e2f8fe9f', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'FINOCCHIO', NULL, 17, 'g', 17, 2.21, 0.2, 0.17, 0, 0.37);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5e12dff5-4bed-41c9-a928-d8baa466950d', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ae2c60ae-5756-4355-a270-924dd1d6d524', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'ACETO', NULL, 5, 'g', 5, 0.2, 0.02, 0.03, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('483dde21-ca2c-460e-b309-28f3d3923a6d', '4bb4e2bc-c260-40f7-bf51-62e28545801b', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Verdure grigliate (melanzane, peperoni, zucchine e radicchio)
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'Verdure grigliate (melanzane, peperoni, zucchine e radicchio)', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 210.3, 129, 61, 2.35, 4.9, 10.29, 4.4);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8dab819a-9475-4800-ab05-7634d0709a9c', 'c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'MELANZANE', NULL, 50, 'g', 50, 10, 0.55, 1.3, 0.05, 1.3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('163a7c64-b43b-4f1f-abdd-00316d6998d8', 'c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'PEPERONI, DOLCI', NULL, 50, 'g', 50, 13, 0.45, 2.1, 0.15, 0.95);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('b37700e5-b913-49f2-96e8-8d7f8bd0f5ed', 'c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'RADICCHIO ROSSO', NULL, 50, 'g', 50, 9, 0.7, 0.8, 0.05, 1.5);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9aae8ca7-d4ef-4519-b7a3-b60459256efe', 'c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'ZUCCHINE', NULL, 50, 'g', 50, 7, 0.65, 0.7, 0.05, 0.65);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('542964a2-afdf-4365-b088-2c76c545557d', 'c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8e90cff6-48fa-48f9-8aaa-cec54c405d8d', 'c00a4a6e-f3b1-429b-9894-b9b7a330f09e', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);

-- Recipe: Verze in padella
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'Verze in padella', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 265.4, 143, 72, 4.41, 5.61, 10.42, 4.95);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f3d3aa0b-8816-4b4b-9f7a-22468854d6aa', 'e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'CAVOLO CAPPUCCIO, VERDE', NULL, 200, 'g', 200, 48, 4.2, 5, 0.2, 5.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ed5906c7-a19d-4ee6-b75b-a06d3e9d51cf', 'e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'BRODO VEGETALE', NULL, 50, 'g', 50, 3, 0.15, 0.15, 0.2, -1);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('21169575-b847-43d6-a9ac-bd929cb0bed9', 'e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('43c6ee82-e043-40b8-b60b-3b889c0b033d', 'e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'AGLIO, fresco', NULL, 5, 'g', 5, 2.25, 0.05, 0.42, 0.03, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fb8e8ddd-aa31-47af-9e86-e1613b206825', 'e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a358ff82-ad8a-44b8-b42a-21c19d324166', 'e6269f2a-0de3-4734-b1a3-e27b98eae0e7', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Yogurt bianco intero con miele
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('2711499b-f430-453f-afc6-b68dfada1a77', 'Yogurt bianco intero con miele', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 145, 143, 99, 4.87, 21.44, 4.88, 0);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3f932825-544a-4ef3-8d3d-9a66fb8e6d33', '2711499b-f430-453f-afc6-b68dfada1a77', 'YOGURT DI LATTE INTERO', NULL, 125, 'g', 125, 82.5, 4.75, 5.38, 4.88, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9bfe7a7a-fdb8-4e25-8aaf-68ac705b0ba9', '2711499b-f430-453f-afc6-b68dfada1a77', 'MIELE', NULL, 20, 'g', 20, 60.8, 0.12, 16.06, 0, 0);

-- Recipe: Zucchine lessate o al vapore, condite
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('d4739cbb-7504-4e7f-8dc1-8ea3c7581dd3', 'Zucchine lessate o al vapore, condite', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 215.4, 120, 56, 2.8, 2.74, 10.22, 2.88);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7cb6ac10-6913-4ac0-aae6-5828a5f72f7e', 'd4739cbb-7504-4e7f-8dc1-8ea3c7581dd3', 'ZUCCHINE', NULL, 200, 'g', 200, 28, 2.6, 2.8, 0.2, 2.6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5c7d9bd0-15af-468c-ac36-5ae5b705eaf5', 'd4739cbb-7504-4e7f-8dc1-8ea3c7581dd3', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c88953dd-9a3f-4dfb-8acb-58da297d3b2c', 'd4739cbb-7504-4e7f-8dc1-8ea3c7581dd3', 'PREZZEMOLO, fresco', NULL, 5, 'g', 5, 1.5, 0.19, -0.1, 0.03, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8fdd2abd-91b7-4b5e-af5a-63f7d77c87dd', 'd4739cbb-7504-4e7f-8dc1-8ea3c7581dd3', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5aad2843-3bef-4bde-b4f8-f5911dafbede', 'd4739cbb-7504-4e7f-8dc1-8ea3c7581dd3', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Zucchine trifolate
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('45e2c4b6-80b9-442b-94e8-8041b772b515', 'Zucchine trifolate', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 220.4, 122, 55, 2.85, 3.16, 10.25, 3);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('166c5a24-76f6-455d-be08-d4494465be10', '45e2c4b6-80b9-442b-94e8-8041b772b515', 'ZUCCHINE', NULL, 200, 'g', 200, 28, 2.6, 2.8, 0.2, 2.6);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('104c1771-4177-4e77-ade0-add152a0dd92', '45e2c4b6-80b9-442b-94e8-8041b772b515', 'AGLIO, fresco', NULL, 5, 'g', 5, 2.25, 0.05, 0.42, 0.03, 0.12);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('d5eda5f8-8138-465e-aea7-b741414bd9b6', '45e2c4b6-80b9-442b-94e8-8041b772b515', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('9f15eb16-2b4b-4b25-bd85-b138f16f13e4', '45e2c4b6-80b9-442b-94e8-8041b772b515', 'PREZZEMOLO, fresco', NULL, 5, 'g', 5, 1.5, 0.19, -0.1, 0.03, 0.25);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('ddfb8f73-b8b9-48b2-9692-d3584aad5883', '45e2c4b6-80b9-442b-94e8-8041b772b515', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('31945bc7-86d4-4d1d-9934-5933a8323159', '45e2c4b6-80b9-442b-94e8-8041b772b515', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Zuppa di cipolle
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('7c35d24e-fb68-432e-99d4-d20795a2b448', 'Zuppa di cipolle', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 365.1, 254, 70, 9.6, 15.37, 17.2, 2.35);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('12a75638-86eb-4820-9762-46607897d045', '7c35d24e-fb68-432e-99d4-d20795a2b448', 'CIPOLLE', NULL, 200, 'g', 200, 56, 2, 11.4, 0.2, 2.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('185d508b-8410-4c44-8cfb-474b7ca6527e', '7c35d24e-fb68-432e-99d4-d20795a2b448', 'BRODO DI CARNE E VERDURA', NULL, 125, 'g', 125, 6.25, 0.91, 0.15, 0.24, 0.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('7b9262ff-0b3b-4ae6-b7c8-834d51a61b5b', '7c35d24e-fb68-432e-99d4-d20795a2b448', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('377ea0bb-8d46-4cad-919a-f629f1aff9b9', '7c35d24e-fb68-432e-99d4-d20795a2b448', 'FONTINA', NULL, 25, 'g', 25, 85.75, 6.13, 0.2, 6.73, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('83825d54-f8c2-497e-b834-9310ac2bcb83', '7c35d24e-fb68-432e-99d4-d20795a2b448', 'FARINA DI FRUMENTO, TIPO 00', NULL, 5, 'g', 5, 16.15, 0.55, 3.58, 0.04, 0.11);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a3fb6ed6-009f-4044-8496-549e663a2dbe', '7c35d24e-fb68-432e-99d4-d20795a2b448', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Zuppa di legumi
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('f980c299-07f5-4ad7-9662-bd889aa18e7a', 'Zuppa di legumi', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 290.1, 317, 109, 15.87, 31.05, 13.18, 9.41);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5acf7a40-0b2c-4dbf-a732-457fb67862b7', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'LENTICCHIE, secche', NULL, 20, 'g', 20, 70.4, 5, 10.8, 0.5, 2.74);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2aa2d933-a2bd-4738-99c5-63847334b9c7', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'FAGIOLI, secchi', NULL, 10, 'g', 10, 34.5, 2.36, 5.17, 0.25, 1.7);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('df5b2c3c-20e3-4a0c-baf3-d56d6b72dc34', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'CECI, secchi', NULL, 10, 'g', 10, 36.3, 2.18, 5.43, 0.49, 1.38);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('592c05ef-d515-43c7-98b1-c78110f43af1', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'PISELLI, secchi', NULL, 10, 'g', 10, 33.7, 2.17, 5.36, 0.2, 1.57);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('e64e0dc8-9df9-492f-b07b-1c34f158e03c', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'CIPOLLE', NULL, 20, 'g', 20, 5.6, 0.2, 1.14, 0.02, 0.22);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('33391ed0-6e5f-48cc-86e7-9ea7695f3102', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'SEDANO', NULL, 20, 'g', 20, 4.6, 0.46, 0.48, 0.04, 0.32);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fb4492d4-8e52-4663-b53a-817e5f9cdde4', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'CAVOLO CAPPUCCIO, VERDE', NULL, 20, 'g', 20, 4.8, 0.42, 0.5, 0.02, 0.58);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2860e974-4571-488f-96ad-777ea4361e71', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'CAROTE', NULL, 20, 'g', 20, 7.8, 0.22, 1.52, 0, 0.62);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('76b0643e-00d6-472c-82d0-aad8c7963935', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'BIETA', NULL, 20, 'g', 20, 3.8, 0.26, 0.56, 0.02, 0.24);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4f8a4fdc-5c23-428c-8c76-f05cdfacb46c', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('25da4f21-f2f6-4d6c-a4e6-39a13490254c', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('f8e22294-797e-4b7f-99c1-5ade6fb224c8', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('64a68ed1-a197-4064-84e5-93c4d3b2e0e3', 'f980c299-07f5-4ad7-9662-bd889aa18e7a', 'BRODO DI CARNE E VERDURA', NULL, 125, 'g', 125, 6.25, 0.91, 0.15, 0.24, 0.01);

-- Recipe: Zuppa di legumi e cereali
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'Zuppa di legumi e cereali', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 275.1, 394, 143, 17.4, 48.19, 13.52, 11.22);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6a7b76c3-8c84-42fa-92c6-27f30d226164', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'LENTICCHIE, secche', NULL, 10, 'g', 10, 35.2, 2.5, 5.4, 0.25, 1.37);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('0ab631f6-6df8-42e4-b8c8-396b283afb8f', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'FAGIOLI, secchi', NULL, 20, 'g', 20, 69, 4.72, 10.34, 0.5, 3.4);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('713c534c-80d6-4cb9-8312-8ec0d0e12152', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'CECI, secchi', NULL, 10, 'g', 10, 36.3, 2.18, 5.43, 0.49, 1.38);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4ef30b83-5861-4cf5-8095-583f4fa4184d', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'PISELLI, secchi', NULL, 10, 'g', 10, 33.7, 2.17, 5.36, 0.2, 1.57);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('68003ec3-16ac-4b7c-bbf9-6c96c7fb6462', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'ORZO, PERLATO, CRUDO', NULL, 25, 'g', 25, 86.5, 2.35, 18.43, 0.38, 2.3);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3a7c4457-ec67-40ef-84bb-765b4aef953c', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'CIPOLLE', NULL, 20, 'g', 20, 5.6, 0.2, 1.14, 0.02, 0.22);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8a2f996f-2b85-45c1-8402-77f14e8cf34c', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'SEDANO', NULL, 20, 'g', 20, 4.6, 0.46, 0.48, 0.04, 0.32);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4b24979a-1a8a-413a-8c90-8ce8aef13331', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'CAROTE', NULL, 20, 'g', 20, 7.8, 0.22, 1.52, 0, 0.62);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('591ce647-350c-421e-8ad9-0b8796072478', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3c6b03f5-5b3f-4f0b-9734-aebdcd5d7615', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fab1d662-51c4-4ea0-a1d5-7b24cb33603b', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('2f82d755-90e6-471c-a2a1-ee1a98c625f3', '4e5cbdb5-1296-4673-bb74-18da34ccff8a', 'BRODO DI CARNE E VERDURA', NULL, 125, 'g', 125, 6.25, 0.91, 0.15, 0.24, 0.01);

-- Recipe: Zuppa di pesce (con crostacei)
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'Zuppa di pesce (con crostacei)', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 351.4, 376, 96, 40.22, 16.91, 16.46, 2.13);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('025f74ea-6a77-408d-8c6d-70a9dfdde5da', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'PESCE, NS, CON LISCA', NULL, 150, 'g', 150, 157.5, 26.14, 1.1, 5.5, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('fa12c1f2-31bf-493e-b3e2-6e2feb102954', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'CROSTACEI, NS', NULL, 75, 'g', 75, 53.25, 10.8, 1.25, 0.63, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('27d32cd1-7ae2-4210-912a-c555f1500dc3', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'PREZZEMOLO, fresco', NULL, 4, 'g', 4, 1.2, 0.15, -0.08, 0.02, 0.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('c18f7995-346e-4657-a8c5-8bdb6a2f0c6e', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'CIPOLLE', NULL, 30, 'g', 30, 8.4, 0.3, 1.71, 0.03, 0.33);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('34e41661-4032-4c7c-8a69-782ded481a3b', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'AGLIO, fresco', NULL, 2, 'g', 2, 0.9, 0.02, 0.17, 0.01, 0.05);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('25eb747c-b95b-4e5e-96f5-7b40d3548384', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'SEDANO', NULL, 20, 'g', 20, 4.6, 0.46, 0.48, 0.04, 0.32);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('3628e02e-d5f7-4ad1-801b-6506126d54d7', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5acd5792-8707-4ee6-83d2-ca333c7706a5', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'POMODORO, CONSERVA (sostanza secca 30%)', NULL, 60, 'g', 60, 60, 2.34, 12.24, 0.24, 1.2);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('62e57bde-fd03-485b-8f63-55c55649a757', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'SALE da cucina', NULL, 0.3, 'g', 0.3, 0, 0, 0, 0, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('a458c8e3-821e-4672-ae92-42e5365b109b', 'ac9cf254-ef60-463c-83d1-6a637f1ccde7', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

-- Recipe: Zuppa di porri, verza e patate
INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)
VALUES ('fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'Zuppa di porri, verza e patate', true, true, '9b1cd123-6145-4763-89ac-6e629a4b4b6c', 'easy', 'lunch', 15, 0, 2, 390.1, 215, 55, 7.85, 16.79, 11.89, 6.64);

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('072fe6ed-f568-4638-b22d-b4704208bf6a', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'PORRI', NULL, 100, 'g', 100, 35, 2.1, 5.2, 0.1, 2.9);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('6ced1ba5-63a4-42f2-bd63-796874343de5', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'CAVOLO CAPPUCCIO, VERDE', NULL, 100, 'g', 100, 24, 2.1, 2.5, 0.1, 2.9);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('447712c9-289e-448f-a40e-2be5ace102db', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'PATATE', NULL, 50, 'g', 50, 40, 1.05, 9, 0.05, 0.8);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('4b3ca184-88ec-4a11-b141-5b78712cc411', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'BRODO DI CARNE E VERDURA', NULL, 125, 'g', 125, 6.25, 0.91, 0.15, 0.24, 0.01);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('5f36aeb2-f4f5-422c-ae38-ef621d98fc5d', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'OLIO DI OLIVA EXTRAVERGINE', NULL, 10, 'g', 10, 89.9, 0, 0, 9.99, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('144e3b8d-1898-4202-a59b-aac098aa2410', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'PARMIGIANO', NULL, 5, 'g', 5, 19.35, 1.68, -0.1, 1.41, 0);
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)
VALUES ('8136761c-6dd2-4ba3-bc5b-8d3f64816f73', 'fd2a1bbe-aed7-4c38-8efd-f93dd2f0410f', 'PEPE NERO', NULL, 0.1, 'g', 0.1, 0.27, 0.01, 0.04, 0, 0.03);

COMMIT;
