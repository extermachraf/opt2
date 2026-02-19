-- Location: supabase/migrations/20251206121100_fix_nrs_2002_questionnaire_questions.sql
-- Schema Analysis: Existing questionnaire system with NRS 2002 template (d4917df5-5a84-41f7-aa8b-c20bd96d0ddf)
-- Integration Type: Modificative - replacing incorrect questions with proper NRS 2002 structure
-- Dependencies: questionnaire_templates, questionnaire_questions tables

-- Fix NRS 2002 Questionnaire Questions according to proper specifications
-- Replace incorrect "BMI < 20,5?" standalone question with proper 7-question structure

-- Step 1: Remove existing incorrect NRS 2002 questions
DELETE FROM public.questionnaire_questions 
WHERE template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

-- Step 2: Add the correct NRS 2002 questions structure

-- Question 1: BMI < 20,5? (Automatic calculation)
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores, notes
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_bmi_under_20_5',
        'BMI < 20,5?',
        'calculated',
        1,
        true,
        '[]'::jsonb,
        '{}'::jsonb,
        'Valore calcolato automaticamente dal sistema basato su altezza e peso del profilo medico'
    );

-- Question 2: Weight loss in last 3 months
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_weight_loss_3m',
        'Hai perso peso involontariamente negli ultimi 3 mesi?',
        'yes_no',
        2,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb
    );

-- Question 3: Reduced food intake in last week
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_reduced_intake',
        'Hai ridotto gli introiti alimentari nell''ultima settimana (non per perdere peso)?',
        'yes_no',
        3,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb
    );

-- Question 4: Acute pathology
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_acute_pathology',
        'Hai una patologia in fase acuta?',
        'yes_no',
        4,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb
    );

-- Question 5: Recent intensive care admission
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_intensive_care',
        'Sei stato ricoverato/a in terapia intensiva recentemente?',
        'yes_no',
        5,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb
    );

-- Question 6: Nutritional status assessment (conditional - shows if any of first 5 is "Sì")
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores, depends_on, depends_value
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_nutritional_status',
        'Seleziona una delle opzioni di seguito per valutare il tuo stato nutrizionale',
        'single_choice',
        6,
        true,
        '[
            "Il mio stato nutrizionale è normale",
            "Ho perso più del 5% del mio peso involontariamente negli ultimi 3 mesi oppure ho diminuito lievemente i miei introiti alimentari",
            "Ho perso più del 5% del mio peso involontariamente negli ultimi 2 mesi oppure ho diminuito moderatamente i miei introiti alimentari", 
            "Ho perso più del 5% del mio peso involontariamente nell''ultimo mese oppure ho diminuito gravemente i miei introiti alimentari"
        ]'::jsonb,
        '{
            "Il mio stato nutrizionale è normale": 0,
            "Ho perso più del 5% del mio peso involontariamente negli ultimi 3 mesi oppure ho diminuito lievemente i miei introiti alimentari": 1,
            "Ho perso più del 5% del mio peso involontariamente negli ultimi 2 mesi oppure ho diminuito moderatamente i miei introiti alimentari": 2,
            "Ho perso più del 5% del mio peso involontariamente nell''ultimo mese oppure ho diminuito gravemente i miei introiti alimentari": 3
        }'::jsonb,
        'ANY_PREVIOUS_YES',
        'Sì'
    );

-- Question 7: Disease severity assessment (conditional - shows if any of first 5 is "Sì")
INSERT INTO public.questionnaire_questions (
    template_id, question_id, question_text, question_type, 
    order_index, is_required, options, scores, depends_on, depends_value
) VALUES 
    (
        'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf',
        'nrs_disease_severity',
        'Seleziona una delle opzioni di seguito per valutare la tua patologia',
        'single_choice',
        7,
        true,
        '[
            "Stato normale",
            "Patologia cronica con complicanza, patologia oncologica, chirurgia minore",
            "Chirurgia maggiore, patologia onco-ematologica, infezione grave, sepsi, trapianto",
            "Trauma grave, trapianto di midollo osseo, ricovero in terapia intensiva"
        ]'::jsonb,
        '{
            "Stato normale": 0,
            "Patologia cronica con complicanza, patologia oncologica, chirurgia minore": 1,
            "Chirurgia maggiore, patologia onco-ematologica, infezione grave, sepsi, trapianto": 2,
            "Trauma grave, trapianto di midollo osseo, ricovero in terapia intensiva": 3
        }'::jsonb,
        'ANY_PREVIOUS_YES',
        'Sì'
    );

-- Step 3: Fix database functions by dropping and recreating with correct parameter names

-- Drop the existing function first to avoid parameter name conflict
DROP FUNCTION IF EXISTS public.nrs_2002_should_show_extended_questions(UUID);

