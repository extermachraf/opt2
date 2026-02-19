-- Migration: Add sample assessment data for proper evaluation display
-- This migration adds sample data to ensure the "Valutazioni" page displays real information

-- STEP 1: First, extend the questionnaire_type enum to include the new types for 7 categories
-- These must be in separate transactions to avoid the "unsafe use of new value" error
DO $$
BEGIN
    -- Add functional_assessment if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'functional_assessment' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'questionnaire_type')) THEN
        ALTER TYPE public.questionnaire_type ADD VALUE 'functional_assessment';
    END IF;
END $$;

DO $$
BEGIN
    -- Add metabolic_assessment if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'metabolic_assessment' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'questionnaire_type')) THEN
        ALTER TYPE public.questionnaire_type ADD VALUE 'metabolic_assessment';
    END IF;
END $$;

-- STEP 2: Create sample medical profiles if not exists (using only existing columns and proper constraint)
INSERT INTO public.medical_profiles (
  id,
  user_id,
  height_cm,
  current_weight_kg,
  goal_type,
  activity_level,
  allergies,
  medical_conditions,
  medications,
  target_daily_calories,
  target_protein_g,
  target_carbs_g,
  target_fat_g,
  bmr_calories,
  target_weight_kg,
  dietary_restrictions,
  created_at,
  updated_at
) VALUES 
(
  gen_random_uuid(),
  'd4a87e24-2cab-4fc0-a753-fba15ba7c755',
  170.0,
  75.5,
  'maintain_weight',
  'moderately_active',
  ARRAY['lattosio'],
  ARRAY['ipertensione'],
  ARRAY['farmaco per pressione'],
  2100,
  105,
  262,
  70,
  1650,
  70.0,
  ARRAY['gluten-free'],
  NOW(),
  NOW()
) ON CONFLICT (user_id) DO UPDATE SET
  height_cm = EXCLUDED.height_cm,
  current_weight_kg = EXCLUDED.current_weight_kg,
  target_daily_calories = EXCLUDED.target_daily_calories,
  updated_at = NOW();

-- STEP 3: Add weight entries for weight loss calculations (removing ON CONFLICT since no unique constraint exists)
INSERT INTO public.weight_entries (
  id,
  user_id,
  weight_kg,
  recorded_at,
  notes,
  created_at
) 
SELECT 
  gen_random_uuid(),
  'd4a87e24-2cab-4fc0-a753-fba15ba7c755',
  weight,
  date,
  note,
  date
FROM (VALUES
  (78.2, NOW() - INTERVAL '3 months', 'Peso iniziale'),
  (76.8, NOW() - INTERVAL '2 months', 'Controllo mensile'),
  (75.5, NOW() - INTERVAL '1 month', 'Controllo mensile'),
  (75.5, NOW(), 'Peso attuale')
) AS temp_data(weight, date, note)
WHERE NOT EXISTS (
  SELECT 1 FROM public.weight_entries 
  WHERE user_id = 'd4a87e24-2cab-4fc0-a753-fba15ba7c755' 
  AND recorded_at::date = temp_data.date::date
);

