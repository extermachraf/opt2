-- Migration: Fix tryptophan column name typo
-- Issue: Queries are referencing 'tryptofan_mg' but actual column is 'tryptophan_mg'
-- This migration renames the column to match what the application code expects

-- Rename the column from tryptophan_mg to tryptofan_mg to match existing queries
ALTER TABLE public.food_items 
RENAME COLUMN tryptophan_mg TO tryptofan_mg;

-- Add comment explaining the column name
COMMENT ON COLUMN public.food_items.tryptofan_mg IS 'Tryptophan content in milligrams per 100g (note: intentional spelling variation for consistency with existing codebase)';