-- Location: supabase/migrations/20250923200000_recipe_management_module.sql
-- Schema Analysis: Existing food_items, meal_entries, meal_foods tables for individual ingredients and meals
-- Integration Type: NEW_MODULE - Adding recipe management functionality
-- Dependencies: References existing user_profiles and food_items tables

-- =============================================
-- RECIPE MANAGEMENT MODULE MIGRATION
-- =============================================

-- 1. Custom Types
CREATE TYPE public.recipe_difficulty AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE public.recipe_category AS ENUM ('breakfast', 'lunch', 'dinner', 'snack', 'dessert', 'beverage', 'supplement');

-- 2. Core Recipe Table
CREATE TABLE public.recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    instructions TEXT,
    prep_time_minutes INTEGER DEFAULT 0,
    cook_time_minutes INTEGER DEFAULT 0,
    total_time_minutes INTEGER GENERATED ALWAYS AS (prep_time_minutes + cook_time_minutes) STORED,
    servings INTEGER DEFAULT 1,
    difficulty public.recipe_difficulty DEFAULT 'easy'::public.recipe_difficulty,
    category public.recipe_category DEFAULT 'snack'::public.recipe_category,
    image_url TEXT,
    is_public BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Nutritional summary (calculated from ingredients)
    total_calories INTEGER DEFAULT 0,
    total_protein_g NUMERIC(8,2) DEFAULT 0,
    total_carbs_g NUMERIC(8,2) DEFAULT 0,
    total_fat_g NUMERIC(8,2) DEFAULT 0,
    total_fiber_g NUMERIC(8,2) DEFAULT 0
);

-- 3. Recipe Ingredients Junction Table
CREATE TABLE public.recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    ingredient_name TEXT NOT NULL, -- Can reference food_items.name or be custom
    food_item_id UUID REFERENCES public.food_items(id) ON DELETE SET NULL, -- Optional link to existing food items
    quantity NUMERIC(8,2) NOT NULL DEFAULT 0,
    unit TEXT DEFAULT 'g', -- grams, ml, pieces, etc.
    weight_grams NUMERIC(8,2) NOT NULL DEFAULT 0, -- For nutritional calculations
    calories NUMERIC(8,2) DEFAULT 0,
    protein_g NUMERIC(8,2) DEFAULT 0,
    carbs_g NUMERIC(8,2) DEFAULT 0,
    fat_g NUMERIC(8,2) DEFAULT 0,
    fiber_g NUMERIC(8,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Recipe Tags for categorization
CREATE TABLE public.recipe_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    tag_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(recipe_id, tag_name)
);

-- 5. Recipe Favorites (User-specific)
CREATE TABLE public.recipe_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(recipe_id, user_id)
);

-- 6. Essential Indexes
CREATE INDEX idx_recipes_created_by ON public.recipes(created_by);
CREATE INDEX idx_recipes_category ON public.recipes(category);
CREATE INDEX idx_recipes_difficulty ON public.recipes(difficulty);
CREATE INDEX idx_recipes_is_public ON public.recipes(is_public);
CREATE INDEX idx_recipes_is_verified ON public.recipes(is_verified);
CREATE INDEX idx_recipes_created_at ON public.recipes(created_at);

CREATE INDEX idx_recipe_ingredients_recipe_id ON public.recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_food_item_id ON public.recipe_ingredients(food_item_id);

CREATE INDEX idx_recipe_tags_recipe_id ON public.recipe_tags(recipe_id);
CREATE INDEX idx_recipe_tags_tag_name ON public.recipe_tags(tag_name);

CREATE INDEX idx_recipe_favorites_recipe_id ON public.recipe_favorites(recipe_id);
CREATE INDEX idx_recipe_favorites_user_id ON public.recipe_favorites(user_id);

