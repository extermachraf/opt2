-- Location: supabase/migrations/20251006190000_add_sf12_questionnaire_questions.sql
-- Schema Analysis: Existing questionnaire infrastructure with questionnaire_templates, questionnaire_questions, assessment_sessions, questionnaire_responses
-- Integration Type: Addition - Adding new SF-12 questionnaire to existing system
-- Dependencies: questionnaire_templates, questionnaire_questions (existing tables)

-- SF-12 Questionnaire Implementation
-- The SF-12 is a 12-question health self-assessment
-- No scoring calculations - only records responses for professional review

DO $$
DECLARE
    sf12_template_id UUID := gen_random_uuid();
BEGIN
    -- Insert SF-12 questionnaire template
    INSERT INTO public.questionnaire_templates (
        id,
        title,
        description,
        questionnaire_type,
        category,
        is_active,
        version
    ) VALUES (
        sf12_template_id,
        'SF-12 - Questionario sulla Salute',
        'Questionario di autovalutazione della salute in 12 domande. Sistema di registrazione delle risposte senza calcolo del punteggio.',
        'sf12'::public.questionnaire_type,
        'Categoria 6 - Valutazione Salute SF-12',
        true,
        1
    );

    -- Insert all 12 SF-12 questions
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        scores,
        order_index,
        is_required
    ) VALUES
        -- Question 1: General health status
        (sf12_template_id, 'sf12_general_health', 'In generale, diresti che la tua salute è:', 'single_choice'::public.question_type, 
         '["Eccellente", "Molto buona", "Buona", "Passabile", "Scadente"]'::jsonb,
         '{}'::jsonb, 1, true),

        -- Question 2: Physical limitations - moderate activities
        (sf12_template_id, 'sf12_moderate_activities', 'La tua salute ti limita attualmente nello svolgimento di attività di moderato impegno fisico (es. usare l''aspirapolvere, fare un giro in bicicletta, ecc.)?', 'single_choice'::public.question_type,
         '["Sì parecchio", "Sì parzialmente", "No per nulla"]'::jsonb,
         '{}'::jsonb, 2, true),

        -- Question 3: Physical limitations - climbing stairs
        (sf12_template_id, 'sf12_climbing_stairs', 'La tua salute ti limita attualmente nel salire qualche piano di scale?', 'single_choice'::public.question_type,
         '["Sì parecchio", "Sì parzialmente", "No per nulla"]'::jsonb,
         '{}'::jsonb, 3, true),

        -- Question 4: Role limitations due to physical health - work performance
        (sf12_template_id, 'sf12_work_performance_physical', 'Nelle ultime 4 settimane, hai reso meno di quanto avresti voluto sul lavoro o nelle altre attività quotidiane, a causa della tua salute?', 'yes_no'::public.question_type,
         '["Sì", "No"]'::jsonb,
         '{}'::jsonb, 4, true),

        -- Question 5: Role limitations due to physical health - work limitations
        (sf12_template_id, 'sf12_work_limitations_physical', 'Nelle ultime 4 settimane, hai dovuto limitare alcuni tipi di lavoro o di altre attività, a causa della tua salute?', 'yes_no'::public.question_type,
         '["Sì", "No"]'::jsonb,
         '{}'::jsonb, 5, true),

        -- Question 6: Role limitations due to emotional problems - work performance
        (sf12_template_id, 'sf12_work_performance_emotional', 'Nelle ultime 4 settimane, hai reso meno di quanto avresti voluto sul lavoro o nelle altre attività quotidiane, a causa del tuo stato emotivo (es. sentirsi depresso, ansioso)?', 'yes_no'::public.question_type,
         '["Sì", "No"]'::jsonb,
         '{}'::jsonb, 6, true),

        -- Question 7: Role limitations due to emotional problems - concentration
        (sf12_template_id, 'sf12_concentration_emotional', 'Nelle ultime 4 settimane, hai avuto un calo di concentrazione sul lavoro o nelle altre attività quotidiane, a causa del tuo stato emotivo?', 'yes_no'::public.question_type,
         '["Sì", "No"]'::jsonb,
         '{}'::jsonb, 7, true),

        -- Question 8: Bodily pain
        (sf12_template_id, 'sf12_pain_interference', 'Nelle ultime 4 settimane, in che misura il dolore ti ha ostacolato nel lavoro che svolgi abitualmente (sia in casa sia fuori casa)?', 'single_choice'::public.question_type,
         '["Per nulla", "Molto poco", "Un po''", "Molto", "Moltissimo"]'::jsonb,
         '{}'::jsonb, 8, true),

        -- Question 9: Mental health - calm and peaceful
        (sf12_template_id, 'sf12_calm_peaceful', 'Per quanto tempo nelle ultime 4 settimane ti sei sentito calmo e sereno?', 'single_choice'::public.question_type,
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb,
         '{}'::jsonb, 9, true),

        -- Question 10: Vitality - energy
        (sf12_template_id, 'sf12_energy', 'Per quanto tempo nelle ultime 4 settimane ti sei sentito pieno di energia?', 'single_choice'::public.question_type,
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb,
         '{}'::jsonb, 10, true),

        -- Question 11: Mental health - downhearted and blue
        (sf12_template_id, 'sf12_downhearted', 'Per quanto tempo nelle ultime 4 settimane ti sei sentito scoraggiato e triste?', 'single_choice'::public.question_type,
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb,
         '{}'::jsonb, 11, true),

        -- Question 12: Social functioning
        (sf12_template_id, 'sf12_social_functioning', 'Nelle ultime 4 settimane per quanto tempo la tua salute fisica o il tuo stato emotivo hanno interferito nelle attività sociali, in famiglia, con gli amici?', 'single_choice'::public.question_type,
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb,
         '{}'::jsonb, 12, true);

    RAISE NOTICE 'SF-12 questionnaire template and questions created successfully with template_id: %', sf12_template_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'SF-12 questionnaire already exists: %', SQLERRM;
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error in SF-12 creation: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating SF-12 questionnaire: %', SQLERRM;
END $$;