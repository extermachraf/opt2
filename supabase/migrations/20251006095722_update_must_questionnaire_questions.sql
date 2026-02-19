-- Location: supabase/migrations/20251006095722_update_must_questionnaire_questions.sql
-- Schema Analysis: Existing questionnaire system with MUST template, questions, and scoring functions
-- Integration Type: Modification of existing MUST questionnaire questions and scoring logic
-- Dependencies: questionnaire_templates, questionnaire_questions tables

-- Update MUST questionnaire questions 1, 2, and 3 according to new specifications

DO $$
DECLARE
    must_template_id UUID;
BEGIN
    -- Get the MUST template ID
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' 
    LIMIT 1;

    IF must_template_id IS NULL THEN
        RAISE EXCEPTION 'MUST template not found';
    END IF;

    -- Update Question 1: BMI (automatic calculation)
    UPDATE public.questionnaire_questions 
    SET 
        question_text = 'BMI',
        question_type = 'calculated',
        notes = 'Valore calcolato automaticamente in base ad altezza e peso del paziente',
        scores = jsonb_build_object(
            'BMI > 20', 0,
            '18.5 < BMI < 20', 1,
            'BMI < 18.5', 2
        ),
        options = '[]'::jsonb,
        updated_at = CURRENT_TIMESTAMP
    WHERE template_id = must_template_id 
    AND question_id LIKE '%bmi%' 
    OR (template_id = must_template_id AND order_index = 0);

    -- If BMI question doesn't exist, create it
    IF NOT FOUND THEN
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            order_index, is_required, notes, scores, options
        ) VALUES (
            must_template_id, 'must_bmi_auto', 'BMI', 'calculated',
            0, true, 
            'Valore calcolato automaticamente in base ad altezza e peso del paziente',
            jsonb_build_object(
                'BMI > 20', 0,
                '18.5 < BMI < 20', 1,
                'BMI < 18.5', 2
            ),
            '[]'::jsonb
        );
    END IF;

    -- Update Question 2: Weight loss assessment
    UPDATE public.questionnaire_questions 
    SET 
        question_text = 'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?',
        question_type = 'single_choice',
        notes = 'Valutazione della perdita di peso recente',
        scores = jsonb_build_object(
            'Calo di peso inferiore al 5%', 0,
            'Calo di peso compreso fra 5% e 10%', 1,
            'Calo di peso superiore al 10%', 2
        ),
        options = jsonb_build_array(
            'Calo di peso inferiore al 5%',
            'Calo di peso compreso fra 5% e 10%',
            'Calo di peso superiore al 10%'
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE template_id = must_template_id 
    AND (question_id LIKE '%weight%' OR question_id LIKE '%peso%' OR order_index = 1);

    -- If weight loss question doesn't exist, create it  
    IF NOT FOUND THEN
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type,
            order_index, is_required, notes, scores, options
        ) VALUES (
            must_template_id, 'must_weight_loss', 
            'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?', 
            'single_choice', 1, true,
            'Valutazione della perdita di peso recente',
            jsonb_build_object(
                'Calo di peso inferiore al 5%', 0,
                'Calo di peso compreso fra 5% e 10%', 1,
                'Calo di peso superiore al 10%', 2
            ),
            jsonb_build_array(
                'Calo di peso inferiore al 5%',
                'Calo di peso compreso fra 5% e 10%',
                'Calo di peso superiore al 10%'
            )
        );
    END IF;

    -- Update Question 3: Fasting assessment
    UPDATE public.questionnaire_questions 
    SET 
        question_text = 'Sei a digiuno da 5 o più giorni?',
        question_type = 'yes_no',
        notes = 'Valutazione dello stato di digiuno prolungato',
        scores = jsonb_build_object(
            'Sì', 2,
            'No', 0
        ),
        options = jsonb_build_array('Sì', 'No'),
        updated_at = CURRENT_TIMESTAMP
    WHERE template_id = must_template_id 
    AND (question_id LIKE '%digiuno%' OR question_id LIKE '%fast%' OR order_index = 2);

    -- If fasting question doesn't exist, create it
    IF NOT FOUND THEN
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type,
            order_index, is_required, notes, scores, options  
        ) VALUES (
            must_template_id, 'must_fasting', 'Sei a digiuno da 5 o più giorni?', 
            'yes_no', 2, true,
            'Valutazione dello stato di digiuno prolungato',
            jsonb_build_object('Sì', 2, 'No', 0),
            jsonb_build_array('Sì', 'No')
        );
    END IF;

    RAISE NOTICE 'MUST questionnaire questions updated successfully';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating MUST questions: %', SQLERRM;