-- 7. Functions for nutritional calculations
CREATE OR REPLACE FUNCTION public.calculate_recipe_nutrition(recipe_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update recipe totals based on ingredients
    UPDATE public.recipes 
    SET 
        total_calories = COALESCE((
            SELECT SUM(ri.calories) 
            FROM public.recipe_ingredients ri 
            WHERE ri.recipe_id = recipe_uuid
        ), 0),
        total_protein_g = COALESCE((
            SELECT SUM(ri.protein_g) 
            FROM public.recipe_ingredients ri 
            WHERE ri.recipe_id = recipe_uuid
        ), 0),
        total_carbs_g = COALESCE((
            SELECT SUM(ri.carbs_g) 
            FROM public.recipe_ingredients ri 
            WHERE ri.recipe_id = recipe_uuid
        ), 0),
        total_fat_g = COALESCE((
            SELECT SUM(ri.fat_g) 
            FROM public.recipe_ingredients ri 
            WHERE ri.recipe_id = recipe_uuid
        ), 0),
        total_fiber_g = COALESCE((
            SELECT SUM(ri.fiber_g) 
            FROM public.recipe_ingredients ri 
            WHERE ri.recipe_id = recipe_uuid
        ), 0),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = recipe_uuid;
END;
$$;

-- 8. Trigger to update recipe nutrition when ingredients change
CREATE OR REPLACE FUNCTION public.update_recipe_nutrition_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM public.calculate_recipe_nutrition(OLD.recipe_id);
        RETURN OLD;
    ELSE
        PERFORM public.calculate_recipe_nutrition(NEW.recipe_id);
        RETURN NEW;
    END IF;
END;
$$;

CREATE TRIGGER recipe_ingredients_nutrition_update
    AFTER INSERT OR UPDATE OR DELETE ON public.recipe_ingredients
    FOR EACH ROW
    EXECUTE FUNCTION public.update_recipe_nutrition_trigger();

-- 9. Updated timestamp trigger
CREATE TRIGGER recipes_updated_at_trigger
    BEFORE UPDATE ON public.recipes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at();

-- 10. Enable RLS
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_favorites ENABLE ROW LEVEL SECURITY;

-- 11. RLS Policies

-- Recipes: Public read, authenticated users can create/manage own
CREATE POLICY "public_can_read_public_recipes"
ON public.recipes
FOR SELECT
TO public
USING (is_public = true);

CREATE POLICY "users_manage_own_recipes"
ON public.recipes
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "authenticated_can_create_recipes"
ON public.recipes
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

-- Recipe Ingredients: Access through recipe ownership or public recipe viewing
CREATE POLICY "users_access_recipe_ingredients"
ON public.recipe_ingredients
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.recipes r 
        WHERE r.id = recipe_id 
        AND (r.created_by = auth.uid() OR r.is_public = true)
    )
);

CREATE POLICY "public_can_read_public_recipe_ingredients"
ON public.recipe_ingredients
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.recipes r 
        WHERE r.id = recipe_id 
        AND r.is_public = true
    )
);

-- Recipe Tags: Same as ingredients
CREATE POLICY "users_access_recipe_tags"
ON public.recipe_tags
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.recipes r 
        WHERE r.id = recipe_id 
        AND (r.created_by = auth.uid() OR r.is_public = true)
    )
);

CREATE POLICY "public_can_read_public_recipe_tags"
ON public.recipe_tags
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.recipes r 
        WHERE r.id = recipe_id 
        AND r.is_public = true
    )
);

