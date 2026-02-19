-- Schema Analysis: Existing partial food structure with food_items, meal_foods, recipes
-- Integration Type: Extension - Adding comprehensive nutritional data to existing food system
-- Dependencies: Existing food_items, user_profiles tables

-- 1. Create food category enum for standardized categories
CREATE TYPE public.food_category_code AS ENUM (
    '1001', -- Potatoes & tubers
    '2001', -- Leafy vegetables
    '2003', -- Root vegetables
    '2004', -- Cabbages
    '2005', -- Bulb vegetables
    '2006', -- Vegetable juices
    '2007', -- Mushrooms
    '2008', -- Salad vegetables
    '2009', -- Fruiting vegetables
    '2010', -- Preserved vegetables
    '2011', -- Seaweeds
    '3000', -- Mixed vegetables
    '3001', -- Pulses
    '3002', -- Pulse flours
    '3004', -- Soy products
    '4001', -- Fresh fruits
    '4002', -- Canned fruits
    '4003'  -- Dried fruits & nuts
);

-- 2. Extend existing food_items table with comprehensive nutritional data
ALTER TABLE public.food_items 
ADD COLUMN food_code TEXT UNIQUE,
ADD COLUMN italian_name TEXT,
ADD COLUMN english_name TEXT,
ADD COLUMN scientific_name TEXT,
ADD COLUMN category public.food_category_code,
ADD COLUMN edible_portion_percent NUMERIC DEFAULT 100,
ADD COLUMN energy_kj INTEGER DEFAULT 0,
-- Extended vitamins
ADD COLUMN vitamin_a_mcg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_b1_mg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_b2_mg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_b3_mg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_b6_mg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_b12_mcg NUMERIC DEFAULT 0,
ADD COLUMN folate_mcg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_c_mg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_d_mcg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_e_mg NUMERIC DEFAULT 0,
ADD COLUMN vitamin_k_mcg NUMERIC DEFAULT 0,
-- Extended minerals
ADD COLUMN potassium_mg NUMERIC DEFAULT 0,
ADD COLUMN calcium_mg NUMERIC DEFAULT 0,
ADD COLUMN phosphorus_mg NUMERIC DEFAULT 0,
ADD COLUMN magnesium_mg NUMERIC DEFAULT 0,
ADD COLUMN iron_mg NUMERIC DEFAULT 0,
ADD COLUMN zinc_mg NUMERIC DEFAULT 0,
ADD COLUMN copper_mg NUMERIC DEFAULT 0,
ADD COLUMN manganese_mg NUMERIC DEFAULT 0,
ADD COLUMN selenium_mcg NUMERIC DEFAULT 0,
ADD COLUMN iodine_mcg NUMERIC DEFAULT 0,
-- Fatty acids
ADD COLUMN saturated_fat_g NUMERIC DEFAULT 0,
ADD COLUMN monounsaturated_fat_g NUMERIC DEFAULT 0,
ADD COLUMN polyunsaturated_fat_g NUMERIC DEFAULT 0,
ADD COLUMN omega_3_g NUMERIC DEFAULT 0,
ADD COLUMN omega_6_g NUMERIC DEFAULT 0,
-- Amino acids (essential)
ADD COLUMN histidine_mg NUMERIC DEFAULT 0,
ADD COLUMN isoleucine_mg NUMERIC DEFAULT 0,
ADD COLUMN leucine_mg NUMERIC DEFAULT 0,
ADD COLUMN lysine_mg NUMERIC DEFAULT 0,
ADD COLUMN methionine_mg NUMERIC DEFAULT 0,
ADD COLUMN phenylalanine_mg NUMERIC DEFAULT 0,
ADD COLUMN threonine_mg NUMERIC DEFAULT 0,
ADD COLUMN tryptophan_mg NUMERIC DEFAULT 0,
ADD COLUMN valine_mg NUMERIC DEFAULT 0,
-- Sugars breakdown
ADD COLUMN glucose_g NUMERIC DEFAULT 0,
ADD COLUMN fructose_g NUMERIC DEFAULT 0,
ADD COLUMN sucrose_g NUMERIC DEFAULT 0,
ADD COLUMN lactose_g NUMERIC DEFAULT 0,
-- Additional nutrients
ADD COLUMN water_g NUMERIC DEFAULT 0,
ADD COLUMN ash_g NUMERIC DEFAULT 0,
ADD COLUMN starch_g NUMERIC DEFAULT 0,
ADD COLUMN cholesterol_mg NUMERIC DEFAULT 0,
ADD COLUMN caffeine_mg NUMERIC DEFAULT 0,
ADD COLUMN alcohol_g NUMERIC DEFAULT 0,
-- Search optimization
ADD COLUMN search_vector tsvector;

