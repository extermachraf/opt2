-- Location: supabase/migrations/20250925161456_fix_questionnaire_progress_calculation.sql
-- Schema Analysis: Existing questionnaire system needs data cleanup and progress calculation fixes
-- Integration Type: Data modification and cleanup for existing questionnaire system
-- Dependencies: Existing questionnaire_templates, questionnaire_questions tables

-- Fix questionnaire data issues:
-- 1. Remove "Valutazione Nutrizionale Consolidata" if it exists
-- 2. Merge duplicated questions in "Valutazione Rischio Nutrizionale"
-- 3. Ensure clean questionnaire structure for proper progress calculation

DO $$
DECLARE
    vrn_template_id UUID;
BEGIN
    -- Get the Valutazione Rischio Nutrizionale template ID
    SELECT id INTO vrn_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type
    LIMIT 1;

    -- Remove any template with "Valutazione Nutrizionale Consolidata" in title or category
    DELETE FROM public.questionnaire_responses 
    WHERE session_id IN (
        SELECT id FROM public.assessment_sessions 
        WHERE questionnaire_type = 'consolidated_nutritional_assessment'::public.questionnaire_type
    );
    
    DELETE FROM public.assessment_sessions 
    WHERE questionnaire_type = 'consolidated_nutritional_assessment'::public.questionnaire_type;
    
    DELETE FROM public.questionnaire_questions 
    WHERE template_id IN (
        SELECT id FROM public.questionnaire_templates 
        WHERE title ILIKE '%Valutazione Nutrizionale Consolidata%' 
        OR category ILIKE '%Consolidata%'
        OR questionnaire_type = 'consolidated_nutritional_assessment'::public.questionnaire_type
    );
    
    DELETE FROM public.questionnaire_templates 
    WHERE title ILIKE '%Valutazione Nutrizionale Consolidata%' 
    OR category ILIKE '%Consolidata%'
    OR questionnaire_type = 'consolidated_nutritional_assessment'::public.questionnaire_type;

    -- Clean up and merge duplicated questions in Valutazione Rischio Nutrizionale
    IF vrn_template_id IS NOT NULL THEN
        -- Remove existing questions for this template to rebuild clean structure
        DELETE FROM public.questionnaire_questions WHERE template_id = vrn_template_id;
        
        -- Insert cleaned up questions for Valutazione Rischio Nutrizionale with merged options
        INSERT INTO public.questionnaire_questions (
            template_id, question_id, question_text, question_type, options, order_index, is_required, notes, score_value
        ) VALUES
            -- Merged pathology severity question with all options in one
            (vrn_template_id, 'vrn_pathology_severity', 'Gravità della patologia concomitante', 'single_choice', 
             '["Patologie non impattanti sui fabbisogni nutrizionali", "Patologie croniche con complicanze (cirrosi, BPCO, insufficienza renale in dialisi, diabete scompensato, patologie gastroenterologiche, neurologiche e reumatologiche), patologie oncologiche, patologie acute (infettive, respiratorie, cardiologiche), chirurgia minore, frattura del femore", "Chirurgia maggiore, ictus, patologie onco-ematologiche, polmonite grave, trapianto di organo (non midollo osseo), sepsi", "Trauma grave, trapianto di midollo osseo, ricovero in Terapia Intensiva"]'::jsonb, 
             1, true, 'Punteggio: 0 per prima opzione, 1 per seconda, 2 per terza, 3 per quarta', null),
            
            -- Weight loss question
            (vrn_template_id, 'vrn_weight_loss', 'Hai perso involontariamente peso negli ultimi 3 mesi?', 'yes_no', 
             '["Sì", "No"]'::jsonb, 2, true, null, null),
             
            -- Reduced intake question
            (vrn_template_id, 'vrn_reduced_intake', 'Hai ridotto i consumi alimentari rispetto alle tue abitudini (non per perdere peso)?', 'yes_no', 
             '["Sì", "No"]'::jsonb, 3, true, null, null),
             
            -- BMI check (calculated)
            (vrn_template_id, 'vrn_bmi_check', 'Il BMI è < 20,5?', 'calculated', 
             '["Sì", "No"]'::jsonb, 4, true, 'Calcolo automatico a partire dai valori di Altezza paziente [cm] e Peso attuale paziente [kg]', null),
             
            -- Has pathology (calculated)
            (vrn_template_id, 'vrn_has_pathology', 'Il paziente presenta una patologia?', 'calculated', 
             '["Sì", "No"]'::jsonb, 5, true, 'Compilazione automatica se il paziente ha selezionato una opzione fra le Patologie concomitanti', null),
             
            -- Merged nutritional status question with all options
            (vrn_template_id, 'vrn_nutritional_status', 'In quale stato nutrizionale ti ritrovi? Come è stata la tua alimentazione nella ultima settimana?', 'single_choice', 
             '["Normale", "Calo > 5% del peso corporeo negli ultimi 3 mesi/Alimentazione diminuita lievemente", "Calo > 5% del peso corporeo negli ultimi 2 mesi/Alimentazione diminuita moderatamente", "Calo > 5% del peso corporeo nel ultimo mese (o > 15% negli ultimi 3 mesi)/Alimentazione diminuita gravemente"]'::jsonb, 
             6, true, 'Punteggio: 0 per normale, 1 per lieve, 2 per moderata, 3 per grave', null);
    END IF;

    RAISE NOTICE 'Questionnaire cleanup completed successfully. Removed consolidated questionnaire and merged duplicate questions.';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during questionnaire cleanup: %', SQLERRM;
END $$;

-- Add comment for tracking
COMMENT ON TABLE public.questionnaire_templates IS 'Updated questionnaire templates - removed consolidated questionnaire and merged duplicate questions for clean progress calculation';