-- Recipe Favorites: Users manage their own favorites
CREATE POLICY "users_manage_own_recipe_favorites"
ON public.recipe_favorites
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 12. Insert Recipe Data
DO $$
DECLARE
    system_user_id UUID;
    recipe_id UUID;
    ingredient_data JSONB;
    tag_name TEXT;
    
    -- Recipe data array
    recipes_data JSONB := '[
        {
            "title": "Affogato al caffè con due palline di fiordilatte",
            "category": "dessert",
            "difficulty": "easy",
            "prep_time": 5,
            "servings": 1,
            "tags": ["Italian", "Coffee", "Dessert", "Quick"],
            "ingredients": [
                {"name": "CAFFE MOKA, in tazza", "quantity": 50.0, "weight": 50, "kcal": 2, "unit": "ml"},
                {"name": "GELATO ALLA PANNA", "quantity": 100.0, "weight": 100, "kcal": 218, "unit": "g"}
            ]
        },
        {
            "title": "Alici marinate",
            "category": "lunch",
            "difficulty": "medium", 
            "prep_time": 30,
            "servings": 2,
            "tags": ["Italian", "Seafood", "Marinated", "Mediterranean"],
            "ingredients": [
                {"name": "ACCIUGHE o ALICI", "quantity": 150.0, "weight": 150, "kcal": 96, "unit": "g"},
                {"name": "OLIO DI SEMI DI MAIS", "quantity": 10.0, "weight": 10, "kcal": 899, "unit": "ml"},
                {"name": "ACETO", "quantity": 9.0, "weight": 9, "kcal": 4, "unit": "ml"}
            ]
        },
        {
            "title": "Arrosticini di agnello",
            "category": "dinner",
            "difficulty": "medium",
            "prep_time": 15,
            "cook_time": 20,
            "servings": 2,
            "tags": ["Italian", "Grilled", "Lamb", "Herbs"],
            "ingredients": [
                {"name": "AGNELLO, CARNE SEMIGRASSA", "quantity": 100.0, "weight": 100, "kcal": 211, "unit": "g"},
                {"name": "ROSMARINO, secco", "quantity": 1.0, "weight": 1, "kcal": 366, "unit": "g"},
                {"name": "ALLORO, secco", "quantity": 1.0, "weight": 1, "kcal": 341, "unit": "g"}
            ]
        },
        {
            "title": "Arrosto di vitello",
            "category": "dinner",
            "difficulty": "medium",
            "prep_time": 20,
            "cook_time": 45,
            "servings": 3,
            "tags": ["Italian", "Roasted", "Veal", "Herbs"],
            "ingredients": [
                {"name": "BOVINO, VITELLONE, sottofesa, senza grasso visibile", "quantity": 100.0, "weight": 100, "kcal": 111, "unit": "g"},
                {"name": "BRODO VEGETALE", "quantity": 50.0, "weight": 50, "kcal": 6, "unit": "ml"},
                {"name": "OLIO DI OLIVA EXTRAVERGINE", "quantity": 10.0, "weight": 10, "kcal": 899, "unit": "ml"},
                {"name": "ROSMARINO, fresco", "quantity": 3.0, "weight": 3, "kcal": 111, "unit": "g"}
            ]
        },
        {
            "title": "Asparagi lessati e conditi", 
            "category": "lunch",
            "difficulty": "easy",
            "prep_time": 5,
            "cook_time": 10,
            "servings": 2,
            "tags": ["Italian", "Vegetables", "Healthy", "Quick"],
            "ingredients": [
                {"name": "ASPARAGI DI CAMPO", "quantity": 200.0, "weight": 200, "kcal": 33, "unit": "g"},
                {"name": "OLIO DI OLIVA EXTRAVERGINE", "quantity": 10.0, "weight": 10, "kcal": 899, "unit": "ml"}
            ]
        },
        {
            "title": "Banana zucchero e limone",
            "category": "dessert",
            "difficulty": "easy", 
            "prep_time": 5,
            "servings": 1,
            "tags": ["Italian", "Fruit", "Sweet", "Quick"],
            "ingredients": [
                {"name": "BANANA", "quantity": 150.0, "weight": 150, "kcal": 69, "unit": "g"},
                {"name": "ZUCCHERO (Saccarosio)", "quantity": 5.0, "weight": 5, "kcal": 392, "unit": "g"},
                {"name": "SUCCO DI LIMONE, fresco", "quantity": 5.0, "weight": 5, "kcal": 6, "unit": "ml"}
            ]
        },
        {
            "title": "Besciamella",
            "category": "supplement",
            "difficulty": "medium",
            "prep_time": 5,
            "cook_time": 10,
            "servings": 4,
            "tags": ["Italian", "Sauce", "Creamy", "Base"],
            "ingredients": [
                {"name": "BURRO", "quantity": 8.0, "weight": 8, "kcal": 758, "unit": "g"},
                {"name": "FARINA DI FRUMENTO, TIPO 00", "quantity": 8.0, "weight": 8, "kcal": 348, "unit": "g"},
                {"name": "LATTE DI VACCA, INTERO PASTORIZZATO", "quantity": 85.0, "weight": 85, "kcal": 64, "unit": "ml"}
            ]
        },
        {
            "title": "Bistecca alla pizzaiola",
            "category": "dinner",
            "difficulty": "medium",
            "prep_time": 10,
            "cook_time": 25,
            "servings": 2,
            "tags": ["Italian", "Beef", "Tomato", "Classic"],
            "ingredients": [
                {"name": "BOVINO, VITELLONE, TAGLI DI CARNE MAGRA, senza grasso visibile", "quantity": 100.0, "weight": 100, "kcal": 108, "unit": "g"},
                {"name": "POMODORI, PELATI, IN SCATOLA CON LIQUIDO", "quantity": 80.0, "weight": 80, "kcal": 22, "unit": "g"},
                {"name": "OLIO DI OLIVA EXTRAVERGINE", "quantity": 10.0, "weight": 10, "kcal": 899, "unit": "ml"},
                {"name": "AGLIO, fresco", "quantity": 1.0, "weight": 1, "kcal": 45, "unit": "g"}
            ]
        },
        {
            "title": "Bistecca di cavallo ai ferri",
            "category": "dinner",
            "difficulty": "medium",
            "prep_time": 5,
            "cook_time": 15,
            "servings": 2,
            "tags": ["Italian", "Grilled", "Meat", "Herbs"],
            "ingredients": [
                {"name": "CAVALLO, senza grasso visibile", "quantity": 100.0, "weight": 100, "kcal": 145, "unit": "g"},
                {"name": "OLIO DI OLIVA EXTRAVERGINE", "quantity": 10.0, "weight": 10, "kcal": 899, "unit": "ml"},
                {"name": "ERBE AROMATICHE (FOGLIE)", "quantity": 2.0, "weight": 2, "kcal": 88, "unit": "g"}
            ]
        },
        {
            "title": "Bistecca di manzo ai ferri",
            "category": "dinner",
            "difficulty": "medium",
            "prep_time": 5,
            "cook_time": 15,
            "servings": 2,
            "tags": ["Italian", "Grilled", "Beef", "Herbs"],
            "ingredients": [
                {"name": "BOVINO, VITELLONE, TAGLI DI CARNE MAGRA, senza grasso visibile", "quantity": 100.0, "weight": 100, "kcal": 108, "unit": "g"},
                {"name": "OLIO DI OLIVA EXTRAVERGINE", "quantity": 10.0, "weight": 10, "kcal": 899, "unit": "ml"},
                {"name": "ERBE AROMATICHE (FOGLIE)", "quantity": 2.0, "weight": 2, "kcal": 88, "unit": "g"}
            ]
        }
    ]'::JSONB;
    
    recipe_item JSONB;
    ingredient_item JSONB;
    tag_item TEXT;
