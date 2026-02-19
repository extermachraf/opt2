-- Migration: Add daily_caloric_intake column to medical_profiles
-- Created: 2025-12-25
-- Description: Adds support for manual daily caloric intake entry

-- Add the daily_caloric_intake column
ALTER TABLE medical_profiles 
ADD COLUMN IF NOT EXISTS daily_caloric_intake NUMERIC;

-- Add comment to document the column
COMMENT ON COLUMN medical_profiles.daily_caloric_intake IS 'Manually entered daily caloric intake in kcal. Takes precedence over calculated values.';
