-- Schema Analysis: Diario Alimentare questionnaire exists with duplicate meal questions
-- Integration Type: Modificative - Consolidating duplicate questions with identical text
-- Dependencies: questionnaire_templates, questionnaire_questions

-- Final consolidation of Diario Alimentare duplicate questions
-- Problem: Multiple questions with identical text "Aggiungere pasto: selezionare il pasto"
-- Solution: Create single unified question with all meal options

-- Step 1: Get the Diario Alimentare template ID
DO $$
DECLARE
    diario_template_id UUID;
    unified_question_id UUID := gen_random_uuid();
    existing_response_count INTEGER;
BEGIN
    -- Get template ID for Diario Alimentare
    SELECT id INTO diario_template_id 
    FROM public.questionnaire_templates 
    WHERE questionnaire_type = 'dietary_diary'::questionnaire_type 
    AND title = 'Diario Alimentare';
    
    IF diario_template_id IS NULL THEN
        RAISE NOTICE 'Diario Alimentare template not found';
        RETURN;
    END IF;
    
    -- Check if responses exist for these questions
    SELECT COUNT(*) INTO existing_response_count
    FROM public.questionnaire_responses qr
    JOIN public.questionnaire_questions qq ON qr.question_id = qq.question_id
    WHERE qq.template_id = diario_template_id
    AND qq.question_text = 'Aggiungere pasto: selezionare il pasto';
    
    -- Step 2: Delete ALL existing duplicate meal questions
    DELETE FROM public.questionnaire_questions
    WHERE template_id = diario_template_id
    AND question_text = 'Aggiungere pasto: selezionare il pasto'
    AND question_id IN ('diary_meal_colazione', 'diary_meal_pranzo', 'diary_meal_cena', 'diary_meal_spuntino');
    
    -- Step 3: Create single unified meal selection question
    INSERT INTO public.questionnaire_questions (
        id,
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        order_index,
        is_required,
        created_at
    ) VALUES (
        unified_question_id,
        diario_template_id,
        'diary_meal_unified',
        'Seleziona il pasto che desideri registrare',
        'single_choice'::question_type,
        '["Colazione", "Pranzo", "Cena", "Spuntino Mattutino", "Spuntino Pomeridiano"]'::jsonb,
        1,
        true,
        CURRENT_TIMESTAMP
    );
    
    -- Step 4: Add comprehensive food diary questions
    INSERT INTO public.questionnaire_questions (
        template_id,
        question_id,
        question_text,
        question_type,
        options,
        order_index,
        is_required,
        depends_on,
        depends_value,
        created_at
    ) VALUES 
    -- Food items selection
    (
        diario_template_id,
        'diary_food_items',
        'Cosa hai mangiato? (seleziona tutti gli alimenti consumati)',
        'food_database'::question_type,
        '[]'::jsonb,
        2,
        true,
        'diary_meal_unified',
        null,
        CURRENT_TIMESTAMP
    ),
    -- Portion size
    (
        diario_template_id,
        'diary_portion_size',
        'Come valuti la dimensione della tua porzione?',
        'single_choice'::question_type,
        '["Piccola", "Normale", "Grande", "Molto grande"]'::jsonb,
        3,
        true,
        'diary_meal_unified',
        null,
        CURRENT_TIMESTAMP
    ),
    -- Meal timing
    (
        diario_template_id,
        'diary_meal_time',
        'A che ora hai consumato questo pasto?',
        'text_input'::question_type,
        '{"placeholder": "Es: 08:30", "format": "time"}'::jsonb,
        4,
        false,
        'diary_meal_unified',
        null,
        CURRENT_TIMESTAMP
    ),
    -- Location
    (
        diario_template_id,
        'diary_meal_location',
        'Dove hai consumato il pasto?',
        'single_choice'::question_type,
        '["Casa", "Lavoro", "Ristorante", "Bar/Caffetteria", "Altro"]'::jsonb,
        5,
        false,
        'diary_meal_unified',
        null,
        CURRENT_TIMESTAMP
    ),
    -- Satisfaction level
    (
        diario_template_id,
        'diary_satisfaction',
        'Come ti sei sentito dopo il pasto?',
        'scale_0_10'::question_type,
        '{"min": 0, "max": 10, "labels": {"0": "Molto insoddisfatto", "10": "Molto soddisfatto"}}'::jsonb,
        6,
        false,
        'diary_meal_unified',
        null,
        CURRENT_TIMESTAMP
    ),
    -- Additional notes
    (
        diario_template_id,
        'diary_notes',
        'Note aggiuntive (opzionale)',
        'text_input'::question_type,
        '{"placeholder": "Aggiungi eventuali osservazioni sul pasto..."}'::jsonb,
        7,
        false,
        'diary_meal_unified',
        null,
        CURRENT_TIMESTAMP
    );
    
    RAISE NOTICE 'Successfully consolidated Diario Alimentare questions. Existing responses: %', existing_response_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error consolidating questions: %', SQLERRM;
        ROLLBACK;
END $$;

-- Step 5: Create validation function to verify no duplicates remain
CREATE OR REPLACE FUNCTION public.validate_diario_alimentare_no_duplicates()
RETURNS TABLE(
    duplicate_count INTEGER,
    question_texts TEXT[]
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    COUNT(*)::INTEGER as duplicate_count,
    ARRAY_AGG(DISTINCT question_text) as question_texts
FROM public.questionnaire_questions qq
JOIN public.questionnaire_templates qt ON qq.template_id = qt.id
WHERE qt.questionnaire_type = 'dietary_diary'::questionnaire_type
AND qt.title = 'Diario Alimentare'
GROUP BY qq.question_text
HAVING COUNT(*) > 1;
$$;

-- Step 6: Run validation to confirm no duplicates remain
DO $$
DECLARE
    validation_result RECORD;
BEGIN
    SELECT * INTO validation_result 
    FROM public.validate_diario_alimentare_no_duplicates()
    LIMIT 1;
    
    IF validation_result.duplicate_count IS NULL THEN
        RAISE NOTICE 'SUCCESS: No duplicate questions found in Diario Alimentare';
    ELSE
        RAISE NOTICE 'WARNING: Found % duplicate questions: %', 
            validation_result.duplicate_count, 
            validation_result.question_texts;
    END IF;
END $$;