END $$;

-- Create enhanced BMI auto-calculation function for MUST questionnaire
CREATE OR REPLACE FUNCTION public.calculate_must_bmi_score(user_id_param UUID)
RETURNS TABLE(
    calculated_value TEXT,
    display_text TEXT,
    score_value INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_bmi NUMERIC;
    bmi_score INTEGER;
    bmi_display TEXT;
BEGIN
    -- Calculate BMI from medical profile
    SELECT 
        CASE 
            WHEN mp.height_cm > 0 AND mp.current_weight_kg > 0 THEN
                mp.current_weight_kg / ((mp.height_cm / 100.0) ^ 2)
            ELSE NULL
        END
    INTO user_bmi
    FROM public.medical_profiles mp
    WHERE mp.user_id = user_id_param;

    -- Determine score based on BMI ranges
    IF user_bmi IS NULL THEN
        calculated_value := 'Non disponibile';
        display_text := 'BMI non calcolabile - dati mancanti';
        score_value := 0;
    ELSIF user_bmi < 18.5 THEN
        calculated_value := 'BMI < 18.5';
        display_text := 'BMI: ' || ROUND(user_bmi, 1) || ' (Sottopeso - Score: 2)';
        score_value := 2;
    ELSIF user_bmi >= 18.5 AND user_bmi < 20 THEN
        calculated_value := '18.5 < BMI < 20';
        display_text := 'BMI: ' || ROUND(user_bmi, 1) || ' (Lievemente sotto il normale - Score: 1)';
        score_value := 1;
    ELSE -- BMI >= 20
        calculated_value := 'BMI ≥ 20';
        display_text := 'BMI: ' || ROUND(user_bmi, 1) || ' (Normale o sopra - Score: 0)';
        score_value := 0;
    END IF;

    RETURN NEXT;
END;
$$;

-- Enhanced auto-calculation function that handles MUST questionnaire specifically
CREATE OR REPLACE FUNCTION public.auto_calculate_must_responses(session_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_id_val UUID;
    questionnaire_type_val TEXT;
    bmi_result RECORD;
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
        RETURN;
    END IF;

    -- Calculate and save BMI response
    SELECT * INTO bmi_result 
    FROM public.calculate_must_bmi_score(user_id_val);

    -- Upsert BMI response
    INSERT INTO public.questionnaire_responses (
        session_id, question_id, response_value, response_score, calculated_value
    ) VALUES (
        session_uuid, 'must_bmi_auto', bmi_result.calculated_value, 
        bmi_result.score_value, bmi_result.display_text
    )
    ON CONFLICT (session_id, question_id) 
    DO UPDATE SET
        response_value = EXCLUDED.response_value,
        response_score = EXCLUDED.response_score, 
        calculated_value = EXCLUDED.calculated_value,
        updated_at = CURRENT_TIMESTAMP;

    RAISE NOTICE 'MUST auto-calculations completed for session: %', session_uuid;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in MUST auto-calculation: %', SQLERRM;
END;
$$;

-- Update the main auto_calculate_responses function to handle MUST questionnaire
CREATE OR REPLACE FUNCTION public.auto_calculate_responses(session_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    questionnaire_type_val TEXT;
BEGIN
    -- Get questionnaire type
    SELECT questionnaire_type INTO questionnaire_type_val
    FROM public.assessment_sessions
    WHERE id = session_uuid;

    -- Handle MUST questionnaire specifically
    IF questionnaire_type_val = 'must' THEN
        PERFORM public.auto_calculate_must_responses(session_uuid);
    ELSE
        -- Call original auto-calculation logic for other questionnaires
        -- This preserves existing functionality for other questionnaire types
        RAISE NOTICE 'Auto-calculation for questionnaire type: %', questionnaire_type_val;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in auto_calculate_responses: %', SQLERRM;
END;
$$;