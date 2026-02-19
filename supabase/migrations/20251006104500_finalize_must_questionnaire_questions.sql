-- Fix MUST questionnaire questions 1-3 with correct Italian text and proper scoring
-- This migration ensures the questions match user requirements exactly

-- Update Question 1: BMI (calculated automatically)
UPDATE public.questionnaire_questions 
SET 
  question_text = 'BMI',
  question_type = 'calculated',
  notes = 'Valore calcolato automaticamente dal sistema utilizzando altezza e peso del paziente. BMI > 20 = 0 punti, 18.5 < BMI < 20 = 1 punto, BMI < 18.5 = 2 punti',
  options = '[]'::jsonb,
  scores = '{
    "BMI < 18.5": 2,
    "18.5 ≤ BMI < 20": 1, 
    "BMI ≥ 20": 0
  }'::jsonb,
  order_index = 0
WHERE question_id = 'must_bmi_calculated'
  AND template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true
  );

-- Update Question 2: Weight Loss Assessment
UPDATE public.questionnaire_questions 
SET 
  question_text = 'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?',
  question_type = 'single_choice',
  notes = 'Valutazione della perdita di peso non intenzionale negli ultimi 3-6 mesi',
  options = '[
    "Calo di peso inferiore al 5%",
    "Calo di peso compreso fra 5% e 10%", 
    "Calo di peso superiore al 10%"
  ]'::jsonb,
  scores = '{
    "Calo di peso inferiore al 5%": 0,
    "Calo di peso compreso fra 5% e 10%": 1,
    "Calo di peso superiore al 10%": 2
  }'::jsonb,
  order_index = 1
WHERE question_id = 'must_weight_loss_assessment'
  AND template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true
  );

-- Update Question 3: Fasting Assessment
UPDATE public.questionnaire_questions 
SET 
  question_text = 'Sei a digiuno da 5 o più giorni?',
  question_type = 'yes_no',
  notes = 'Valutazione del periodo di digiuno prolungato',
  options = '["Sì", "No"]'::jsonb,
  scores = '{
    "Sì": 2,
    "No": 0
  }'::jsonb,
  order_index = 2
WHERE question_id = 'must_fasting_assessment'
  AND template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true
  );

-- Ensure we have the third question if it doesn't exist
INSERT INTO public.questionnaire_questions (
  template_id,
  question_id,
  question_text,
  question_type,
  options,
  scores,
  notes,
  order_index,
  is_required
)
SELECT 
  t.id,
  'must_fasting_assessment',
  'Sei a digiuno da 5 o più giorni?',
  'yes_no',
  '["Sì", "No"]'::jsonb,
  '{"Sì": 2, "No": 0}'::jsonb,
  'Valutazione del periodo di digiuno prolungato',
  2,
  true
FROM public.questionnaire_templates t
WHERE t.questionnaire_type = 'must' 
  AND t.is_active = true
  AND NOT EXISTS (
    SELECT 1 FROM public.questionnaire_questions q
    WHERE q.template_id = t.id 
      AND q.question_id = 'must_fasting_assessment'
  );

-- Verify we have exactly 3 questions for MUST questionnaire (questions 1-3 as requested)
-- Count should show /3 not /8
DO $$
DECLARE
  must_template_id UUID;
  question_count INTEGER;
BEGIN
  -- Get the MUST template ID
  SELECT id INTO must_template_id 
  FROM public.questionnaire_templates 
  WHERE questionnaire_type = 'must' AND is_active = true
  LIMIT 1;
  
  IF must_template_id IS NOT NULL THEN
    -- Count questions for this template
    SELECT COUNT(*) INTO question_count
    FROM public.questionnaire_questions
    WHERE template_id = must_template_id;
    
    RAISE NOTICE 'MUST questionnaire has % questions (should show /% in UI)', question_count, question_count;
    
    -- Ensure we have the right question order
    UPDATE public.questionnaire_questions 
    SET order_index = 0
    WHERE template_id = must_template_id 
      AND question_id = 'must_bmi_calculated';
      
    UPDATE public.questionnaire_questions 
    SET order_index = 1
    WHERE template_id = must_template_id 
      AND question_id = 'must_weight_loss_assessment';
      
    UPDATE public.questionnaire_questions 
    SET order_index = 2
    WHERE template_id = must_template_id 
      AND question_id = 'must_fasting_assessment';
  END IF;
END $$;

-- Update the template to reflect correct question count
UPDATE public.questionnaire_templates 
SET 
  description = 'MUST (Malnutrition Universal Screening Tool) - Strumento universale di screening della malnutrizione con 3 domande per valutazione rapida del rischio nutrizionale',
  updated_at = NOW()
WHERE questionnaire_type = 'must' AND is_active = true;

-- Cleanup: Remove any extra questions beyond the required 3 for MUST
DELETE FROM public.questionnaire_questions 
WHERE template_id IN (
  SELECT id FROM public.questionnaire_templates 
  WHERE questionnaire_type = 'must' AND is_active = true
)
AND question_id NOT IN (
  'must_bmi_calculated',
  'must_weight_loss_assessment', 
  'must_fasting_assessment'
)
AND order_index > 2;

COMMENT ON TABLE public.questionnaire_questions IS 'Updated MUST questionnaire with exactly 3 questions as requested by user - BMI, Weight Loss, and Fasting assessment';