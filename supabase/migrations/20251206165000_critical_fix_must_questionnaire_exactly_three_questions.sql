-- ====================================================================
-- CRITICAL FIX: Ensure MUST questionnaire has exactly 3 questions
-- ====================================================================
-- Migration: 20251206165000_critical_fix_must_questionnaire_exactly_three_questions.sql
-- Purpose: Fix MUST questionnaire to have exactly 3 questions as specified
-- Questions: 1) BMI (calculated), 2) Weight Loss (3 options), 3) Acute Illness (yes/no)

BEGIN;

-- Get the MUST questionnaire template ID
DO $$
DECLARE
    must_template_id UUID;
    question_count INTEGER;
    bmi_question_exists BOOLEAN := FALSE;
    weight_loss_question_exists BOOLEAN := FALSE;
    acute_illness_question_exists BOOLEAN := FALSE;
BEGIN
    -- Find MUST template
    SELECT id INTO must_template_id
    FROM public.questionnaire_templates
    WHERE questionnaire_type = 'must' AND is_active = true
    LIMIT 1;

    IF must_template_id IS NULL THEN
        RAISE NOTICE 'MUST template not found, skipping fix';
        RETURN;
    END IF;

    RAISE NOTICE 'Found MUST template: %', must_template_id;

    -- Count current questions
    SELECT COUNT(*) INTO question_count
    FROM public.questionnaire_questions
    WHERE template_id = must_template_id;

    RAISE NOTICE 'Current MUST questions count: %', question_count;

    -- Check which questions exist
    SELECT EXISTS(
        SELECT 1 FROM public.questionnaire_questions 
        WHERE template_id = must_template_id 
        AND question_type = 'calculated' 
        AND question_id LIKE '%bmi%'
    ) INTO bmi_question_exists;

    SELECT EXISTS(
        SELECT 1 FROM public.questionnaire_questions 
        WHERE template_id = must_template_id 
        AND question_type = 'single_choice' 
        AND (question_id LIKE '%weight%' OR question_text ILIKE '%peso%')
    ) INTO weight_loss_question_exists;

    SELECT EXISTS(
        SELECT 1 FROM public.questionnaire_questions 
        WHERE template_id = must_template_id 
        AND question_type = 'yes_no' 
        AND (question_id LIKE '%illness%' OR question_text ILIKE '%malattia%')
    ) INTO acute_illness_question_exists;

    RAISE NOTICE 'Questions check - BMI: %, Weight Loss: %, Acute Illness: %', 
                 bmi_question_exists, weight_loss_question_exists, acute_illness_question_exists;

    -- If we have more than 3 questions, remove excess ones
    IF question_count > 3 THEN
        RAISE NOTICE 'Removing excess MUST questions (keeping only first 3 by order_index)';
        
        DELETE FROM public.questionnaire_questions
        WHERE template_id = must_template_id
        AND id NOT IN (
            SELECT id
            FROM public.questionnaire_questions
            WHERE template_id = must_template_id
            ORDER BY order_index ASC, created_at ASC
            LIMIT 3
        );
        
        RAISE NOTICE 'Removed excess MUST questions';
    END IF;

    -- Ensure we have exactly the 3 required questions
    
    -- 1. BMI Question (calculated)
    IF NOT bmi_question_exists THEN
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            order_index, is_required, options, scores
        ) VALUES (
            must_template_id,
            'must_bmi_calculated',
            'Calcolo BMI (Body Mass Index)',
            'calculated',
            1,
            true,
            NULL,
            NULL
        );
        RAISE NOTICE 'Added BMI question';
    ELSE
        -- Update existing BMI question to ensure correct properties
        UPDATE public.questionnaire_questions
        SET question_id = 'must_bmi_calculated',
            question_type = 'calculated',
            order_index = 1,
            is_required = true
        WHERE template_id = must_template_id 
        AND question_type = 'calculated' 
        AND question_id LIKE '%bmi%';
        RAISE NOTICE 'Updated existing BMI question';
    END IF;

    -- 2. Weight Loss Question (single choice)
    IF NOT weight_loss_question_exists THEN
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            order_index, is_required, options, scores
        ) VALUES (
            must_template_id,
            'must_weight_loss_3months',
            'Perdita di peso involontaria negli ultimi 3 mesi',
            'single_choice',
            2,
            true,
            '["Nessuna perdita di peso (0 punti)", "1-3 kg o perdita di peso non quantificata (1 punto)", "Più di 3 kg (2 punti)"]'::jsonb,
            '[0, 1, 2]'::jsonb
        );
        RAISE NOTICE 'Added weight loss question';
    ELSE
        -- Update existing weight loss question
        UPDATE public.questionnaire_questions
        SET question_id = 'must_weight_loss_3months',
            question_type = 'single_choice',
            order_index = 2,
            is_required = true,
            options = '["Nessuna perdita di peso (0 punti)", "1-3 kg o perdita di peso non quantificata (1 punto)", "Più di 3 kg (2 punti)"]'::jsonb,
            scores = '[0, 1, 2]'::jsonb
        WHERE template_id = must_template_id 
        AND question_type = 'single_choice' 
        AND (question_id LIKE '%weight%' OR question_text ILIKE '%peso%');
        RAISE NOTICE 'Updated existing weight loss question';
    END IF;

    -- 3. Acute Illness Question (yes/no)
    IF NOT acute_illness_question_exists THEN
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            order_index, is_required, options, scores
        ) VALUES (
            must_template_id,
            'must_acute_illness',
            'Presenza di malattia acuta con ridotto apporto alimentare per più di 5 giorni',
            'yes_no',
            3,
            true,
            '["No", "Sì"]'::jsonb,
            '[0, 2]'::jsonb
        );
        RAISE NOTICE 'Added acute illness question';
    ELSE
        -- Update existing acute illness question
        UPDATE public.questionnaire_questions
        SET question_id = 'must_acute_illness',
            question_type = 'yes_no',
            order_index = 3,
            is_required = true,
            options = '["No", "Sì"]'::jsonb,
            scores = '[0, 2]'::jsonb
        WHERE template_id = must_template_id 
        AND question_type = 'yes_no' 
        AND (question_id LIKE '%illness%' OR question_text ILIKE '%malattia%');
        RAISE NOTICE 'Updated existing acute illness question';
    END IF;

    -- Final count verification
    SELECT COUNT(*) INTO question_count
    FROM public.questionnaire_questions
    WHERE template_id = must_template_id;

    RAISE NOTICE 'Final MUST questions count: %', question_count;
    
    -- Ensure the count is exactly 3
    IF question_count != 3 THEN
        RAISE EXCEPTION 'MUST questionnaire should have exactly 3 questions, but has %', question_count;
    END IF;

    RAISE NOTICE 'SUCCESS: MUST questionnaire now has exactly 3 questions';
END;
$$;

-- Update template description to reflect the fix
UPDATE public.questionnaire_templates
SET description = 'MUST questionnaire con esattamente 3 domande: BMI (calcolato), Perdita di peso (3 opzioni), Malattia acuta (sì/no)',
    updated_at = CURRENT_TIMESTAMP
WHERE questionnaire_type = 'must' AND is_active = true;

-- Clean up any orphaned responses for non-existent questions
DELETE FROM public.questionnaire_responses
WHERE question_id NOT IN (
    SELECT question_id 
    FROM public.questionnaire_questions
);

COMMIT;

-- Verification query (commented out for production)
/*
SELECT 
    qq.question_id,
    qq.question_text,
    qq.question_type,
    qq.order_index,
    qq.options,
    qq.scores
FROM public.questionnaire_questions qq
JOIN public.questionnaire_templates qt ON qt.id = qq.template_id
WHERE qt.questionnaire_type = 'must' AND qt.is_active = true
ORDER BY qq.order_index;
*/