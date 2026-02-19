-- Schema Analysis: Quiz system already exists with quiz_templates and quiz_questions tables
-- Integration Type: Modificative - Cleaning up duplicated questions in existing "Falsi Miti" quiz
-- Dependencies: quiz_templates, quiz_questions (existing)

-- Remove duplicated questions from "Falsi Miti" quiz and keep only 10 unique questions
DO $$
DECLARE
    falsi_miti_template_id UUID;
    questions_to_keep UUID[];
    questions_count INTEGER;
BEGIN
    -- Get the "Falsi Miti" template ID
    SELECT id INTO falsi_miti_template_id 
    FROM public.quiz_templates 
    WHERE title = 'Quiz Falsi Miti' AND category = 'false_myths'::public.quiz_category;
    
    IF falsi_miti_template_id IS NULL THEN
        RAISE NOTICE 'Falsi Miti quiz template not found';
        RETURN;
    END IF;
    
    -- Count current questions
    SELECT COUNT(*) INTO questions_count
    FROM public.quiz_questions 
    WHERE template_id = falsi_miti_template_id;
    
    RAISE NOTICE 'Found % questions in Falsi Miti quiz', questions_count;
    
    -- Select 10 unique questions to keep (prioritize by order_index and creation date)
    SELECT ARRAY_AGG(id) INTO questions_to_keep
    FROM (
        SELECT DISTINCT ON (question_text) id, question_text, order_index, created_at
        FROM public.quiz_questions 
        WHERE template_id = falsi_miti_template_id
        ORDER BY question_text, order_index ASC, created_at ASC
        LIMIT 10
    ) unique_questions;
    
    -- Delete duplicate questions (keep only the selected 10)
    DELETE FROM public.quiz_questions 
    WHERE template_id = falsi_miti_template_id 
    AND id != ALL(questions_to_keep);
    
    -- Update order_index for remaining questions to be sequential (1-10)
    UPDATE public.quiz_questions 
    SET order_index = subquery.new_order
    FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY order_index, created_at) as new_order
        FROM public.quiz_questions 
        WHERE template_id = falsi_miti_template_id
    ) subquery
    WHERE public.quiz_questions.id = subquery.id;
    
    -- Verify final count
    SELECT COUNT(*) INTO questions_count
    FROM public.quiz_questions 
    WHERE template_id = falsi_miti_template_id;
    
    RAISE NOTICE 'Falsi Miti quiz now has % unique questions', questions_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error cleaning up Falsi Miti quiz: %', SQLERRM;
END $$;

-- Ensure the quiz template description is updated
UPDATE public.quiz_templates 
SET description = 'Quiz sui falsi miti della nutrizione oncologica - 10 domande essenziali',
    updated_at = CURRENT_TIMESTAMP
WHERE title = 'Quiz Falsi Miti' AND category = 'false_myths'::public.quiz_category;