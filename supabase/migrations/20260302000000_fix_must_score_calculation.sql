-- Location: supabase/migrations/20260302000000_fix_must_score_calculation.sql
-- Purpose: Fix MUST questionnaire always returning score = 0.
--
-- Root cause: complete_questionnaire_with_bmi_validation did not call
-- auto_calculate_must_responses_corrected before summing response_score values.
-- As a result the BMI question's response_score was never set in the DB when
-- the Flutter client skipped the MUST-specific BMI-save path (e.g. because
-- _questionnaireType was not resolved correctly from navigation args).
--
-- Fix: add a MUST-specific branch (mirrors the NRS 2002 branch) that:
--   1. Calls auto_calculate_must_responses_corrected – ensures the BMI
--      response_score is saved with the correct value (0/1/2) derived from the
--      user's actual BMI.
--   2. Then sums ALL response_scores with calculate_questionnaire_score (which
--      already works correctly for Q2 weight-loss and Q3 acute-illness).
--
-- This is safe for all other questionnaires: the new branch is guarded by
--   v_session.questionnaire_type = 'must'::public.questionnaire_type
-- so NRS 2002, ESAS, SARC-F, SF-12 and any future types are not affected.

CREATE OR REPLACE FUNCTION public.complete_questionnaire_with_bmi_validation(
  p_session_id    uuid,
  p_total_score   integer DEFAULT NULL::integer,
  p_risk_level    text    DEFAULT NULL::text,
  p_recommendations text  DEFAULT NULL::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_validation_result JSONB;
  v_session           RECORD;
  final_score         INTEGER;
  final_risk_level    TEXT;
BEGIN
  -- Get session info
  SELECT questionnaire_type, status, user_id
  INTO   v_session
  FROM   public.assessment_sessions
  WHERE  id = p_session_id;

  IF v_session IS NULL THEN
    RETURN jsonb_build_object(
      'success', false, 'message', 'Sessione non trovata',
      'error_code', 'SESSION_NOT_FOUND');
  END IF;

  IF v_session.status = 'completed'::public.assessment_status THEN
    RETURN jsonb_build_object(
      'success', false, 'message', 'Questionario già completato',
      'error_code', 'ALREADY_COMPLETED');
  END IF;

  -- ── NRS 2002 ──────────────────────────────────────────────────────────────
  IF v_session.questionnaire_type = 'nrs_2002'::public.questionnaire_type THEN
    PERFORM public.auto_calculate_nrs_2002_responses(p_session_id);

    final_score      := COALESCE(p_total_score, public.calculate_nrs_2002_total_score(p_session_id));
    final_risk_level := 'advisory';

    UPDATE public.assessment_sessions
    SET status           = 'completed'::public.assessment_status,
        completed_at     = NOW(),
        total_score      = final_score,
        risk_level       = final_risk_level,
        recommendations  = COALESCE(p_recommendations,
          'Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti.'),
        bmi_validated_at = NOW(),
        updated_at       = NOW()
    WHERE id = p_session_id;

    RETURN jsonb_build_object(
      'success', true, 'message', 'NRS 2002 completato con successo',
      'session_id', p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'consultation_mode', false);
  END IF;

  -- ── MUST ──────────────────────────────────────────────────────────────────
  -- Auto-calculate the BMI response_score BEFORE summing to avoid score = 0
  IF v_session.questionnaire_type = 'must'::public.questionnaire_type THEN
    -- Ensure height/weight are available (also sets bmi_validated_at)
    v_validation_result := public.validate_and_update_bmi_for_session(p_session_id);

    IF NOT (v_validation_result->>'is_valid')::boolean THEN
      RETURN jsonb_build_object(
        'success', false,
        'message', v_validation_result->>'message',
        'error_code', COALESCE(v_validation_result->>'error_code', 'BMI_VALIDATION_FAILED'),
        'validation_details', v_validation_result);
    END IF;

    -- Write (or overwrite) the BMI response with the correct score (0/1/2)
    PERFORM public.auto_calculate_must_responses_corrected(p_session_id);

    final_score      := COALESCE(p_total_score, public.calculate_questionnaire_score(p_session_id));
    final_risk_level := COALESCE(p_risk_level, 'completed');

    UPDATE public.assessment_sessions
    SET status          = 'completed'::public.assessment_status,
        completed_at    = NOW(),
        total_score     = final_score,
        risk_level      = final_risk_level,
        recommendations = COALESCE(p_recommendations,
          'Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti'),
        updated_at      = NOW()
    WHERE id = p_session_id;

    RETURN jsonb_build_object(
      'success', true, 'message', 'MUST completato con successo',
      'session_id', p_session_id,
      'questionnaire_type', v_session.questionnaire_type,
      'bmi_validation', v_validation_result,
      'consultation_mode', false);
  END IF;

  -- ── ESAS ──────────────────────────────────────────────────────────────────
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

  -- ── SARC-F ────────────────────────────────────────────────────────────────
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

  -- ── SF-12 ─────────────────────────────────────────────────────────────────
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

  -- ── All other scoring questionnaires ──────────────────────────────────────
  v_validation_result := public.validate_and_update_bmi_for_session(p_session_id);

  IF NOT (v_validation_result->>'is_valid')::boolean THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', v_validation_result->>'message',
      'error_code', COALESCE(v_validation_result->>'error_code', 'BMI_VALIDATION_FAILED'),
      'validation_details', v_validation_result);
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
    'success', true, 'message', 'Questionario completato con successo',
    'session_id', p_session_id,
    'bmi_validation', v_validation_result,
    'questionnaire_type', v_session.questionnaire_type,
    'consultation_mode', (v_session.questionnaire_type = 'esas'));

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Errore durante il completamento: ' || SQLERRM,
      'error_code', 'COMPLETION_ERROR');
END;
$function$;

COMMENT ON FUNCTION public.complete_questionnaire_with_bmi_validation(uuid, integer, text, text) IS
  'MUST now calls auto_calculate_must_responses_corrected before scoring to fix score=0 bug. Updated 2026-03-02.';

