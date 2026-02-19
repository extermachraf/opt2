-- CRITICAL FIX: Properly update MUST questionnaire questions 1-3 while preserving questions 4-8
-- This migration addresses the user's concern that questions 1-3 are still not fixed correctly

-- First, get the MUST template ID to ensure we're updating the correct questionnaire
DO $$
DECLARE
    must_template_id UUID;
BEGIN
    -- Find the MUST template ID
    SELECT id INTO must_template_id 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true
    LIMIT 1;

    -- Only proceed if we found the MUST template
    IF must_template_id IS NOT NULL THEN
        -- Update Question 1: BMI (automatic calculation)
        UPDATE questionnaire_questions 
        SET 
            question_text = 'BMI',
            question_type = 'calculated',
            options = '[]'::jsonb,
            scores = jsonb_build_object(
                'BMI > 20', 0,
                '18.5 < BMI < 20', 1,
                'BMI < 18.5', 2
            ),
            notes = 'Valore calcolato automaticamente dal sistema utilizzando altezza e peso del paziente. BMI > 20 = 0 punti, 18.5 < BMI < 20 = 1 punto, BMI < 18.5 = 2 punti.',
            is_required = true,
            order_index = 0
        WHERE template_id = must_template_id 
        AND (question_id = 'must_bmi_calculated' OR order_index = 0);

        -- Insert Question 1 if it doesn't exist
        INSERT INTO questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            options, scores, notes, is_required, order_index
        )
        SELECT 
            must_template_id,
            'must_bmi_calculated',
            'BMI',
            'calculated',
            '[]'::jsonb,
            jsonb_build_object(
                'BMI > 20', 0,
                '18.5 < BMI < 20', 1,  
                'BMI < 18.5', 2
            ),
            'Valore calcolato automaticamente dal sistema utilizzando altezza e peso del paziente. BMI > 20 = 0 punti, 18.5 < BMI < 20 = 1 punto, BMI < 18.5 = 2 punti.',
            true,
            0
        WHERE NOT EXISTS (
            SELECT 1 FROM questionnaire_questions 
            WHERE template_id = must_template_id 
            AND (question_id = 'must_bmi_calculated' OR order_index = 0)
        );

        -- Update Question 2: Weight Loss Assessment
        UPDATE questionnaire_questions 
        SET 
            question_text = 'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?',
            question_type = 'single_choice',
            options = jsonb_build_array(
                'Calo di peso inferiore al 5%',
                'Calo di peso compreso fra 5% e 10%', 
                'Calo di peso superiore al 10%'
            ),
            scores = jsonb_build_object(
                'Calo di peso inferiore al 5%', 0,
                'Calo di peso compreso fra 5% e 10%', 1,
                'Calo di peso superiore al 10%', 2
            ),
            notes = 'Valutazione della perdita di peso non intenzionale negli ultimi 3-6 mesi. Score: <5% = 0 punti, 5-10% = 1 punto, >10% = 2 punti.',
            is_required = true,
            order_index = 1
        WHERE template_id = must_template_id 
        AND (question_id = 'must_weight_loss_assessment' OR order_index = 1);

        -- Insert Question 2 if it doesn't exist
        INSERT INTO questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            options, scores, notes, is_required, order_index
        )
        SELECT 
            must_template_id,
            'must_weight_loss_assessment', 
            'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?',
            'single_choice',
            jsonb_build_array(
                'Calo di peso inferiore al 5%',
                'Calo di peso compreso fra 5% e 10%',
                'Calo di peso superiore al 10%'
            ),
            jsonb_build_object(
                'Calo di peso inferiore al 5%', 0,
                'Calo di peso compreso fra 5% e 10%', 1,
                'Calo di peso superiore al 10%', 2
            ),
            'Valutazione della perdita di peso non intenzionale negli ultimi 3-6 mesi. Score: <5% = 0 punti, 5-10% = 1 punto, >10% = 2 punti.',
            true,
            1
        WHERE NOT EXISTS (
            SELECT 1 FROM questionnaire_questions 
            WHERE template_id = must_template_id 
            AND (question_id = 'must_weight_loss_assessment' OR order_index = 1)
        );

        -- Update Question 3: Fasting Assessment  
        UPDATE questionnaire_questions 
        SET 
            question_text = 'Sei a digiuno da 5 o più giorni?',
            question_type = 'yes_no',
            options = jsonb_build_array('Sì', 'No'),
            scores = jsonb_build_object(
                'Sì', 2,
                'No', 0
            ),
            notes = 'Valutazione del digiuno prolungato. Sì = 2 punti, No = 0 punti.',
            is_required = true,
            order_index = 2
        WHERE template_id = must_template_id 
        AND (question_id = 'must_fasting_assessment' OR order_index = 2);

        -- Insert Question 3 if it doesn't exist
        INSERT INTO questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            options, scores, notes, is_required, order_index
        )
        SELECT 
            must_template_id,
            'must_fasting_assessment',
            'Sei a digiuno da 5 o più giorni?', 
            'yes_no',
            jsonb_build_array('Sì', 'No'),
            jsonb_build_object(
                'Sì', 2,
                'No', 0
            ),
            'Valutazione del digiuno prolungato. Sì = 2 punti, No = 0 punti.',
            true,
            2
        WHERE NOT EXISTS (
            SELECT 1 FROM questionnaire_questions 
            WHERE template_id = must_template_id 
            AND (question_id = 'must_fasting_assessment' OR order_index = 2)
        );

        -- CRITICAL: Ensure questions 4-8 are preserved by updating their order_index to be sequential
        -- This prevents any issues with existing questions
        UPDATE questionnaire_questions 
        SET order_index = order_index + 3
        WHERE template_id = must_template_id 
        AND order_index > 2 
        AND question_id NOT IN ('must_bmi_calculated', 'must_weight_loss_assessment', 'must_fasting_assessment');

        -- Log the successful update
        RAISE NOTICE 'Successfully updated MUST questionnaire questions 1-3 while preserving existing questions';
        
    ELSE
        -- If no MUST template found, create one with the questions
        INSERT INTO questionnaire_templates (
            questionnaire_type, title, description, category, is_active
        ) VALUES (
            'must',
            'MUST - Malnutrition Universal Screening Tool', 
            'Strumento di screening universale per la malnutrizione utilizzato per identificare i pazienti a rischio nutrizionale',
            'Categoria 1 - Valutazione Rischio Nutrizionale',
            true
        )
        RETURNING id INTO must_template_id;

        -- Add the three required questions to the new template
        INSERT INTO questionnaire_questions (
            template_id, question_id, question_text, question_type, 
            options, scores, notes, is_required, order_index
        ) VALUES 
        (
            must_template_id, 'must_bmi_calculated', 'BMI', 'calculated',
            '[]'::jsonb,
            jsonb_build_object('BMI > 20', 0, '18.5 < BMI < 20', 1, 'BMI < 18.5', 2),
            'Valore calcolato automaticamente dal sistema utilizzando altezza e peso del paziente. BMI > 20 = 0 punti, 18.5 < BMI < 20 = 1 punto, BMI < 18.5 = 2 punti.',
            true, 0
        ),
        (
            must_template_id, 'must_weight_loss_assessment',
            'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?', 'single_choice',
            jsonb_build_array('Calo di peso inferiore al 5%', 'Calo di peso compreso fra 5% e 10%', 'Calo di peso superiore al 10%'),
            jsonb_build_object('Calo di peso inferiore al 5%', 0, 'Calo di peso compreso fra 5% e 10%', 1, 'Calo di peso superiore al 10%', 2),
            'Valutazione della perdita di peso non intenzionale negli ultimi 3-6 mesi. Score: <5% = 0 punti, 5-10% = 1 punto, >10% = 2 punti.',
            true, 1
        ),
        (
            must_template_id, 'must_fasting_assessment',
            'Sei a digiuno da 5 o più giorni?', 'yes_no',
            jsonb_build_array('Sì', 'No'),
            jsonb_build_object('Sì', 2, 'No', 0),
            'Valutazione del digiuno prolungato. Sì = 2 punti, No = 0 punti.',
            true, 2
        );

        RAISE NOTICE 'Created new MUST template with correct questions 1-3';
    END IF;