-- Create function to check if Questions 6-7 should be displayed (using session_uuid to match existing pattern)
CREATE FUNCTION public.nrs_2002_should_show_extended_questions(session_uuid UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    has_yes_response BOOLEAN := false;
BEGIN
    -- Check if any of the first 5 questions has "Sì" response
    SELECT EXISTS (
        SELECT 1 FROM public.questionnaire_responses qr
        JOIN public.questionnaire_questions qq ON qr.question_id = qq.question_id
        WHERE qr.session_id = nrs_2002_should_show_extended_questions.session_uuid
        AND qq.template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf'
        AND qq.order_index BETWEEN 1 AND 5
        AND qr.response_value = 'Sì'
    ) INTO has_yes_response;
    
    RETURN has_yes_response;
END;
$$;

-- Drop the existing function first to avoid parameter name conflict
DROP FUNCTION IF EXISTS public.calculate_nrs_2002_final_score(UUID);

-- Create function to calculate NRS 2002 final score with age adjustment (using session_uuid to match existing pattern)
CREATE FUNCTION public.calculate_nrs_2002_final_score(session_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    nutritional_score INTEGER := 0;
    disease_score INTEGER := 0;
    age_score INTEGER := 0;
    user_age INTEGER := 0;
    final_score INTEGER := 0;
BEGIN
    -- Get nutritional status score (Question 6)
    SELECT COALESCE((qr.response_scores->>'total')::INTEGER, 0)
    INTO nutritional_score
    FROM public.questionnaire_responses qr
    JOIN public.questionnaire_questions qq ON qr.question_id = qq.question_id
    WHERE qr.session_id = calculate_nrs_2002_final_score.session_uuid
    AND qq.question_id = 'nrs_nutritional_status';
    
    -- Get disease severity score (Question 7)
    SELECT COALESCE((qr.response_scores->>'total')::INTEGER, 0)
    INTO disease_score
    FROM public.questionnaire_responses qr
    JOIN public.questionnaire_questions qq ON qr.question_id = qq.question_id
    WHERE qr.session_id = calculate_nrs_2002_final_score.session_uuid
    AND qq.question_id = 'nrs_disease_severity';
    
    -- Calculate user age and add age score if > 69
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, mp.date_of_birth))
    INTO user_age
    FROM public.assessment_sessions asess
    JOIN public.user_profiles up ON asess.user_id = up.id
    JOIN public.medical_profiles mp ON up.id = mp.user_id
    WHERE asess.id = calculate_nrs_2002_final_score.session_uuid;
    
    -- Add 1 point if age > 69
    IF user_age > 69 THEN
        age_score := 1;
    END IF;
    
    -- Calculate final score
    final_score := nutritional_score + disease_score + age_score;
    
    RETURN final_score;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Return 0 if any error occurs in calculation
        RETURN 0;
END;
$$;

-- Drop the existing function first to avoid parameter name conflict
DROP FUNCTION IF EXISTS public.calculate_nrs_2002_bmi_response(UUID);

-- Create function for automatic BMI calculation and response
CREATE FUNCTION public.calculate_nrs_2002_bmi_response(user_id UUID)
RETURNS TABLE(
    calculated_value TEXT,
    display_value TEXT,
    score INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_bmi NUMERIC;
    is_under_20_5 BOOLEAN;
BEGIN
    -- Get BMI from medical profile
    SELECT (mp.weight / POWER(mp.height / 100.0, 2))
    INTO user_bmi
    FROM public.medical_profiles mp
    WHERE mp.user_id = calculate_nrs_2002_bmi_response.user_id
    AND mp.weight IS NOT NULL
    AND mp.height IS NOT NULL;
    
    IF user_bmi IS NOT NULL THEN
        is_under_20_5 := user_bmi < 20.5;
        
        RETURN QUERY SELECT
            CASE WHEN is_under_20_5 THEN 'Sì'::TEXT ELSE 'No'::TEXT END,
            ('BMI: ' || ROUND(user_bmi, 1)::TEXT || CASE 
                WHEN is_under_20_5 THEN ' - Sotto 20.5' 
                ELSE ' - Sopra o uguale a 20.5' 
            END)::TEXT,
            CASE WHEN is_under_20_5 THEN 1 ELSE 0 END;
    ELSE
        -- No medical data available
        RETURN QUERY SELECT
            'Dati insufficienti'::TEXT,
            'BMI non calcolabile - inserire altezza e peso nel profilo medico'::TEXT,
            0;
    END IF;
END;
$$;

-- Add helpful comment for questionnaire completion message
COMMENT ON TABLE public.questionnaire_templates IS 'NRS 2002 questionnaire shows advisory message: "Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti." (no score displayed to user)';