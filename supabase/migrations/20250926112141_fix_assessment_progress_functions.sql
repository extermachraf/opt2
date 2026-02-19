-- Fix Assessment Progress Functions - resolve column ambiguity and improve error handling
-- Generated: 2025-09-26 11:21:41

-- First, let's recreate the calculate_user_questionnaire_progress function with proper table aliases
CREATE OR REPLACE FUNCTION public.calculate_user_questionnaire_progress(target_user_id uuid)
RETURNS TABLE(
  questionnaire_type public.questionnaire_type,
  template_id uuid,
  title text,
  category text,
  total_questions integer,
  completed_responses integer,
  completion_percentage integer,
  is_completed boolean,
  completed_at timestamp with time zone
)
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
    (COALESCE(response_counts.response_count, 0) >= COALESCE(question_counts.question_count, 0) 
     AND COALESCE(question_counts.question_count, 0) > 0) as is_completed,
    completed_sessions.completed_at
  FROM public.questionnaire_templates qt
  
  -- Get question counts for each template (fixed alias)
  LEFT JOIN (
    SELECT 
      qq.template_id,
      COUNT(*) as question_count
    FROM public.questionnaire_questions qq
    GROUP BY qq.template_id
  ) question_counts ON question_counts.template_id = qt.id
  
  -- Get unique completed sessions per questionnaire type (prevents duplicates)
  LEFT JOIN (
    SELECT DISTINCT ON (asess.questionnaire_type)
      asess.questionnaire_type,
      asess.completed_at,
      asess.id as session_id
    FROM public.assessment_sessions asess
    WHERE asess.user_id = target_user_id
      AND asess.status = 'completed'::public.assessment_status
    ORDER BY asess.questionnaire_type, asess.completed_at DESC
  ) completed_sessions ON completed_sessions.questionnaire_type = qt.questionnaire_type
  
  -- Get response counts for the latest completed session only
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

-- Recreate the calculate_user_overall_progress function with better error handling
CREATE OR REPLACE FUNCTION public.calculate_user_overall_progress(target_user_id uuid)
RETURNS TABLE(
  total_questionnaires integer,
  completed_questionnaires integer,
  total_questions integer,
  completed_questions integer,
  overall_percentage integer
)
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
  -- Use a more explicit approach to avoid column ambiguity
  FOR questionnaire_progress IN 
    SELECT 
      prog.questionnaire_type,
      prog.template_id,
      prog.title,
      prog.category,
      prog.total_questions,
      prog.completed_responses,
      prog.completion_percentage,
      prog.is_completed,
      prog.completed_at
    FROM public.calculate_user_questionnaire_progress(target_user_id) prog
  LOOP
    total_qs := total_qs + 1;
    total_questions_count := total_questions_count + COALESCE(questionnaire_progress.total_questions, 0);
    completed_questions_count := completed_questions_count + COALESCE(questionnaire_progress.completed_responses, 0);
    
    IF questionnaire_progress.is_completed THEN
      completed_qs := completed_qs + 1;
    END IF;
  END LOOP;
  
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

-- Create a fallback function for when progress calculation fails
CREATE OR REPLACE FUNCTION public.get_basic_assessment_progress(target_user_id uuid)
RETURNS TABLE(
  total_questionnaires integer,
  completed_questionnaires integer,
  total_questions integer,
  completed_questions integer,
  overall_percentage integer
)
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
              WHERE asess.user_id = target_user_id
                AND asess.status = 'completed'::public.assessment_status), 0) as completed_questions,
    CASE 
      WHEN (SELECT COUNT(*) FROM public.questionnaire_questions qq 
            INNER JOIN public.questionnaire_templates qt ON qt.id = qq.template_id
            WHERE qt.is_active = true) = 0 THEN 0
      ELSE ROUND((
        (SELECT COUNT(*) FROM public.questionnaire_responses qr
         INNER JOIN public.assessment_sessions asess ON asess.id = qr.session_id
         WHERE asess.user_id = target_user_id
           AND asess.status = 'completed'::public.assessment_status)::DECIMAL / 
        (SELECT COUNT(*) FROM public.questionnaire_questions qq 
         INNER JOIN public.questionnaire_templates qt ON qt.id = qq.template_id
         WHERE qt.is_active = true)::DECIMAL
      ) * 100)::INTEGER
    END as overall_percentage;
END;
$function$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.calculate_user_questionnaire_progress(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_user_overall_progress(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_basic_assessment_progress(uuid) TO authenticated;

-- Add comments for documentation
COMMENT ON FUNCTION public.calculate_user_questionnaire_progress(uuid) IS 
'Fixed function to calculate individual questionnaire progress with proper table aliases to avoid column ambiguity';

COMMENT ON FUNCTION public.calculate_user_overall_progress(uuid) IS 
'Fixed function to calculate overall assessment progress using explicit loop approach';

COMMENT ON FUNCTION public.get_basic_assessment_progress(uuid) IS 
'Fallback function for basic assessment progress when main functions fail';