-- 3. Create comprehensive indexes for search and filtering
CREATE INDEX idx_food_items_food_code ON public.food_items(food_code);
CREATE INDEX idx_food_items_category ON public.food_items(category);
CREATE INDEX idx_food_items_edible_portion ON public.food_items(edible_portion_percent);
CREATE INDEX idx_food_items_italian_name ON public.food_items USING gin(to_tsvector('italian', coalesce(italian_name, '')));
CREATE INDEX idx_food_items_english_name ON public.food_items USING gin(to_tsvector('english', coalesce(english_name, '')));
CREATE INDEX idx_food_items_scientific_name ON public.food_items USING gin(to_tsvector('english', coalesce(scientific_name, '')));
CREATE INDEX idx_food_items_search_vector ON public.food_items USING gin(search_vector);
CREATE INDEX idx_food_items_calories ON public.food_items(calories_per_100g);
CREATE INDEX idx_food_items_protein ON public.food_items(protein_per_100g);

-- 4. Create function to update search vector
CREATE OR REPLACE FUNCTION public.update_food_search_vector()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.search_vector := setweight(to_tsvector('english', coalesce(NEW.english_name, '')), 'A') ||
                        setweight(to_tsvector('italian', coalesce(NEW.italian_name, '')), 'B') ||
                        setweight(to_tsvector('english', coalesce(NEW.scientific_name, '')), 'C') ||
                        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'D');
    RETURN NEW;
END;
$$;

-- 5. Create trigger for search vector updates
CREATE TRIGGER food_items_search_vector_update
    BEFORE INSERT OR UPDATE ON public.food_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_food_search_vector();

