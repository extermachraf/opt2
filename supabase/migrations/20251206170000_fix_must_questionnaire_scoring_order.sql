-- Location: supabase/migrations/20251206170000_fix_must_questionnaire_scoring_order.sql
-- Schema Analysis: Existing questionnaire system with MUST questionnaire scoring issues
-- Integration Type: Modification to fix MUST questionnaire question options and scoring
-- Dependencies: questionnaire_templates, questionnaire_questions, questionnaire_responses

-- Fix MUST questionnaire scoring order to match user expectations
-- Ensure questions have proper option order where first answer = 0 points, second = 1 point, third = 2 points

DO $$
DECLARE
    must_template_id UUID;
    bmi_question_id UUID;
    weight_loss_question_id UUID; 
    acute_illness_question_id UUID;
BEGIN
    -- Get MUST questionnaire template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true 
    LIMIT 1;

    IF must_template_id IS NULL THEN
        RAISE NOTICE 'MUST template not found - cannot fix scoring order';
        RETURN;
    END IF;

    -- Delete existing MUST questions to recreate with proper order
    DELETE FROM public.questionnaire_questions 
    WHERE template_id = must_template_id;

    -- Create Question 1: BMI (calculated) - Score based on BMI ranges
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        order_index,
        is_required,
        notes,
        options,
        scores
    ) VALUES (
        must_template_id,
        'must_bmi_calculated',
        'Indice di Massa Corporea (BMI) - Calcolato automaticamente',
        'calculated',
        1,
        true,
        'BMI calcolato automaticamente da altezza e peso del profilo medico. Punteggio: BMI ≥20 = 0 punti, 18.5≤BMI<20 = 1 punto, BMI<18.5 = 2 punti',
        '["BMI ≥ 20 (Peso normale)", "18.5 ≤ BMI < 20 (Leggermente sottopeso)", "BMI < 18.5 (Sottopeso)"]'::jsonb,
        '{"BMI ≥ 20 (Peso normale)": 0, "18.5 ≤ BMI < 20 (Leggermente sottopeso)": 1, "BMI < 18.5 (Sottopeso)": 2}'::jsonb
    );

    -- Create Question 2: Weight Loss (3 options) - First answer = 0 points, second = 1 point, third = 2 points
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        order_index,
        is_required,
        notes,
        options,
        scores
    ) VALUES (
        must_template_id,
        'must_weight_loss',
        'Perdita di peso involontaria negli ultimi 3-6 mesi',
        'single_choice',
        2,
        true,
        'Valuta la perdita di peso recente. Prima opzione = 0 punti, seconda = 1 punto, terza = 2 punti',
        '["Nessuna perdita di peso o perdita < 5%", "Perdita di peso 5-10%", "Perdita di peso > 10%"]'::jsonb,
        '{"Nessuna perdita di peso o perdita < 5%": 0, "Perdita di peso 5-10%": 1, "Perdita di peso > 10%": 2}'::jsonb
    );

    -- Create Question 3: Acute Illness (yes/no) - First answer = 0 points, second = 2 points
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        order_index,
        is_required,
        notes,
        options,
        scores
    ) VALUES (
        must_template_id,
        'must_acute_illness',
        'Malattia acuta che ha influenzato o potrebbe influenzare l''assunzione di cibo per più di 5 giorni',
        'yes_no',
        3,
        true,
        'Presenza di malattia acuta. No = 0 punti, Sì = 2 punti',
        '["No", "Sì"]'::jsonb,
        '{"No": 0, "Sì": 2}'::jsonb
    );

    RAISE NOTICE 'Successfully fixed MUST questionnaire scoring order with 3 questions';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error fixing MUST questionnaire scoring: %', SQLERRM;
END $$;

-- Update the enhanced BMI calculation function to ensure proper scoring alignment
CREATE OR REPLACE FUNCTION public.calculate_must_bmi_score_corrected(user_id_param uuid)
RETURNS TABLE(calculated_value text, display_text text, score_value integer, bmi_numeric numeric)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    user_bmi NUMERIC;
    bmi_score INTEGER;
    bmi_display TEXT;
    bmi_category TEXT;
