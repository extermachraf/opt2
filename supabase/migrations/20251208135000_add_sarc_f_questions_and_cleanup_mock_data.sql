-- Migration: Add SARC-F questionnaire questions and cleanup any existing mock data
-- Generated at: 2025-12-08 13:50:00

-- First, ensure SARC-F template exists
DO $$
DECLARE
    sarc_f_template_id UUID;
BEGIN
    -- Check if SARC-F template already exists
    SELECT id INTO sarc_f_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sarc_f' AND is_active = true
    LIMIT 1;

    -- Create SARC-F template if it doesn't exist
    IF sarc_f_template_id IS NULL THEN
        INSERT INTO public.questionnaire_templates (
            id,
            questionnaire_type,
            title,
            description,
            category,
            is_active,
            version,
            created_at,
            updated_at
        ) VALUES (
            gen_random_uuid(),
            'sarc_f'::questionnaire_type,
            'SARC-F - Strength, Assistance, Rise, Climb, Falls',
            'Questionario per la valutazione della sarcopenia e delle capacità funzionali negli anziani. Strumento di screening per identificare il rischio di sarcopenia.',
            'Categoria 4 - Valutazione Funzionale SARC-F',
            true,
            1,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        )
        RETURNING id INTO sarc_f_template_id;
        
        RAISE NOTICE 'Created new SARC-F template with ID: %', sarc_f_template_id;
    ELSE
        RAISE NOTICE 'SARC-F template already exists with ID: %', sarc_f_template_id;
    END IF;

    -- Clean up any existing SARC-F questions to prevent duplicates
    DELETE FROM public.questionnaire_questions 
    WHERE template_id = sarc_f_template_id;
    
    RAISE NOTICE 'Cleaned up existing SARC-F questions';

    -- Insert SARC-F questions
    INSERT INTO public.questionnaire_questions (
        id,
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        scores,
        order_index,
        is_required,
        created_at
    ) VALUES 
    -- Question 1: Strength (Forza)
    (
        gen_random_uuid(),
        sarc_f_template_id,
        'sarc_strength',
        'Quanta difficoltà hai nel sollevare e trasportare 4,5 kg (come una borsa pesante della spesa)?',
        'single_choice'::question_type,
        '["Nessuna difficoltà", "Qualche difficoltà", "Molta difficoltà o incapace senza aiuto"]'::jsonb,
        '{"Nessuna difficoltà": 0, "Qualche difficoltà": 1, "Molta difficoltà o incapace senza aiuto": 2}'::jsonb,
        1,
        true,
        CURRENT_TIMESTAMP
    ),
    -- Question 2: Assistance in walking (Assistenza nel camminare)
    (
        gen_random_uuid(),
        sarc_f_template_id,
        'sarc_assistance_walking',
        'Quanta difficoltà hai nel camminare attraverso una stanza?',
        'single_choice'::question_type,
        '["Nessuna difficoltà", "Qualche difficoltà", "Molta difficoltà, uso ausili o incapace senza aiuto"]'::jsonb,
        '{"Nessuna difficoltà": 0, "Qualche difficoltà": 1, "Molta difficoltà, uso ausili o incapace senza aiuto": 2}'::jsonb,
        2,
        true,
        CURRENT_TIMESTAMP
    ),
    -- Question 3: Rise from a chair (Alzarsi dalla sedia)
    (
        gen_random_uuid(),
        sarc_f_template_id,
        'sarc_rise_chair',
        'Quanta difficoltà hai nell''alzarti da una sedia o dal letto?',
        'single_choice'::question_type,
        '["Nessuna difficoltà", "Qualche difficoltà", "Molta difficoltà o incapace senza aiuto"]'::jsonb,
        '{"Nessuna difficoltà": 0, "Qualche difficoltà": 1, "Molta difficoltà o incapace senza aiuto": 2}'::jsonb,
        3,
        true,
        CURRENT_TIMESTAMP
    ),
    -- Question 4: Climb stairs (Salire le scale)
    (
        gen_random_uuid(),
        sarc_f_template_id,
        'sarc_climb_stairs',
        'Quanta difficoltà hai nel salire 10 gradini?',
        'single_choice'::question_type,
        '["Nessuna difficoltà", "Qualche difficoltà", "Molta difficoltà o incapace senza aiuto"]'::jsonb,
        '{"Nessuna difficoltà": 0, "Qualche difficoltà": 1, "Molta difficoltà o incapace senza aiuto": 2}'::jsonb,
        4,
        true,
        CURRENT_TIMESTAMP
    ),
    -- Question 5: Falls (Cadute)
    (
        gen_random_uuid(),
        sarc_f_template_id,
        'sarc_falls',
        'Quante volte sei caduto/a nell''ultimo anno?',
        'single_choice'::question_type,
        '["Nessuna caduta", "1-3 cadute", "4 o più cadute"]'::jsonb,
        '{"Nessuna caduta": 0, "1-3 cadute": 1, "4 o più cadute": 2}'::jsonb,
        5,
        true,
        CURRENT_TIMESTAMP
    ),
    -- Question 6: Calf circumference (Circonferenza polpaccio) - Optional measurement
    (
        gen_random_uuid(),
        sarc_f_template_id,
        'sarc_calf_circumference',
        'Circonferenza del polpaccio (opzionale - misurata nella parte più larga del polpaccio non dominante in cm)',
        'number_input'::question_type,
        null,
        null,
        6,
        false,
        CURRENT_TIMESTAMP
    );

    RAISE NOTICE 'Added % SARC-F questions', 6;

