-- =====================================================================================
-- MIGRATION: Fix Questionnaire Progress Calculation
-- Description: Fixes progress calculation logic and prevents duplicate sessions
-- Author: AI Assistant
-- Created: 2025-09-25 21:55:34
-- Updated: 2025-09-25 22:00:34 (Fixed duplicate data constraint issue)
-- =====================================================================================

-- Step 1: FIRST handle existing duplicate sessions to prevent constraint violation
-- Keep only the most recent completed session for each user-questionnaire combination
WITH duplicate_sessions AS (
  SELECT 
    id,
    user_id,
    questionnaire_type,
    status,
    ROW_NUMBER() OVER (
      PARTITION BY user_id, questionnaire_type 
      ORDER BY completed_at DESC NULLS LAST, created_at DESC, updated_at DESC
    ) as rn
  FROM public.assessment_sessions
  WHERE status = 'completed'
)
UPDATE public.assessment_sessions
SET status = 'cancelled',
    updated_at = CURRENT_TIMESTAMP
WHERE id IN (
  SELECT id 
  FROM duplicate_sessions 
  WHERE rn > 1
)
AND status = 'completed';

-- Step 2: Add unique constraint to prevent duplicate questionnaire completions per user
-- This ensures users can't retake the same questionnaire type and have it count multiple times
CREATE UNIQUE INDEX IF NOT EXISTS idx_assessment_sessions_unique_completed 
ON public.assessment_sessions (user_id, questionnaire_type)
WHERE status = 'completed';

