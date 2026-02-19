-- Fix type mismatch in calculate_user_questionnaire_progress_with_retake function
-- Error: Returned type bigint does not match expected type integer in column 5

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS public.calculate_user_questionnaire_progress_with_retake(uuid);

-- Recreate the function with proper type casting
CREATE OR REPLACE FUNCTION public.calculate_user_questionnaire_progress_with_retake(target_user_id uuid)
 RETURNS TABLE(
    questionnaire_type public.questionnaire_type, 
    template_id uuid, 
    title text, 
    category text, 
    total_questions integer, 
    completed_responses integer, 
    completion_percentage integer, 
    is_completed boolean, 
    completed_at timestamp with time zone, 
    can_retake boolean, 
    session_id uuid
 )
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    WITH latest_sessions AS (
        SELECT DISTINCT ON (a.questionnaire_type)
            a.id as session_id,
            a.questionnaire_type,
            a.status,
            a.completed_at,
            a.updated_at,
            a.created_at
        FROM public.assessment_sessions a
        WHERE a.user_id = target_user_id
        ORDER BY a.questionnaire_type, a.updated_at DESC, a.created_at DESC
    ),
    session_responses AS (
        SELECT 
            ls.questionnaire_type,
            ls.session_id,
            ls.status,
            ls.completed_at,
            COUNT(qr.id)::INTEGER as response_count  -- Cast to INTEGER
        FROM latest_sessions ls
        LEFT JOIN public.questionnaire_responses qr ON ls.session_id = qr.session_id
        GROUP BY ls.questionnaire_type, ls.session_id, ls.status, ls.completed_at
    )
    SELECT
        qt.questionnaire_type,
        qt.id as template_id,
        qt.title,
        qt.category,
        COALESCE(question_counts.total_questions, 0)::INTEGER as total_questions,  -- Cast to INTEGER
        COALESCE(sr.response_count, 0)::INTEGER as completed_responses,
        CASE 
            WHEN COALESCE(question_counts.total_questions, 0) > 0 THEN
                (COALESCE(sr.response_count, 0) * 100 / question_counts.total_questions)::INTEGER
            ELSE 0
        END as completion_percentage,
        COALESCE(sr.status = 'completed', false) as is_completed,
        sr.completed_at,
        true as can_retake, -- Always allow retaking
        sr.session_id
    FROM public.questionnaire_templates qt
    LEFT JOIN (
        SELECT 
            qq.template_id,
            COUNT(qq.id)::INTEGER as total_questions  -- FIXED: Cast COUNT to INTEGER
        FROM public.questionnaire_questions qq
        GROUP BY qq.template_id
    ) question_counts ON qt.id = question_counts.template_id
    LEFT JOIN session_responses sr ON qt.questionnaire_type = sr.questionnaire_type
    WHERE qt.is_active = true
    ORDER BY qt.created_at;
END;
$function$;

-- Add comment explaining the fix
COMMENT ON FUNCTION public.calculate_user_questionnaire_progress_with_retake(uuid) IS 
'Fixed type mismatch error by explicitly casting COUNT() results to INTEGER to match return type specification. 
This resolves SQL Error Code 42804 where bigint was returned instead of integer.';

-- Test the function to ensure it works
DO $$
DECLARE
    test_user_id uuid := 'd4a87e24-2cab-4fc0-a753-fba15ba7c755';
    test_result RECORD;
BEGIN
    -- Test the function with a sample user ID
    SELECT * INTO test_result 
    FROM public.calculate_user_questionnaire_progress_with_retake(test_user_id) 
    LIMIT 1;
    
    RAISE NOTICE 'Function test completed successfully';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Function test failed: %', SQLERRM;
END $$;