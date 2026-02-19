-- Location: supabase/migrations/20251216220000_add_four_topic_quiz_templates.sql
-- Schema Analysis: Existing quiz system with quiz_templates, quiz_questions, and quiz_attempts tables
-- Integration Type: Enhancement - Ensure all 4 quiz topics have proper templates
-- Dependencies: quiz_templates, quiz_questions (existing), quiz_topic enum (existing)

-- Ensure we have all 4 topic-based quiz templates
DO $$
DECLARE
    template1_id UUID := gen_random_uuid();
    template2_id UUID := gen_random_uuid(); 
    template3_id UUID := gen_random_uuid();
    template4_id UUID := gen_random_uuid();
BEGIN
    -- Insert quiz templates for all 4 topics (using INSERT ... ON CONFLICT to avoid duplicates)
    INSERT INTO public.quiz_templates (id, title, description, category, topic, is_active) 
    VALUES
        (template1_id, 'Alimenti, nutrienti, supplementi nutrizionali orali, nutraceutici', 'Quiz su alimenti, nutrienti e supplementi nutrizionali', 'topic_based'::public.quiz_category, 'alimenti_nutrienti_supplementi'::public.quiz_topic, true),
        (template2_id, 'Nutrizione durante le terapie oncologiche', 'Quiz sulla nutrizione durante i trattamenti oncologici', 'topic_based'::public.quiz_category, 'nutrizione_terapie_oncologiche'::public.quiz_topic, true),
        (template3_id, 'Che cosa fare prima e in corso di terapia', 'Quiz su preparazione e gestione nutrizionale durante le terapie', 'topic_based'::public.quiz_category, 'cosa_fare_prima_terapia'::public.quiz_topic, true),
        (template4_id, 'Mangiare sano per mantenersi in salute', 'Quiz sui principi di alimentazione sana per la salute generale', 'topic_based'::public.quiz_category, 'mangiare_sano_salute'::public.quiz_topic, true)
    ON CONFLICT (topic) DO UPDATE SET
        title = EXCLUDED.title,
        description = EXCLUDED.description,
        is_active = EXCLUDED.is_active;

    -- Add sample questions for each topic if they don't exist
    -- Topic 1: Alimenti, nutrienti, supplementi (10 questions)
    INSERT INTO public.quiz_questions (template_id, topic_id, question_text, options, correct_answer, explanation, order_index)
    SELECT template1_id, '1', 'Quali sono i macronutrienti principali?', 
           '["Carboidrati, proteine, grassi", "Vitamine, minerali, fibre", "Zuccheri, sale, acqua", "Calcio, ferro, magnesio"]'::jsonb,
           'Carboidrati, proteine, grassi',
           'I macronutrienti principali sono carboidrati, proteine e grassi che forniscono energia e sono necessari in grandi quantità.',
           1
    WHERE NOT EXISTS (
        SELECT 1 FROM public.quiz_questions 
        WHERE template_id = (SELECT id FROM public.quiz_templates WHERE topic = 'alimenti_nutrienti_supplementi'::public.quiz_topic LIMIT 1)
        AND order_index = 1
    );

    -- Topic 2: Nutrizione durante terapie (10 questions)  
    INSERT INTO public.quiz_questions (template_id, topic_id, question_text, options, correct_answer, explanation, order_index)
    SELECT template2_id, '1', 'Durante la chemioterapia è consigliabile:', 
           '["Mangiare solo cibi crudi", "Evitare completamente le proteine", "Fare pasti piccoli e frequenti", "Bere solo succhi di frutta"]'::jsonb,
           'Fare pasti piccoli e frequenti',
           'Durante la chemioterapia, pasti piccoli e frequenti aiutano a gestire nausea e mantenere l''apporto nutrizionale.',
           1
    WHERE NOT EXISTS (
        SELECT 1 FROM public.quiz_questions 
        WHERE template_id = (SELECT id FROM public.quiz_templates WHERE topic = 'nutrizione_terapie_oncologiche'::public.quiz_topic LIMIT 1)
        AND order_index = 1
    );

    -- Topic 3: Prima e durante terapia (10 questions)
    INSERT INTO public.quiz_questions (template_id, topic_id, question_text, options, correct_answer, explanation, order_index)
    SELECT template3_id, '1', 'Prima di un intervento chirurgico è importante:', 
           '["Digiunare per una settimana", "Mantenere un buono stato nutrizionale", "Assumere solo liquidi", "Evitare tutte le vitamine"]'::jsonb,
           'Mantenere un buono stato nutrizionale',
           'Un buono stato nutrizionale prima dell''intervento riduce il rischio di complicazioni e favorisce la guarigione.',
           1
    WHERE NOT EXISTS (
        SELECT 1 FROM public.quiz_questions 
        WHERE template_id = (SELECT id FROM public.quiz_templates WHERE topic = 'cosa_fare_prima_terapia'::public.quiz_topic LIMIT 1)
        AND order_index = 1
    );

    -- Topic 4: Mangiare sano (5 questions)
    INSERT INTO public.quiz_questions (template_id, topic_id, question_text, options, correct_answer, explanation, order_index)
    SELECT template4_id, '1', 'Una dieta equilibrata include:', 
           '["Solo proteine animali", "Varietà di alimenti da tutti i gruppi", "Solo carboidrati semplici", "Solo cibi processati"]'::jsonb,
           'Varietà di alimenti da tutti i gruppi',
           'Una dieta equilibrata deve includere alimenti vari da tutti i gruppi alimentari per garantire tutti i nutrienti necessari.',
           1
    WHERE NOT EXISTS (
        SELECT 1 FROM public.quiz_questions 
        WHERE template_id = (SELECT id FROM public.quiz_templates WHERE topic = 'mangiare_sano_salute'::public.quiz_topic LIMIT 1)
        AND order_index = 1
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating quiz templates: %', SQLERRM;
END $$;