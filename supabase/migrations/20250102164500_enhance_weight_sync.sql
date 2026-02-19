-- Migration: Enhance weight synchronization between medical profiles and weight entries
-- Description: Create trigger to automatically sync weight entries when medical profile current_weight_kg is updated

-- Function to sync weight entry when medical profile is updated
CREATE OR REPLACE FUNCTION sync_medical_profile_weight_to_entries()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only sync if current_weight_kg has actually changed
    IF (TG_OP = 'INSERT' AND NEW.current_weight_kg IS NOT NULL) OR
       (TG_OP = 'UPDATE' AND OLD.current_weight_kg IS DISTINCT FROM NEW.current_weight_kg AND NEW.current_weight_kg IS NOT NULL) THEN
        
        -- Use the existing upsert function with current timestamp
        PERFORM public.upsert_weight_entry(
            p_user_id => NEW.user_id,
            p_weight_kg => NEW.current_weight_kg,
            p_recorded_at => NOW(),
            p_notes => 'Sincronizzato dagli aggiornamenti del profilo'
        );
    END IF;

    RETURN NEW;
END;
$$;

-- Create trigger on medical_profiles for weight sync
DROP TRIGGER IF EXISTS sync_weight_on_medical_profile_change ON public.medical_profiles;
CREATE TRIGGER sync_weight_on_medical_profile_change
    AFTER INSERT OR UPDATE OF current_weight_kg ON public.medical_profiles
    FOR EACH ROW
    EXECUTE FUNCTION sync_medical_profile_weight_to_entries();

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION sync_medical_profile_weight_to_entries() TO authenticated;
GRANT EXECUTE ON FUNCTION sync_medical_profile_weight_to_entries() TO service_role;

-- Comment for documentation
COMMENT ON FUNCTION sync_medical_profile_weight_to_entries() IS 'Automatically syncs weight entries when medical profile current_weight_kg is updated';
COMMENT ON TRIGGER sync_weight_on_medical_profile_change ON public.medical_profiles IS 'Triggers weight entry sync when current_weight_kg changes in medical profiles';