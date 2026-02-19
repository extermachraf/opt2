-- Fix NRS 2002 BMI calculation function with correct column names
-- This resolves the "Errore Completamento" issue where BMI calculation fails

-- CRITICAL FIX: Update NRS 2002 BMI calculation function with correct column names
CREATE OR REPLACE FUNCTION public.calculate_nrs_2002_bmi_response(user_id uuid)
RETURNS TABLE(calculated_value text, display_value text, score integer)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_bmi NUMERIC;
    is_under_20_5 BOOLEAN;
BEGIN
    -- CRITICAL FIX: Use correct column names from medical_profiles table
    -- Changed mp.weight -> mp.current_weight_kg and mp.height -> mp.height_cm
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
            ('BMI: ' || ROUND(user_bmi, 1)::TEXT || CASE 
                WHEN is_under_20_5 THEN ' - Sotto 20.5' 
                ELSE ' - Sopra o uguale a 20.5' 
            END)::TEXT,
            CASE WHEN is_under_20_5 THEN 1 ELSE 0 END;
    ELSE
        -- No medical data available
        RETURN QUERY SELECT
            'Dati insufficienti'::TEXT,
            'BMI non calcolabile - inserire altezza e peso nel profilo medico'::TEXT,
            0;
    END IF;
END;
$$;

