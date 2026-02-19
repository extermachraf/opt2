-- Location: supabase/migrations/20250121083147_fix_questionnaire_completion_error.sql
-- Schema Analysis: Complete questionnaire system exists with BMI validation
-- Integration Type: Fix - Resolve questionnaire completion errors
-- Dependencies: assessment_sessions, questionnaire_templates, medical_profiles, weight_entries

-- CRITICAL FIX: Fix BMI validation issues preventing questionnaire completion
-- Issue: Users get "Errore Completamento" when submitting MUST, NRS 2002, and Valutazione Rischio Nutrizionale
-- Root Cause: BMI validation required but bmi_validated_at field not properly set during completion

-- Step 1: Create enhanced BMI validation function that automatically validates and updates sessions
CREATE OR REPLACE FUNCTION public.validate_and_update_bmi_for_session(p_session_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
  v_session RECORD;
  v_weight_entry RECORD;
  v_medical_profile RECORD;
  v_bmi NUMERIC(5,2);
  v_requires_bmi BOOLEAN := FALSE;
  v_today DATE := CURRENT_DATE;
BEGIN
  -- Get session details
  SELECT user_id, questionnaire_type, bmi_validated_at
  INTO v_session
  FROM public.assessment_sessions
  WHERE id = p_session_id;

  -- If session not found, return error
  IF v_session IS NULL THEN
    RETURN jsonb_build_object(
      'is_valid', false,
      'message', 'Sessione non trovata',
      'error_code', 'SESSION_NOT_FOUND'
    );
  END IF;

  -- Check if questionnaire type requires BMI validation
  v_requires_bmi := v_session.questionnaire_type IN (
    'must'::public.questionnaire_type,
    'nrs_2002'::public.questionnaire_type,
    'nutritional_risk_assessment'::public.questionnaire_type,
    'consolidated_nutritional_assessment'::public.questionnaire_type
  );

  -- If BMI validation not required, mark as valid
  IF NOT v_requires_bmi THEN
    RETURN jsonb_build_object(
      'is_valid', true,
      'message', 'BMI validation not required for this questionnaire',
      'requires_bmi_validation', false
    );
  END IF;

  -- If already validated, return success
  IF v_session.bmi_validated_at IS NOT NULL THEN
    RETURN jsonb_build_object(
      'is_valid', true,
      'message', 'BMI already validated for this session',
      'requires_bmi_validation', true,
      'already_validated', true
    );
  END IF;

  -- Get most recent weight entry (not just today's)
  SELECT weight_kg, recorded_at
  INTO v_weight_entry
  FROM public.weight_entries
  WHERE user_id = v_session.user_id
  ORDER BY recorded_at DESC
  LIMIT 1;

  -- Get medical profile with height
  SELECT height_cm, current_weight_kg
  INTO v_medical_profile
  FROM public.medical_profiles
  WHERE user_id = v_session.user_id
  LIMIT 1;

  -- Use weight from weight_entries or fallback to medical_profiles
  DECLARE
    v_weight NUMERIC;
    v_height NUMERIC;
  BEGIN
    v_weight := COALESCE(v_weight_entry.weight_kg, v_medical_profile.current_weight_kg);
    v_height := v_medical_profile.height_cm;

    -- Validate we have required data
    IF v_weight IS NULL OR v_weight <= 0 THEN
      RETURN jsonb_build_object(
        'is_valid', false,
        'message', 'Peso non disponibile. Inserisci il peso nel profilo medico per continuare.',
        'requires_weight_update', true,
        'requires_height_update', v_height IS NULL OR v_height <= 0,
        'error_code', 'MISSING_WEIGHT'
      );
    END IF;

    IF v_height IS NULL OR v_height <= 0 THEN
      RETURN jsonb_build_object(
        'is_valid', false,
        'message', 'Altezza non disponibile. Inserisci l''altezza nel profilo medico per continuare.',
        'requires_weight_update', false,
        'requires_height_update', true,
        'error_code', 'MISSING_HEIGHT'
      );
    END IF;

    -- Calculate BMI
    v_bmi := v_weight / POWER((v_height / 100.0), 2);

    -- Validate BMI calculation
    IF v_bmi IS NULL OR v_bmi <= 0 OR v_bmi > 100 THEN
      RETURN jsonb_build_object(
        'is_valid', false,
        'message', 'BMI non valido calcolato dai dati forniti. Verifica peso e altezza.',
        'requires_weight_update', true,
        'requires_height_update', true,
        'error_code', 'INVALID_BMI'
      );
    END IF;

    -- Update session with BMI validation data
    UPDATE public.assessment_sessions
    SET 
      bmi_validated_at = NOW(),
      bmi_value_at_start = v_bmi,
      weight_at_validation = v_weight,
      height_at_validation = v_height,
      updated_at = NOW()
    WHERE id = p_session_id;

    -- Return successful validation
    RETURN jsonb_build_object(
      'is_valid', true,
      'message', 'BMI validato automaticamente: ' || ROUND(v_bmi, 1),
      'bmi_value', ROUND(v_bmi, 1),
      'weight', v_weight,
      'height', v_height,
      'requires_bmi_validation', true,
      'auto_validated', true,
      'validation_date', NOW()::text
    );
  END;

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'is_valid', false,
      'message', 'Errore durante la validazione BMI: ' || SQLERRM,
      'error_code', 'VALIDATION_ERROR'
    );
END;
$func$;

-- Step 2: Create function to complete questionnaire with automatic BMI validation
CREATE OR REPLACE FUNCTION public.complete_questionnaire_with_bmi_validation(
  p_session_id uuid,
  p_total_score integer DEFAULT NULL,
  p_risk_level text DEFAULT NULL,
  p_recommendations text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
  v_validation_result jsonb;
  v_session RECORD;
BEGIN
  -- Get session info
  SELECT questionnaire_type, status, user_id
  INTO v_session
  FROM public.assessment_sessions
  WHERE id = p_session_id;

  -- Check if session exists
  IF v_session IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Sessione non trovata',
      'error_code', 'SESSION_NOT_FOUND'
    );
  END IF;

  -- Check if already completed
  IF v_session.status = 'completed'::public.assessment_status THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Questionario già completato',
      'error_code', 'ALREADY_COMPLETED'
    );
  END IF;

  -- Validate BMI if required
  v_validation_result := public.validate_and_update_bmi_for_session(p_session_id);
  
  -- If BMI validation fails, return the validation error
  IF NOT (v_validation_result->>'is_valid')::boolean THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', v_validation_result->>'message',
      'error_code', COALESCE(v_validation_result->>'error_code', 'BMI_VALIDATION_FAILED'),
      'validation_details', v_validation_result
    );
  END IF;

  -- Complete the questionnaire
  UPDATE public.assessment_sessions
  SET 
    status = 'completed'::public.assessment_status,
    completed_at = NOW(),
    total_score = COALESCE(p_total_score, total_score),
    risk_level = COALESCE(p_risk_level, risk_level),
    recommendations = COALESCE(p_recommendations, recommendations),
    updated_at = NOW()
  WHERE id = p_session_id;

  -- Return success
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Questionario completato con successo',
    'session_id', p_session_id,
    'bmi_validation', v_validation_result,
    'questionnaire_type', v_session.questionnaire_type
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Errore durante il completamento: ' || SQLERRM,
      'error_code', 'COMPLETION_ERROR'
    );
