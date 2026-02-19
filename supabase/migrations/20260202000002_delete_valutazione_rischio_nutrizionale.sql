-- Location: supabase/migrations/20260202000002_delete_valutazione_rischio_nutrizionale.sql
-- Purpose: Delete "Valutazione del rischio nutrizionale" questionnaire
-- Questionnaire Type: nutritional_risk_assessment
-- This will delete:
-- 1. All questionnaire responses for this questionnaire
-- 2. All assessment sessions for this questionnaire
-- 3. All questions for this questionnaire
-- 4. The questionnaire template itself

-- Step 1: Delete all responses for sessions of this questionnaire type
DELETE FROM public.questionnaire_responses
WHERE session_id IN (
    SELECT id FROM public.assessment_sessions
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type
);

-- Step 2: Delete all assessment sessions for this questionnaire type
DELETE FROM public.assessment_sessions
WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;

-- Step 3: Delete all questions for this questionnaire template
DELETE FROM public.questionnaire_questions
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type
);

-- Step 4: Delete the questionnaire template itself
DELETE FROM public.questionnaire_templates
WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;

-- Verification block
DO $$
DECLARE
    template_count INTEGER;
    question_count INTEGER;
    session_count INTEGER;
    response_count INTEGER;
BEGIN
    -- Check if template still exists
    SELECT COUNT(*) INTO template_count
    FROM public.questionnaire_templates
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;
    
    -- Check if questions still exist
    SELECT COUNT(*) INTO question_count
    FROM public.questionnaire_questions
    WHERE template_id IN (
        SELECT id FROM public.questionnaire_templates
        WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type
    );
    
    -- Check if sessions still exist
    SELECT COUNT(*) INTO session_count
    FROM public.assessment_sessions
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;
    
    -- Check if responses still exist
    SELECT COUNT(*) INTO response_count
    FROM public.questionnaire_responses
    WHERE session_id IN (
        SELECT id FROM public.assessment_sessions
        WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type
    );
    
    -- Log results
    RAISE NOTICE 'Deletion verification:';
    RAISE NOTICE '- Templates remaining: %', template_count;
    RAISE NOTICE '- Questions remaining: %', question_count;
    RAISE NOTICE '- Sessions remaining: %', session_count;
    RAISE NOTICE '- Responses remaining: %', response_count;
    
    -- Verify deletion was successful
    IF template_count = 0 AND question_count = 0 AND session_count = 0 AND response_count = 0 THEN
        RAISE NOTICE '✅ SUCCESS: "Valutazione del rischio nutrizionale" questionnaire completely deleted';
    ELSE
        RAISE NOTICE '⚠️ WARNING: Some data may still exist:';
        IF template_count > 0 THEN
            RAISE NOTICE '  - % template(s) still exist', template_count;
        END IF;
        IF question_count > 0 THEN
            RAISE NOTICE '  - % question(s) still exist', question_count;
        END IF;
        IF session_count > 0 THEN
            RAISE NOTICE '  - % session(s) still exist', session_count;
        END IF;
        IF response_count > 0 THEN
            RAISE NOTICE '  - % response(s) still exist', response_count;
        END IF;
    END IF;
END $$;

-- Note: The enum value 'nutritional_risk_assessment' is kept in the questionnaire_type enum
-- to avoid breaking existing database constraints and migrations.
-- It will simply not be used anymore.

-- Add comment for documentation
COMMENT ON TYPE public.questionnaire_type IS 'Questionnaire types - nutritional_risk_assessment questionnaire deleted on 2026-02-02 (enum value kept for compatibility)';

