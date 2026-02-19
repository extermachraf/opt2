-- Location: supabase/migrations/20250924153931_update_valutazione_rischio_nutrizionale.sql
-- Schema Analysis: Existing questionnaire_templates and questionnaire_questions tables
-- Integration Type: MODIFICATIVE - Update existing nutritional risk assessment questionnaire
-- Dependencies: questionnaire_templates, questionnaire_questions

-- Update the existing "Valutazione Rischio Nutrizionale" template
DO $$
DECLARE
    risk_template_id UUID;
BEGIN
    -- Find or create the nutritional risk assessment template
    SELECT id INTO risk_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type
    LIMIT 1;
    
    -- If template doesn't exist, create it
    IF risk_template_id IS NULL THEN
        INSERT INTO public.questionnaire_templates (
            title, 
            category, 
            questionnaire_type, 
            description,
            is_active
        ) VALUES (
            'Valutazione Rischio Nutrizionale',
            'Categoria 3 - Valutazione Rischio Nutrizionale',
            'nutritional_risk_assessment'::public.questionnaire_type,
            'Valutazione del rischio nutrizionale attraverso analisi di patologie, peso corporeo, BMI e abitudini alimentari',
            true
        ) RETURNING id INTO risk_template_id;
    ELSE
        -- Update existing template
        UPDATE public.questionnaire_templates 
        SET 
            title = 'Valutazione Rischio Nutrizionale',
            category = 'Categoria 3 - Valutazione Rischio Nutrizionale',
            description = 'Valutazione del rischio nutrizionale attraverso analisi di patologie, peso corporeo, BMI e abitudini alimentari',
            updated_at = CURRENT_TIMESTAMP
        WHERE id = risk_template_id;
    END IF;

    -- Delete existing questions for this template
    DELETE FROM public.questionnaire_questions 
    WHERE template_id = risk_template_id;

    -- Insert new questions structure
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        scores,
        score_value,
        notes,
        order_index,
        is_required
    ) VALUES 
    -- Question 1: Gravità della patologia concomitante
    (
        risk_template_id,
        'patologia_gravita',
        'Gravità della patologia concomitante',
        'single_choice'::public.question_type,
        '["Patologie non impattanti sui fabbisogni nutrizionali (cioè diverse da quelle seguenti)", "Patologie croniche con complicanze (es. cirrosi, BPCO, insufficienza renale in dialisi, diabete scompensato, patologie gastroenterologiche, neurologiche e reumatologiche), patologie oncologiche, patologie acute (es. infettive, respiratorie, cardiologiche), chirurgia minore, frattura del femore", "Chirurgia maggiore, ictus, patologie onco-ematologiche, polmonite grave, trapianto d''organo (non midollo osseo), sepsi", "Trauma grave, trapianto di midollo osseo, ricovero in Terapia Intensiva"]'::jsonb,
        '{"Patologie non impattanti": 0, "Patologie croniche con complicanze / oncologiche / acute lievi / chirurgia minore / frattura femore": 1, "Chirurgia maggiore / ictus / patologie onco-ematologiche / polmonite grave / trapianto d''organo (non midollo) / sepsi": 2, "Trauma grave / trapianto di midollo osseo / ricovero in Terapia Intensiva": 3}'::jsonb,
        0,
        'Se una delle risposte ai quattro quesiti sopra è "Sì", deve comparire questa domanda. Punteggio per questa risposta: 0',
        1,
        true
    ),
    -- Question 2: Perdita peso involontaria
    (
        risk_template_id,
        'perdita_peso_3_mesi',
        'Hai perso involontariamente peso negli ultimi 3 mesi?',
        'yes_no'::public.question_type,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb,
        null,
        null,
        2,
        true
    ),
    -- Question 3: Riduzione consumi alimentari
    (
        risk_template_id,
        'riduzione_consumi_alimentari',
        'Hai ridotto i consumi alimentari rispetto alle tue abitudini (non per perdere peso)?',
        'yes_no'::public.question_type,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb,
        null,
        null,
        3,
        true
    ),
    -- Question 4: BMI sotto 20.5
    (
        risk_template_id,
        'bmi_sotto_20_5',
        'Il BMI è < 20,5?',
        'calculated'::public.question_type,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb,
        null,
        'Calcolo automatico a partire dai valori di Altezza paziente [cm] e Peso attuale paziente [kg]',
        4,
        true
    ),
    -- Question 5: Presenza patologia
    (
        risk_template_id,
        'presenza_patologia',
        'Il paziente presenta una patologia?',
        'calculated'::public.question_type,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 1, "No": 0}'::jsonb,
        null,
        'Compilazione automatica se il paziente ha selezionato una opzione fra le Patologie concomitanti',
        5,
        true
    ),
    -- Question 6: Stato nutrizionale - Normale
    (
        risk_template_id,
        'stato_nutrizionale_normale',
        'In quale stato nutrizionale ti ritrovi? Come è stata la tua alimentazione nell''ultima settimana?',
        'single_choice'::public.question_type,
        '["Normale"]'::jsonb,
        '{"Normale": 0}'::jsonb,
        0,
        'Se una delle risposte ai quattro quesiti sopra è "Sì", deve comparire questa domanda. Punteggio per questa risposta: 0',
        6,
        false
    ),
    -- Question 7: Stato nutrizionale - Lieve
    (
        risk_template_id,
        'stato_nutrizionale_lieve',
        'In quale stato nutrizionale ti ritrovi? Come è stata la tua alimentazione nell''ultima settimana?',
        'single_choice'::public.question_type,
        '["Calo > 5% del peso corporeo negli ultimi 3 mesi/Alimentazione diminuita lievemente"]'::jsonb,
        '{"Calo >5% peso negli ultimi 3 mesi / alimentazione diminuita lievemente": 1}'::jsonb,
        1,
        'Punteggio per questa risposta: 1',
        7,
        false
    ),
    -- Question 8: Stato nutrizionale - Moderato
    (
        risk_template_id,
        'stato_nutrizionale_moderato',
        'In quale stato nutrizionale ti ritrovi? Come è stata la tua alimentazione nell''ultima settimana?',
        'single_choice'::public.question_type,
        '["Calo > 5% del peso corporeo negli ultimi 2 mesi/Alimentazione diminuita moderatamente"]'::jsonb,
        '{"Calo >5% peso negli ultimi 2 mesi / alimentazione diminuita moderatamente": 2}'::jsonb,
        2,
        'Punteggio per questa risposta: 2',
        8,
        false
    ),
    -- Question 9: Stato nutrizionale - Grave
    (
        risk_template_id,
        'stato_nutrizionale_grave',
        'In quale stato nutrizionale ti ritrovi? Come è stata la tua alimentazione nell''ultima settimana?',
        'single_choice'::public.question_type,
        '["Calo > 5% del peso corporeo nell''ultimo mese (o > 15% negli ultimi 3 mesi)/Alimentazione diminuita gravemente"]'::jsonb,
        '{"Calo >5% peso nell''ultimo mese (o >15% in 3 mesi) / alimentazione diminuita gravemente": 3}'::jsonb,
        3,
        'Punteggio per questa risposta: 3',
        9,
        false
    );

    RAISE NOTICE 'Successfully updated Valutazione Rischio Nutrizionale questionnaire with % questions', 9;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating questionnaire: %', SQLERRM;
        ROLLBACK;
END $$;

-- Update questionnaire service mapping for the new category name
UPDATE public.questionnaire_templates 
SET category = 'Valutazione Rischio Nutrizionale'
WHERE questionnaire_type = 'nutritional_risk_assessment'::public.questionnaire_type;

-- Add comment for documentation
COMMENT ON TABLE public.questionnaire_questions IS 'Updated with new Valutazione Rischio Nutrizionale structure including patologia gravità, BMI calculation, weight loss assessment, and nutritional status evaluation';