END;
$func$;

-- Step 3: Update the BMI validation trigger to be more lenient and provide better error handling
CREATE OR REPLACE FUNCTION public.enforce_bmi_validation_on_completion()
RETURNS trigger
LANGUAGE plpgsql
AS $func$
DECLARE
  v_requires_bmi BOOLEAN := FALSE;
  v_validation_result jsonb;
BEGIN
  -- Check if this is a completion update
  IF OLD.status != 'completed'::public.assessment_status AND 
     NEW.status = 'completed'::public.assessment_status THEN
    
    -- Check if questionnaire type requires BMI validation
    v_requires_bmi := NEW.questionnaire_type IN (
      'must'::public.questionnaire_type,
      'nrs_2002'::public.questionnaire_type,
      'nutritional_risk_assessment'::public.questionnaire_type,
      'consolidated_nutritional_assessment'::public.questionnaire_type
    );

    -- If BMI validation is required but not present, try to validate automatically
    IF v_requires_bmi AND NEW.bmi_validated_at IS NULL THEN
      -- Attempt automatic BMI validation
      v_validation_result := public.validate_and_update_bmi_for_session(NEW.id);
      
      -- If automatic validation fails, provide helpful error message
      IF NOT (v_validation_result->>'is_valid')::boolean THEN
        RAISE EXCEPTION 'Completamento questionario bloccato: %', v_validation_result->>'message'
        USING HINT = 'Verifica che peso e altezza siano inseriti nel profilo medico';
      END IF;
      
      -- Update the NEW record with validation data if successful
      NEW.bmi_validated_at := NOW();
      NEW.bmi_value_at_start := (v_validation_result->>'bmi_value')::numeric;
      NEW.weight_at_validation := (v_validation_result->>'weight')::numeric;
      NEW.height_at_validation := (v_validation_result->>'height')::numeric;
    END IF;
  END IF;

  RETURN NEW;
END;
$func$;

-- Step 4: Create helper function to auto-validate BMI for existing incomplete sessions
CREATE OR REPLACE FUNCTION public.auto_validate_incomplete_sessions()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
  v_session RECORD;
  v_validation_result jsonb;
  v_updated_count integer := 0;
  v_failed_count integer := 0;
  v_results jsonb := '[]'::jsonb;
BEGIN
  -- Find incomplete sessions that require BMI validation but don't have it
  FOR v_session IN
    SELECT id, user_id, questionnaire_type
    FROM public.assessment_sessions
    WHERE status = 'in_progress'::public.assessment_status
    AND questionnaire_type IN (
      'must'::public.questionnaire_type,
      'nrs_2002'::public.questionnaire_type,
      'nutritional_risk_assessment'::public.questionnaire_type,
      'consolidated_nutritional_assessment'::public.questionnaire_type
    )
    AND bmi_validated_at IS NULL
  LOOP
    -- Try to validate BMI for this session
    v_validation_result := public.validate_and_update_bmi_for_session(v_session.id);
    
    IF (v_validation_result->>'is_valid')::boolean THEN
      v_updated_count := v_updated_count + 1;
    ELSE
      v_failed_count := v_failed_count + 1;
    END IF;
    
    -- Add result to results array
    v_results := v_results || jsonb_build_object(
      'session_id', v_session.id,
      'questionnaire_type', v_session.questionnaire_type,
      'result', v_validation_result
    );
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'updated_sessions', v_updated_count,
    'failed_sessions', v_failed_count,
    'details', v_results
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Errore durante la validazione automatica: ' || SQLERRM,
      'updated_sessions', v_updated_count,
      'failed_sessions', v_failed_count
    );
END;
$func$;

-- Step 5: Run automatic validation for existing incomplete sessions
DO $$
DECLARE
    v_result jsonb;
BEGIN
    -- Auto-validate existing incomplete sessions
    SELECT public.auto_validate_incomplete_sessions() INTO v_result;
    
    RAISE NOTICE 'Auto-validation result: %', v_result;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during auto-validation: %', SQLERRM;
END $$;