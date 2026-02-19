-- Location: supabase/migrations/20241206130000_fix_sf12_questionnaire_duplicates.sql
-- Schema Analysis: questionnaire_templates and questionnaire_questions tables exist with sf12 type
-- Integration Type: MODIFICATIVE - Clean up duplicates and standardize SF-12 questionnaire  
-- Dependencies: questionnaire_templates, questionnaire_questions tables

-- Step 1: Clean up any existing SF-12 related data (remove duplicates)
DELETE FROM public.questionnaire_responses 
WHERE session_id IN (
    SELECT DISTINCT qs.id 
    FROM public.assessment_sessions qs 
    WHERE qs.questionnaire_type = 'sf12'
);

DELETE FROM public.assessment_sessions 
WHERE questionnaire_type = 'sf12';

DELETE FROM public.questionnaire_questions 
WHERE template_id IN (
    SELECT id FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'sf12'
);

DELETE FROM public.questionnaire_templates 
WHERE questionnaire_type = 'sf12';

-- Step 2: Create single, clean SF-12 template
DO $$
DECLARE
    sf12_template_id UUID := gen_random_uuid();
BEGIN
    -- Insert the one and only SF-12 questionnaire template
    INSERT INTO public.questionnaire_templates (
        id,
        questionnaire_type,
        title,
        description,
        category,
        is_active,
        version
    ) VALUES (
        sf12_template_id,
        'sf12'::public.questionnaire_type,
        'SF-12 - Short Form Health Survey',
        'Questionario di autovalutazione della salute. Le risposte vengono registrate per la consultazione professionale. Non viene calcolato alcun punteggio.',
        'Categoria 4 - Qualità della Vita SF-12',
        true,
        1
    );

    -- Insert exactly 12 questions as specified by user
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        order_index,
        is_required,
        scores
    ) VALUES
    -- Question 1
    (sf12_template_id, 'sf12_general_health', 'In generale, diresti che la tua salute è:', 
     'single_choice'::public.question_type,
     '["Eccellente","Molto buona","Buona","Passabile","Scadente"]'::jsonb,
     1, true, '{}'::jsonb),
    
    -- Question 2  
    (sf12_template_id, 'sf12_moderate_activities', 'La tua salute ti limita attualmente nello svolgimento di attività di moderato impegno fisico (es. usare l''aspirapolvere, fare un giro in bicicletta, ecc.)?',
     'single_choice'::public.question_type,
     '["Sì parecchio","Sì parzialmente","No per nulla"]'::jsonb,
     2, true, '{}'::jsonb),
    
    -- Question 3
    (sf12_template_id, 'sf12_climbing_stairs', 'La tua salute ti limita attualmente nel salire qualche piano di scale?',
     'single_choice'::public.question_type, 
     '["Sì parecchio","Sì parzialmente","No per nulla"]'::jsonb,
     3, true, '{}'::jsonb),
    
    -- Question 4
    (sf12_template_id, 'sf12_work_performance_physical', 'Nelle ultime 4 settimane, hai reso meno di quanto avresti voluto sul lavoro o nelle altre attività quotidiane, a causa della tua salute?',
     'yes_no'::public.question_type,
     '["Sì","No"]'::jsonb,
     4, true, '{}'::jsonb),
    
    -- Question 5
    (sf12_template_id, 'sf12_work_limitations_physical', 'Nelle ultime 4 settimane, hai dovuto limitare alcuni tipi di lavoro o di altre attività, a causa della tua salute?',
     'yes_no'::public.question_type,
     '["Sì","No"]'::jsonb,
     5, true, '{}'::jsonb),
    
    -- Question 6
    (sf12_template_id, 'sf12_work_performance_emotional', 'Nelle ultime 4 settimane, hai reso meno di quanto avresti voluto sul lavoro o nelle altre attività quotidiane, a causa del tuo stato emotivo (es. sentirsi depresso, ansioso)?',
     'yes_no'::public.question_type,
     '["Sì","No"]'::jsonb,
     6, true, '{}'::jsonb),
    
    -- Question 7
    (sf12_template_id, 'sf12_concentration_emotional', 'Nelle ultime 4 settimane, hai avuto un calo di concentrazione sul lavoro o nelle altre attività quotidiane, a causa del tuo stato emotivo?',
     'yes_no'::public.question_type,
     '["Sì","No"]'::jsonb,
     7, true, '{}'::jsonb),
    
    -- Question 8
    (sf12_template_id, 'sf12_pain_interference', 'Nelle ultime 4 settimane, in che misura il dolore ti ha ostacolato nel lavoro che svolgi abitualmente (sia in casa sia fuori casa)?',
     'single_choice'::public.question_type,
     '["Per nulla","Molto poco","Un po''","Molto","Moltissimo"]'::jsonb,
     8, true, '{}'::jsonb),
    
    -- Question 9
    (sf12_template_id, 'sf12_calm_peaceful', 'Per quanto tempo nelle ultime 4 settimane ti sei sentito calmo e sereno?',
     'single_choice'::public.question_type,
     '["Sempre","Quasi sempre","Molto tempo","Una parte del tempo","Quasi mai","Mai"]'::jsonb,
     9, true, '{}'::jsonb),
    
    -- Question 10
    (sf12_template_id, 'sf12_energy', 'Per quanto tempo nelle ultime 4 settimane ti sei sentito pieno di energia?',
     'single_choice'::public.question_type,
     '["Sempre","Quasi sempre","Molto tempo","Una parte del tempo","Quasi mai","Mai"]'::jsonb,
     10, true, '{}'::jsonb),
    
    -- Question 11
    (sf12_template_id, 'sf12_downhearted_sad', 'Per quanto tempo nelle ultime 4 settimane ti sei sentito scoraggiato e triste?',
     'single_choice'::public.question_type,
     '["Sempre","Quasi sempre","Molto tempo","Una parte del tempo","Quasi mai","Mai"]'::jsonb,
     11, true, '{}'::jsonb),
    
    -- Question 12
    (sf12_template_id, 'sf12_social_interference', 'Nelle ultime 4 settimane per quanto tempo la tua salute fisica o il tuo stato emotivo hanno interferito nelle attività sociali, in famiglia, con gli amici?',
     'single_choice'::public.question_type,
     '["Sempre","Quasi sempre","Molto tempo","Una parte del tempo","Quasi mai","Mai"]'::jsonb,
     12, true, '{}'::jsonb);

END $$;

-- Verification query to ensure exactly 12 questions exist
DO $$
DECLARE
    question_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO question_count 
    FROM public.questionnaire_questions qq
    JOIN public.questionnaire_templates qt ON qq.template_id = qt.id
    WHERE qt.questionnaire_type = 'sf12';
    
    IF question_count != 12 THEN
        RAISE EXCEPTION 'SF-12 questionnaire setup failed: Expected 12 questions, found %', question_count;
    END IF;
    
    RAISE NOTICE 'SF-12 questionnaire setup complete: % questions created successfully', question_count;
END $$;