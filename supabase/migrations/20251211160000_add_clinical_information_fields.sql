-- Location: supabase/migrations/20251211160000_add_clinical_information_fields.sql
-- Schema Analysis: Extending existing medical_profiles table with clinical information fields
-- Integration Type: PARTIAL_EXISTS - Adding clinical fields to existing medical_profiles
-- Dependencies: medical_profiles table (already exists)

-- Add clinical information fields to existing medical_profiles table
ALTER TABLE public.medical_profiles
ADD COLUMN sede_primaria_tumore TEXT,
ADD COLUMN data_prima_diagnosi DATE,
ADD COLUMN trattamento_in_corso TEXT,
ADD COLUMN patologie_concomitanti TEXT,
ADD COLUMN farmaci_periodici TEXT;

-- Add indexes for new fields if needed for performance
CREATE INDEX IF NOT EXISTS idx_medical_profiles_data_diagnosi ON public.medical_profiles(data_prima_diagnosi);

-- No RLS policy changes needed - existing policies already cover the table
-- Pattern 1 applies: users_manage_own_medical_profiles policy already exists and covers new columns