-- Step 3: Create improved function for calculating questionnaire progress
-- This function calculates progress based only on unique completed questionnaires per user
CREATE OR REPLACE FUNCTION public.calculate_user_questionnaire_progress(
  target_user_id UUID
)
RETURNS TABLE (
  questionnaire_type public.questionnaire_type,
  template_id UUID,
  title TEXT,
  category TEXT,
  total_questions INTEGER,
  completed_responses INTEGER,
  completion_percentage INTEGER,
  is_completed BOOLEAN,
  completed_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    qt.questionnaire_type,
    qt.id as template_id,
    qt.title,
    qt.category,
    COALESCE(question_counts.question_count, 0) as total_questions,
    COALESCE(response_counts.response_count, 0) as completed_responses,
    CASE 
      WHEN COALESCE(question_counts.question_count, 0) = 0 THEN 0
      ELSE ROUND((COALESCE(response_counts.response_count, 0)::DECIMAL / question_counts.question_count::DECIMAL) * 100)::INTEGER
    END as completion_percentage,
    (COALESCE(response_counts.response_count, 0) >= COALESCE(question_counts.question_count, 0) 
     AND COALESCE(question_counts.question_count, 0) > 0) as is_completed,
    completed_sessions.completed_at
  FROM public.questionnaire_templates qt
  
  -- Get question counts for each template
  LEFT JOIN (
    SELECT 
      template_id,
      COUNT(*) as question_count
    FROM public.questionnaire_questions
    GROUP BY template_id
  ) question_counts ON question_counts.template_id = qt.id
  
  -- Get unique completed sessions per questionnaire type (prevents duplicates)
  LEFT JOIN (
    SELECT DISTINCT ON (questionnaire_type)
      questionnaire_type,
      completed_at,
      id as session_id
    FROM public.assessment_sessions
    WHERE user_id = target_user_id
      AND status = 'completed'
    ORDER BY questionnaire_type, completed_at DESC
  ) completed_sessions ON completed_sessions.questionnaire_type = qt.questionnaire_type
  
  -- Get response counts for the latest completed session only
  LEFT JOIN (
    SELECT 
      qs.questionnaire_type,
      COUNT(qr.*) as response_count
    FROM public.assessment_sessions qs
    INNER JOIN public.questionnaire_responses qr ON qr.session_id = qs.id
    WHERE qs.user_id = target_user_id 
      AND qs.status = 'completed'
      AND qs.id IN (
        -- Only count responses from the latest completed session per questionnaire type
        SELECT DISTINCT ON (questionnaire_type) id
        FROM public.assessment_sessions
        WHERE user_id = target_user_id AND status = 'completed'
        ORDER BY questionnaire_type, completed_at DESC
      )
    GROUP BY qs.questionnaire_type
  ) response_counts ON response_counts.questionnaire_type = qt.questionnaire_type
  
  WHERE qt.is_active = true
  ORDER BY qt.category, qt.title;
END;
$$;

-- Step 4: Create function to calculate overall user progress (realistic calculation)
CREATE OR REPLACE FUNCTION public.calculate_user_overall_progress(
  target_user_id UUID
)
RETURNS TABLE (
  total_questionnaires INTEGER,
  completed_questionnaires INTEGER,
  total_questions INTEGER,
  completed_questions INTEGER,
  overall_percentage INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_questionnaires,
    COUNT(CASE WHEN progress.is_completed THEN 1 END)::INTEGER as completed_questionnaires,
    SUM(progress.total_questions)::INTEGER as total_questions,
    SUM(progress.completed_responses)::INTEGER as completed_questions,
    CASE 
      WHEN SUM(progress.total_questions) = 0 THEN 0
      ELSE ROUND((SUM(progress.completed_responses)::DECIMAL / SUM(progress.total_questions)::DECIMAL) * 100)::INTEGER
    END as overall_percentage
  FROM public.calculate_user_questionnaire_progress(target_user_id) progress;
END;
$$;

-- Step 5: Create helper function to check if questionnaire is already completed
CREATE OR REPLACE FUNCTION public.is_questionnaire_completed(
  target_user_id UUID,
  questionnaire_type_param public.questionnaire_type
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  completed_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO completed_count
  FROM public.assessment_sessions
  WHERE user_id = target_user_id
    AND questionnaire_type = questionnaire_type_param
    AND status = 'completed';
    
  RETURN completed_count > 0;
END;
$$;

-- Step 6: Add comments to document the changes
COMMENT ON FUNCTION public.calculate_user_questionnaire_progress(UUID) IS 
'Calculates realistic questionnaire progress preventing duplicate counting of retaken questionnaires';

COMMENT ON FUNCTION public.calculate_user_overall_progress(UUID) IS 
'Calculates overall user progress based on unique questionnaire completions only';

COMMENT ON FUNCTION public.is_questionnaire_completed(UUID, public.questionnaire_type) IS 
'Checks if user has already completed a specific questionnaire type to prevent duplicates';

-- Step 7: Create trigger to prevent future duplicate completions
CREATE OR REPLACE FUNCTION public.prevent_duplicate_questionnaire_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Only check when status is being set to 'completed'
  IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
    -- Check if user already has a completed session for this questionnaire type
    IF public.is_questionnaire_completed(NEW.user_id, NEW.questionnaire_type) THEN
      RAISE EXCEPTION 'User has already completed questionnaire type: %. Cannot complete the same questionnaire multiple times.', NEW.questionnaire_type
      USING HINT = 'This questionnaire type has already been completed by this user',
            ERRCODE = 'unique_violation';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Apply the trigger to assessment_sessions table
DROP TRIGGER IF EXISTS trigger_prevent_duplicate_completion ON public.assessment_sessions;
CREATE TRIGGER trigger_prevent_duplicate_completion
  BEFORE UPDATE ON public.assessment_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_duplicate_questionnaire_completion();

-- Step 8: Also add trigger for INSERT operations to prevent duplicates on creation
DROP TRIGGER IF EXISTS trigger_prevent_duplicate_completion_insert ON public.assessment_sessions;
CREATE TRIGGER trigger_prevent_duplicate_completion_insert
  BEFORE INSERT ON public.assessment_sessions
  FOR EACH ROW
  WHEN (NEW.status = 'completed')
  EXECUTE FUNCTION public.prevent_duplicate_questionnaire_completion();

-- Step 9: Add sample data update to show corrected progress calculation
-- Update existing user's progress to demonstrate the fix
UPDATE public.assessment_sessions 
SET updated_at = CURRENT_TIMESTAMP
WHERE user_id IN (
  SELECT DISTINCT user_id 
  FROM public.assessment_sessions 
  WHERE status = 'completed'
)
AND status = 'completed';

-- Step 10: Create index for better performance on progress queries  
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_user_status_type 
ON public.assessment_sessions (user_id, status, questionnaire_type, completed_at);

CREATE INDEX IF NOT EXISTS idx_questionnaire_responses_session_count
ON public.questionnaire_responses (session_id);

-- Step 11: Add index to optimize duplicate detection
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_duplicate_check
ON public.assessment_sessions (user_id, questionnaire_type, status) 
WHERE status = 'completed';

-- Step 12: Verification query to ensure no duplicates remain
-- This will help verify the migration worked correctly
DO $$
DECLARE
  duplicate_count INTEGER;
BEGIN
  SELECT COUNT(*) 
  INTO duplicate_count
  FROM (
    SELECT user_id, questionnaire_type, COUNT(*)
    FROM public.assessment_sessions
    WHERE status = 'completed'
    GROUP BY user_id, questionnaire_type
    HAVING COUNT(*) > 1
  ) duplicates;
  
  IF duplicate_count > 0 THEN
    RAISE WARNING 'Found % duplicate completed assessment sessions after migration', duplicate_count;
  ELSE
    RAISE NOTICE 'Migration successful: No duplicate completed assessment sessions found';
  END IF;
END $$;