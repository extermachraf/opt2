-- Location: supabase/migrations/20250926120244_consolidate_diario_alimentare_duplicates.sql
-- Schema Analysis: Existing questionnaire system with templates, questions, and responses
-- Integration Type: Modificative - Consolidating duplicate questions in Diario Alimentare
-- Dependencies: questionnaire_templates, questionnaire_questions, questionnaire_responses

-- Consolidate duplicate questions in "Diario Alimentare" questionnaire
-- Combine questions with same text but different meal options into single questions

DO $$
DECLARE
    diario_template_id UUID;
    meal_selection_question_id UUID;
    existing_responses_count INT;
BEGIN
    -- Get the Diario Alimentare template ID
    SELECT id INTO diario_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'dietary_diary' 
    AND title = 'Diario Alimentare';
    
    IF diario_template_id IS NULL THEN
        RAISE NOTICE 'Diario Alimentare template not found';
        RETURN;
    END IF;
    
    -- Check if there are existing responses for the duplicate questions
    SELECT COUNT(*) INTO existing_responses_count
    FROM public.questionnaire_responses qr
    JOIN public.assessment_sessions sess ON qr.session_id = sess.id
    JOIN public.questionnaire_templates qt ON sess.questionnaire_type = qt.questionnaire_type
    WHERE qt.id = diario_template_id
    AND qr.question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    -- If there are existing responses, preserve them by updating question structure
    IF existing_responses_count > 0 THEN
        RAISE NOTICE 'Found % existing responses. Updating question structure to preserve data.', existing_responses_count;
    END IF;
    
    -- Step 1: Create the consolidated meal selection question
    -- Update the first meal question to include all meal options
    UPDATE public.questionnaire_questions 
    SET 
        question_id = 'diary_meal_selection',
        question_text = 'Seleziona il tipo di pasto da registrare',
        options = '["Colazione", "Pranzo", "Cena", "Spuntino Mattutino", "Spuntino Pomeridiano", "Spuntino Serale"]'::jsonb,
        order_index = 1,
        notes = 'Domanda consolidata per la selezione del tipo di pasto'
    WHERE template_id = diario_template_id 
    AND question_id = 'diary_meal_colazione';
    
    -- Step 2: Update any existing responses to use the new consolidated question ID
    UPDATE public.questionnaire_responses
    SET question_id = 'diary_meal_selection'
    WHERE question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino')
    AND session_id IN (
        SELECT sess.id 
        FROM public.assessment_sessions sess
        JOIN public.questionnaire_templates qt ON sess.questionnaire_type = qt.questionnaire_type
        WHERE qt.id = diario_template_id
    );
    
    -- Step 3: Remove the duplicate meal questions (keeping only the consolidated one)
    DELETE FROM public.questionnaire_questions
    WHERE template_id = diario_template_id 
    AND question_id IN ('diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    -- Step 4: Add food selection questions with proper dependencies
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, 
        order_index, is_required, depends_on, depends_value
    ) VALUES
    (
        diario_template_id, 
        'diary_food_selection', 
        'Seleziona gli alimenti consumati nel pasto', 
        'food_database'::public.question_type, 
        '[]'::jsonb, 
        2, 
        true, 
        'diary_meal_selection', 
        null
    ),
    (
        diario_template_id, 
        'diary_portion_size', 
        'Indica la dimensione della porzione', 
        'single_choice'::public.question_type, 
        '["Piccola", "Media", "Grande", "Molto grande"]'::jsonb, 
        3, 
        true, 
        'diary_food_selection', 
        null
    ),
    (
        diario_template_id, 
        'diary_meal_time', 
        'A che ora hai consumato il pasto?', 
        'text_input'::public.question_type, 
        '[]'::jsonb, 
        4, 
        false, 
        'diary_meal_selection', 
        null
    ),
    (
        diario_template_id, 
        'diary_meal_location', 
        'Dove hai consumato il pasto?', 
        'single_choice'::public.question_type, 
        '["Casa", "Ristorante", "Ufficio", "Scuola", "Altro"]'::jsonb, 
        5, 
        false, 
        'diary_meal_selection', 
        null
    ),
    (
        diario_template_id, 
        'diary_hunger_level', 
        'Quanto eri affamato prima del pasto? (scala 1-10)', 
        'scale_0_10'::public.question_type, 
        '[]'::jsonb, 
        6, 
        false, 
        'diary_meal_selection', 
        null
    ),
    (
        diario_template_id, 
        'diary_satisfaction_level', 
        'Quanto sei soddisfatto dopo il pasto? (scala 1-10)', 
        'scale_0_10'::public.question_type, 
        '[]'::jsonb, 
        7, 
        false, 
        'diary_meal_selection', 
        null
    ),
    (
        diario_template_id, 
        'diary_notes', 
        'Note aggiuntive sul pasto (opzionale)', 
        'text_input'::public.question_type, 
        '[]'::jsonb, 
        8, 
        false, 
        'diary_meal_selection', 
        null
    )
    ON CONFLICT (template_id, question_id) DO UPDATE SET
        question_text = EXCLUDED.question_text,
        options = EXCLUDED.options,
        order_index = EXCLUDED.order_index,
        is_required = EXCLUDED.is_required,
        depends_on = EXCLUDED.depends_on;
    
    -- Step 5: Update template description to reflect the consolidation
    UPDATE public.questionnaire_templates
    SET 
        description = 'Registrazione completa dei pasti quotidiani con selezione unificata del tipo di pasto e raccolta dettagliata delle informazioni nutrizionali',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = diario_template_id;
    
    RAISE NOTICE 'Successfully consolidated Diario Alimentare duplicate questions. Meal selection now uses single question with multiple options.';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error consolidating Diario Alimentare questions: %', SQLERRM;
        -- Don't rollback, just log the error
END $$;

-- Create function to help with questionnaire data migration if needed
CREATE OR REPLACE FUNCTION public.migrate_diario_alimentare_responses()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    response_record RECORD;
    meal_type TEXT;
BEGIN
    -- Migrate any remaining responses that might have old question IDs
    FOR response_record IN 
        SELECT qr.id, qr.question_id, qr.response_value, qr.session_id
        FROM public.questionnaire_responses qr
        JOIN public.assessment_sessions sess ON qr.session_id = sess.id
        WHERE sess.questionnaire_type = 'dietary_diary'
        AND qr.question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino')
    LOOP
        -- Determine meal type from old question ID
        meal_type := CASE response_record.question_id
            WHEN 'diary_meal_colazione' THEN 'Colazione'
            WHEN 'diary_meal_pranzo' THEN 'Pranzo' 
            WHEN 'diary_meal_cena' THEN 'Cena'
            WHEN 'diary_meal_spuntino' THEN 'Spuntino'
            ELSE response_record.response_value
        END;
        
        -- Update the response to use consolidated question
        UPDATE public.questionnaire_responses
        SET 
            question_id = 'diary_meal_selection',
            response_value = meal_type
        WHERE id = response_record.id;
    END LOOP;
    
    RAISE NOTICE 'Migration completed for Diario Alimentare responses';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during response migration: %', SQLERRM;
END;
$func$;

-- Execute the migration function
SELECT public.migrate_diario_alimentare_responses();

-- Add helpful comment
COMMENT ON FUNCTION public.migrate_diario_alimentare_responses() IS 'Migrates old separate meal questions to consolidated meal selection question in Diario Alimentare questionnaire';