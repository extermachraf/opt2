-- Fix: "column reference started_at is ambiguous" in get_todays_questionnaire_session
-- The RETURNS TABLE declares columns named "started_at" and "completed_at" which clash
-- with the identically-named columns on assessment_sessions inside the query.
-- Solution: rename the output columns to avoid any ambiguity, and fully qualify
-- every column reference inside the body.

-- Step 1: Drop existing function (return type changed, so CREATE OR REPLACE alone won't work)
DROP FUNCTION IF EXISTS public.get_todays_questionnaire_session(UUID, public.questionnaire_type);

-- Recreate get_todays_questionnaire_session with unambiguous output names
CREATE OR REPLACE FUNCTION public.get_todays_questionnaire_session(
  p_user_id UUID,
  p_questionnaire_type public.questionnaire_type
)
RETURNS TABLE (
  session_id UUID,
  status public.assessment_status,
  session_started_at TIMESTAMPTZ,
  session_completed_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
  RETURN QUERY
  SELECT
    a.id            AS session_id,
    a.status        AS status,
    a.started_at    AS session_started_at,
    a.completed_at  AS session_completed_at
  FROM public.assessment_sessions a
  WHERE a.user_id = p_user_id
    AND a.questionnaire_type = p_questionnaire_type
    AND a.started_at::date = CURRENT_DATE
  ORDER BY a.started_at DESC
  LIMIT 1;
END;
$func$;

COMMENT ON FUNCTION public.get_todays_questionnaire_session(UUID, public.questionnaire_type) IS
'Returns the most recent questionnaire session for a user created today. Output columns renamed to session_started_at / session_completed_at to avoid PL/pgSQL ambiguity with table columns.';

-- Step 2: Fix can_start_new_questionnaire_session (same ambiguity on started_at)
CREATE OR REPLACE FUNCTION public.can_start_new_questionnaire_session(
  p_user_id UUID,
  p_questionnaire_type public.questionnaire_type
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
  v_session_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_session_count
  FROM public.assessment_sessions a
  WHERE a.user_id = p_user_id
    AND a.questionnaire_type = p_questionnaire_type
    AND a.started_at::date = CURRENT_DATE;

  RETURN v_session_count = 0;
END;
$func$;

COMMENT ON FUNCTION public.can_start_new_questionnaire_session(UUID, public.questionnaire_type) IS
'Checks if a user can start a new questionnaire session today. Returns false if a session already exists for today.';

