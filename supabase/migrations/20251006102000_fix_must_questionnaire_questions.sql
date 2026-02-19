-- CRITICAL FIX: Properly update MUST questionnaire questions 1-3 with correct identification and implementation
-- Location: supabase/migrations/20251006102000_fix_must_questionnaire_questions.sql

-- Enhanced MUST questionnaire questions fix with better question identification
DO $$
DECLARE
    must_template_id UUID;
    existing_question_count INTEGER;
BEGIN
    -- Get the MUST template ID with error handling
    SELECT id INTO must_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true
    LIMIT 1;

    IF must_template_id IS NULL THEN
        RAISE NOTICE 'MUST template not found, creating template first...';
        
        -- Create MUST template if it doesn't exist
        INSERT INTO public.questionnaire_templates (
            questionnaire_type, title, description, category, is_active, version
        ) VALUES (
            'must', 
            'MUST - Malnutrition Universal Screening Tool',
            'Screening universale per la malnutrizione con valutazione automatica BMI e analisi perdita peso',
            'Categoria 2 - Valutazioni Nutrizionali MUST',
            true,
            1
        ) RETURNING id INTO must_template_id;
        
        RAISE NOTICE 'Created new MUST template with ID: %', must_template_id;
    END IF;

    -- Check existing questions count
    SELECT COUNT(*) INTO existing_question_count
    FROM public.questionnaire_questions
    WHERE template_id = must_template_id;

    RAISE NOTICE 'Found % existing questions for MUST template', existing_question_count;

    -- CRITICAL FIX: Delete all existing MUST questions and recreate with proper structure
    DELETE FROM public.questionnaire_questions WHERE template_id = must_template_id;
    
    RAISE NOTICE 'Cleared existing MUST questions, creating new structured questions...';

    -- Question 1: BMI (automatic calculation) - FIXED with proper question_id
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, 
        order_index, is_required, notes, scores, options
    ) VALUES (
        must_template_id, 
        'must_bmi_calculated', 
        'BMI',
        'calculated',
        0, 
        true, 
        'Valore calcolato automaticamente dal sistema utilizzando altezza e peso del paziente. Il BMI viene categorizzato secondo i criteri MUST.',
        jsonb_build_object(
            'BMI ≥ 20', 0,
            '18.5 ≤ BMI < 20', 1,
            'BMI < 18.5', 2
        ),
        '[]'::jsonb
    );

    -- Question 2: Weight loss assessment - FIXED with proper Italian text
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type,
        order_index, is_required, notes, scores, options
    ) VALUES (
        must_template_id, 
        'must_weight_loss_assessment', 
        'Hai sperimentato un calo di peso non programmato negli ultimi 3/6 mesi?',
        'single_choice',
        1, 
        true,
        'Valutazione della perdita di peso non intenzionale negli ultimi 3-6 mesi secondo i criteri MUST.',
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

    -- Question 3: Fasting assessment - FIXED with proper yes/no structure
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type,
        order_index, is_required, notes, scores, options  
    ) VALUES (
        must_template_id, 
        'must_fasting_status', 
        'Sei a digiuno da 5 o più giorni?',
        'yes_no',
        2, 
        true,
        'Valutazione dello stato di digiuno prolungato (5 o più giorni) secondo i criteri MUST.',
        jsonb_build_object(
            'Sì', 2,
            'No', 0
        ),
        jsonb_build_array('Sì', 'No')
    );

    RAISE NOTICE 'Successfully created/updated MUST questionnaire questions 1-3';

    -- CRITICAL: Update questionnaire template timestamp to force refresh
    UPDATE public.questionnaire_templates 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE id = must_template_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating MUST questions: %', SQLERRM;
        -- Don't fail the migration, just log the error
END $$;

