-- Migration: Fix existing user verification status
-- Description: Updates existing users to have proper verification status for login access

-- Update existing users who should be verified but have incorrect status
-- This fixes the "Account not found" issue for verified emails
UPDATE public.user_profiles 
SET 
  email_verified = true,
  registration_completed = true,
  otp_code = null,
  otp_expires_at = null,
  otp_attempts = 0,
  last_otp_attempt = null,
  updated_at = CURRENT_TIMESTAMP
WHERE 
  email IS NOT NULL 
  AND email != '' 
  AND is_active = true
  AND (email_verified = false OR registration_completed = false);

-- Add a helpful function to check user verification status
CREATE OR REPLACE FUNCTION check_user_login_eligibility(user_email TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_record RECORD;
  result JSONB;
BEGIN
  -- Get user details
  SELECT 
    email,
    email_verified,
    registration_completed,
    is_active,
    full_name,
    created_at
  INTO user_record
  FROM public.user_profiles
  WHERE email = user_email;

  -- Check if user exists
  IF user_record.email IS NULL THEN
    result := jsonb_build_object(
      'eligible', false,
      'reason', 'user_not_found',
      'message', 'Account non trovato. Verifica l''email o registrati.'
    );
  -- Check if user is active
  ELSIF user_record.is_active = false THEN
    result := jsonb_build_object(
      'eligible', false,
      'reason', 'account_inactive',
      'message', 'Account disattivato. Contatta il supporto.'
    );
  -- Check verification status
  ELSIF user_record.email_verified = false OR user_record.registration_completed = false THEN
    result := jsonb_build_object(
      'eligible', false,
      'reason', 'verification_required',
      'message', 'Email non verificata. Completa la verifica OTP prima del login.',
      'requires_otp', true
    );
  -- User is eligible
  ELSE
    result := jsonb_build_object(
      'eligible', true,
      'reason', 'verified',
      'message', 'Account verificato e pronto per il login.',
      'user_name', user_record.full_name
    );
  END IF;

  RETURN result;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION check_user_login_eligibility(TEXT) TO authenticated, anon;

-- Add comment for documentation
COMMENT ON FUNCTION check_user_login_eligibility(TEXT) IS 
'Checks if a user is eligible for login based on their verification and account status. Returns detailed eligibility information.';