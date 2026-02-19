-- Location: supabase/migrations/20251206140000_add_complete_esas_questionnaire_questions.sql
-- Schema Analysis: ESAS template exists, only 'esas_tiredness' question exists, need to add 9 more questions
-- Integration Type: PARTIAL_EXISTS - Extending existing ESAS questionnaire
-- Dependencies: questionnaire_templates (esas template), questionnaire_type enum (esas type)

-- Add complete ESAS questionnaire questions (Edmonton Symptom Assessment System)
-- ESAS is a 10-question symptom self-assessment with NO SCORE CALCULATION
-- Only the most recent attempt is shown for review

DO $$
DECLARE
    esas_template_id UUID;
BEGIN
    -- Get the ESAS template ID
    SELECT id INTO esas_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'esas' AND is_active = true
    LIMIT 1;
    
    IF esas_template_id IS NULL THEN
        RAISE EXCEPTION 'ESAS template not found. Please create the ESAS template first.';
    END IF;
    
    -- Delete any existing incomplete ESAS questions to ensure clean slate
    DELETE FROM public.questionnaire_questions 
    WHERE template_id = esas_template_id;
    
    -- Insert all 10 ESAS questions with scale 0-10, no score calculation
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        order_index,
        is_required,
        scores,
        notes
    ) VALUES
    
    -- Question 1: Physical Pain (Dolore fisico)
    (esas_template_id, 'esas_pain', 
     'Quantifica il livello di dolore fisico percepito (0 = nessun dolore, 10 = massimo dolore).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     1, true, NULL, 
     'Scala 0-10 per valutazione del dolore fisico'),
    
    -- Question 2: Tiredness (Stanchezza)
    (esas_template_id, 'esas_tiredness', 
     'Quantifica il livello di stanchezza percepito (0 = nessuna stanchezza, 10 = massima stanchezza).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     2, true, NULL,
     'Scala 0-10 per valutazione della stanchezza'),
    
    -- Question 3: Nausea (Nausea)
    (esas_template_id, 'esas_nausea', 
     'Quantifica il livello di nausea percepito (0 = nessuna nausea, 10 = massima nausea).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     3, true, NULL,
     'Scala 0-10 per valutazione della nausea'),
    
    -- Question 4: Depression (Depressione)  
    (esas_template_id, 'esas_depression', 
     'Quantifica il livello di depressione percepito (0 = nessuna depressione, 10 = massima depressione).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     4, true, NULL,
     'Scala 0-10 per valutazione della depressione'),
    
    -- Question 5: Anxiety (Ansia)
    (esas_template_id, 'esas_anxiety', 
     'Quantifica il livello di ansia percepito (0 = nessuna ansia, 10 = massima ansia).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     5, true, NULL,
     'Scala 0-10 per valutazione dell''ansia'),
    
    -- Question 6: Drowsiness (Sonnolenza)
    (esas_template_id, 'esas_drowsiness', 
     'Quantifica il livello di sonnolenza percepito (0 = nessuna sonnolenza, 10 = massima sonnolenza).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     6, true, NULL,
     'Scala 0-10 per valutazione della sonnolenza'),
    
    -- Question 7: Appetite (Appetito)
    (esas_template_id, 'esas_appetite', 
     'Quantifica il livello di appetito percepito (0 = nessun appetito, 10 = massimo appetito).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     7, true, NULL,
     'Scala 0-10 per valutazione dell''appetito'),
    
    -- Question 8: Wellbeing (Benessere)
    (esas_template_id, 'esas_wellbeing', 
     'Quantifica il livello di benessere percepito (0 = massimo benessere, 10 = nessun benessere).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     8, true, NULL,
     'Scala 0-10 per valutazione del benessere (invertita)'),
    
    -- Question 9: Shortness of Breath (Respiro corto)
    (esas_template_id, 'esas_shortness_breath', 
     'Quantifica il livello di respiro corto percepito (0 = nessun respiro corto, 10 = massimo respiro corto).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     9, true, NULL,
     'Scala 0-10 per valutazione del respiro corto'),
    
    -- Question 10: Other Problems (Altri problemi)
    (esas_template_id, 'esas_other_problems', 
     'Quantifica il livello di difficoltà associata ad altri problemi (0 = nessuna difficoltà, 10 = massima difficoltà).',
     'scale_0_10'::public.question_type,
     '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb,
     10, true, NULL,
     'Scala 0-10 per valutazione di altri problemi');

    -- Verify all 10 questions were inserted
    IF (SELECT COUNT(*) FROM public.questionnaire_questions WHERE template_id = esas_template_id) != 10 THEN
        RAISE EXCEPTION 'Failed to insert all 10 ESAS questions. Expected 10, got %', 
            (SELECT COUNT(*) FROM public.questionnaire_questions WHERE template_id = esas_template_id);
    END IF;

    RAISE NOTICE 'Successfully added complete ESAS questionnaire with 10 questions';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding ESAS questions: %', SQLERRM;
        RAISE;
END $$;