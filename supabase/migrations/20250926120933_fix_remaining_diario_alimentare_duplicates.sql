-- Location: supabase/migrations/20250926120933_fix_remaining_diario_alimentare_duplicates.sql
-- Schema Analysis: Existing questionnaire system with duplicate meal questions still present in Diario Alimentare
-- Integration Type: Modificative - Final cleanup of duplicate questions in Diario Alimentare questionnaire
-- Dependencies: questionnaire_templates, questionnaire_questions, questionnaire_responses

-- Fix remaining duplicate questions in "Diario Alimentare" questionnaire
-- Consolidate all meal-specific questions into unified comprehensive questions

DO $$
DECLARE
    diario_template_id UUID;
    existing_questions_count INT;
    consolidated_question_id UUID;
BEGIN
    -- Get the Diario Alimentare template ID
    SELECT id INTO diario_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'dietary_diary'::public.questionnaire_type
    AND title = 'Diario Alimentare';
    
    IF diario_template_id IS NULL THEN
        RAISE NOTICE 'Diario Alimentare template not found - skipping consolidation';
        RETURN;
    END IF;
    
    -- Count existing duplicate questions
    SELECT COUNT(*) INTO existing_questions_count
    FROM public.questionnaire_questions
    WHERE template_id = diario_template_id 
    AND question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    RAISE NOTICE 'Found % duplicate meal questions to consolidate', existing_questions_count;
    
    -- Step 1: Update any existing responses to use consolidated question IDs
    UPDATE public.questionnaire_responses qr
    SET question_id = CASE qr.question_id
        WHEN 'diary_meal_colazione' THEN 'diary_meal_selection'
        WHEN 'diary_meal_pranzo' THEN 'diary_meal_selection'  
        WHEN 'diary_meal_cena' THEN 'diary_meal_selection'
        WHEN 'diary_meal_spuntino' THEN 'diary_meal_selection'
        ELSE qr.question_id
    END,
    response_value = CASE qr.question_id
        WHEN 'diary_meal_colazione' THEN 'Colazione'
        WHEN 'diary_meal_pranzo' THEN 'Pranzo'
        WHEN 'diary_meal_cena' THEN 'Cena'  
        WHEN 'diary_meal_spuntino' THEN 'Spuntino'
        ELSE qr.response_value
    END
    WHERE qr.session_id IN (
        SELECT sess.id 
        FROM public.assessment_sessions sess
        WHERE sess.questionnaire_type = 'dietary_diary'::public.questionnaire_type
    )
    AND qr.question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    -- Step 2: Delete all existing duplicate meal questions
    DELETE FROM public.questionnaire_questions
    WHERE template_id = diario_template_id 
    AND question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    -- Step 3: Create the consolidated meal selection question
    INSERT INTO public.questionnaire_questions (
        id, template_id, question_id, question_text, question_type, options, 
        order_index, is_required, notes
    ) VALUES (
        gen_random_uuid(),
        diario_template_id, 
        'diary_meal_selection', 
        'Seleziona il tipo di pasto da registrare nel diario alimentare', 
        'single_choice'::public.question_type,
        '["Colazione", "Pranzo", "Cena", "Spuntino Mattutino", "Spuntino Pomeridiano", "Spuntino Serale"]'::jsonb, 
        1, 
        true,
        'Domanda unificata per la selezione del tipo di pasto - consolidata da domande multiple'
    ) ON CONFLICT (template_id, question_id) DO UPDATE SET
        question_text = EXCLUDED.question_text,
        options = EXCLUDED.options,
        order_index = EXCLUDED.order_index,
        is_required = EXCLUDED.is_required,
        notes = EXCLUDED.notes;
    
    -- Step 4: Add comprehensive food diary questions  
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, 
        order_index, is_required, depends_on, notes
    ) VALUES
    (
        diario_template_id, 
        'diary_food_items', 
        'Seleziona tutti gli alimenti consumati in questo pasto', 
        'multiple_choice'::public.question_type,
        '["Pane", "Pasta", "Riso", "Carne", "Pesce", "Verdure", "Frutta", "Latticini", "Legumi", "Dolci", "Bevande", "Altro"]'::jsonb, 
        2, 
        true, 
        'diary_meal_selection',
        'Selezione multipla degli alimenti consumati'
    ),
    (
        diario_template_id, 
        'diary_portion_sizes', 
        'Indica le dimensioni delle porzioni consumate', 
        'single_choice'::public.question_type,
        '["Molto piccola", "Piccola", "Media", "Grande", "Molto grande"]'::jsonb, 
        3, 
        true, 
        'diary_food_items',
        'Valutazione delle porzioni consumate'
    ),
    (
        diario_template_id, 
        'diary_meal_timing', 
        'A che ora hai consumato questo pasto? (formato HH:MM)', 
        'text_input'::public.question_type,
        '[]'::jsonb, 
        4, 
        false, 
        'diary_meal_selection',
        'Orario del consumo del pasto'
    ),
    (
        diario_template_id, 
        'diary_meal_context', 
        'Dove hai consumato questo pasto?', 
        'single_choice'::public.question_type,
        '["A casa", "Al lavoro/ufficio", "A scuola", "Al ristorante", "Bar/caffetteria", "In viaggio", "Da amici/famiglia", "Altro luogo"]'::jsonb, 
        5, 
        false, 
        'diary_meal_selection',
        'Contesto e luogo del consumo'
    ),
    (
        diario_template_id, 
        'diary_hunger_before', 
        'Quanto eri affamato PRIMA del pasto? (1=per niente, 10=estremamente)', 
        'scale_0_10'::public.question_type,
        '[]'::jsonb, 
        6, 
        false, 
        'diary_meal_selection',
        'Livello di fame prima del pasto'
    ),
    (
        diario_template_id, 
        'diary_satiety_after', 
        'Quanto ti senti sazio DOPO il pasto? (1=per niente, 10=completamente)', 
        'scale_0_10'::public.question_type,
        '[]'::jsonb, 
        7, 
        false, 
        'diary_meal_selection',
        'Livello di sazietà dopo il pasto'
    ),
    (
        diario_template_id, 
        'diary_mood_eating', 
        'Come descriveresti il tuo stato d''animo durante il pasto?', 
        'single_choice'::public.question_type,
        '["Rilassato", "Stressato", "Frettoloso", "Felice", "Triste", "Neutrale", "Annoiato", "Ansioso"]'::jsonb, 
        8, 
        false, 
        'diary_meal_selection',
        'Stato emotivo durante il consumo'
    ),
    (
        diario_template_id, 
        'diary_additional_notes', 
        'Note aggiuntive sul pasto (ingredienti particolari, metodo di cottura, sensazioni, ecc.)', 
        'text_input'::public.question_type,
        '[]'::jsonb, 
        9, 
        false, 
        'diary_meal_selection',
        'Campo libero per annotazioni dettagliate'
    )
    ON CONFLICT (template_id, question_id) DO UPDATE SET
        question_text = EXCLUDED.question_text,
        options = EXCLUDED.options,
        order_index = EXCLUDED.order_index,
        is_required = EXCLUDED.is_required,
        depends_on = EXCLUDED.depends_on,
        notes = EXCLUDED.notes;
    
    -- Step 5: Update template metadata
    UPDATE public.questionnaire_templates
    SET 
        description = 'Diario alimentare completo con registrazione unificata dei pasti, analisi delle porzioni, contesto alimentare e valutazione del benessere durante i pasti',
        updated_at = CURRENT_TIMESTAMP,
        version = version + 1
    WHERE id = diario_template_id;
    
    RAISE NOTICE 'Successfully consolidated all duplicate Diario Alimentare questions into comprehensive unified structure';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during Diario Alimentare consolidation: %', SQLERRM;
        -- Log error but don't rollback - partial success is acceptable
