-- Migration: Protect manual calorie targets from automatic recalculation
-- Created: 2026-02-16
-- Description: Ensures that manually set daily_caloric_intake values are preserved
--              when weight changes. Only auto-calculates target_daily_calories when
--              no manual calorie target is set.

-- Function to protect manual calorie targets and auto-calculate when appropriate
CREATE OR REPLACE FUNCTION protect_manual_calorie_target()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only recalculate target_daily_calories if:
    -- 1. Weight has actually changed
    -- 2. No manual daily_caloric_intake is set (user hasn't set a fixed target)
    -- 3. New weight value is valid (not null)
    IF (OLD.current_weight_kg IS DISTINCT FROM NEW.current_weight_kg) 
       AND (NEW.daily_caloric_intake IS NULL) 
       AND (NEW.current_weight_kg IS NOT NULL) THEN
        
        -- Auto-calculate based on weight using simple formula
        -- Using 27.5 kcal/kg as midpoint of recommended 25-30 kcal/kg range
        NEW.target_daily_calories := ROUND(NEW.current_weight_kg * 27.5);
        
        RAISE NOTICE 'Auto-calculated target_daily_calories: % kcal for weight: % kg (no manual target set)', 
                     NEW.target_daily_calories, NEW.current_weight_kg;
    
    -- If manual calorie intake IS set, preserve it and don't recalculate
    ELSIF (OLD.current_weight_kg IS DISTINCT FROM NEW.current_weight_kg) 
          AND (NEW.daily_caloric_intake IS NOT NULL) THEN
        
        RAISE NOTICE 'Weight changed from % kg to % kg, but preserving manual calorie target: % kcal', 
                     OLD.current_weight_kg, NEW.current_weight_kg, NEW.daily_caloric_intake;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create trigger to protect manual calorie targets
DROP TRIGGER IF EXISTS protect_manual_calories_on_weight_change ON public.medical_profiles;
CREATE TRIGGER protect_manual_calories_on_weight_change
    BEFORE UPDATE OF current_weight_kg ON public.medical_profiles
    FOR EACH ROW
    EXECUTE FUNCTION protect_manual_calorie_target();

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION protect_manual_calorie_target() TO authenticated;
GRANT EXECUTE ON FUNCTION protect_manual_calorie_target() TO service_role;

-- Add comments for documentation
COMMENT ON FUNCTION protect_manual_calorie_target() IS 'Protects manually set daily_caloric_intake values from being overwritten when weight changes. Auto-calculates target_daily_calories only when no manual target is set.';

COMMENT ON TRIGGER protect_manual_calories_on_weight_change ON public.medical_profiles IS 'Ensures manual calorie targets (daily_caloric_intake) are preserved when weight changes. Only recalculates target_daily_calories when daily_caloric_intake is NULL.';

