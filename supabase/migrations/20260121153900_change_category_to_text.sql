-- Migration to change food_items.category from ENUM to TEXT
-- This allows us to store BDA category codes (like "4004", "1001", etc.)

-- First, alter the column type from enum to TEXT
ALTER TABLE public.food_items 
ALTER COLUMN category TYPE TEXT USING category::TEXT;

-- Drop the old enum type if it exists (optional, only if you want to clean up)
-- DROP TYPE IF EXISTS food_category_code CASCADE;

-- Add a comment
COMMENT ON COLUMN public.food_items.category IS 'Food category code from BDA database (now TEXT to accept any value)';