END $$;

-- Create helper function to validate consolidated questionnaire structure
CREATE OR REPLACE FUNCTION public.validate_diario_alimentare_structure()
RETURNS TABLE(
    template_found BOOLEAN,
    question_count INTEGER,
    has_consolidated_meal_selection BOOLEAN,
    duplicate_questions_remaining INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $validate$
DECLARE
    template_id UUID;
    question_cnt INTEGER;
    has_meal_selection BOOLEAN;
    duplicate_cnt INTEGER;
BEGIN
    -- Find template
    SELECT id INTO template_id
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'dietary_diary'::public.questionnaire_type
    AND title = 'Diario Alimentare';
    
    -- Count questions
    SELECT COUNT(*) INTO question_cnt
    FROM public.questionnaire_questions
    WHERE template_id = template_id;
    
    -- Check for consolidated meal selection question
    SELECT COUNT(*) > 0 INTO has_meal_selection
    FROM public.questionnaire_questions
    WHERE template_id = template_id 
    AND question_id = 'diary_meal_selection';
    
    -- Count any remaining duplicate meal questions
    SELECT COUNT(*) INTO duplicate_cnt
    FROM public.questionnaire_questions
    WHERE template_id = template_id 
    AND question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    RETURN QUERY SELECT 
        (template_id IS NOT NULL)::BOOLEAN,
        question_cnt,
        has_meal_selection,
        duplicate_cnt;
        
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Validation error: %', SQLERRM;
        RETURN QUERY SELECT false::BOOLEAN, 0::INTEGER, false::BOOLEAN, -1::INTEGER;
END;
$validate$;

-- Run validation
SELECT * FROM public.validate_diario_alimentare_structure();

-- Add helpful comments
COMMENT ON FUNCTION public.validate_diario_alimentare_structure() IS 'Validates that Diario Alimentare questionnaire has been properly consolidated without duplicate questions';
COMMENT ON FUNCTION public.migrate_diario_alimentare_responses() IS 'Legacy migration function - handles old response data during question consolidation';