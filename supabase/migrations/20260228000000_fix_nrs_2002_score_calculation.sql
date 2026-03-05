-- Location: supabase/migrations/20260228000000_fix_nrs_2002_score_calculation.sql
-- Purpose: Fix NRS 2002 final score calculation
--   1. Create calculate_nrs_2002_total_score: sums ONLY Q6+Q7 response_score,
--      and adds +1 age bonus if user age > 69.
--   2. Update complete_questionnaire_with_bmi_validation to use the new function
--      for NRS 2002 instead of the generic calculate_questionnaire_score.

-- Step 1: Create (or replace) the correct NRS 2002 score function
CREATE OR REPLACE FUNCTION public.calculate_nrs_2002_total_score(p_session_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    q6_score INTEGER := 0;
    q7_score INTEGER := 0;
    age_bonus INTEGER := 0;
    user_age  INTEGER;
BEGIN
    -- Q6: nutritional status score (0-3)
    SELECT COALESCE(response_score, 0)
    INTO q6_score
    FROM public.questionnaire_responses
    WHERE session_id = p_session_id
      AND question_id = 'nrs_nutritional_status';

    -- Q7: disease severity score (0-3)
    SELECT COALESCE(response_score, 0)
    INTO q7_score
    FROM public.questionnaire_responses
    WHERE session_id = p_session_id
      AND question_id = 'nrs_disease_severity';

    -- Age bonus: +1 if user is older than 69
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, up.date_of_birth))::INTEGER
    INTO user_age
    FROM public.assessment_sessions asess
    JOIN public.user_profiles up ON asess.user_id = up.id
    WHERE asess.id = p_session_id;

    IF user_age IS NOT NULL AND user_age > 69 THEN
        age_bonus := 1;
    END IF;

    RETURN q6_score + q7_score + age_bonus;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$;

COMMENT ON FUNCTION public.calculate_nrs_2002_total_score(UUID) IS
  'NRS 2002 score: sum of Q6 (nutritional status, 0-3) + Q7 (disease severity, 0-3) + age bonus (+1 if age > 69). Q1-Q5 are screening-only and carry no score.';

-- Step 2: Replace complete_questionnaire_with_bmi_validation so the NRS 2002
-- branch uses calculate_nrs_2002_total_score instead of calculate_questionnaire_score.
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

  -- NRS 2002: auto-calculate BMI response, then score only Q6+Q7 plus age bonus
  IF v_session.questionnaire_type = 'nrs_2002'::public.questionnaire_type THEN
    PERFORM public.auto_calculate_nrs_2002_responses(p_session_id);

    final_score     := COALESCE(p_total_score, public.calculate_nrs_2002_total_score(p_session_id));
    final_risk_level := 'advisory';

    UPDATE public.assessment_sessions
    SET
      status           = 'completed'::public.assessment_status,
      completed_at     = NOW(),
      total_score      = final_score,
      risk_level       = final_risk_level,
      recommendations  = COALESCE(p_recommendations, 'Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti.'),
      bmi_validated_at = NOW(),
      updated_at       = NOW()
    WHERE id = p_session_id;

    RETURN jsonb_build_object(
      'success',            true,
      'message',            'NRS 2002 completato con successo',
      'session_id',         p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode',  false
    );
  END IF;

  -- ESAS: no scoring, consultation only
  IF v_session.questionnaire_type = 'esas'::public.questionnaire_type THEN
    UPDATE public.assessment_sessions
    SET status = 'completed'::public.assessment_status, completed_at = NOW(),
        total_score = 0, risk_level = 'consultation_only',
        recommendations = 'Risposte registrate per consultazione del paziente',
        updated_at = NOW()
    WHERE id = p_session_id;
    RETURN jsonb_build_object('success', true,
      'message', 'Questionario ESAS completato - risposte registrate per consultazione',
      'session_id', p_session_id, 'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', true);
  END IF;

  -- SARC-F: no scoring
  IF v_session.questionnaire_type = 'sarc_f'::public.questionnaire_type THEN
    UPDATE public.assessment_sessions
    SET status = 'completed'::public.assessment_status, completed_at = NOW(),
        total_score = 0, risk_level = 'completed',
        recommendations = 'Risposte SARC-F registrate per consultazione del professionista sanitario',
        updated_at = NOW()
    WHERE id = p_session_id;
    RETURN jsonb_build_object('success', true,
      'message', 'SARC-F completato con successo - risposte registrate',
      'session_id', p_session_id, 'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', true);
  END IF;

  -- SF-12: no scoring
  IF v_session.questionnaire_type = 'sf12'::public.questionnaire_type THEN
    UPDATE public.assessment_sessions
    SET status = 'completed'::public.assessment_status, completed_at = NOW(),
        total_score = 0, risk_level = 'completed',
        recommendations = 'Risposte SF-12 registrate per consultazione del professionista sanitario',
        updated_at = NOW()
    WHERE id = p_session_id;
    RETURN jsonb_build_object('success', true,
      'message', 'SF-12 completato con successo - risposte registrate',
      'session_id', p_session_id, 'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', true);
  END IF;

  -- MUST and other scoring questionnaires: BMI validation + generic score sum
  v_validation_result := public.validate_and_update_bmi_for_session(p_session_id);

  IF NOT (v_validation_result->>'is_valid')::boolean THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', v_validation_result->>'message',
      'error_code', COALESCE(v_validation_result->>'error_code', 'BMI_VALIDATION_FAILED'),
      'validation_details', v_validation_result
    );
  END IF;

  IF public.should_calculate_score_for_questionnaire(v_session.questionnaire_type::text) THEN
    final_score      := COALESCE(p_total_score, public.calculate_questionnaire_score(p_session_id));
    final_risk_level := COALESCE(p_risk_level, 'completed');
  ELSE
    final_score      := 0;
    final_risk_level := 'consultation_only';
  END IF;

  UPDATE public.assessment_sessions
  SET status = 'completed'::public.assessment_status, completed_at = NOW(),
      total_score = final_score, risk_level = final_risk_level,
      recommendations = COALESCE(p_recommendations, recommendations),
      updated_at = NOW()
  WHERE id = p_session_id;

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

COMMENT ON FUNCTION public.complete_questionnaire_with_bmi_validation(uuid, integer, text, text) IS
  'NRS 2002 now uses calculate_nrs_2002_total_score (Q6+Q7+age bonus). Updated 2026-02-28.';

