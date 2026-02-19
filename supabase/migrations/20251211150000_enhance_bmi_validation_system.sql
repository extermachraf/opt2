-- Migration: Enhanced BMI Validation System
-- Description: Adds server-side validation for BMI requirements and improved tracking

-- Add BMI validation tracking fields to assessment_sessions
ALTER TABLE public.assessment_sessions 
ADD COLUMN IF NOT EXISTS bmi_validated_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS bmi_value_at_start NUMERIC(5,2),
ADD COLUMN IF NOT EXISTS weight_at_validation NUMERIC(5,2),
ADD COLUMN IF NOT EXISTS height_at_validation NUMERIC(5,2);

-- Create index for BMI validation queries
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_bmi_validation 
ON public.assessment_sessions (user_id, bmi_validated_at, questionnaire_type);

-- Enhanced function to validate BMI before starting questionnaires
CREATE OR REPLACE FUNCTION public.validate_bmi_for_questionnaire(
  p_user_id UUID,
  p_questionnaire_type public.questionnaire_type
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_weight_entry RECORD;
  v_medical_profile RECORD;
  v_bmi NUMERIC(5,2);
  v_requires_bmi BOOLEAN := FALSE;
  v_result jsonb;
BEGIN
  -- Check if questionnaire type requires BMI validation
  v_requires_bmi := p_questionnaire_type IN (
    'must'::public.questionnaire_type,
    'nrs_2002'::public.questionnaire_type,
    'nutritional_risk_assessment'::public.questionnaire_type,
    'sarc_f'::public.questionnaire_type,
    'consolidated_nutritional_assessment'::public.questionnaire_type
  );

  -- If BMI validation not required, return valid immediately
  IF NOT v_requires_bmi THEN
    RETURN jsonb_build_object(
      'is_valid', true,
      'message', 'BMI validation not required for this questionnaire',
      'requires_bmi_validation', false
    );
  END IF;

  -- Get today's weight entry
  SELECT weight_kg, recorded_at
  INTO v_weight_entry
  FROM public.weight_entries
  WHERE user_id = p_user_id
    AND DATE(recorded_at) = v_today
  ORDER BY recorded_at DESC
  LIMIT 1;

  -- Get medical profile with height
  SELECT height_cm, updated_at
  INTO v_medical_profile
  FROM public.medical_profiles
  WHERE user_id = p_user_id
  LIMIT 1;

  -- Validate weight entry for today
  IF v_weight_entry IS NULL THEN
    RETURN jsonb_build_object(
      'is_valid', false,
      'message', 'Peso non registrato per oggi. Aggiorna il peso per continuare.',
      'requires_weight_update', true,
      'requires_height_update', v_medical_profile IS NULL OR v_medical_profile.height_cm IS NULL,
      'requires_bmi_validation', true
    );
  END IF;

  -- Validate height information
  IF v_medical_profile IS NULL OR v_medical_profile.height_cm IS NULL OR v_medical_profile.height_cm <= 0 THEN
    RETURN jsonb_build_object(
      'is_valid', false,
      'message', 'Altezza mancante o non valida. Inserisci l''altezza per calcolare il BMI.',
      'requires_weight_update', false,
      'requires_height_update', true,
      'requires_bmi_validation', true
    );
  END IF;

  -- Calculate BMI
  v_bmi := v_weight_entry.weight_kg / POWER((v_medical_profile.height_cm / 100.0), 2);

  -- Validate BMI calculation
  IF v_bmi IS NULL OR v_bmi <= 0 OR v_bmi > 100 THEN
    RETURN jsonb_build_object(
      'is_valid', false,
      'message', 'BMI non valido calcolato dai dati forniti. Verifica peso e altezza.',
      'requires_weight_update', true,
      'requires_height_update', true,
      'requires_bmi_validation', true
    );
  END IF;

  -- Return successful validation with BMI data
  RETURN jsonb_build_object(
    'is_valid', true,
    'message', 'BMI validato correttamente: ' || ROUND(v_bmi, 1),
    'bmi_value', ROUND(v_bmi, 1),
    'weight', v_weight_entry.weight_kg,
    'height', v_medical_profile.height_cm,
    'requires_weight_update', false,
    'requires_height_update', false,
    'requires_bmi_validation', true,
    'validation_date', v_today::text
  );
END;
$$;

-- Enhanced function to start assessment session with BMI validation
CREATE OR REPLACE FUNCTION public.start_assessment_session_with_bmi_validation(
  p_user_id UUID,
  p_questionnaire_type public.questionnaire_type
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_validation_result jsonb;
  v_session_id UUID;
  v_bmi_data jsonb;
BEGIN
  -- First validate BMI if required
  v_validation_result := public.validate_bmi_for_questionnaire(p_user_id, p_questionnaire_type);
  
  -- If BMI validation fails, return the validation result
  IF NOT (v_validation_result->>'is_valid')::boolean THEN
    RETURN v_validation_result;
  END IF;

  -- Extract BMI data for storage
  v_bmi_data := v_validation_result;

  -- Create assessment session with BMI validation data
  INSERT INTO public.assessment_sessions (
    user_id,
    questionnaire_type,
    status,
    started_at,
    bmi_validated_at,
    bmi_value_at_start,
    weight_at_validation,
    height_at_validation
  )
  VALUES (
    p_user_id,
    p_questionnaire_type,
    'in_progress'::public.assessment_status,
    NOW(),
    CASE 
      WHEN (v_bmi_data->>'requires_bmi_validation')::boolean THEN NOW()
      ELSE NULL
    END,
    (v_bmi_data->>'bmi_value')::numeric,
    (v_bmi_data->>'weight')::numeric,
    (v_bmi_data->>'height')::numeric
  )
  RETURNING id INTO v_session_id;

  -- Return success with session ID and BMI data
  RETURN jsonb_build_object(
    'success', true,
    'session_id', v_session_id,
    'bmi_validation', v_validation_result,
    'message', 'Assessment session created with BMI validation'
  );
END;
$$;

-- Function to get BMI validation history for a user
CREATE OR REPLACE FUNCTION public.get_user_bmi_validation_history(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
  session_date DATE,
  questionnaire_type public.questionnaire_type,
  bmi_value NUMERIC(5,2),
  weight_value NUMERIC(5,2),
  height_value NUMERIC(5,2),
  validation_successful BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    DATE(a.bmi_validated_at) as session_date,
    a.questionnaire_type,
    a.bmi_value_at_start as bmi_value,
    a.weight_at_validation as weight_value,
    a.height_at_validation as height_value,
    (a.bmi_value_at_start IS NOT NULL) as validation_successful
  FROM public.assessment_sessions a
  WHERE a.user_id = p_user_id
    AND a.bmi_validated_at IS NOT NULL
  ORDER BY a.bmi_validated_at DESC
  LIMIT p_limit;
END;
$$;

-- Add trigger to prevent questionnaire completion without BMI validation for required types
CREATE OR REPLACE FUNCTION public.enforce_bmi_validation_on_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_requires_bmi BOOLEAN := FALSE;
BEGIN
  -- Check if this is a completion update
  IF OLD.status != 'completed'::public.assessment_status AND 
     NEW.status = 'completed'::public.assessment_status THEN
    
    -- Check if questionnaire type requires BMI validation
    v_requires_bmi := NEW.questionnaire_type IN (
      'must'::public.questionnaire_type,
      'nrs_2002'::public.questionnaire_type,
      'nutritional_risk_assessment'::public.questionnaire_type,
      'sarc_f'::public.questionnaire_type,
      'consolidated_nutritional_assessment'::public.questionnaire_type
    );

    -- If BMI validation is required but not present, prevent completion
    IF v_requires_bmi AND NEW.bmi_validated_at IS NULL THEN
      RAISE EXCEPTION 'BMI validation required before completing % questionnaire', NEW.questionnaire_type;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger for BMI validation enforcement
DROP TRIGGER IF EXISTS trigger_enforce_bmi_validation ON public.assessment_sessions;
CREATE TRIGGER trigger_enforce_bmi_validation
  BEFORE UPDATE ON public.assessment_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_bmi_validation_on_completion();

-- Add RLS policies for new functions
ALTER TABLE public.assessment_sessions ENABLE ROW LEVEL SECURITY;

-- Update RLS policy to include new BMI fields
DROP POLICY IF EXISTS users_manage_own_assessment_sessions ON public.assessment_sessions;
CREATE POLICY users_manage_own_assessment_sessions ON public.assessment_sessions
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Grant execute permissions for the new functions
GRANT EXECUTE ON FUNCTION public.validate_bmi_for_questionnaire(UUID, public.questionnaire_type) TO authenticated;
GRANT EXECUTE ON FUNCTION public.start_assessment_session_with_bmi_validation(UUID, public.questionnaire_type) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_bmi_validation_history(UUID, INTEGER) TO authenticated;

-- Add helpful comments
COMMENT ON FUNCTION public.validate_bmi_for_questionnaire(UUID, public.questionnaire_type) IS 
  'Validates BMI requirements for questionnaires that require current weight/height data';

COMMENT ON FUNCTION public.start_assessment_session_with_bmi_validation(UUID, public.questionnaire_type) IS 
  'Creates assessment session with built-in BMI validation for applicable questionnaire types';

COMMENT ON FUNCTION public.get_user_bmi_validation_history(UUID, INTEGER) IS 
  'Retrieves BMI validation history for tracking and analytics purposes';