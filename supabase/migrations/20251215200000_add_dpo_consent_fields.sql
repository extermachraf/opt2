-- Location: supabase/migrations/20251215200000_add_dpo_consent_fields.sql
-- Schema Analysis: user_profiles table already exists with consent-related fields
-- Integration Type: addition - adding new DPO compliance consent columns
-- Dependencies: user_profiles table

-- Add three required DPO consent columns to user_profiles table
ALTER TABLE public.user_profiles
ADD COLUMN terms_of_service_accepted BOOLEAN DEFAULT false,
ADD COLUMN privacy_policy_accepted BOOLEAN DEFAULT false,
ADD COLUMN data_processing_accepted BOOLEAN DEFAULT false,
ADD COLUMN consent_timestamp TIMESTAMPTZ;

-- Add index for consent tracking
CREATE INDEX idx_user_profiles_consent 
ON public.user_profiles(terms_of_service_accepted, privacy_policy_accepted, data_processing_accepted);

-- Add constraint to ensure consent timestamp is set when all consents are true
CREATE OR REPLACE FUNCTION public.validate_consent_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Set consent timestamp when all three consents are accepted
    IF NEW.terms_of_service_accepted = true 
       AND NEW.privacy_policy_accepted = true 
       AND NEW.data_processing_accepted = true 
       AND OLD.consent_timestamp IS NULL THEN
        NEW.consent_timestamp = CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create trigger for consent timestamp validation
CREATE TRIGGER validate_consent_timestamp_trigger
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_consent_timestamp();

-- Comment on the new columns
COMMENT ON COLUMN public.user_profiles.terms_of_service_accepted IS 'User acceptance of Terms of Service (DPO compliance)';
COMMENT ON COLUMN public.user_profiles.privacy_policy_accepted IS 'User acceptance of Privacy Policy (DPO compliance)';  
COMMENT ON COLUMN public.user_profiles.data_processing_accepted IS 'User acceptance of personal data processing (DPO compliance)';
COMMENT ON COLUMN public.user_profiles.consent_timestamp IS 'Timestamp when all three consents were accepted';