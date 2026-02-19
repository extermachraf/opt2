-- Migration: Add help text to NRS 2002 Question 4 (Acute Pathology)
-- Location: supabase/migrations/20260203000001_add_help_text_to_nrs2002_question4.sql
-- Purpose: Add informational help text to explain what "patologia grave acuta" means
-- Dependencies: questionnaire_questions table, NRS 2002 template

-- Update Question 4 (nrs_acute_pathology) to include help text in the notes field
UPDATE public.questionnaire_questions
SET notes = 'Con patologia grave acuta si intende una patologia cronica con complicanza, patologia oncologica, patologia onco-ematologica, …'
WHERE question_id = 'nrs_acute_pathology'
AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

-- Verify the update
DO $$
DECLARE
    updated_notes TEXT;
BEGIN
    -- Get the updated notes
    SELECT notes INTO updated_notes
    FROM public.questionnaire_questions
    WHERE question_id = 'nrs_acute_pathology'
    AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';
    
    -- Log the result
    IF updated_notes IS NOT NULL THEN
        RAISE NOTICE '✅ SUCCESS: Help text added to NRS 2002 Question 4';
        RAISE NOTICE 'Help text: %', updated_notes;
    ELSE
        RAISE NOTICE '❌ ERROR: Failed to add help text to NRS 2002 Question 4';
    END IF;
END $$;

-- Add comment for documentation
COMMENT ON COLUMN public.questionnaire_questions.notes IS 'Additional notes or help text for the question. Can be displayed as an info tooltip in the UI.';

