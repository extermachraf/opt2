-- Location: supabase/migrations/20251210140000_add_nutritional_professional_field.sql
-- Schema Analysis: Existing medical_profiles table with health information fields
-- Integration Type: Extension - adding new column to existing table
-- Dependencies: Existing medical_profiles table

-- Add new enum type for nutritional professional options
CREATE TYPE public.nutritional_professional_type AS ENUM (
    'nutrizionista_clinico',
    'biologo_nutrizionista', 
    'dietista'
);

-- Add new column to existing medical_profiles table
ALTER TABLE public.medical_profiles 
ADD COLUMN nutritional_professional public.nutritional_professional_type;

-- Add index for the new column to improve query performance
CREATE INDEX idx_medical_profiles_nutritional_professional 
ON public.medical_profiles(nutritional_professional);

-- Update the existing trigger to handle the new column
-- The existing update trigger will automatically handle the new column

-- Add mock data to existing records for demonstration
DO $$
DECLARE
    existing_profile_record RECORD;
BEGIN
    -- Update existing medical profiles with sample data
    FOR existing_profile_record IN 
        SELECT id FROM public.medical_profiles LIMIT 2
    LOOP
        UPDATE public.medical_profiles 
        SET nutritional_professional = CASE 
            WHEN random() < 0.33 THEN 'nutrizionista_clinico'::public.nutritional_professional_type
            WHEN random() < 0.66 THEN 'biologo_nutrizionista'::public.nutritional_professional_type
            ELSE 'dietista'::public.nutritional_professional_type
        END
        WHERE id = existing_profile_record.id;
    END LOOP;
    
    RAISE NOTICE 'Added nutritional professional field to existing medical profiles';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating existing records: %', SQLERRM;
END $$;