-- 6. Create food search function with comprehensive filtering
CREATE OR REPLACE FUNCTION public.search_foods(
    search_query TEXT DEFAULT '',
    category_filter public.food_category_code DEFAULT NULL,
    min_protein NUMERIC DEFAULT NULL,
    max_calories INTEGER DEFAULT NULL,
    limit_count INTEGER DEFAULT 50
)
RETURNS TABLE(
    id UUID,
    food_code TEXT,
    italian_name TEXT,
    english_name TEXT,
    scientific_name TEXT,
    category public.food_category_code,
    edible_portion_percent NUMERIC,
    calories_per_100g INTEGER,
    protein_per_100g NUMERIC,
    carbs_per_100g NUMERIC,
    fat_per_100g NUMERIC,
    fiber_per_100g NUMERIC,
    search_rank REAL
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    fi.id,
    fi.food_code,
    fi.italian_name,
    fi.english_name,
    fi.scientific_name,
    fi.category,
    fi.edible_portion_percent,
    fi.calories_per_100g,
    fi.protein_per_100g,
    fi.carbs_per_100g,
    fi.fat_per_100g,
    fi.fiber_per_100g,
    CASE 
        WHEN search_query = '' THEN 0.0
        ELSE ts_rank(fi.search_vector, plainto_tsquery('english', search_query))
    END as search_rank
FROM public.food_items fi
WHERE 
    (search_query = '' OR fi.search_vector @@ plainto_tsquery('english', search_query))
    AND (category_filter IS NULL OR fi.category = category_filter)
    AND (min_protein IS NULL OR fi.protein_per_100g >= min_protein)
    AND (max_calories IS NULL OR fi.calories_per_100g <= max_calories)
ORDER BY 
    CASE WHEN search_query = '' THEN fi.english_name END ASC,
    CASE WHEN search_query != '' THEN ts_rank(fi.search_vector, plainto_tsquery('english', search_query)) END DESC
LIMIT limit_count;
$$;

-- 7. Create function to get nutritional breakdown
CREATE OR REPLACE FUNCTION public.get_nutritional_breakdown(food_item_id UUID, portion_grams NUMERIC DEFAULT 100)
RETURNS TABLE(
    nutrient_category TEXT,
    nutrients JSONB
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    food_record RECORD;
    multiplier NUMERIC;
BEGIN
    -- Get food item
    SELECT * INTO food_record FROM public.food_items WHERE id = food_item_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Food item not found';
    END IF;
    
    -- Calculate multiplier based on portion size
    multiplier := portion_grams / 100.0;
    
    -- Return structured nutritional data
    RETURN QUERY
    SELECT 'macronutrients'::TEXT, jsonb_build_object(
        'calories', (food_record.calories_per_100g * multiplier)::NUMERIC,
        'protein_g', (food_record.protein_per_100g * multiplier)::NUMERIC,
        'carbs_g', (food_record.carbs_per_100g * multiplier)::NUMERIC,
        'fat_g', (food_record.fat_per_100g * multiplier)::NUMERIC,
        'fiber_g', (food_record.fiber_per_100g * multiplier)::NUMERIC,
        'water_g', (food_record.water_g * multiplier)::NUMERIC
    )
    UNION ALL
    SELECT 'vitamins'::TEXT, jsonb_build_object(
        'vitamin_a_mcg', (food_record.vitamin_a_mcg * multiplier)::NUMERIC,
        'vitamin_b1_mg', (food_record.vitamin_b1_mg * multiplier)::NUMERIC,
        'vitamin_b2_mg', (food_record.vitamin_b2_mg * multiplier)::NUMERIC,
        'vitamin_c_mg', (food_record.vitamin_c_mg * multiplier)::NUMERIC,
        'vitamin_d_mcg', (food_record.vitamin_d_mcg * multiplier)::NUMERIC,
        'folate_mcg', (food_record.folate_mcg * multiplier)::NUMERIC
    )
    UNION ALL
    SELECT 'minerals'::TEXT, jsonb_build_object(
        'calcium_mg', (food_record.calcium_mg * multiplier)::NUMERIC,
        'iron_mg', (food_record.iron_mg * multiplier)::NUMERIC,
        'potassium_mg', (food_record.potassium_mg * multiplier)::NUMERIC,
        'sodium_mg', (food_record.sodium_per_100g * multiplier)::NUMERIC,
        'zinc_mg', (food_record.zinc_mg * multiplier)::NUMERIC,
        'phosphorus_mg', (food_record.phosphorus_mg * multiplier)::NUMERIC
    );
END;
$$;

-- 8. Update existing RLS policies to handle new columns
-- Food items already has proper RLS policies, no changes needed

-- 9. Insert comprehensive food data from the provided batch
DO $$
DECLARE
    potato_powder_id UUID := gen_random_uuid();
    tapioca_id UUID := gen_random_uuid();
    potato_starch_id UUID := gen_random_uuid();
    young_potatoes_id UUID := gen_random_uuid();
    regular_potatoes_id UUID := gen_random_uuid();
BEGIN
    -- Clear existing basic food items to replace with comprehensive data
    DELETE FROM public.food_items WHERE name IN ('Apple', 'Banana');
    
    -- Insert comprehensive food database - BATCH 1: POTATOES & TUBERS
    INSERT INTO public.food_items (
        id, food_code, italian_name, english_name, scientific_name, category,
        edible_portion_percent, calories_per_100g, energy_kj, protein_per_100g,
        carbs_per_100g, fat_per_100g, fiber_per_100g, water_g,
        iron_mg, calcium_mg, sodium_per_100g, potassium_mg, phosphorus_mg, zinc_mg,
        is_verified, created_by, name
    ) VALUES
    (potato_powder_id, '100219_1', 'PATATE, POLVERE ISTANTANEA', 'POTATO, POWDER', NULL, '1001'::public.food_category_code,
     100, 351, 1488, 9.1, 73.2, 0.8, 16.5, 7, 2.4, 89, 1190, 1550, 220, 1.1,
     true, NULL, 'Potato Powder'),
     
    (tapioca_id, '18_1', 'TAPIOCA', 'TAPIOCA', 'Manihot utilissima', '1001'::public.food_category_code,
     100, 364, 1554, 0.6, 95.8, 0.2, 0.4, 12.6, 1, 12, 4, 20, 12, 0.12,
     true, NULL, 'Tapioca'),
     
    (potato_starch_id, '3002_1', 'PATATE, FECOLA', 'STARCH, POTATO', NULL, '1001'::public.food_category_code,
     100, 349, 1488, 1.4, 91.5, 0, 0, 16.1, 0.3, 10, 31, 1580, 27, 1.3,
     true, NULL, 'Potato Starch'),
     
    (young_potatoes_id, '380_1', 'PATATE, NOVELLE', 'POTATOES, YOUNG or EARLY', 'Solanum tuberosum', '1001'::public.food_category_code,
     96, 70, 298, 2, 15.8, 0, 1.4, 81.9, 0.6, 10, 23, 367, 54, 0.52,
     true, NULL, 'Young Potatoes'),
     
    (regular_potatoes_id, '381_1', 'PATATE', 'POTATOES', 'Solanum tuberosum', '1001'::public.food_category_code,
     83, 80, 340, 2.1, 18, 0.1, 1.6, 78.5, 0.6, 10, 7, 570, 54, 0.27,
     true, NULL, 'Potatoes');

    -- Update search vectors for all inserted items
    UPDATE public.food_items SET search_vector = 
        setweight(to_tsvector('english', coalesce(english_name, '')), 'A') ||
        setweight(to_tsvector('italian', coalesce(italian_name, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(scientific_name, '')), 'C') ||
        setweight(to_tsvector('english', coalesce(name, '')), 'D')
    WHERE id IN (potato_powder_id, tapioca_id, potato_starch_id, young_potatoes_id, regular_potatoes_id);
    
    RAISE NOTICE 'Successfully inserted comprehensive food database with % items', 5;
END $$;

-- 10. Create view for food categories with descriptions (FIXED VERSION)
-- Using a function to avoid set-returning functions in CASE expressions
CREATE OR REPLACE FUNCTION public.get_food_category_description(category_code public.food_category_code)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
SELECT 
    CASE category_code
        WHEN '1001' THEN 'Potatoes & tubers'
        WHEN '2001' THEN 'Leafy vegetables'
        WHEN '2003' THEN 'Root vegetables'
        WHEN '2004' THEN 'Cabbages'
        WHEN '2005' THEN 'Bulb vegetables'
        WHEN '2006' THEN 'Vegetable juices'
        WHEN '2007' THEN 'Mushrooms'
        WHEN '2008' THEN 'Salad vegetables'
        WHEN '2009' THEN 'Fruiting vegetables'
        WHEN '2010' THEN 'Preserved vegetables'
        WHEN '2011' THEN 'Seaweeds'
        WHEN '3000' THEN 'Mixed vegetables'
        WHEN '3001' THEN 'Pulses'
        WHEN '3002' THEN 'Pulse flours'
        WHEN '3004' THEN 'Soy products'
        WHEN '4001' THEN 'Fresh fruits'
        WHEN '4002' THEN 'Canned fruits'
        WHEN '4003' THEN 'Dried fruits & nuts'
        ELSE 'Unknown category'
    END;
$$;

-- Create the corrected view using LATERAL JOIN
CREATE VIEW public.food_categories_view AS
SELECT 
    codes.code,
    public.get_food_category_description(codes.code) as description
FROM (
    SELECT unnest(enum_range(NULL::public.food_category_code)) as code
) codes;

-- Create RLS policy for the view
ALTER VIEW public.food_categories_view SET (security_barrier = true);
GRANT SELECT ON public.food_categories_view TO public;
GRANT EXECUTE ON FUNCTION public.get_food_category_description(public.food_category_code) TO public;