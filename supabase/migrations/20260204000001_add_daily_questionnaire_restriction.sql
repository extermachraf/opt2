-- Location: supabase/migrations/20260204000001_add_daily_questionnaire_restriction.sql
-- Schema Analysis: Existing questionnaire system with assessment_sessions table
-- Integration Type: Enhancement - Adding daily restriction for questionnaire completion
-- Dependencies: assessment_sessions table, questionnaire_type enum

-- Purpose: Implement once-per-day questionnaire restriction while allowing same-day edits
-- This migration adds a function to check if a user has a questionnaire session for today
-- and returns the session ID if it exists, enabling edit mode instead of creating duplicates

-- Step 1: Create function to get today's session for a specific questionnaire type
CREATE OR REPLACE FUNCTION public.get_todays_questionnaire_session(
  p_user_id UUID,
  p_questionnaire_type public.questionnaire_type
)
RETURNS TABLE (
  session_id UUID,
  status public.assessment_status,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
  -- Get the most recent session for this questionnaire type created today
  RETURN QUERY
  SELECT
    id,
    assessment_sessions.status,
    assessment_sessions.started_at,
    assessment_sessions.completed_at
  FROM public.assessment_sessions
  WHERE user_id = p_user_id
    AND questionnaire_type = p_questionnaire_type
    AND started_at::date = CURRENT_DATE
  ORDER BY started_at DESC
  LIMIT 1;
END;
$func$;

-- Step 2: Create function to check if user can start a new questionnaire session today
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
  -- Check if user has any session for this questionnaire type today
  SELECT COUNT(*)
  INTO v_session_count
  FROM public.assessment_sessions
  WHERE user_id = p_user_id
    AND questionnaire_type = p_questionnaire_type
    AND started_at::date = CURRENT_DATE;

  -- Return true if no session exists for today
  RETURN v_session_count = 0;
END;
$func$;

-- Step 3: Add comments for documentation
COMMENT ON FUNCTION public.get_todays_questionnaire_session(UUID, public.questionnaire_type) IS 
'Returns the most recent questionnaire session for a user created today. Used to enable edit mode for same-day questionnaire completion.';

COMMENT ON FUNCTION public.can_start_new_questionnaire_session(UUID, public.questionnaire_type) IS 
'Checks if a user can start a new questionnaire session today. Returns false if a session already exists for today, enforcing once-per-day restriction.';

-- Step 4: Create index to optimize daily session lookups
-- Note: We create a regular index on started_at instead of a functional index on the date
-- This still helps with performance for date-based queries
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_user_type_started
ON public.assessment_sessions (user_id, questionnaire_type, started_at DESC);

COMMENT ON INDEX idx_assessment_sessions_user_type_started IS
'Optimizes lookups for daily questionnaire sessions by user and type. Uses started_at for range queries.';

