-- Location: supabase/migrations/20250925110600_add_italian_registration_fields.sql
-- Schema Analysis: Existing user_profiles and medical_profiles with OTP system
-- Integration Type: Extension of existing auth system with Italian requirements
-- Dependencies: user_profiles (existing table)

-- Add missing Italian registration fields to user_profiles
ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS name TEXT,
ADD COLUMN IF NOT EXISTS surname TEXT,
ADD COLUMN IF NOT EXISTS telephone TEXT,
ADD COLUMN IF NOT EXISTS birthplace TEXT,
ADD COLUMN IF NOT EXISTS codice_fiscale TEXT,
ADD COLUMN IF NOT EXISTS comune_residenza TEXT,
ADD COLUMN IF NOT EXISTS region_treatment TEXT;

-- Update medical_profiles to use Italian field names and add missing gender field
ALTER TABLE public.medical_profiles
ADD COLUMN IF NOT EXISTS gender_at_birth public.gender DEFAULT 'prefer_not_to_say'::public.gender,
ADD COLUMN IF NOT EXISTS birth_date DATE;

-- Create indexes for the new fields
CREATE INDEX IF NOT EXISTS idx_user_profiles_codice_fiscale ON public.user_profiles(codice_fiscale);
CREATE INDEX IF NOT EXISTS idx_user_profiles_telephone ON public.user_profiles(telephone);
CREATE INDEX IF NOT EXISTS idx_medical_profiles_gender_birth_date ON public.medical_profiles(gender_at_birth, birth_date);

-- Update the handle_new_user function to handle Italian fields
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id, 
    email, 
    full_name, 
    role,
    name,
    surname,
    telephone,
    birthplace,
    codice_fiscale,
    comune_residenza,
    region_treatment
  )
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'patient')::public.user_role,
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'surname',
    NEW.raw_user_meta_data->>'telephone',
    NEW.raw_user_meta_data->>'birthplace',
    NEW.raw_user_meta_data->>'codice_fiscale',
    NEW.raw_user_meta_data->>'comune_residenza',
    NEW.raw_user_meta_data->>'region_treatment'
  );
  RETURN NEW;
END;
$$;

-- Add cleanup function for test data
CREATE OR REPLACE FUNCTION public.cleanup_test_auth_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@nutrivita.test' OR email LIKE 'test%@example.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.medical_profiles WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);
    
    RAISE NOTICE 'Cleaned up % test users', array_length(auth_user_ids_to_delete, 1);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;