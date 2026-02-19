-- Location: supabase/migrations/20251006112716_fix_must_questionnaire_to_exactly_three_questions.sql
-- Schema Analysis: MUST questionnaire currently shows "2/5" progress but user wants exactly 3 questions with "3/3" display
-- Integration Type: MODIFICATIVE - Update existing questionnaire structure
-- Dependencies: questionnaire_templates, questionnaire_questions

-- Step 1: Clean up MUST questionnaire to have exactly 3 questions
DO $$
DECLARE
    must_template_id UUID;
    existing_question_count INTEGER;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;
    
    IF must_template_id IS NOT NULL THEN
        -- Count existing questions
        SELECT COUNT(*) INTO existing_question_count
        FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'Found % questions for MUST questionnaire', existing_question_count;
        
        -- Delete ALL existing MUST questions first to ensure clean slate
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'Deleted all existing MUST questions';
        
        -- Insert exactly 3 questions for MUST questionnaire
        INSERT INTO public.questionnaire_questions (
            template_id,
            question_id,
            question_text,
            question_type,
            order_index,
            options,
            scores,
            is_required,
            notes
        ) VALUES
        -- Question 1: BMI (Calculated)
        (
            must_template_id,
            'must_bmi_calculated',
            'BMI',
            'calculated'::public.question_type,
            0,
            '[]'::jsonb,
            '{"BMI < 18.5": 2, "BMI 18.5-20": 1, "BMI ≥ 20": 0}'::jsonb,
            true,
            'Valore calcolato automaticamente dal sistema utilizzando altezza e peso dell''utente'
        ),
        -- Question 2: Weight Loss Assessment
        (
            must_template_id,
            'must_weight_loss_assessment', 
            'Hai sperimentato un calo di peso non programmato negli ultimi 3-6 mesi?',
            'single_choice'::public.question_type,
            1,
            '["Calo di peso inferiore al 5%", "Calo di peso del 5-10%", "Calo di peso superiore al 10%"]'::jsonb,
            '{"Calo di peso inferiore al 5%": 0, "Calo di peso del 5-10%": 1, "Calo di peso superiore al 10%": 2}'::jsonb,
            true,
            'Valutazione della perdita di peso non intenzionale negli ultimi mesi'
        ),
        -- Question 3: Acute Disease Effect
        (
            must_template_id,
            'must_acute_disease_effect',
            'È presente una condizione acuta che ha comportato assenza di assunzione di cibo per più di 5 giorni?',
            'single_choice'::public.question_type,
            2,
            '["No", "Sì"]'::jsonb,
            '{"No": 0, "Sì": 2}'::jsonb,
            true,
            'Valutazione dell''impatto di malattie acute sull''assunzione alimentare'
        );
        
        RAISE NOTICE 'Successfully inserted exactly 3 questions for MUST questionnaire';
        
        -- Verify the count
        SELECT COUNT(*) INTO existing_question_count
        FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'MUST questionnaire now has % questions', existing_question_count;
        
    ELSE
        RAISE NOTICE 'MUST template not found';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error fixing MUST questionnaire: %', SQLERRM;
        RAISE;
END $$;

-- Step 2: Update the fix_questionnaire_question_counts function to reflect correct MUST count
CREATE OR REPLACE FUNCTION public.fix_questionnaire_question_counts()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    must_template_id UUID;
    nrs_template_id UUID;
    esas_template_id UUID;
    sf12_template_id UUID;
    sarc_template_id UUID;
    valutazione_template_id UUID;
