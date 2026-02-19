-- Schema Analysis: Existing questionnaire system with assessment_sessions, questionnaire_responses, and unique constraints
-- Integration Type: modification/enhancement 
-- Dependencies: assessment_sessions, questionnaire_responses, questionnaire_templates, user_profiles
-- Purpose: Enable questionnaire retaking by removing unique constraint and adding retake functionality

-- Step 1: Drop the unique constraint that prevents duplicate completions
DROP INDEX IF EXISTS public.idx_assessment_sessions_unique_completed;

-- Step 2: Remove the trigger that prevents duplicate completion
DROP TRIGGER IF EXISTS trigger_prevent_duplicate_completion ON public.assessment_sessions;
DROP TRIGGER IF EXISTS trigger_prevent_duplicate_completion_insert ON public.assessment_sessions;

-- Step 3: Create function to reset questionnaire progress for retaking
CREATE OR REPLACE FUNCTION public.reset_questionnaire_progress(
    p_user_id UUID, 
    p_questionnaire_type public.questionnaire_type
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    new_session_id UUID;
    sessions_to_delete UUID[];
BEGIN
    -- Get all session IDs for this user and questionnaire type (both completed and in_progress)
    SELECT ARRAY_AGG(id) INTO sessions_to_delete
    FROM public.assessment_sessions
    WHERE user_id = p_user_id 
    AND questionnaire_type = p_questionnaire_type;
    
    -- Delete questionnaire responses for these sessions (child records first)
    DELETE FROM public.questionnaire_responses 
    WHERE session_id = ANY(sessions_to_delete);
    
    -- Delete the assessment sessions
    DELETE FROM public.assessment_sessions 
    WHERE user_id = p_user_id 
    AND questionnaire_type = p_questionnaire_type;
    
    -- Create a new fresh session for retaking
    INSERT INTO public.assessment_sessions (
        user_id,
        questionnaire_type,
        status,
        started_at,
        created_at,
        updated_at
    )
    VALUES (
        p_user_id,
        p_questionnaire_type,
        'in_progress'::public.assessment_status,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO new_session_id;
    
    RETURN new_session_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error resetting questionnaire progress: %', SQLERRM;
        RETURN NULL;
END;
$func$;

-- Step 4: Create function to check if retaking is allowed (always true now)
CREATE OR REPLACE FUNCTION public.can_retake_questionnaire(
    p_user_id UUID, 
    p_questionnaire_type public.questionnaire_type
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
    -- Allow retaking for all questionnaires
    SELECT true;
$func$;

-- Step 5: Update the existing is_questionnaire_completed function to be more specific
CREATE OR REPLACE FUNCTION public.is_questionnaire_completed(target_user_id UUID, questionnaire_type_param public.questionnaire_type)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    completed_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO completed_count
    FROM public.assessment_sessions
    WHERE user_id = target_user_id
    AND questionnaire_type = questionnaire_type_param
    AND status = 'completed'::public.assessment_status;
    
    RETURN completed_count > 0;
END;
$func$;

-- Step 6: Create function to get the latest assessment session for a user and questionnaire type
CREATE OR REPLACE FUNCTION public.get_latest_assessment_session(
    p_user_id UUID,
    p_questionnaire_type public.questionnaire_type
)
RETURNS TABLE (
    session_id UUID,
    session_status TEXT,
    completed_at TIMESTAMPTZ,
    can_retake BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    RETURN QUERY
    SELECT 
        id,
        status::TEXT,
        completed_at,
        true::BOOLEAN as can_retake
    FROM public.assessment_sessions
    WHERE user_id = p_user_id
    AND questionnaire_type = p_questionnaire_type
    ORDER BY updated_at DESC, created_at DESC
    LIMIT 1;
END;
$func$;

-- Step 7: Add retaking support to the existing progress calculation function
CREATE OR REPLACE FUNCTION public.calculate_user_questionnaire_progress_with_retake(target_user_id UUID)
RETURNS TABLE (
    questionnaire_type public.questionnaire_type,
    template_id UUID,
    title TEXT,
    category TEXT,
    total_questions INTEGER,
    completed_responses INTEGER,
    completion_percentage INTEGER,
    is_completed BOOLEAN,
    completed_at TIMESTAMPTZ,
    can_retake BOOLEAN,
    session_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
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
            COUNT(qr.id) as response_count
        FROM latest_sessions ls
        LEFT JOIN public.questionnaire_responses qr ON ls.session_id = qr.session_id
        GROUP BY ls.questionnaire_type, ls.session_id, ls.status, ls.completed_at
    )
    SELECT
        qt.questionnaire_type,
        qt.id as template_id,
        qt.title,
        qt.category,
        COALESCE(question_counts.total_questions, 0) as total_questions,
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
            COUNT(qq.id) as total_questions
        FROM public.questionnaire_questions qq
        GROUP BY qq.template_id
    ) question_counts ON qt.id = question_counts.template_id
    LEFT JOIN session_responses sr ON qt.questionnaire_type = sr.questionnaire_type
    WHERE qt.is_active = true
    ORDER BY qt.created_at;
END;
$func$;

-- Add index for better performance on retaking queries
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_user_type_updated 
ON public.assessment_sessions(user_id, questionnaire_type, updated_at DESC, created_at DESC);

-- Comment explaining the change
COMMENT ON FUNCTION public.reset_questionnaire_progress IS 'Resets questionnaire progress by deleting existing sessions and responses, then creates a new fresh session for retaking';
COMMENT ON FUNCTION public.can_retake_questionnaire IS 'Returns true as all questionnaires can now be retaken';
COMMENT ON FUNCTION public.calculate_user_questionnaire_progress_with_retake IS 'Enhanced progress calculation that includes retaking capability flag';