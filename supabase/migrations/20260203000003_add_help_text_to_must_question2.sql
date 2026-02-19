-- Update help text for MUST question 2 (weight loss)
-- This migration replaces the old help text with the new calculation information

-- First, let's see what question IDs exist for MUST weight loss
-- The migration will update ALL weight loss questions in MUST template

UPDATE public.questionnaire_questions
SET notes = 'Dividi per 20 il tuo peso per trovarne il 5% e per 10 per trovarne il 10%. Es.: se pesi 60 kg, il 5% del tuo peso è: 60/20 = 3 kg; il 10% del tuo peso è 60/10 = 6 kg'
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates
    WHERE questionnaire_type = 'must' AND is_active = true
)
AND (
    question_id LIKE '%weight%'
    OR question_id LIKE '%peso%'
    OR question_text ILIKE '%peso%'
    OR question_text ILIKE '%weight%'
)
AND question_type = 'single_choice'
AND order_index = 2;

