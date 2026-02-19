-- Location: supabase/migrations/20251006123000_complete_must_questionnaire_three_questions.sql
-- Schema Analysis: MUST questionnaire template exists with 2 questions, need to add the missing third question
-- Integration Type: Modificative - Adding missing question to existing questionnaire structure
-- Dependencies: questionnaire_templates, questionnaire_questions tables (already exist)

-- Add the missing third question (weight loss assessment) to complete the MUST questionnaire
-- Current status: Only 2 questions exist for MUST template, should be exactly 3

DO $$
DECLARE
    must_template_id UUID;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' 
    LIMIT 1;

    -- Check if template exists
    IF must_template_id IS NULL THEN
        RAISE NOTICE 'MUST template not found, cannot add question';
        RETURN;
    END IF;

    -- Add the missing third question: Weight Loss Assessment
    -- This completes the MUST questionnaire to have exactly 3 questions
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        order_index,
        is_required,
        options,
        scores,
        notes
    ) VALUES (
        must_template_id,
        'must_weight_loss',
        'Perdita di peso negli ultimi 3-6 mesi',
        'single_choice'::public.question_type,
        1, -- Between BMI (order 0) and fasting (order 2)
        true,
        '["Nessuna perdita", "1-5%", "6-10%", "11-15%", ">15%"]'::jsonb,
        '{"Nessuna perdita":0,"1-5%":0,"6-10%":1,"11-15%":2,">15%":2}'::jsonb,
        'Valutazione della perdita di peso recente per determinare il rischio nutrizionale secondo criteri MUST'
    );

    RAISE NOTICE 'Successfully added third MUST question - questionnaire now has 3/3 questions';
    
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Weight loss question already exists for MUST template';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding MUST weight loss question: %', SQLERRM;
END $$;

-- Verify the questionnaire now has exactly 3 questions
DO $$
DECLARE
    question_count INTEGER;
    must_template_id UUID;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' 
    LIMIT 1;

    IF must_template_id IS NOT NULL THEN
        -- Count questions for MUST template
        SELECT COUNT(*) INTO question_count 
        FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;

        RAISE NOTICE 'MUST questionnaire verification: % questions found (should be 3)', question_count;
        
        IF question_count = 3 THEN
            RAISE NOTICE 'SUCCESS: MUST questionnaire now shows 3/3 questions correctly';
        ELSE
            RAISE NOTICE 'WARNING: MUST questionnaire has % questions, expected 3', question_count;
        END IF;
    END IF;
END $$;