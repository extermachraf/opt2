-- Update SF-12 questions text
-- Changes:
-- Questions 3-4: "salute" → "salute fisica" (with HTML underlining)
-- Questions 7 and 11: underline "stato emotivo"

-- Question 3: Change "salute" to "salute fisica" (underlined)
UPDATE public.questionnaire_questions
SET question_text = 'La tua <u>salute fisica</u> ti limita attualmente nel salire qualche piano di scale?'
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sf12' AND is_active = true
)
AND (question_id = 'sf12_climbing_stairs' OR order_index = 3);

-- Question 4: Change "salute" to "salute fisica" (underlined)
-- This appears to be about physical work limitations
UPDATE public.questionnaire_questions
SET question_text = REPLACE(
    question_text,
    'a causa della tua salute',
    'a causa della tua <u>salute fisica</u>'
)
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates
    WHERE questionnaire_type = 'sf12' AND is_active = true
)
AND order_index = 4;

-- Question 7: Underline "stato emotivo"
UPDATE public.questionnaire_questions
SET question_text = 'Nelle ultime 4 settimane, hai avuto un calo di concentrazione sul lavoro o nelle altre attività quotidiane, a causa del tuo <u>stato emotivo</u>?'
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sf12' AND is_active = true
)
AND (question_id LIKE '%concentration%' OR order_index = 7);

-- Question 11: This is actually question 12 that mentions "stato emotivo"
-- Underline "stato emotivo" in question 12
UPDATE public.questionnaire_questions
SET question_text = 'Nelle ultime 4 settimane per quanto tempo la tua salute fisica o il tuo <u>stato emotivo</u> hanno interferito nelle attività sociali, in famiglia, con gli amici?'
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sf12' AND is_active = true
)
AND (question_id LIKE '%social%' OR order_index = 12);