BEGIN
    -- Try to get the first user as system user, otherwise use null
    SELECT id INTO system_user_id FROM public.user_profiles LIMIT 1;
    
    -- Loop through each recipe in the array
    FOR recipe_item IN SELECT * FROM jsonb_array_elements(recipes_data)
    LOOP
        -- Insert recipe
        INSERT INTO public.recipes (
            id, title, category, difficulty, prep_time_minutes, cook_time_minutes, 
            servings, is_public, is_verified, created_by
        ) VALUES (
            gen_random_uuid(),
            recipe_item->>'title',
            CASE 
                WHEN recipe_item->>'category' = 'dessert' THEN 'dessert'::public.recipe_category
                WHEN recipe_item->>'category' = 'lunch' THEN 'lunch'::public.recipe_category  
                WHEN recipe_item->>'category' = 'dinner' THEN 'dinner'::public.recipe_category
                WHEN recipe_item->>'category' = 'supplement' THEN 'supplement'::public.recipe_category
                ELSE 'snack'::public.recipe_category
            END,
            CASE 
                WHEN recipe_item->>'difficulty' = 'easy' THEN 'easy'::public.recipe_difficulty
                WHEN recipe_item->>'difficulty' = 'medium' THEN 'medium'::public.recipe_difficulty
                WHEN recipe_item->>'difficulty' = 'hard' THEN 'hard'::public.recipe_difficulty
                ELSE 'easy'::public.recipe_difficulty
            END,
            COALESCE((recipe_item->>'prep_time')::INTEGER, 0),
            COALESCE((recipe_item->>'cook_time')::INTEGER, 0),
            COALESCE((recipe_item->>'servings')::INTEGER, 1),
            true, -- is_public
            true, -- is_verified (system recipes)
            system_user_id
        ) RETURNING id INTO recipe_id;
        
        -- Insert ingredients
        FOR ingredient_item IN SELECT * FROM jsonb_array_elements(recipe_item->'ingredients')
        LOOP
            INSERT INTO public.recipe_ingredients (
                recipe_id, ingredient_name, quantity, unit, weight_grams, calories
            ) VALUES (
                recipe_id,
                ingredient_item->>'name',
                (ingredient_item->>'quantity')::NUMERIC,
                COALESCE(ingredient_item->>'unit', 'g'),
                (ingredient_item->>'weight')::NUMERIC,
                (ingredient_item->>'kcal')::NUMERIC
            );
        END LOOP;
        
        -- Insert tags
        FOR tag_item IN SELECT * FROM jsonb_array_elements_text(recipe_item->'tags')
        LOOP
            INSERT INTO public.recipe_tags (recipe_id, tag_name)
            VALUES (recipe_id, tag_item);
        END LOOP;
        
        -- Calculate nutrition for this recipe
        PERFORM public.calculate_recipe_nutrition(recipe_id);
    END LOOP;
    
    RAISE NOTICE 'Successfully inserted % Italian recipes', jsonb_array_length(recipes_data);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting recipes: %', SQLERRM;
END $$;

-- Verify data insertion
DO $$
DECLARE
    recipe_count INTEGER;
    ingredient_count INTEGER;
    tag_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO recipe_count FROM public.recipes;
    SELECT COUNT(*) INTO ingredient_count FROM public.recipe_ingredients;  
    SELECT COUNT(*) INTO tag_count FROM public.recipe_tags;
    
    RAISE NOTICE 'Recipes inserted: %', recipe_count;
    RAISE NOTICE 'Recipe ingredients inserted: %', ingredient_count;
    RAISE NOTICE 'Recipe tags inserted: %', tag_count;
END $$;