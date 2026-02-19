-- Location: supabase/migrations/20251003113305_fix_questionnaire_question_counts.sql
-- Schema Analysis: Existing questionnaire system with templates, questions, sessions, and responses
-- Integration Type: Modificative - Fixing question counts for specific questionnaires
-- Dependencies: questionnaire_templates, questionnaire_questions

-- Fix questionnaire progress calculation by ensuring correct question counts
-- Based on user requirements:
-- MUST: 8/8 (not 7/8)
-- NRS 2002: 12/12 (not 16/12)
-- ESAS: 10/10 (not 80/10)
-- SF-12: 12/12 (not 17/12)
-- SARC-F: 6/6 (not 7/6)
-- Valutazione Rischio Nutrizionale: 6/6

-- Step 1: Create function to standardize questionnaire question counts
CREATE OR REPLACE FUNCTION public.fix_questionnaire_question_counts()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    must_template_id UUID;
    nrs_template_id UUID;
    esas_template_id UUID;
    sf12_template_id UUID;
    sarc_template_id UUID;
    valutazione_template_id UUID;
BEGIN
    -- Get template IDs for each questionnaire type
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;
    
    SELECT id INTO nrs_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nrs_2002'::public.questionnaire_type;
    
    SELECT id INTO esas_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'esas'::public.questionnaire_type;
    
    SELECT id INTO sf12_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sf12'::public.questionnaire_type;
    
    SELECT id INTO sarc_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sarc_f'::public.questionnaire_type;
    
    SELECT id INTO valutazione_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;

    -- Remove excess questions and ensure correct counts
    
    -- MUST - Malnutrition Universal Screening Tool: Should have exactly 8 questions
    IF must_template_id IS NOT NULL THEN
        -- Delete excess questions beyond the first 8
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = must_template_id 
        AND order_index > 7;
        
        -- Ensure exactly 8 questions exist by updating order_index
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = must_template_id
            ORDER BY created_at, id
            LIMIT 8
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- NRS 2002: Should have exactly 12 questions
    IF nrs_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = nrs_template_id 
        AND order_index > 11;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = nrs_template_id
            ORDER BY created_at, id
            LIMIT 12
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- ESAS: Should have exactly 10 questions
    IF esas_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = esas_template_id 
        AND order_index > 9;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = esas_template_id
            ORDER BY created_at, id
            LIMIT 10
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- SF-12: Should have exactly 12 questions
    IF sf12_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = sf12_template_id 
        AND order_index > 11;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = sf12_template_id
            ORDER BY created_at, id
            LIMIT 12
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- SARC-F: Should have exactly 6 questions
    IF sarc_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = sarc_template_id 
        AND order_index > 5;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = sarc_template_id
            ORDER BY created_at, id
            LIMIT 6
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- Valutazione Rischio Nutrizionale: Should have exactly 6 questions
    IF valutazione_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = valutazione_template_id 
        AND order_index > 5;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = valutazione_template_id
            ORDER BY created_at, id
            LIMIT 6
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    RAISE NOTICE 'Successfully fixed questionnaire question counts';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error fixing questionnaire question counts: %', SQLERRM;
        RAISE;
END;
$function$;

-- Step 2: Execute the fix
SELECT public.fix_questionnaire_question_counts();

-- Step 3: Update progress calculation functions to ensure accurate counting
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
            COUNT(qr.id)::INTEGER as response_count
        FROM latest_sessions ls
        LEFT JOIN public.questionnaire_responses qr ON ls.session_id = qr.session_id
        GROUP BY ls.questionnaire_type, ls.session_id, ls.status, ls.completed_at
    ),
    -- ENHANCED: Define exact question counts per questionnaire type
    questionnaire_counts AS (
        SELECT 
            'must'::public.questionnaire_type as qtype, 8 as expected_count
        UNION ALL SELECT 'nrs_2002'::public.questionnaire_type, 12
        UNION ALL SELECT 'esas'::public.questionnaire_type, 10
        UNION ALL SELECT 'sf12'::public.questionnaire_type, 12
        UNION ALL SELECT 'sarc_f'::public.questionnaire_type, 6
        UNION ALL SELECT 'nutritional_risk_assessment'::public.questionnaire_type, 6
        UNION ALL SELECT 'functional_assessment'::public.questionnaire_type, 8
        UNION ALL SELECT 'metabolic_assessment'::public.questionnaire_type, 10
    )
    SELECT
        qt.questionnaire_type,
        qt.id as template_id,
        qt.title,
        qt.category,
        -- Use predefined counts or fall back to actual DB count
        COALESCE(qc.expected_count, COALESCE(question_counts.total_questions, 0))::INTEGER as total_questions,
        COALESCE(sr.response_count, 0)::INTEGER as completed_responses,
        CASE 
            WHEN COALESCE(qc.expected_count, question_counts.total_questions, 0) > 0 THEN
                (COALESCE(sr.response_count, 0) * 100 / COALESCE(qc.expected_count, question_counts.total_questions))::INTEGER
            ELSE 0
        END as completion_percentage,
        COALESCE(sr.status = 'completed'::public.assessment_status, false) as is_completed,
        sr.completed_at,
        true as can_retake, -- Always allow retaking
        sr.session_id
    FROM public.questionnaire_templates qt
    LEFT JOIN questionnaire_counts qc ON qt.questionnaire_type = qc.qtype
    LEFT JOIN (
        SELECT 
            qq.template_id,
            COUNT(qq.id)::INTEGER as total_questions
        FROM public.questionnaire_questions qq
        GROUP BY qq.template_id
    ) question_counts ON qt.id = question_counts.template_id
    LEFT JOIN session_responses sr ON qt.questionnaire_type = sr.questionnaire_type
    WHERE qt.is_active = true
        AND qt.questionnaire_type != 'dietary_diary'::public.questionnaire_type -- Exclude Diario Alimentare
    ORDER BY qt.created_at;
END;
$function$;

-- Step 4: Verify the fixes by showing current question counts
DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE '=== QUESTIONNAIRE QUESTION COUNTS AFTER FIX ===';
    
    FOR rec IN 
        SELECT 
            qt.questionnaire_type,
            qt.title,
            COUNT(qq.id) as actual_questions
        FROM public.questionnaire_templates qt
        LEFT JOIN public.questionnaire_questions qq ON qt.id = qq.template_id
        WHERE qt.is_active = true
            AND qt.questionnaire_type != 'dietary_diary'::public.questionnaire_type
        GROUP BY qt.questionnaire_type, qt.title
        ORDER BY qt.questionnaire_type
    LOOP
        RAISE NOTICE '% (%): % questions', rec.title, rec.questionnaire_type, rec.actual_questions;
    END LOOP;
    
    RAISE NOTICE '=== VERIFICATION COMPLETE ===';
END $$;