END $$;

-- Update the enhanced BMI calculation function to handle the new MUST questions
CREATE OR REPLACE FUNCTION calculate_must_bmi_score_enhanced(p_user_id UUID)
RETURNS TABLE(
    calculated_value TEXT,
    display_value TEXT,
    score INTEGER
) AS $$
DECLARE
    user_bmi NUMERIC;
    height_cm NUMERIC;
    weight_kg NUMERIC;
BEGIN
    -- Get user's medical data
    SELECT mp.height_cm, mp.current_weight_kg
    INTO height_cm, weight_kg
    FROM medical_profiles mp
    WHERE mp.user_id = p_user_id;

    -- Calculate BMI if data exists
    IF height_cm IS NOT NULL AND weight_kg IS NOT NULL AND height_cm > 0 THEN
        user_bmi := weight_kg / POWER(height_cm / 100.0, 2);
        
        -- Apply MUST scoring criteria exactly as specified
        IF user_bmi < 18.5 THEN
            calculated_value := 'BMI < 18.5';
            display_value := 'BMI: ' || ROUND(user_bmi, 1)::TEXT || ' (Sottopeso grave)';
            score := 2;
        ELSIF user_bmi >= 18.5 AND user_bmi < 20.0 THEN
            calculated_value := '18.5 ≤ BMI < 20';
            display_value := 'BMI: ' || ROUND(user_bmi, 1)::TEXT || ' (Lievemente sottopeso)';
            score := 1;
        ELSE
            calculated_value := 'BMI ≥ 20';
            display_value := 'BMI: ' || ROUND(user_bmi, 1)::TEXT || ' (Normale o superiore)';
            score := 0;
        END IF;
    ELSE
        calculated_value := 'Dati insufficienti';
        display_value := 'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score := 0;
    END IF;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enhanced auto-calculation function for MUST questionnaire