END $$;

-- Cleanup any existing mock/test data for SARC-F to use real Supabase data
DELETE FROM public.questionnaire_responses 
WHERE session_id IN (
    SELECT id FROM public.assessment_sessions 
    WHERE questionnaire_type = 'sarc_f' 
    AND user_id = 'd4a87e24-2cab-4fc0-a753-fba15ba7c755'
    AND status IN ('draft', 'cancelled')
);

DELETE FROM public.assessment_sessions 
WHERE questionnaire_type = 'sarc_f' 
AND user_id = 'd4a87e24-2cab-4fc0-a753-fba15ba7c755'
AND status IN ('draft', 'cancelled');

-- Add sample SARC-F assessment session and responses for demonstration
DO $$
DECLARE
    demo_session_id UUID := gen_random_uuid();
    demo_user_id UUID := 'd4a87e24-2cab-4fc0-a753-fba15ba7c755';
BEGIN
    -- Create sample completed SARC-F session
    INSERT INTO public.assessment_sessions (
        id,
        user_id,
        questionnaire_type,
        status,
        started_at,
        completed_at,
        total_score,
        risk_level,
        created_at,
        updated_at
    ) VALUES (
        demo_session_id,
        demo_user_id,
        'sarc_f'::questionnaire_type,
        'completed'::assessment_status,
        '2025-12-07T09:00:00Z'::timestamptz,
        '2025-12-07T09:15:00Z'::timestamptz,
        0, -- No score calculated for SARC-F as requested
        'completed', -- Just mark as completed, no risk calculation
        '2025-12-07T09:00:00Z'::timestamptz,
        '2025-12-07T09:15:00Z'::timestamptz
    );

    -- Add sample responses for SARC-F questions
    INSERT INTO public.questionnaire_responses (
        id,
        session_id,
        question_id,
        response_value,
        response_score,
        created_at,
        updated_at
    ) VALUES 
    (gen_random_uuid(), demo_session_id, 'sarc_strength', 'Qualche difficoltà', null, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), demo_session_id, 'sarc_assistance_walking', 'Nessuna difficoltà', null, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), demo_session_id, 'sarc_rise_chair', 'Nessuna difficoltà', null, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), demo_session_id, 'sarc_climb_stairs', 'Qualche difficoltà', null, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), demo_session_id, 'sarc_falls', 'Nessuna caduta', null, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), demo_session_id, 'sarc_calf_circumference', '34.5', null, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

    RAISE NOTICE 'Added sample SARC-F assessment session with 6 responses';
END $$;

-- Add comment explaining SARC-F specific behavior
COMMENT ON TABLE public.questionnaire_templates IS 'Questionnaire templates - SARC-F questionnaire does not calculate scores, only displays answers for healthcare professional review';