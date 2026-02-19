-- Migration: Add help text to NRS 2002 Question 6 (Nutritional Status)
-- Location: supabase/migrations/20260203000002_add_help_text_to_nrs2002_question6.sql
-- Purpose: Add informational help text to explain how to calculate 5% of body weight
-- Dependencies: questionnaire_questions table, NRS 2002 template

-- Update Question 6 (nrs_nutritional_status) to include help text in the notes field
UPDATE public.questionnaire_questions
SET notes = 'Dividi per 20 il tuo peso per trovarne il 5%. Es.: se pesi 60 kg, il 5% del tuo peso è: 60/20 = 3 kg'
WHERE question_id = 'nrs_nutritional_status'
AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

-- Verify the update
DO $$
DECLARE
    updated_notes TEXT;
BEGIN
    -- Get the updated notes
    SELECT notes INTO updated_notes
    FROM public.questionnaire_questions
    WHERE question_id = 'nrs_nutritional_status'
    AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';
    
    -- Log the result
    IF updated_notes IS NOT NULL THEN
        RAISE NOTICE '✅ SUCCESS: Help text added to NRS 2002 Question 6';
        RAISE NOTICE 'Help text: %', updated_notes;
    ELSE
        RAISE NOTICE '❌ ERROR: Failed to add help text to NRS 2002 Question 6';
    END IF;
END $$;