-- STEP 4: Add sample questionnaire templates for the 7 categories (using INSERT ... WHERE NOT EXISTS)
INSERT INTO public.questionnaire_templates (
  id,
  questionnaire_type,
  title,
  description,
  category,
  is_active,
  version,
  age_restriction,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  type::public.questionnaire_type,
  title,
  description,
  category,
  true,
  1,
  age_restriction,
  NOW(),
  NOW()
FROM (VALUES
  ('nrs_2002', 'NRS 2002 - Nutritional Risk Screening', 'Screening del rischio nutrizionale secondo protocollo NRS 2002', 'Categoria 1 - Valutazioni Nutrizionali', 'adult'),
  ('must', 'MUST - Malnutrition Universal Screening Tool', 'Screening universale per la malnutrizione', 'Categoria 1 - Valutazioni Nutrizionali', 'adult'),
  ('esas', 'ESAS - Edmonton Symptom Assessment System', 'Valutazione dei sintomi e del benessere generale', 'Categoria 2 - Qualità della Vita', 'adult'),
  ('sf12', 'SF-12 - Short Form Health Survey', 'Questionario breve per la valutazione della salute percepita', 'Categoria 2 - Qualità della Vita', 'adult'),
  ('sarc_f', 'SARC-F - Sarcopenia Screening', 'Screening per la sarcopenia negli anziani', 'Categoria 3 - Sarcopenia e Forza Muscolare', 'elderly'),
  ('dietary_diary', 'Diario Alimentare', 'Registrazione e analisi dei pasti quotidiani', 'Categoria 4 - Diario Alimentare', 'all'),
  ('nutritional_risk_assessment', 'Valutazione Rischio Nutrizionale', 'Valutazione completa del rischio nutrizionale del paziente', 'Categoria 5 - Valutazione del Rischio', 'adult'),
  ('functional_assessment', 'Valutazione Funzionale', 'Assessment delle capacità fisiche e funzionali del paziente', 'Categoria 6 - Valutazione Funzionale', 'adult'),
  ('metabolic_assessment', 'Valutazione Metabolica', 'Analisi dei parametri metabolici e biochimici', 'Categoria 7 - Valutazione Metabolica', 'adult')
) AS temp_templates(type, title, description, category, age_restriction)
WHERE NOT EXISTS (
  SELECT 1 FROM public.questionnaire_templates 
  WHERE questionnaire_type = temp_templates.type::public.questionnaire_type
);

-- STEP 5: Add additional assessment sessions to show variety in evaluation history (using INSERT ... WHERE NOT EXISTS)
INSERT INTO public.assessment_sessions (
  id,
  user_id,
  questionnaire_type,
  status,
  total_score,
  risk_level,
  started_at,
  completed_at,
  recommendations,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  'd4a87e24-2cab-4fc0-a753-fba15ba7c755',
  type::public.questionnaire_type,
  status::public.assessment_status,
  score,
  risk,
  start_time,
  complete_time,
  recommendation,
  start_time,
  start_time
FROM (VALUES
  ('esas', 'completed', 25, 'medium', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '45 minutes', 'Controllare livelli di stanchezza e dolore. Considerare supporto nutrizionale.'),
  ('sf12', 'completed', 18, 'low', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days' + INTERVAL '30 minutes', 'Buona qualità della vita generale. Continuare con lo stile di vita attuale.'),
  ('must', 'completed', 2, 'low', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days' + INTERVAL '20 minutes', 'Stato nutrizionale nella norma. Mantenere alimentazione bilanciata.'),
  ('nutritional_risk_assessment', 'in_progress', NULL, NULL, NOW() - INTERVAL '2 days', NULL, NULL),
  ('functional_assessment', 'completed', 8, 'low', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days' + INTERVAL '25 minutes', 'Capacità funzionali buone. Mantenere attività fisica regolare.')
) AS temp_sessions(type, status, score, risk, start_time, complete_time, recommendation)
WHERE NOT EXISTS (
  SELECT 1 FROM public.assessment_sessions 
  WHERE user_id = 'd4a87e24-2cab-4fc0-a753-fba15ba7c755' 
  AND questionnaire_type = temp_sessions.type::public.questionnaire_type
);

-- STEP 6: Add some questionnaire responses for existing completed assessments (using INSERT ... WHERE NOT EXISTS)
DO $$
DECLARE
    session_uuid UUID;
BEGIN
    -- Get a completed NRS session
    SELECT id INTO session_uuid 
    FROM public.assessment_sessions 
    WHERE questionnaire_type = 'nrs_2002'::public.questionnaire_type
    AND status = 'completed'::public.assessment_status
    AND user_id = 'd4a87e24-2cab-4fc0-a753-fba15ba7c755'
    LIMIT 1;
    
    IF session_uuid IS NOT NULL THEN
        -- Insert responses for NRS assessment
        INSERT INTO public.questionnaire_responses (
            id,
            session_id,
            question_id,
            response_value,
            response_score,
            calculated_value,
            created_at,
            updated_at
        )
        SELECT 
            gen_random_uuid(),
            session_uuid,
            question,
            answer,
            score,
            calc_val,
            NOW(),
            NOW()
        FROM (VALUES
            ('nrs_bmi_check', 'No', 0, 26.2),
            ('nrs_weight_loss_3m', 'Sì', 1, NULL)
        ) AS temp_responses(question, answer, score, calc_val)
        WHERE NOT EXISTS (
            SELECT 1 FROM public.questionnaire_responses 
            WHERE session_id = session_uuid 
            AND question_id = temp_responses.question
        );
    END IF;
END $$;

-- STEP 7: Update any existing assessment sessions to have proper risk level and recommendations
UPDATE public.assessment_sessions 
SET 
  recommendations = CASE 
    WHEN risk_level = 'high' THEN 'Valutazione nutrizionale approfondita necessaria. Consultare specialista.'
    WHEN risk_level = 'medium' THEN 'Monitorare parametri nutrizionali. Considerare consulenza nutrizionale.'
    WHEN risk_level = 'low' THEN 'Stato nutrizionale adeguato. Mantenere stile di vita sano.'
    ELSE 'Completare la valutazione per ricevere raccomandazioni personalizzate.'
  END,
  updated_at = NOW()
WHERE recommendations IS NULL;

-- STEP 8: Create indexes for better query performance on assessment data
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_user_type_status 
ON public.assessment_sessions(user_id, questionnaire_type, status);

CREATE INDEX IF NOT EXISTS idx_questionnaire_responses_session_question 
ON public.questionnaire_responses(session_id, question_id);

CREATE INDEX IF NOT EXISTS idx_weight_entries_user_date 
ON public.weight_entries(user_id, recorded_at DESC);

-- Add a comment to track this migration
COMMENT ON TABLE public.assessment_sessions IS 'Assessment sessions with sample data for proper evaluation display - Updated 2025-09-24';