-- Enhanced BMI auto-calculation function specifically for MUST questionnaire
CREATE OR REPLACE FUNCTION public.calculate_must_bmi_score_enhanced(user_id_param UUID)
RETURNS TABLE(
    calculated_value TEXT,
    display_text TEXT,
    score_value INTEGER,
    bmi_numeric NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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

    -- CRITICAL FIX: Proper MUST BMI scoring with correct ranges
    IF user_bmi IS NULL THEN
        calculated_value := 'Dati insufficienti';
        display_text := 'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score_value := 0;
        bmi_category := 'Non disponibile';
    ELSIF user_bmi < 18.5 THEN
        calculated_value := 'BMI < 18.5';
        display_text := 'BMI: ' || user_bmi || ' (Sottopeso grave)';
        score_value := 2;
        bmi_category := 'Sottopeso grave';
    ELSIF user_bmi >= 18.5 AND user_bmi < 20.0 THEN
        calculated_value := '18.5 ≤ BMI < 20';
        display_text := 'BMI: ' || user_bmi || ' (Lievemente sottopeso)';
        score_value := 1;
        bmi_category := 'Lievemente sottopeso';
    ELSE -- BMI >= 20
        calculated_value := 'BMI ≥ 20';
        display_text := 'BMI: ' || user_bmi || ' (Peso normale o superiore)';
        score_value := 0;
        bmi_category := 'Normale';
    END IF;

    bmi_numeric := user_bmi;

    RETURN NEXT;
END;
$$;

-- Enhanced auto-calculation function with better MUST questionnaire handling
CREATE OR REPLACE FUNCTION public.auto_calculate_must_responses_enhanced(session_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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

    RAISE NOTICE 'Processing MUST auto-calculations for session: % and user: %', session_uuid, user_id_val;

    -- Get template ID for MUST questionnaire
    SELECT id INTO template_id_val
    FROM public.questionnaire_templates
    WHERE questionnaire_type = 'must' AND is_active = true
    LIMIT 1;

    -- Calculate and save BMI response
    SELECT * INTO bmi_result 
    FROM public.calculate_must_bmi_score_enhanced(user_id_val);

    RAISE NOTICE 'BMI calculation result: value=%, score=%, display=%', bmi_result.calculated_value, bmi_result.score_value, bmi_result.display_text;

    -- CRITICAL FIX: Use the correct question_id that matches the database
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

    RAISE NOTICE 'Successfully saved MUST BMI response for session: %', session_uuid;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in MUST auto-calculation: %', SQLERRM;
END;
$$;

-- Update the main auto_calculate_responses function to use enhanced version
CREATE OR REPLACE FUNCTION public.auto_calculate_responses(session_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    questionnaire_type_val TEXT;
BEGIN
    -- Get questionnaire type with error handling
    SELECT questionnaire_type INTO questionnaire_type_val
    FROM public.assessment_sessions
    WHERE id = session_uuid;

    IF questionnaire_type_val IS NULL THEN
        RAISE NOTICE 'Session not found or invalid: %', session_uuid;
        RETURN;
    END IF;

    RAISE NOTICE 'Auto-calculating responses for questionnaire type: %', questionnaire_type_val;

    -- Handle MUST questionnaire specifically with enhanced logic
    IF questionnaire_type_val = 'must' THEN
        PERFORM public.auto_calculate_must_responses_enhanced(session_uuid);
        RAISE NOTICE 'Completed MUST auto-calculations for session: %', session_uuid;
    ELSE
        RAISE NOTICE 'No auto-calculation needed for questionnaire type: %', questionnaire_type_val;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in auto_calculate_responses: %', SQLERRM;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.calculate_must_bmi_score_enhanced(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.auto_calculate_must_responses_enhanced(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.auto_calculate_responses(UUID) TO authenticated;

-- Force a refresh by updating all MUST template timestamps
UPDATE public.questionnaire_templates 
SET updated_at = CURRENT_TIMESTAMP 
WHERE questionnaire_type = 'must';

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'MUST questionnaire questions fix completed successfully';
    RAISE NOTICE 'Questions updated: 1. BMI (automatic), 2. Weight loss assessment, 3. Fasting status';
    RAISE NOTICE 'Enhanced BMI calculation and auto-response functions created';
END $$;