CREATE OR REPLACE FUNCTION auto_calculate_must_responses_enhanced(session_uuid UUID)
RETURNS VOID AS $$
DECLARE
    session_user_id UUID;
    bmi_result RECORD;
BEGIN
    -- Get user ID from session
    SELECT user_id INTO session_user_id
    FROM assessment_sessions
    WHERE id = session_uuid;

    IF session_user_id IS NULL THEN
        RAISE EXCEPTION 'Session not found: %', session_uuid;
    END IF;

    -- Calculate and save BMI response (Question 1)
    SELECT * INTO bmi_result
    FROM calculate_must_bmi_score_enhanced(session_user_id);

    -- Upsert BMI response
    INSERT INTO questionnaire_responses (
        session_id, question_id, response_value, response_score, calculated_value, updated_at
    ) VALUES (
        session_uuid, 'must_bmi_calculated', bmi_result.calculated_value, bmi_result.score, bmi_result.display_value, CURRENT_TIMESTAMP
    )
    ON CONFLICT (session_id, question_id)
    DO UPDATE SET
        response_value = EXCLUDED.response_value,
        response_score = EXCLUDED.response_score,
        calculated_value = EXCLUDED.calculated_value,
        updated_at = EXCLUDED.updated_at;

    -- Log the calculation
    RAISE NOTICE 'Auto-calculated MUST BMI response: % (Score: %)', bmi_result.calculated_value, bmi_result.score;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enhance the main auto-calculation function to call MUST-specific logic
CREATE OR REPLACE FUNCTION auto_calculate_responses(session_uuid UUID)
RETURNS VOID AS $$
DECLARE
    questionnaire_type_value TEXT;
BEGIN
    -- Get questionnaire type
    SELECT questionnaire_type INTO questionnaire_type_value
    FROM assessment_sessions
    WHERE id = session_uuid;

    -- Call specific calculation functions based on questionnaire type
    IF questionnaire_type_value = 'must' THEN
        PERFORM auto_calculate_must_responses_enhanced(session_uuid);
    END IF;

    -- Note: Other questionnaire types can have their own specific calculation functions added here
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verification query to confirm the changes
DO $$
DECLARE
    must_template_id UUID;
    question_count INTEGER;
BEGIN
    SELECT id INTO must_template_id 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true;

    IF must_template_id IS NOT NULL THEN
        SELECT COUNT(*) INTO question_count
        FROM questionnaire_questions
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'MUST questionnaire verification: Template ID = %, Total questions = %', must_template_id, question_count;
        
        -- Show the first 3 questions to verify they're correct
        RAISE NOTICE 'Question 1 (BMI): %', (SELECT question_text FROM questionnaire_questions WHERE template_id = must_template_id AND order_index = 0);
        RAISE NOTICE 'Question 2 (Weight Loss): %', (SELECT question_text FROM questionnaire_questions WHERE template_id = must_template_id AND order_index = 1);
        RAISE NOTICE 'Question 3 (Fasting): %', (SELECT question_text FROM questionnaire_questions WHERE template_id = must_template_id AND order_index = 2);
    END IF;
END $$;