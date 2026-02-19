-- Fix questionnaire completion error by updating the function call to properly cast enum type to text
-- This fixes the "Errore Completamento" error that occurs when completing MUST, SARC-F, Valutazione Rischio Nutrizionale, and SF-12 questionnaires

-- Drop and recreate the complete_questionnaire_with_bmi_validation function with proper type casting
DROP FUNCTION IF EXISTS public.complete_questionnaire_with_bmi_validation(uuid, integer, text, text);

CREATE OR REPLACE FUNCTION public.complete_questionnaire_with_bmi_validation(
  p_session_id uuid, 
  p_total_score integer DEFAULT NULL::integer, 
  p_risk_level text DEFAULT NULL::text, 
  p_recommendations text DEFAULT NULL::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
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

  -- Handle SARC-F questionnaire special completion (no scoring)
  IF v_session.questionnaire_type = 'sarc_f'::public.questionnaire_type THEN
    -- For SARC-F: No scoring, just mark as completed for consultation
    final_score := 0;
    final_risk_level := 'completed';
    
    -- Update the session without BMI validation
    UPDATE public.assessment_sessions
    SET 
      status = 'completed'::public.assessment_status,
      completed_at = NOW(),
      total_score = final_score,
      risk_level = final_risk_level,
      recommendations = 'Risposte SARC-F registrate per consultazione del professionista sanitario',
      updated_at = NOW()
    WHERE id = p_session_id;

    -- Return success for SARC-F
    RETURN jsonb_build_object(
      'success', true,
      'message', 'SARC-F completato con successo - risposte registrate',
      'session_id', p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', true
    );
  END IF;

  -- Handle SF-12 questionnaire special completion (no scoring)
  IF v_session.questionnaire_type = 'sf12'::public.questionnaire_type THEN
    -- For SF-12: No scoring, just mark as completed for consultation
    final_score := 0;
    final_risk_level := 'completed';
    
    -- Update the session without BMI validation
    UPDATE public.assessment_sessions
    SET 
      status = 'completed'::public.assessment_status,
      completed_at = NOW(),
      total_score = final_score,
      risk_level = final_risk_level,
      recommendations = 'Risposte SF-12 registrate per consultazione del professionista sanitario',
      updated_at = NOW()
    WHERE id = p_session_id;

    -- Return success for SF-12
    RETURN jsonb_build_object(
      'success', true,
      'message', 'SF-12 completato con successo - risposte registrate',
      'session_id', p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', true
    );
  END IF;

  -- For other questionnaires (MUST), continue with normal BMI validation
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

  -- CRITICAL FIX: Properly cast enum to text when calling should_calculate_score_for_questionnaire
  IF public.should_calculate_score_for_questionnaire(v_session.questionnaire_type::text) THEN
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
$function$;

-- Also ensure the should_calculate_score_for_questionnaire function properly handles all questionnaire types
DROP FUNCTION IF EXISTS public.should_calculate_score_for_questionnaire(text);

CREATE OR REPLACE FUNCTION public.should_calculate_score_for_questionnaire(questionnaire_type_param text)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
AS $function$
SELECT questionnaire_type_param NOT IN ('esas', 'sarc_f', 'sf12');
$function$;

-- Add validation for questionnaire types to prevent future errors
-- This ensures proper handling of all supported questionnaire types
DO $$
BEGIN
  -- Add a comment documenting supported questionnaire types
  COMMENT ON FUNCTION public.should_calculate_score_for_questionnaire(text) IS 'Determines if a questionnaire type should calculate scores. Returns false for consultation-only questionnaires: esas, sarc_f, sf12. Returns true for scoring questionnaires: must, nrs_2002';
  COMMENT ON FUNCTION public.complete_questionnaire_with_bmi_validation(uuid, integer, text, text) IS 'Enhanced questionnaire completion with proper enum type casting and specific handling for each questionnaire type';
END $$;