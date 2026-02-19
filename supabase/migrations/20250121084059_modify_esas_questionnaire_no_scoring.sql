-- Location: supabase/migrations/20250121084059_modify_esas_questionnaire_no_scoring.sql
-- Schema Analysis: Existing questionnaire system with assessment_sessions, questionnaire_templates, questionnaire_questions, questionnaire_responses
-- Integration Type: Modification - Update ESAS questionnaire behavior to exclude scoring
-- Dependencies: assessment_sessions, questionnaire_templates, questionnaire_responses, calculate_questionnaire_score function

-- Update questionnaire templates to mark ESAS as non-scoring
UPDATE public.questionnaire_templates 
SET description = 'Valutazione dei sintomi e del benessere psicofisico - Le risposte vengono registrate solo per consultazione del paziente, senza calcolo del punteggio'
WHERE questionnaire_type = 'esas'::public.questionnaire_type;

-- Create function to check if questionnaire type should be scored
CREATE OR REPLACE FUNCTION public.should_calculate_score_for_questionnaire(questionnaire_type_param TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT questionnaire_type_param NOT IN ('esas', 'sarc_f');
$$;

-- Update the calculate_questionnaire_score function to exclude ESAS and SARC-F
CREATE OR REPLACE FUNCTION public.calculate_questionnaire_score(session_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    total_score INTEGER := 0;
    session_questionnaire_type TEXT;
BEGIN
    -- Get the questionnaire type for this session
    SELECT questionnaire_type INTO session_questionnaire_type
    FROM public.assessment_sessions
    WHERE id = session_uuid;
    
    -- Only calculate score for questionnaires that should be scored
    IF public.should_calculate_score_for_questionnaire(session_questionnaire_type) THEN
        -- Sum all response scores for the session
        SELECT COALESCE(SUM(qr.response_score), 0) INTO total_score
        FROM public.questionnaire_responses qr
        WHERE qr.session_id = session_uuid;
    ELSE
        -- For ESAS and SARC-F, return 0 (no scoring)
        total_score := 0;
    END IF;
    
    RETURN total_score;
END;
$func$;

-- Update complete_questionnaire_with_bmi_validation function to handle ESAS specially
CREATE OR REPLACE FUNCTION public.complete_questionnaire_with_bmi_validation(p_session_id UUID, p_total_score INTEGER DEFAULT NULL::integer, p_risk_level TEXT DEFAULT NULL::text, p_recommendations TEXT DEFAULT NULL::text)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
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
$func$;

-- Create function to get latest ESAS responses for patient consultation
CREATE OR REPLACE FUNCTION public.get_latest_esas_responses_for_patient(patient_user_id UUID)
RETURNS TABLE(
    session_id UUID,
    question_text TEXT,
    response_value TEXT,
    completed_at TIMESTAMPTZ,
    question_order INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT DISTINCT ON (qq.question_id)
    qr.session_id,
    qq.question_text,
    qr.response_value,
    ases.completed_at,
    qq.order_index as question_order
FROM public.questionnaire_responses qr
JOIN public.assessment_sessions ases ON qr.session_id = ases.id
JOIN public.questionnaire_templates qt ON ases.questionnaire_type = qt.questionnaire_type
JOIN public.questionnaire_questions qq ON qt.id = qq.template_id AND qr.question_id = qq.question_id
WHERE ases.user_id = patient_user_id
  AND ases.questionnaire_type = 'esas'::public.questionnaire_type
  AND ases.status = 'completed'::public.assessment_status
ORDER BY qq.question_id, ases.completed_at DESC, qq.order_index ASC;
$func$;

-- Create function to cleanup old ESAS sessions (keep only the latest attempt)
CREATE OR REPLACE FUNCTION public.cleanup_old_esas_sessions(patient_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    latest_session_id UUID;
    old_session_ids UUID[];
BEGIN
    -- Get the latest completed ESAS session
    SELECT id INTO latest_session_id
    FROM public.assessment_sessions
    WHERE user_id = patient_user_id
      AND questionnaire_type = 'esas'::public.questionnaire_type
      AND status = 'completed'::public.assessment_status
    ORDER BY completed_at DESC
    LIMIT 1;

    -- Get all other ESAS sessions for this user
    SELECT ARRAY_AGG(id) INTO old_session_ids
    FROM public.assessment_sessions
    WHERE user_id = patient_user_id
      AND questionnaire_type = 'esas'::public.questionnaire_type
      AND id != COALESCE(latest_session_id, '00000000-0000-0000-0000-000000000000'::UUID);

    -- Delete responses and sessions for old attempts
    IF array_length(old_session_ids, 1) > 0 THEN
        DELETE FROM public.questionnaire_responses 
        WHERE session_id = ANY(old_session_ids);
        
        DELETE FROM public.assessment_sessions 
        WHERE id = ANY(old_session_ids);
        
        RAISE NOTICE 'Cleaned up % old ESAS sessions for user %', array_length(old_session_ids, 1), patient_user_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error cleaning up old ESAS sessions: %', SQLERRM;
END;
$func$;

-- Add trigger to automatically cleanup old ESAS sessions when a new one is completed
CREATE OR REPLACE FUNCTION public.trigger_cleanup_old_esas_on_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    -- Only trigger cleanup for ESAS questionnaires when status changes to completed
    IF NEW.questionnaire_type = 'esas'::public.questionnaire_type 
       AND NEW.status = 'completed'::public.assessment_status 
       AND (OLD.status IS NULL OR OLD.status != 'completed'::public.assessment_status) THEN
        
        PERFORM public.cleanup_old_esas_sessions(NEW.user_id);
    END IF;
    
    RETURN NEW;
END;
$func$;

-- Create trigger for automatic cleanup
DROP TRIGGER IF EXISTS trigger_cleanup_esas_sessions ON public.assessment_sessions;
CREATE TRIGGER trigger_cleanup_esas_sessions
    AFTER UPDATE ON public.assessment_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_cleanup_old_esas_on_completion();

-- Set all existing completed ESAS sessions to consultation_only risk level
UPDATE public.assessment_sessions 
SET 
    risk_level = 'consultation_only',
    total_score = 0,
    recommendations = 'Risposte registrate per consultazione del paziente',
    updated_at = NOW()
WHERE questionnaire_type = 'esas'::public.questionnaire_type 
  AND status = 'completed'::public.assessment_status;

-- Add helpful comment for future reference
COMMENT ON FUNCTION public.get_latest_esas_responses_for_patient IS 'Retrieves the latest ESAS questionnaire responses for patient consultation. Only returns responses from the most recent completed ESAS attempt.';
COMMENT ON FUNCTION public.cleanup_old_esas_sessions IS 'Removes old ESAS sessions and responses, keeping only the latest attempt for each patient.';
COMMENT ON FUNCTION public.should_calculate_score_for_questionnaire IS 'Determines if a questionnaire type should have its score calculated. ESAS and SARC-F questionnaires do not calculate scores.';