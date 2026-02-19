-- Location: supabase/migrations/20260121150800_create_food_ingredients_table.sql
-- Purpose: Create food_ingredients table to store Italian Food Database (BDA) data
-- This table will store nutritional information for individual food ingredients

-- Create the food_ingredients table
CREATE TABLE IF NOT EXISTS public.food_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    italian_name TEXT,
    english_name TEXT,
    scientific_name TEXT,
    category TEXT,
    edible_part_percent DOUBLE PRECISION DEFAULT 100.0,
    calories_per_100g INTEGER NOT NULL DEFAULT 0,
    protein_per_100g DOUBLE PRECISION DEFAULT 0.0,
    fat_per_100g DOUBLE PRECISION DEFAULT 0.0,
    carbs_per_100g DOUBLE PRECISION DEFAULT 0.0,
    fiber_per_100g DOUBLE PRECISION DEFAULT 0.0,
    sugar_per_100g DOUBLE PRECISION DEFAULT 0.0,
    sodium_per_100g DOUBLE PRECISION DEFAULT 0.0,
    source TEXT DEFAULT 'BDA - Banca Dati di Composizione degli Alimenti',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better search performance
CREATE INDEX IF NOT EXISTS idx_food_ingredients_name ON public.food_ingredients(name);
CREATE INDEX IF NOT EXISTS idx_food_ingredients_italian_name ON public.food_ingredients(italian_name);
CREATE INDEX IF NOT EXISTS idx_food_ingredients_category ON public.food_ingredients(category);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_food_ingredients_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically update updated_at
DROP TRIGGER IF EXISTS trigger_update_food_ingredients_updated_at ON public.food_ingredients;
CREATE TRIGGER trigger_update_food_ingredients_updated_at
    BEFORE UPDATE ON public.food_ingredients
    FOR EACH ROW
    EXECUTE FUNCTION update_food_ingredients_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE public.food_ingredients ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
-- Allow anyone to read food ingredients (public data)
CREATE POLICY "Allow public read access to food_ingredients"
    ON public.food_ingredients
    FOR SELECT
    TO public
    USING (true);

-- Only authenticated users can insert/update (for admin purposes)
CREATE POLICY "Allow authenticated users to insert food_ingredients"
    ON public.food_ingredients
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update food_ingredients"
    ON public.food_ingredients
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Add comments for documentation
COMMENT ON TABLE public.food_ingredients IS 'Italian Food Database (BDA) - Contains nutritional information for food ingredients';
COMMENT ON COLUMN public.food_ingredients.name IS 'Primary name of the food ingredient';
COMMENT ON COLUMN public.food_ingredients.italian_name IS 'Italian name of the food ingredient';
COMMENT ON COLUMN public.food_ingredients.english_name IS 'English name of the food ingredient';
COMMENT ON COLUMN public.food_ingredients.scientific_name IS 'Scientific/botanical name';
COMMENT ON COLUMN public.food_ingredients.category IS 'Food category code from BDA database';
COMMENT ON COLUMN public.food_ingredients.edible_part_percent IS 'Percentage of edible part (default 100%)';
COMMENT ON COLUMN public.food_ingredients.calories_per_100g IS 'Calories per 100g';
COMMENT ON COLUMN public.food_ingredients.protein_per_100g IS 'Protein in grams per 100g';
COMMENT ON COLUMN public.food_ingredients.fat_per_100g IS 'Fat in grams per 100g';
COMMENT ON COLUMN public.food_ingredients.carbs_per_100g IS 'Carbohydrates in grams per 100g';
COMMENT ON COLUMN public.food_ingredients.fiber_per_100g IS 'Fiber in grams per 100g';
COMMENT ON COLUMN public.food_ingredients.source IS 'Data source (e.g., BDA database)';
