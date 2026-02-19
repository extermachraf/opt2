-- Migration: Add terapia_nutrizionale field to medical_profiles
-- Location: supabase/migrations/20260203000006_add_terapia_nutrizionale_field.sql
-- Purpose: Add support for nutritional therapy tracking (multiple choice)
-- Dependencies: medical_profiles table (already exists)

-- Add terapia_nutrizionale field as TEXT array to support multiple selections
ALTER TABLE public.medical_profiles
ADD COLUMN IF NOT EXISTS terapia_nutrizionale TEXT[];

-- Add comment to document the column
COMMENT ON COLUMN public.medical_profiles.terapia_nutrizionale IS 
'Nutritional therapy types: Alimentazione Enterale, Alimentazione Parenterale, Supplementi Nutrizionali Orali. Supports multiple selections.';

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_medical_profiles_terapia_nutrizionale 
ON public.medical_profiles USING GIN (terapia_nutrizionale);

