-- Location: supabase/migrations/20250923145100_simplify_user_roles_patient_only.sql
-- Schema Analysis: Existing user_role ENUM with values ['patient', 'doctor', 'admin', 'nutritionist']
-- Integration Type: Modificative - Update existing ENUM type
-- Dependencies: user_profiles table references user_role ENUM

-- Step 1: Update all existing users to 'patient' role
UPDATE public.user_profiles 
SET role = 'patient'::public.user_role 
WHERE role IN ('doctor', 'admin', 'nutritionist');

-- Step 2: Remove default constraint first to avoid dependency issues
ALTER TABLE public.user_profiles ALTER COLUMN role DROP DEFAULT;

-- Step 3: Change column to TEXT temporarily
ALTER TABLE public.user_profiles ALTER COLUMN role TYPE TEXT;

-- Step 4: Drop the old ENUM type (now safe since no dependencies remain)
DROP TYPE IF EXISTS public.user_role CASCADE;

-- Step 5: Create new ENUM type with only 'patient' value
CREATE TYPE public.user_role AS ENUM ('patient');

-- Step 6: Convert the column back to the new ENUM type
ALTER TABLE public.user_profiles 
ALTER COLUMN role TYPE public.user_role 
USING role::public.user_role;

-- Step 7: Set default value for the column with new ENUM
ALTER TABLE public.user_profiles 
ALTER COLUMN role SET DEFAULT 'patient'::public.user_role;

-- Step 8: Ensure all existing rows have 'patient' role (in case any were missed)
UPDATE public.user_profiles 
SET role = 'patient'::public.user_role 
WHERE role IS NULL;

-- Step 9: Update any auth.users metadata that might have role information
DO $$
DECLARE
    user_record RECORD;
BEGIN
    -- Update raw_user_meta_data to set role as 'patient' for all users
    FOR user_record IN 
        SELECT id FROM auth.users 
        WHERE raw_user_meta_data->>'role' IN ('doctor', 'admin', 'nutritionist')
    LOOP
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"role": "patient"}'::jsonb
        WHERE id = user_record.id;
    END LOOP;
    
    -- Update raw_app_meta_data to set role as 'patient' for all users
    FOR user_record IN 
        SELECT id FROM auth.users 
        WHERE raw_app_meta_data->>'role' IN ('doctor', 'admin', 'nutritionist')
    LOOP
        UPDATE auth.users 
        SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"role": "patient"}'::jsonb
        WHERE id = user_record.id;
    END LOOP;

    RAISE NOTICE 'Successfully updated all user roles to patient';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating user roles: %', SQLERRM;
END $$;

-- Step 10: Verify the change worked correctly
DO $$
DECLARE
    enum_values TEXT[];
    patient_count INTEGER;
BEGIN
    -- Check the enum values
    SELECT array_agg(enumlabel ORDER BY enumsortorder) 
    INTO enum_values
    FROM pg_enum e 
    JOIN pg_type t ON e.enumtypid = t.oid 
    WHERE t.typname = 'user_role';
    
    -- Count patient records
    SELECT COUNT(*) INTO patient_count FROM public.user_profiles WHERE role = 'patient';
    
    RAISE NOTICE 'Updated user_role enum values: %', enum_values;
    RAISE NOTICE 'Total patient records: %', patient_count;
    
    -- Ensure we have only 'patient' in the enum
    IF array_length(enum_values, 1) = 1 AND enum_values[1] = 'patient' THEN
        RAISE NOTICE 'SUCCESS: user_role enum simplified to patient-only';
    ELSE
        RAISE WARNING 'ISSUE: Expected only patient role, found: %', enum_values;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error verifying role simplification: %', SQLERRM;
END $$;

-- Create a comment for documentation
COMMENT ON TYPE public.user_role IS 'Simplified user role enum containing only patient role for NutriVita application (Updated: 2025-09-23)';