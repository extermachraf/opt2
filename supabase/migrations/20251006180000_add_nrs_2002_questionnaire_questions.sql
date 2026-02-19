-- Location: supabase/migrations/20251006180000_add_nrs_2002_questionnaire_questions.sql
-- Schema Analysis: NRS 2002 questionnaire template already exists, questionnaire_type enum includes 'nrs_2002'
-- Integration Type: Addition of specific questions to existing questionnaire template
-- Dependencies: questionnaire_templates, questionnaire_questions tables

-- Insert NRS 2002 questions into the existing questionnaire template
DO $$
DECLARE
    template_uuid UUID;
BEGIN
    -- Get the existing NRS 2002 template ID
    SELECT id INTO template_uuid 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nrs_2002'::public.questionnaire_type 
    AND is_active = true 
    LIMIT 1;
    
    -- If template exists, insert the questions
    IF template_uuid IS NOT NULL THEN
        -- Delete any existing questions for this template to avoid duplicates
        DELETE FROM public.questionnaire_questions WHERE template_id = template_uuid;
        
        -- Insert all NRS 2002 questions with proper scoring
        INSERT INTO public.questionnaire_questions (
            template_id,
            question_id,
            question_text,
            question_type,
            order_index,
            options,
            scores,
            is_required,
            depends_on,
            depends_value
        ) VALUES
            -- Question 1: BMI < 20.5 (automatic calculation)
            (template_uuid, 'nrs_bmi_under_20_5', 'BMI < 20,5?', 'calculated'::public.question_type, 1, 
             '[]'::jsonb, '{}'::jsonb, true, NULL, NULL),
            
            -- Question 2: Weight loss in last 3 months
            (template_uuid, 'nrs_weight_loss_3m', 'Hai perso peso involontariamente negli ultimi 3 mesi?', 'yes_no'::public.question_type, 2, 
             '["Sì", "No"]'::jsonb, '{"Sì": 0, "No": 0}'::jsonb, true, NULL, NULL),
            
            -- Question 3: Reduced food intake last week
            (template_uuid, 'nrs_reduced_intake_week', 'Hai ridotto gli introiti alimentari nell''ultima settimana (non per perdere peso)?', 'yes_no'::public.question_type, 3, 
             '["Sì", "No"]'::jsonb, '{"Sì": 0, "No": 0}'::jsonb, true, NULL, NULL),
            
            -- Question 4: Acute disease
            (template_uuid, 'nrs_acute_disease', 'Hai una patologia in fase acuta?', 'yes_no'::public.question_type, 4, 
             '["Sì", "No"]'::jsonb, '{"Sì": 0, "No": 0}'::jsonb, true, NULL, NULL),
            
            -- Question 5: Recent ICU stay  
            (template_uuid, 'nrs_icu_recent', 'Sei stato ricoverato/a in terapia intensiva recentemente?', 'yes_no'::public.question_type, 5, 
             '["Sì", "No"]'::jsonb, '{"Sì": 0, "No": 0}'::jsonb, true, NULL, NULL),
            
            -- Question 6: Nutritional status (conditional - only appears if any previous = "Sì")
            (template_uuid, 'nrs_nutritional_status', 'Seleziona una delle opzioni di seguito per valutare il tuo stato nutrizionale', 'single_choice'::public.question_type, 6, 
             '["Il mio stato nutrizionale è normale", "Ho perso più del 5% del mio peso involontariamente negli ultimi 3 mesi oppure ho diminuito lievemente i miei introiti alimentari", "Ho perso più del 5% del mio peso involontariamente negli ultimi 2 mesi oppure ho diminuito moderatamente i miei introiti alimentari", "Ho perso più del 5% del mio peso involontariamente nell''ultimo mese oppure ho diminuito gravemente i miei introiti alimentari"]'::jsonb, 
             '{"Il mio stato nutrizionale è normale": 0, "Ho perso più del 5% del mio peso involontariamente negli ultimi 3 mesi oppure ho diminuito lievemente i miei introiti alimentari": 1, "Ho perso più del 5% del mio peso involontariamente negli ultimi 2 mesi oppure ho diminuito moderatamente i miei introiti alimentari": 2, "Ho perso più del 5% del mio peso involontariamente nell''ultimo mese oppure ho diminuito gravemente i miei introiti alimentari": 3}'::jsonb, 
             false, 'nrs_any_yes_trigger', 'Sì'),
            
            -- Question 7: Disease evaluation (conditional - only appears if any previous = "Sì")  
            (template_uuid, 'nrs_disease_severity', 'Seleziona una delle opzioni di seguito per valutare la tua patologia', 'single_choice'::public.question_type, 7, 
             '["Stato normale", "Patologia cronica con complicanza, patologia oncologica, chirurgia minore", "Chirurgia maggiore, patologia onco-ematologica, infezione grave, sepsi, trapianto", "Trauma grave, trapianto di midollo osseo, ricovero in terapia intensiva"]'::jsonb,
             '{"Stato normale": 0, "Patologia cronica con complicanza, patologia oncologica, chirurgia minore": 1, "Chirurgia maggiore, patologia onco-ematologica, infezione grave, sepsi, trapianto": 2, "Trauma grave, trapianto di midollo osseo, ricovero in terapia intensiva": 3}'::jsonb, 
             false, 'nrs_any_yes_trigger', 'Sì');

        RAISE NOTICE 'NRS 2002 questionnaire questions inserted successfully for template: %', template_uuid;
    ELSE
        RAISE NOTICE 'NRS 2002 template not found. Please ensure the questionnaire template exists.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting NRS 2002 questions: %', SQLERRM;