BEGIN
    -- Calculate BMI from medical profile with enhanced error handling
    SELECT 
        CASE 
            WHEN mp.height_cm > 0 AND mp.current_weight_kg > 0 THEN
                ROUND(mp.current_weight_kg / POWER(mp.height_cm / 100.0, 2), 1)
            ELSE NULL
        END
    INTO user_bmi
    FROM public.medical_profiles mp
    WHERE mp.user_id = user_id_param;

    -- CORRECTED: MUST BMI scoring with proper order (first option = 0 points, second = 1 point, third = 2 points)
    IF user_bmi IS NULL THEN
        calculated_value := 'Dati insufficienti';
        display_text := 'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score_value := 0;
        bmi_category := 'Non disponibile';
    ELSIF user_bmi >= 20.0 THEN
        -- First option: BMI ≥ 20 = 0 points (best case)
        calculated_value := 'BMI ≥ 20 (Peso normale)';
        display_text := 'BMI: ' || user_bmi || ' (Peso normale - 0 punti)';
        score_value := 0;
        bmi_category := 'Normale';
    ELSIF user_bmi >= 18.5 AND user_bmi < 20.0 THEN
        -- Second option: 18.5 ≤ BMI < 20 = 1 point (moderate risk)
        calculated_value := '18.5 ≤ BMI < 20 (Leggermente sottopeso)';
        display_text := 'BMI: ' || user_bmi || ' (Leggermente sottopeso - 1 punto)';
        score_value := 1;
        bmi_category := 'Leggermente sottopeso';
    ELSE -- BMI < 18.5
        -- Third option: BMI < 18.5 = 2 points (highest risk)
        calculated_value := 'BMI < 18.5 (Sottopeso)';
        display_text := 'BMI: ' || user_bmi || ' (Sottopeso - 2 punti)';
        score_value := 2;
        bmi_category := 'Sottopeso';
    END IF;

    bmi_numeric := user_bmi;

    RETURN NEXT;
END;
$function$;

-- Update the enhanced auto-calculation function to use the corrected BMI scoring
CREATE OR REPLACE FUNCTION public.auto_calculate_must_responses_corrected(session_uuid uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    user_id_val UUID;
    questionnaire_type_val TEXT;
    bmi_result RECORD;
    template_id_val UUID;
BEGIN
    -- Get user ID and questionnaire type for this session
    SELECT 
        asession.user_id,
        asession.questionnaire_type
    INTO user_id_val, questionnaire_type_val
    FROM public.assessment_sessions asession
    WHERE asession.id = session_uuid;

    -- Only proceed if this is a MUST questionnaire
    IF questionnaire_type_val != 'must' THEN
        RAISE NOTICE 'Not a MUST questionnaire (%), skipping auto-calculation', questionnaire_type_val;
        RETURN;
    END IF;

    RAISE NOTICE 'Processing MUST auto-calculations with corrected scoring for session: % and user: %', session_uuid, user_id_val;

    -- Get template ID for MUST questionnaire
    SELECT id INTO template_id_val
    FROM public.questionnaire_templates
    WHERE questionnaire_type = 'must' AND is_active = true
    LIMIT 1;

    -- Calculate and save BMI response using corrected function
    SELECT * INTO bmi_result 
    FROM public.calculate_must_bmi_score_corrected(user_id_val);

    RAISE NOTICE 'CORRECTED BMI calculation result: value=%, score=%, display=%', bmi_result.calculated_value, bmi_result.score_value, bmi_result.display_text;

    -- Save the corrected BMI response
    INSERT INTO public.questionnaire_responses (
        session_id, question_id, response_value, response_score, calculated_value, updated_at
    ) VALUES (
        session_uuid, 
        'must_bmi_calculated', 
        bmi_result.calculated_value, 
        bmi_result.score_value, 
        bmi_result.display_text,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (session_id, question_id) 
    DO UPDATE SET
        response_value = EXCLUDED.response_value,
        response_score = EXCLUDED.response_score, 
        calculated_value = EXCLUDED.calculated_value,
        updated_at = CURRENT_TIMESTAMP;

    RAISE NOTICE 'Successfully saved corrected MUST BMI response for session: %', session_uuid;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in corrected MUST auto-calculation: %', SQLERRM;
END;
$function$;

-- Update the main auto-calculate function to use corrected logic
CREATE OR REPLACE FUNCTION public.auto_calculate_responses(session_uuid uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    user_id_val UUID;
    questionnaire_type_val TEXT;
BEGIN
    -- Get questionnaire type for this session
    SELECT 
        asession.questionnaire_type
    INTO questionnaire_type_val
    FROM public.assessment_sessions asession
    WHERE asession.id = session_uuid;

    -- Use corrected MUST calculation for MUST questionnaires
    IF questionnaire_type_val = 'must' THEN
        PERFORM public.auto_calculate_must_responses_corrected(session_uuid);
        RAISE NOTICE 'Used corrected MUST auto-calculation for session: %', session_uuid;
    ELSE
        -- Use standard calculation for other questionnaire types
        RAISE NOTICE 'Using standard auto-calculation for questionnaire type: %', questionnaire_type_val;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in auto_calculate_responses: %', SQLERRM;
END;
$function$;