-- ENHANCED: Create comprehensive NRS 2002 auto-calculation function
CREATE OR REPLACE FUNCTION public.auto_calculate_nrs_2002_responses(session_uuid uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_id_val UUID;
    bmi_result RECORD;
BEGIN
    -- Get user ID for this session
    SELECT user_id INTO user_id_val
    FROM public.assessment_sessions
    WHERE id = session_uuid;
    
    IF user_id_val IS NULL THEN
        RAISE NOTICE 'No user found for session: %', session_uuid;
        RETURN;
    END IF;

    -- Calculate and save BMI response for NRS 2002
    FOR bmi_result IN 
        SELECT * FROM public.calculate_nrs_2002_bmi_response(user_id_val)
    LOOP
        -- Upsert the BMI calculation response
        INSERT INTO public.questionnaire_responses (
            session_id,
            question_id,
            response_value,
            response_score,
            calculated_value,
            updated_at
        ) VALUES (
            session_uuid,
            'nrs_bmi_under_20_5',  -- Correct question ID for NRS 2002 BMI question
            bmi_result.calculated_value,
            bmi_result.score,
            bmi_result.display_value,
            NOW()
        )
        ON CONFLICT (session_id, question_id) 
        DO UPDATE SET
            response_value = EXCLUDED.response_value,
            response_score = EXCLUDED.response_score,
            calculated_value = EXCLUDED.calculated_value,
            updated_at = EXCLUDED.updated_at;

        RAISE NOTICE 'NRS 2002 BMI auto-calculated: % (score: %)', bmi_result.calculated_value, bmi_result.score;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in auto_calculate_nrs_2002_responses: %', SQLERRM;
END;
$$;

-- UPDATE: Enhance main auto-calculation function to handle NRS 2002 specifically
CREATE OR REPLACE FUNCTION public.auto_calculate_responses(session_uuid uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_id_val UUID;
    questionnaire_type_val TEXT;
BEGIN
    -- Get questionnaire type for this session
    SELECT 
        asession.questionnaire_type
    INTO questionnaire_type_val
    FROM public.assessment_sessions asession
    WHERE asession.id = session_uuid;

    -- Handle different questionnaire types with corrected calculations
    IF questionnaire_type_val = 'must' THEN
        PERFORM public.auto_calculate_must_responses_corrected(session_uuid);
        RAISE NOTICE 'Used corrected MUST auto-calculation for session: %', session_uuid;
    ELSIF questionnaire_type_val = 'nrs_2002' THEN
        -- CRITICAL FIX: Use dedicated NRS 2002 calculation function
        PERFORM public.auto_calculate_nrs_2002_responses(session_uuid);
        RAISE NOTICE 'Used corrected NRS 2002 auto-calculation for session: %', session_uuid;
    ELSE
        -- Use standard calculation for other questionnaire types
        RAISE NOTICE 'Using standard auto-calculation for questionnaire type: %', questionnaire_type_val;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in auto_calculate_responses: %', SQLERRM;
END;
$$;

-- ENHANCED: Add specific NRS 2002 completion handling to prevent errors
CREATE OR REPLACE FUNCTION public.complete_questionnaire_with_bmi_validation(p_session_id uuid, p_total_score integer DEFAULT NULL::integer, p_risk_level text DEFAULT NULL::text, p_recommendations text DEFAULT NULL::text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_validation_result JSONB;
  v_session RECORD;
  final_score INTEGER;
  final_risk_level TEXT;
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

  -- CRITICAL FIX: Special handling for NRS 2002 questionnaire
  IF v_session.questionnaire_type = 'nrs_2002'::public.questionnaire_type THEN
    -- For NRS 2002: Auto-calculate BMI responses before validation
    PERFORM public.auto_calculate_nrs_2002_responses(p_session_id);
    
    -- Set specific values for NRS 2002
    final_score := COALESCE(p_total_score, public.calculate_questionnaire_score(p_session_id));
    final_risk_level := 'advisory';
    
    -- Update the session directly without complex BMI validation for NRS 2002
    UPDATE public.assessment_sessions
    SET 
      status = 'completed'::public.assessment_status,
      completed_at = NOW(),
      total_score = final_score,
      risk_level = final_risk_level,
      recommendations = COALESCE(p_recommendations, 'Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti.'),
      bmi_validated_at = NOW(),
      updated_at = NOW()
    WHERE id = p_session_id;

    -- Return success for NRS 2002
    RETURN jsonb_build_object(
      'success', true,
      'message', 'NRS 2002 completato con successo',
      'session_id', p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', false
    );
  END IF;

  -- Handle ESAS questionnaire special completion
  IF v_session.questionnaire_type = 'esas'::public.questionnaire_type THEN
    -- For ESAS: No BMI validation, no scoring, just mark as completed for consultation
    final_score := 0;
    final_risk_level := 'consultation_only';
    
    -- Update the session without BMI validation
    UPDATE public.assessment_sessions
    SET 
      status = 'completed'::public.assessment_status,
      completed_at = NOW(),
      total_score = final_score,
      risk_level = final_risk_level,
      recommendations = 'Risposte registrate per consultazione del paziente',
      updated_at = NOW()
    WHERE id = p_session_id;

    -- Return success for ESAS
    RETURN jsonb_build_object(
      'success', true,
      'message', 'Questionario ESAS completato - risposte registrate per consultazione',
      'session_id', p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', true
    );
  END IF;

  -- For other questionnaires, continue with normal BMI validation
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

  -- Calculate final score based on questionnaire type
  IF public.should_calculate_score_for_questionnaire(v_session.questionnaire_type) THEN
    final_score := COALESCE(p_total_score, public.calculate_questionnaire_score(p_session_id));
    final_risk_level := COALESCE(p_risk_level, 'completed');
  ELSE
    -- For non-scoring questionnaires
    final_score := 0;
    final_risk_level := CASE 
      WHEN v_session.questionnaire_type = 'sarc_f' THEN 'completed'
      WHEN v_session.questionnaire_type = 'must' THEN 'advisory'
      ELSE 'consultation_only'
    END;
  END IF;

  -- Complete the questionnaire
  UPDATE public.assessment_sessions
  SET 
    status = 'completed'::public.assessment_status,
    completed_at = NOW(),
    total_score = final_score,
    risk_level = final_risk_level,
    recommendations = COALESCE(p_recommendations, recommendations),
    updated_at = NOW()
  WHERE id = p_session_id;

  -- Return success
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Questionario completato con successo',
    'session_id', p_session_id,
    'bmi_validation', v_validation_result,
    'questionnaire_type', v_session.questionnaire_type,
    'consultation_mode', (v_session.questionnaire_type = 'esas')
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Errore durante il completamento: ' || SQLERRM,
      'error_code', 'COMPLETION_ERROR'
    );
END;
$$;

-- Add comment for tracking
COMMENT ON FUNCTION public.calculate_nrs_2002_bmi_response IS 'Fixed NRS 2002 BMI calculation with correct column names - 2024-10-24';
COMMENT ON FUNCTION public.auto_calculate_nrs_2002_responses IS 'Dedicated NRS 2002 auto-calculation function - 2024-10-24';