END $$;

-- Create function to handle conditional logic for NRS 2002
CREATE OR REPLACE FUNCTION public.nrs_2002_should_show_extended_questions(session_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.questionnaire_responses qr
    WHERE qr.session_id = session_uuid
    AND qr.question_id IN ('nrs_bmi_under_20_5', 'nrs_weight_loss_3m', 'nrs_reduced_intake_week', 'nrs_acute_disease', 'nrs_icu_recent')
    AND qr.response_value = 'Sì'
)
$$;

-- Create function to calculate NRS 2002 BMI score automatically
CREATE OR REPLACE FUNCTION public.calculate_nrs_2002_bmi_response(user_uuid UUID)
RETURNS TABLE(
    calculated_value TEXT,
    display_value TEXT,
    score_value INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    CASE 
        WHEN mp.height_cm IS NULL OR mp.current_weight_kg IS NULL THEN 'Dati insufficienti'
        WHEN (mp.current_weight_kg / ((mp.height_cm / 100.0) * (mp.height_cm / 100.0))) < 20.5 THEN 'Sì'
        ELSE 'No'
    END as calculated_value,
    CASE 
        WHEN mp.height_cm IS NULL OR mp.current_weight_kg IS NULL THEN 'BMI non calcolabile - inserire altezza e peso nel profilo medico'
        ELSE 'BMI: ' || ROUND((mp.current_weight_kg / ((mp.height_cm / 100.0) * (mp.height_cm / 100.0)))::numeric, 1)::TEXT || 
             CASE 
                WHEN (mp.current_weight_kg / ((mp.height_cm / 100.0) * (mp.height_cm / 100.0))) < 20.5 THEN ' (Sotto 20.5)'
                ELSE ' (Sopra o uguale a 20.5)'
             END
    END as display_value,
    CASE 
        WHEN mp.height_cm IS NULL OR mp.current_weight_kg IS NULL THEN 0
        WHEN (mp.current_weight_kg / ((mp.height_cm / 100.0) * (mp.height_cm / 100.0))) < 20.5 THEN 1
        ELSE 0
    END as score_value
FROM public.medical_profiles mp
WHERE mp.user_id = user_uuid
LIMIT 1
$$;

-- Create function to calculate final NRS 2002 score including age adjustment
CREATE OR REPLACE FUNCTION public.calculate_nrs_2002_final_score(session_uuid UUID)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    COALESCE(
        (SELECT SUM(qr.response_score)
         FROM public.questionnaire_responses qr
         WHERE qr.session_id = session_uuid
         AND qr.question_id IN ('nrs_nutritional_status', 'nrs_disease_severity')), 
        0
    ) + 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.assessment_sessions asess
            JOIN public.user_profiles up ON asess.user_id = up.id
            WHERE asess.id = session_uuid
            AND EXTRACT(YEAR FROM AGE(up.date_of_birth)) > 69
        ) THEN 1
        ELSE 0
    END
$$;