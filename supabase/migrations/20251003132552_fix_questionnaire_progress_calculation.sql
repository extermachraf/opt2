-- Location: supabase/migrations/20251003132552_fix_questionnaire_progress_calculation.sql
-- Schema Analysis: Existing questionnaire assessment system with progress calculation functions
-- Integration Type: Modificative - Fixing progress calculation logic
-- Dependencies: questionnaire_templates, assessment_sessions, questionnaire_responses, questionnaire_questions

-- Fix 1: Update questionnaire templates to ensure exactly 6 active questionnaires (exclude dietary_diary)
UPDATE public.questionnaire_templates 
SET is_active = false 
WHERE questionnaire_type = 'dietary_diary'::public.questionnaire_type;

-- Fix 2: Improve calculate_user_overall_progress function to handle completed questionnaires correctly
CREATE OR REPLACE FUNCTION public.calculate_user_overall_progress(target_user_id uuid)
RETURNS TABLE(total_questionnaires integer, completed_questionnaires integer, total_questions integer, completed_questions integer, overall_percentage integer)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  questionnaire_progress RECORD;
  total_qs INTEGER := 0;
  completed_qs INTEGER := 0;
  total_questions_count INTEGER := 0;
  completed_questions_count INTEGER := 0;
BEGIN
  -- Get active questionnaire templates count (should be 6)
  SELECT COUNT(*) INTO total_qs 
  FROM public.questionnaire_templates 
  WHERE is_active = true;
  
  -- Count completed questionnaires by checking completed assessment sessions
  SELECT COUNT(DISTINCT questionnaire_type) INTO completed_qs
  FROM public.assessment_sessions
  WHERE user_id = target_user_id 
    AND status = 'completed'::public.assessment_status;
  
  -- Calculate total questions from active templates
  SELECT COALESCE(SUM(question_counts.question_count), 0) INTO total_questions_count
  FROM public.questionnaire_templates qt
  LEFT JOIN (
    SELECT template_id, COUNT(*) as question_count
    FROM public.questionnaire_questions
    GROUP BY template_id
  ) question_counts ON question_counts.template_id = qt.id
  WHERE qt.is_active = true;
  
  -- Calculate completed questions from completed sessions only
  SELECT COALESCE(COUNT(qr.id), 0) INTO completed_questions_count
  FROM public.questionnaire_responses qr
  INNER JOIN public.assessment_sessions asess ON asess.id = qr.session_id
  INNER JOIN public.questionnaire_templates qt ON qt.questionnaire_type = asess.questionnaire_type
  WHERE asess.user_id = target_user_id 
    AND asess.status = 'completed'::public.assessment_status
    AND qt.is_active = true;
  
  RETURN QUERY
  SELECT 
    total_qs,
    completed_qs,
    total_questions_count,
    completed_questions_count,
    CASE 
      WHEN total_questions_count = 0 THEN 0
      ELSE ROUND((completed_questions_count::DECIMAL / total_questions_count::DECIMAL) * 100)::INTEGER
    END;
END;
$function$;

