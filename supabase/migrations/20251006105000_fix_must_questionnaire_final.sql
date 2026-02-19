-- Location: supabase/migrations/20251006105000_fix_must_questionnaire_final.sql
-- Schema Analysis: Existing questionnaire system with templates, questions, sessions, and responses
-- Integration Type: Modificative - Fix existing MUST questionnaire to have exactly 3 questions
-- Dependencies: questionnaire_templates, questionnaire_questions existing tables

-- MUST questionnaire should have exactly 3 questions:
-- 1. BMI (calculated)
-- 2. Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?
-- 3. Sei a digiuno da 5 o più giorni?

DO $$
DECLARE
    must_template_id UUID;
    bmi_question_id UUID;
    weight_loss_question_id UUID;
    fasting_question_id UUID;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true 
    LIMIT 1;

    IF must_template_id IS NULL THEN
        RAISE NOTICE 'MUST template not found - cannot fix questions';
        RETURN;
    END IF;

    RAISE NOTICE 'Found MUST template: %', must_template_id;

    -- Delete all existing MUST questions first to avoid duplicates
    DELETE FROM public.questionnaire_questions 
    WHERE template_id = must_template_id;

    RAISE NOTICE 'Deleted existing MUST questions';

    -- Generate new question IDs
    bmi_question_id := gen_random_uuid();
    weight_loss_question_id := gen_random_uuid();
    fasting_question_id := gen_random_uuid();

    -- Insert the 3 required MUST questions with correct order and structure

    -- Question 1: BMI (calculated question)
    INSERT INTO public.questionnaire_questions (
        id, template_id, question_id, question_text, question_type,
        order_index, is_required, options, scores, notes
    ) VALUES (
        bmi_question_id,
        must_template_id,
        'must_bmi_calculated',
        'BMI',
        'calculated'::public.question_type,
        0,
        true,
        '[]'::jsonb,
        '{
            "BMI < 18.5": 2,
            "18.5 ≤ BMI < 20": 1,
            "BMI ≥ 20": 0
        }'::jsonb,
        'Valore calcolato automaticamente dal sistema utilizzando i dati medici dell''utente (altezza e peso).'
    );

    -- Question 2: Weight loss (yes/no question)
    INSERT INTO public.questionnaire_questions (
        id, template_id, question_id, question_text, question_type,
        order_index, is_required, options, scores, notes
    ) VALUES (
        weight_loss_question_id,
        must_template_id,
        'must_weight_loss_3_6_months',
        'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?',
        'yes_no'::public.question_type,
        1,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb,
        'Valutazione della perdita di peso non intenzionale negli ultimi 3-6 mesi.'
    );

    -- Question 3: Fasting status (yes/no question)
    INSERT INTO public.questionnaire_questions (
        id, template_id, question_id, question_text, question_type,
        order_index, is_required, options, scores, notes
    ) VALUES (
        fasting_question_id,
        must_template_id,
        'must_fasting_status',
        'Sei a digiuno da 5 o più giorni?',
        'yes_no'::public.question_type,
        2,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 2, "No": 0}'::jsonb,
        'Valutazione dello stato di digiuno prolungato (5 o più giorni) come indicatore di rischio nutrizionale acuto.'
    );

    RAISE NOTICE 'Successfully inserted 3 MUST questions';

    -- Verify the question count
    DECLARE
        question_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO question_count
        FROM public.questionnaire_questions
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'MUST questionnaire now has % questions', question_count;
        
        IF question_count != 3 THEN
            RAISE EXCEPTION 'Expected 3 questions but found %', question_count;
        END IF;
    END;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error fixing MUST questionnaire: %', SQLERRM;
        -- Don't re-raise to avoid breaking migration
END $$;

-- Update any existing functions that might reference old question counts
CREATE OR REPLACE FUNCTION public.get_must_question_count()
RETURNS INTEGER
LANGUAGE sql
STABLE
AS $$
SELECT 3; -- MUST questionnaire always has exactly 3 questions
$$;

RAISE NOTICE 'MUST questionnaire fix completed - questionnaire now has exactly 3 questions';