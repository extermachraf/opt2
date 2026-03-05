-- Location: supabase/migrations/20260303000000_fix_must_bmi_score_boundary.sql
--
-- Fix MUST BMI scoring boundary: the rule is BMI > 20 → 0, NOT BMI ≥ 20 → 0.
-- Previous code used `user_bmi >= 20.0` which incorrectly gave BMI=20 a score of 0.
-- Correct rule (as specified):
--   BMI > 20       → score 0
--   18,5 ≤ BMI ≤ 20 → score 1
--   BMI < 18,5     → score 2

CREATE OR REPLACE FUNCTION public.calculate_must_bmi_score_corrected(user_id_param uuid)
RETURNS TABLE(calculated_value text, display_text text, score_value integer, bmi_numeric numeric)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    user_bmi NUMERIC;
BEGIN
    -- Calculate BMI from medical profile
    SELECT
        CASE
            WHEN mp.height_cm > 0 AND mp.current_weight_kg > 0 THEN
                ROUND(mp.current_weight_kg / POWER(mp.height_cm / 100.0, 2), 1)
            ELSE NULL
        END
    INTO user_bmi
    FROM public.medical_profiles mp
    WHERE mp.user_id = user_id_param;

    IF user_bmi IS NULL THEN
        calculated_value := 'Dati insufficienti';
        display_text     := 'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score_value      := 0;

    ELSIF user_bmi < 18.5 THEN
        -- BMI < 18,5 → 2 points (highest risk)
        calculated_value := 'BMI < 18,5';
        display_text     := 'BMI: ' || user_bmi || ' (Sottopeso grave - 2 punti)';
        score_value      := 2;

    ELSIF user_bmi <= 20.0 THEN
        -- 18,5 ≤ BMI ≤ 20 → 1 point (moderate risk)
        calculated_value := '18,5 ≤ BMI ≤ 20';
        display_text     := 'BMI: ' || user_bmi || ' (Lievemente sottopeso - 1 punto)';
        score_value      := 1;

    ELSE
        -- BMI > 20 → 0 points (normal)
        calculated_value := 'BMI > 20';
        display_text     := 'BMI: ' || user_bmi || ' (Normale o superiore - 0 punti)';
        score_value      := 0;
    END IF;

    bmi_numeric := user_bmi;
    RETURN NEXT;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.calculate_must_bmi_score_corrected(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_must_bmi_score_corrected(UUID) TO service_role;

COMMENT ON FUNCTION public.calculate_must_bmi_score_corrected IS
  'MUST BMI scoring: BMI > 20 → 0, 18,5 ≤ BMI ≤ 20 → 1, BMI < 18,5 → 2. Fixed 2026-03-03.';

