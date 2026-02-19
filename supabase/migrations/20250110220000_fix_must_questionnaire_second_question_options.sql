-- Schema Analysis: Existing questionnaire system with MUST questionnaire having 4 options in Question 2
-- Integration Type: Modification - Fix MUST questionnaire Question 2 to have only 3 options
-- Dependencies: questionnaire_templates, questionnaire_questions

-- Fix MUST questionnaire Question 2 (weight loss question) to have exactly 3 options instead of 4
-- Remove the first option "Nessuna perdita di peso" as requested

UPDATE public.questionnaire_questions
SET options = jsonb_build_array(
    '1-5 kg (perdita <5%)',
    '6-10 kg (perdita 5-10%)', 
    '>10 kg (perdita >10%)'
),
scores = jsonb_build_array(0, 1, 2)
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'
)
AND question_id LIKE '%weight%'
AND question_text ILIKE '%perdita di peso%'
AND order_index = 2;

-- Verify the update was applied correctly
DO $$
DECLARE
    question_count INTEGER;
    option_count INTEGER;
BEGIN
    -- Check if MUST template exists
    SELECT COUNT(*) INTO question_count
    FROM public.questionnaire_templates qt
    JOIN public.questionnaire_questions qq ON qt.id = qq.template_id
    WHERE qt.questionnaire_type = 'must';

    IF question_count > 0 THEN
        -- Check option count for weight loss question
        SELECT jsonb_array_length(options) INTO option_count
        FROM public.questionnaire_questions qq
        JOIN public.questionnaire_templates qt ON qq.template_id = qt.id
        WHERE qt.questionnaire_type = 'must'
        AND qq.question_text ILIKE '%perdita di peso%'
        AND qq.order_index = 2
        LIMIT 1;

        IF option_count = 3 THEN
            RAISE NOTICE 'SUCCESS: MUST questionnaire Question 2 now has exactly 3 options';
        ELSE
            RAISE NOTICE 'WARNING: MUST questionnaire Question 2 has % options (expected 3)', option_count;
        END IF;
    ELSE
        RAISE NOTICE 'INFO: No MUST questionnaire found in database';
    END IF;
END $$;

-- Clean up any existing responses that referenced the removed first option
-- This ensures data consistency after the option removal
DELETE FROM public.questionnaire_responses
WHERE question_id IN (
    SELECT qq.question_id
    FROM public.questionnaire_questions qq
    JOIN public.questionnaire_templates qt ON qq.template_id = qt.id
    WHERE qt.questionnaire_type = 'must'
    AND qq.question_text ILIKE '%perdita di peso%'
    AND qq.order_index = 2
)
AND response_value = 'Nessuna perdita di peso';

-- Add comment for documentation
COMMENT ON TABLE public.questionnaire_questions IS 'MUST questionnaire fixed to have exactly 3 questions: BMI (calculated), Weight Loss (3 options), Acute Illness (yes/no) - Updated 2025-01-10';