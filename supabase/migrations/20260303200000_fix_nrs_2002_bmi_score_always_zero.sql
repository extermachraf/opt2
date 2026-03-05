-- Migration: Fix NRS 2002 BMI response score to always be 0
-- Problem: calculate_nrs_2002_bmi_response() was returning score=1 when BMI < 20.5.
--          auto_calculate_nrs_2002_responses() calls this and UPSERTS nrs_bmi_under_20_5
--          with response_score=1, overwriting whatever Flutter saved.
--          Since nrs_bmi_under_20_5 is a SCREENING question (Q1), it must always give 0 points.
--          Only Q6 (nrs_nutritional_status) and Q7 (nrs_disease_severity) carry real scores.
-- Fix: Always return score=0 from calculate_nrs_2002_bmi_response().

CREATE OR REPLACE FUNCTION public.calculate_nrs_2002_bmi_response(user_id uuid)
RETURNS TABLE(calculated_value text, display_value text, score integer)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_bmi NUMERIC;
    is_under_20_5 BOOLEAN;
BEGIN
    SELECT (mp.current_weight_kg / POWER(mp.height_cm / 100.0, 2))
    INTO user_bmi
    FROM public.medical_profiles mp
    WHERE mp.user_id = calculate_nrs_2002_bmi_response.user_id
      AND mp.current_weight_kg IS NOT NULL
      AND mp.height_cm IS NOT NULL;

    IF user_bmi IS NOT NULL THEN
        is_under_20_5 := user_bmi < 20.5;

        RETURN QUERY SELECT
            CASE WHEN is_under_20_5 THEN 'Sì'::TEXT ELSE 'No'::TEXT END,
            ('BMI: ' || ROUND(user_bmi, 1)::TEXT ||
             CASE WHEN is_under_20_5
                  THEN ' - Sotto 20.5 (fattore di rischio)'
                  ELSE ' - Sopra o uguale a 20.5 (normale)'
             END)::TEXT,
            0;  -- ← ALWAYS 0: nrs_bmi_under_20_5 is a screening question, not scored
    ELSE
        RETURN QUERY SELECT
            'Dati insufficienti'::TEXT,
            'BMI non calcolabile - inserire altezza e peso nel profilo medico'::TEXT,
            0;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.calculate_nrs_2002_bmi_response(uuid) IS
  'NRS 2002 Q1 BMI screening check. Returns Sì/No based on BMI < 20.5. Score is ALWAYS 0 — Q1 is a screening-only question. Only Q6 and Q7 carry real scores.';

-- Verify: show what the function now returns for an existing user (informational only)
DO $$
BEGIN
    RAISE NOTICE '✅ calculate_nrs_2002_bmi_response updated: BMI response score is now always 0.';
    RAISE NOTICE '   NRS 2002 scoring: Q6 (nrs_nutritional_status) + Q7 (nrs_disease_severity) + age bonus only.';
END $$;

