-- Update MUST question 3 text and help text
-- Changes "Malattia acuta" to "Patologia grave acuta" and adds explanation

UPDATE public.questionnaire_questions
SET
    question_text = 'Presenza di patologia grave acuta con ridotto apporto alimentare per più di 5 giorni',
    notes = 'Con patologia grave acuta si intende una patologia cronica con complicanza, patologia oncologica, patologia onco-ematologica, …'
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates
    WHERE questionnaire_type = 'must' AND is_active = true
)
AND (
    question_id LIKE '%acute%'
    OR question_id LIKE '%illness%'
    OR question_id LIKE '%disease%'
    OR question_text ILIKE '%malattia%'
    OR question_text ILIKE '%acuta%'
)
AND question_type = 'yes_no'
AND order_index = 3;

