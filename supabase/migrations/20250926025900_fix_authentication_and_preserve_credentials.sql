-- Fix Authentication System and Ensure Demo User Exists
-- Migration: 20250926025900_fix_authentication_and_preserve_credentials.sql

BEGIN;

-- Ensure demo user exists for testing login functionality
DO $$
DECLARE
    demo_user_id UUID;
    demo_user_exists BOOLEAN := FALSE;
BEGIN
    -- Check if demo user exists
    SELECT EXISTS(
        SELECT 1 FROM public.user_profiles 
        WHERE email = 'yassine00kriouet@gmail.com'
    ) INTO demo_user_exists;

    IF NOT demo_user_exists THEN
        -- Generate a consistent UUID for demo user
        demo_user_id := 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID;
        
        -- Insert demo user profile
        INSERT INTO public.user_profiles (
            id,
            email,
            full_name,
            name,
            surname,
            telephone,
            date_of_birth,
            gender,
            email_verified,
            registration_completed,
            is_active,
            role,
            password_hash,
            created_at,
            updated_at
        ) VALUES (
            demo_user_id,
            'yassine00kriouet@gmail.com',
            'Yassine Kriouet',
            'Yassine',
            'Kriouet',
            '+39 123 456 7890',
            '1995-06-15',
            'male'::gender,
            true,
            true,
            true,
            'patient'::user_role,
            'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', -- SHA-256 hash of 'Test123456!'
            NOW(),
            NOW()
        );

        RAISE NOTICE 'Demo user created with email: yassine00kriouet@gmail.com';
    ELSE
        RAISE NOTICE 'Demo user already exists';
    END IF;
END $$;

-- Ensure existing users remain active and verified
UPDATE public.user_profiles 
SET 
    is_active = true,
    email_verified = true,
    updated_at = NOW()
WHERE is_active IS NULL 
   OR email_verified IS NULL 
   OR is_active = false;

-- Fix any users with missing required fields
UPDATE public.user_profiles 
SET 
    full_name = COALESCE(full_name, CONCAT(name, ' ', surname), split_part(email, '@', 1)),
    registration_completed = true,
    role = COALESCE(role, 'patient'::user_role)
WHERE full_name IS NULL 
   OR full_name = '' 
   OR registration_completed IS NULL;

-- Add improved function to check user login eligibility
CREATE OR REPLACE FUNCTION public.check_user_login_eligibility(user_email TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
    result JSONB;
BEGIN
    -- Check if user exists and is active
    SELECT 
        id,
        email,
        full_name,
        is_active,
        email_verified,
        registration_completed
    INTO user_record
    FROM public.user_profiles
    WHERE email = user_email;

    IF NOT FOUND THEN
        result := jsonb_build_object(
            'eligible', false,
            'reason', 'Account non trovato. Verifica l''email o registrati.',
            'error_code', 'USER_NOT_FOUND'
        );
    ELSIF user_record.is_active = false THEN
        result := jsonb_build_object(
            'eligible', false,
            'reason', 'Account disattivato. Contatta il supporto.',
            'error_code', 'ACCOUNT_INACTIVE'
        );
    ELSE
        result := jsonb_build_object(
            'eligible', true,
            'user_id', user_record.id,
            'full_name', user_record.full_name,
            'email_verified', user_record.email_verified,
            'registration_completed', user_record.registration_completed
        );
    END IF;

    RETURN result;
END;
$$;

-- Create function to safely create user profile if missing (for authenticated users)
CREATE OR REPLACE FUNCTION public.create_user_profile_if_missing(
    user_id_input UUID,
    email_input TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    existing_profile RECORD;
    result JSONB;
BEGIN
    -- Check if profile exists
    SELECT id, email, full_name 
    INTO existing_profile
    FROM public.user_profiles
    WHERE id = user_id_input;

    IF NOT FOUND THEN
        -- Create missing profile
        INSERT INTO public.user_profiles (
            id,
            email,
            full_name,
            email_verified,
            registration_completed,
            is_active,
            role,
            created_at,
            updated_at
        ) VALUES (
            user_id_input,
            email_input,
            split_part(email_input, '@', 1), -- Use email prefix as name
            true,
            true,
            true,
            'patient'::user_role,
            NOW(),
            NOW()
        );

        result := jsonb_build_object(
            'created', true,
            'profile_id', user_id_input,
            'full_name', split_part(email_input, '@', 1)
        );
    ELSE
        result := jsonb_build_object(
            'created', false,
            'existing', true,
            'full_name', existing_profile.full_name
        );
    END IF;

    RETURN result;
END;
$$;

-- Grant appropriate permissions
GRANT EXECUTE ON FUNCTION public.check_user_login_eligibility(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_user_profile_if_missing(UUID, TEXT) TO authenticated;

-- Ensure RLS policies are correctly configured
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;

CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Add policy for service role (for demo user creation)
CREATE POLICY "service_role_full_access"
ON public.user_profiles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Create indexes for better performance on email lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_email_lookup 
ON public.user_profiles(email) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_user_profiles_auth_status 
ON public.user_profiles(id, email_verified, is_active, registration_completed);

COMMIT;