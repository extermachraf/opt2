-- Fix MUST questionnaire to have exactly 3 questions as requested by user
-- Current issue: Shows "1/8" instead of "1/3" because database has 8 questions instead of 3

-- First, get the MUST questionnaire template ID
DO $$
DECLARE
    must_template_id UUID;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must' 
    AND is_active = true 
    LIMIT 1;

    -- If MUST template exists, update it to have exactly 3 questions
    IF must_template_id IS NOT NULL THEN
        -- First, delete all existing MUST questions to start fresh
        DELETE FROM questionnaire_questions 
        WHERE template_id = must_template_id;

        -- Insert exactly 3 MUST questions as specified
        INSERT INTO questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            options, scores, order_index, is_required, notes
        ) VALUES
        -- Question 1: BMI (calculated)
        (
            must_template_id,
            'must_bmi_calculated',
            'Calcolo BMI (Body Mass Index)',
            'calculated',
            NULL,
            NULL,
            1,
            true,
            'BMI calcolato automaticamente dai dati del profilo medico: <18.5 (2 punti), 18.5-19.9 (1 punto), ≥20 (0 punti)'
        ),
        -- Question 2: Weight loss in past 3-6 months
        (
            must_template_id,
            'must_weight_loss',
            'Hai perso peso involontariamente negli ultimi 3-6 mesi?',
            'single_choice',
            '["No perdita di peso (0 punti)", "Perdita di peso < 5% (1 punto)", "Perdita di peso 5-10% (2 punti)", "Perdita di peso > 10% (3 punti)"]'::jsonb,
            '{"No perdita di peso (0 punti)": 0, "Perdita di peso < 5% (1 punto)": 1, "Perdita di peso 5-10% (2 punti)": 2, "Perdita di peso > 10% (3 punti)": 3}'::jsonb,
            2,
            true,
            'Valuta la perdita di peso involontaria negli ultimi 3-6 mesi'
        ),
        -- Question 3: Acute illness/fasting
        (
            must_template_id,
            'must_acute_illness',
            'Hai avuto una malattia acuta o periodo di digiuno negli ultimi 5 giorni?',
            'yes_no',
            '["Sì", "No"]'::jsonb,
            '{"Sì": 2, "No": 0}'::jsonb,
            3,
            true,
            'Presenza di malattia acuta o effetto di digiuno negli ultimi 5 giorni (Sì = 2 punti, No = 0 punti)'
        );

        -- Log the fix
        RAISE NOTICE 'MUST questionnaire fixed: Updated to exactly 3 questions (BMI, Weight Loss, Acute Illness)';
        RAISE NOTICE 'Progress counter will now show 1/3, 2/3, 3/3 instead of 1/8, 2/8, etc.';

    ELSE
        -- Create MUST template if it doesn't exist
        INSERT INTO questionnaire_templates (
            questionnaire_type, title, description, category, is_active
        ) VALUES (
            'must',
            'MUST - Malnutrition Universal Screening Tool',
            'MUST (Malnutrition Universal Screening Tool) - Strumento universale di screening della malnutrizione con 3 domande per valutazione rapida del rischio nutrizionale',
            'Categoria 2 - Valutazioni Nutrizionali MUST',
            true
        ) RETURNING id INTO must_template_id;

        -- Insert the 3 questions for the new template
        INSERT INTO questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            options, scores, order_index, is_required, notes
        ) VALUES
        -- Question 1: BMI (calculated)
        (
            must_template_id,
            'must_bmi_calculated',
            'Calcolo BMI (Body Mass Index)',
            'calculated',
            NULL,
            NULL,
            1,
            true,
            'BMI calcolato automaticamente dai dati del profilo medico: <18.5 (2 punti), 18.5-19.9 (1 punto), ≥20 (0 punti)'
        ),
        -- Question 2: Weight loss in past 3-6 months
        (
            must_template_id,
            'must_weight_loss',
            'Hai perso peso involontariamente negli ultimi 3-6 mesi?',
            'single_choice',
            '["No perdita di peso (0 punti)", "Perdita di peso < 5% (1 punto)", "Perdita di peso 5-10% (2 punti)", "Perdita di peso > 10% (3 punti)"]'::jsonb,
            '{"No perdita di peso (0 punti)": 0, "Perdita di peso < 5% (1 punto)": 1, "Perdita di peso 5-10% (2 punti)": 2, "Perdita di peso > 10% (3 punti)": 3}'::jsonb,
            2,
            true,
            'Valuta la perdita di peso involontaria negli ultimi 3-6 mesi'
        ),
        -- Question 3: Acute illness/fasting
        (
            must_template_id,
            'must_acute_illness',
            'Hai avuto una malattia acuta o periodo di digiuno negli ultimi 5 giorni?',
            'yes_no',
            '["Sì", "No"]'::jsonb,
            '{"Sì": 2, "No": 0}'::jsonb,
            3,
            true,
            'Presenza di malattia acuta o effetto di digiuno negli ultimi 5 giorni (Sì = 2 punti, No = 0 punti)'
        );

        RAISE NOTICE 'MUST questionnaire template created with exactly 3 questions';
    END IF;

END $$;

-- Verify the fix by counting questions for MUST questionnaire
DO $$
DECLARE
    question_count INTEGER;
    must_template_id UUID;
BEGIN
    -- Get template ID and count questions
    SELECT t.id, COUNT(q.id) INTO must_template_id, question_count
    FROM questionnaire_templates t
    LEFT JOIN questionnaire_questions q ON t.id = q.template_id
    WHERE t.questionnaire_type = 'must' 
    AND t.is_active = true
    GROUP BY t.id;

    -- Log the result
    RAISE NOTICE 'MUST questionnaire verification: Template ID = %, Question count = %', must_template_id, question_count;
    
    -- Ensure we have exactly 3 questions
    IF question_count = 3 THEN
        RAISE NOTICE 'SUCCESS: MUST questionnaire now has exactly 3 questions. Progress counter will show 1/3, 2/3, 3/3';
    ELSE
        RAISE WARNING 'ISSUE: MUST questionnaire has % questions instead of 3', question_count;
    END IF;
END $$;

-- Update any existing MUST assessment sessions to ensure compatibility
-- Set status to 'draft' for any incomplete MUST sessions so users can restart with the new 3-question format
UPDATE assessment_sessions 
SET status = 'draft',
    updated_at = NOW()
WHERE questionnaire_type = 'must' 
AND status = 'in_progress';

-- Add comment for documentation
COMMENT ON TABLE questionnaire_questions IS 'MUST questionnaire fixed to have exactly 3 questions: BMI (calculated), Weight Loss (single choice), Acute Illness (yes/no) - Updated 2025-01-10';