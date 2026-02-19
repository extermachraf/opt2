-- Location: supabase/migrations/20251006140000_add_must_questionnaire_weight_loss_question.sql
-- Schema Analysis: MUST questionnaire currently has 2 questions, user wants 3/3 display
-- Integration Type: ADDITIVE - Adding missing weight loss question to complete MUST questionnaire
-- Dependencies: questionnaire_templates, questionnaire_questions tables

-- Add the missing third question (weight loss) to complete MUST questionnaire
DO $$
DECLARE
    must_template_id UUID;
BEGIN
    -- Get MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;

    -- Only proceed if MUST template exists
    IF must_template_id IS NOT NULL THEN
        -- Add the missing weight loss question as the third question
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
            'must_weight_loss_percentage',
            'Hai perso peso involontariamente negli ultimi 3-6 mesi?',
            'single_choice'::public.question_type,
            1, -- Position between BMI (0) and fasting (2)
            true,
            '["Nessuna perdita di peso", "Perdita di peso del 5-10%", "Perdita di peso > 10%"]'::jsonb,
            '{"Nessuna perdita di peso": 0, "Perdita di peso del 5-10%": 1, "Perdita di peso > 10%": 2}'::jsonb,
            'Valutazione della perdita di peso involontaria per screening nutrizionale MUST'
        );

        -- Update order_index for existing fasting question to be last
        UPDATE public.questionnaire_questions 
        SET order_index = 2 
        WHERE template_id = must_template_id 
        AND question_id = 'must_fasting_status';

        RAISE NOTICE 'Successfully added weight loss question to MUST questionnaire. Now has 3 questions total.';
        
    ELSE
        RAISE NOTICE 'MUST template not found. Cannot add weight loss question.';
    END IF;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Weight loss question already exists for MUST template';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding weight loss question: %', SQLERRM;
END $$;

-- Verify the MUST questionnaire now has exactly 3 questions
DO $$
DECLARE
    question_count INTEGER;
    must_template_id UUID;
BEGIN
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;
    
    IF must_template_id IS NOT NULL THEN
        SELECT COUNT(*) INTO question_count 
        FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'MUST questionnaire now has % questions', question_count;
        
        IF question_count = 3 THEN
            RAISE NOTICE 'SUCCESS: MUST questionnaire completed with 3 questions - will display 3/3';
        ELSE
            RAISE NOTICE 'WARNING: MUST questionnaire has % questions instead of expected 3', question_count;
        END IF;
    END IF;
END $$;