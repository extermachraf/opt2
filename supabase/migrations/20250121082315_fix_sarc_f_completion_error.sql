-- Fix SARC-F questionnaire completion error by removing BMI validation requirement
-- Issue: SARC-F questionnaires don't require BMI validation since they only display answers for healthcare professional review

CREATE OR REPLACE FUNCTION public.enforce_bmi_validation_on_completion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_requires_bmi BOOLEAN := FALSE;
BEGIN
  -- Check if this is a completion update
  IF OLD.status != 'completed'::public.assessment_status AND 
     NEW.status = 'completed'::public.assessment_status THEN
    
    -- Check if questionnaire type requires BMI validation
    -- CRITICAL FIX: Removed 'sarc_f' from the list as it doesn't require BMI validation
    -- SARC-F questionnaires only display answers for healthcare professional review
    v_requires_bmi := NEW.questionnaire_type IN (
      'must'::public.questionnaire_type,
      'nrs_2002'::public.questionnaire_type,
      'nutritional_risk_assessment'::public.questionnaire_type,
      'consolidated_nutritional_assessment'::public.questionnaire_type
    );

    -- If BMI validation is required but not present, prevent completion
    IF v_requires_bmi AND NEW.bmi_validated_at IS NULL THEN
      RAISE EXCEPTION 'BMI validation required before completing % questionnaire', NEW.questionnaire_type;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

-- Add comment explaining the change
COMMENT ON FUNCTION public.enforce_bmi_validation_on_completion() IS 'Updated 2025-01-21: Removed sarc_f from BMI validation requirements. SARC-F questionnaires only display answers for healthcare professional review and do not require BMI validation for completion.';