BEGIN
    -- Get template IDs for each questionnaire type
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;
    
    SELECT id INTO nrs_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nrs_2002'::public.questionnaire_type;
    
    SELECT id INTO esas_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'esas'::public.questionnaire_type;
    
    SELECT id INTO sf12_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sf12'::public.questionnaire_type;
    
    SELECT id INTO sarc_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sarc_f'::public.questionnaire_type;
    
    SELECT id INTO valutazione_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;

    -- Remove excess questions and ensure correct counts
    
    -- MUST - Malnutrition Universal Screening Tool: Should have exactly 3 questions (UPDATED)
    IF must_template_id IS NOT NULL THEN
        -- Delete excess questions beyond the first 3
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = must_template_id 
        AND order_index > 2;
        
        -- Ensure exactly 3 questions exist by updating order_index
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = must_template_id
            ORDER BY created_at, id
            LIMIT 3
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- NRS 2002: Should have exactly 12 questions
    IF nrs_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = nrs_template_id 
        AND order_index > 11;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = nrs_template_id
            ORDER BY created_at, id
            LIMIT 12
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- ESAS: Should have exactly 10 questions
    IF esas_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = esas_template_id 
        AND order_index > 9;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = esas_template_id
            ORDER BY created_at, id
            LIMIT 10
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- SF-12: Should have exactly 12 questions
    IF sf12_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = sf12_template_id 
        AND order_index > 11;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = sf12_template_id
            ORDER BY created_at, id
            LIMIT 12
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- SARC-F: Should have exactly 6 questions
    IF sarc_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = sarc_template_id 
        AND order_index > 5;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = sarc_template_id
            ORDER BY created_at, id
            LIMIT 6
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    -- Valutazione Rischio Nutrizionale: Should have exactly 6 questions
    IF valutazione_template_id IS NOT NULL THEN
        DELETE FROM public.questionnaire_questions 
        WHERE template_id = valutazione_template_id 
        AND order_index > 5;
        
        WITH ordered_questions AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) - 1 as new_order
            FROM public.questionnaire_questions 
            WHERE template_id = valutazione_template_id
            ORDER BY created_at, id
            LIMIT 6
        )
        UPDATE public.questionnaire_questions 
        SET order_index = ordered_questions.new_order
        FROM ordered_questions 
        WHERE public.questionnaire_questions.id = ordered_questions.id;
    END IF;

    RAISE NOTICE 'Successfully fixed questionnaire question counts - MUST now has 3 questions';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error fixing questionnaire question counts: %', SQLERRM;
        RAISE;
END;
$function$;

-- Step 3: Clean up any orphaned questionnaire responses for removed questions
DO $$
DECLARE
    must_template_id UUID;
    valid_question_ids UUID[];
    deleted_responses_count INTEGER;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;
    
    IF must_template_id IS NOT NULL THEN
        -- Get valid question IDs (should be exactly 3)
        SELECT ARRAY_AGG(id) INTO valid_question_ids
        FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;
        
        -- Count responses that will be deleted
        SELECT COUNT(*) INTO deleted_responses_count
        FROM public.questionnaire_responses qr
        INNER JOIN public.assessment_sessions asess ON qr.session_id = asess.id
        WHERE asess.questionnaire_type = 'must'::public.questionnaire_type
        AND qr.question_id NOT IN (
            SELECT question_id FROM public.questionnaire_questions WHERE template_id = must_template_id
        );
        
        -- Clean up orphaned responses for MUST questionnaire
        DELETE FROM public.questionnaire_responses 
        WHERE session_id IN (
            SELECT id FROM public.assessment_sessions 
            WHERE questionnaire_type = 'must'::public.questionnaire_type
        ) 
        AND question_id NOT IN (
            SELECT question_id FROM public.questionnaire_questions WHERE template_id = must_template_id
        );
        
        RAISE NOTICE 'Cleaned up % orphaned MUST questionnaire responses', deleted_responses_count;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error cleaning up orphaned responses: %', SQLERRM;
END $$;

-- Step 4: Verify the final state
DO $$
DECLARE
    must_template_id UUID;
    final_question_count INTEGER;
    question_details RECORD;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must'::public.questionnaire_type;
    
    IF must_template_id IS NOT NULL THEN
        -- Count final questions
        SELECT COUNT(*) INTO final_question_count
        FROM public.questionnaire_questions 
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'FINAL STATE: MUST questionnaire has exactly % questions', final_question_count;
        
        -- List question details for verification
        FOR question_details IN 
            SELECT order_index, question_id, question_text 
            FROM public.questionnaire_questions 
            WHERE template_id = must_template_id 
            ORDER BY order_index
        LOOP
            RAISE NOTICE 'Question %: % - %', 
                question_details.order_index + 1, 
                question_details.question_id, 
                LEFT(question_details.question_text, 50);
        END LOOP;
        
        IF final_question_count = 3 THEN
            RAISE NOTICE 'SUCCESS: MUST questionnaire now correctly configured with 3 questions. Progress will show as 3/3.';
        ELSE
            RAISE WARNING 'WARNING: Expected 3 questions but found %', final_question_count;
        END IF;
    ELSE
        RAISE WARNING 'MUST template still not found after migration';
    END IF;
END $$;