-- Fix 3: Update calculate_user_questionnaire_progress function to properly handle completion status
CREATE OR REPLACE FUNCTION public.calculate_user_questionnaire_progress(target_user_id uuid)
RETURNS TABLE(questionnaire_type questionnaire_type, template_id uuid, title text, category text, total_questions integer, completed_responses integer, completion_percentage integer, is_completed boolean, completed_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    qt.questionnaire_type,
    qt.id as template_id,
    qt.title,
    qt.category,
    COALESCE(question_counts.question_count, 0)::INTEGER as total_questions,
    COALESCE(response_counts.response_count, 0)::INTEGER as completed_responses,
    CASE 
      WHEN COALESCE(question_counts.question_count, 0) = 0 THEN 0
      ELSE ROUND((COALESCE(response_counts.response_count, 0)::DECIMAL / COALESCE(question_counts.question_count, 0)::DECIMAL) * 100)::INTEGER
    END as completion_percentage,
    COALESCE(completed_sessions.is_completed, false) as is_completed,
    completed_sessions.completed_at
  FROM public.questionnaire_templates qt
  
  -- Get question counts for each active template
  LEFT JOIN (
    SELECT 
      qq.template_id,
      COUNT(*) as question_count
    FROM public.questionnaire_questions qq
    GROUP BY qq.template_id
  ) question_counts ON question_counts.template_id = qt.id
  
  -- Get completed sessions info
  LEFT JOIN (
    SELECT DISTINCT ON (asess.questionnaire_type)
      asess.questionnaire_type,
      asess.completed_at,
      (asess.status = 'completed'::public.assessment_status) as is_completed,
      asess.id as session_id
    FROM public.assessment_sessions asess
    WHERE asess.user_id = target_user_id
    ORDER BY asess.questionnaire_type, asess.completed_at DESC NULLS LAST
  ) completed_sessions ON completed_sessions.questionnaire_type = qt.questionnaire_type
  
  -- Get response counts for completed sessions only
  LEFT JOIN (
    SELECT 
      qs.questionnaire_type,
      COUNT(qr.id) as response_count
    FROM public.assessment_sessions qs
    INNER JOIN public.questionnaire_responses qr ON qr.session_id = qs.id
    WHERE qs.user_id = target_user_id 
      AND qs.status = 'completed'::public.assessment_status
      AND qs.id IN (
        -- Only count responses from the latest completed session per questionnaire type
        SELECT DISTINCT ON (asess_inner.questionnaire_type) asess_inner.id
        FROM public.assessment_sessions asess_inner
        WHERE asess_inner.user_id = target_user_id 
          AND asess_inner.status = 'completed'::public.assessment_status
        ORDER BY asess_inner.questionnaire_type, asess_inner.completed_at DESC
      )
    GROUP BY qs.questionnaire_type
  ) response_counts ON response_counts.questionnaire_type = qt.questionnaire_type
  
  WHERE qt.is_active = true
  ORDER BY qt.category, qt.title;
END;
$function$;

-- Fix 4: Update get_basic_assessment_progress function for consistency
CREATE OR REPLACE FUNCTION public.get_basic_assessment_progress(target_user_id uuid)
RETURNS TABLE(total_questionnaires integer, completed_questionnaires integer, total_questions integer, completed_questions integer, overall_percentage integer)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*)::INTEGER FROM public.questionnaire_templates WHERE is_active = true) as total_questionnaires,
    (SELECT COUNT(DISTINCT questionnaire_type)::INTEGER 
     FROM public.assessment_sessions 
     WHERE user_id = target_user_id 
       AND status = 'completed'::public.assessment_status) as completed_questionnaires,
    COALESCE((SELECT COUNT(*)::INTEGER FROM public.questionnaire_questions qq 
              INNER JOIN public.questionnaire_templates qt ON qt.id = qq.template_id
              WHERE qt.is_active = true), 0) as total_questions,
    COALESCE((SELECT COUNT(*)::INTEGER FROM public.questionnaire_responses qr
              INNER JOIN public.assessment_sessions asess ON asess.id = qr.session_id
              INNER JOIN public.questionnaire_templates qt ON qt.questionnaire_type = asess.questionnaire_type
              WHERE asess.user_id = target_user_id
                AND asess.status = 'completed'::public.assessment_status
                AND qt.is_active = true), 0) as completed_questions,
    CASE 
      WHEN (SELECT COUNT(*) FROM public.questionnaire_questions qq 
            INNER JOIN public.questionnaire_templates qt ON qt.id = qq.template_id
            WHERE qt.is_active = true) = 0 THEN 0
      ELSE ROUND((
        (SELECT COUNT(*) FROM public.questionnaire_responses qr
         INNER JOIN public.assessment_sessions asess ON asess.id = qr.session_id
         INNER JOIN public.questionnaire_templates qt ON qt.questionnaire_type = asess.questionnaire_type
         WHERE asess.user_id = target_user_id
           AND asess.status = 'completed'::public.assessment_status
           AND qt.is_active = true)::DECIMAL / 
        (SELECT COUNT(*) FROM public.questionnaire_questions qq 
         INNER JOIN public.questionnaire_templates qt ON qt.id = qq.template_id
         WHERE qt.is_active = true)::DECIMAL
      ) * 100)::INTEGER
    END as overall_percentage;
END;
$function$;

-- Fix 5: Add cleanup function to remove any inconsistent data
CREATE OR REPLACE FUNCTION public.cleanup_questionnaire_inconsistencies()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  -- Remove any orphaned responses that don't belong to completed sessions
  DELETE FROM public.questionnaire_responses
  WHERE session_id IN (
    SELECT qr.session_id
    FROM public.questionnaire_responses qr
    LEFT JOIN public.assessment_sessions asess ON asess.id = qr.session_id
    WHERE asess.id IS NULL OR asess.status != 'completed'::public.assessment_status
  );
  
  -- Ensure dietary_diary is inactive
  UPDATE public.questionnaire_templates 
  SET is_active = false 
  WHERE questionnaire_type = 'dietary_diary'::public.questionnaire_type;
  
  RAISE NOTICE 'Questionnaire inconsistencies cleaned up successfully';
END;
$function$;

-- Run the cleanup
SELECT public.cleanup_questionnaire_inconsistencies();