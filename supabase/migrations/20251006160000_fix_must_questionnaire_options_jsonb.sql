-- Fix MUST questionnaire options column type mismatch
-- The options column is jsonb, not text[], so we need to use JSON array syntax

-- Add the missing third MUST question with correct JSON format for options
DO $$
DECLARE
    must_template_id UUID;
    question_exists BOOLEAN;
BEGIN
    -- Find the MUST template ID
    SELECT id INTO must_template_id 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must' 
    AND is_active = true 
    LIMIT 1;
    
    IF must_template_id IS NULL THEN
        RAISE NOTICE 'MUST template not found, cannot add third question';
        RETURN;
    END IF;
    
    -- Check if the acute disease effect question already exists
    SELECT EXISTS(
        SELECT 1 FROM questionnaire_questions 
        WHERE template_id = must_template_id 
        AND question_id = 'must_acute_disease_effect'
    ) INTO question_exists;
    
    IF NOT question_exists THEN
        -- Insert the third MUST question (Acute disease effect) with proper JSON format
        INSERT INTO questionnaire_questions (
            id,
            template_id,
            question_id,
            question_text,
            question_type,
            order_index,
            is_required,
            options,
            scores,
            notes,
            created_at
        ) VALUES (
            gen_random_uuid(),
            must_template_id,
            'must_acute_disease_effect',
            'Hai avuto una malattia acuta o non hai potuto mangiare (o hai mangiato molto poco) per più di 5 giorni?',
            'single_choice',
            2, -- Third question
            true,
            '["Sì", "No"]'::jsonb,  -- Fixed: Use JSON array format instead of PostgreSQL array
            '{
                "Sì": 2,
                "No": 0
            }'::jsonb,
            'Valutazione dell''effetto di malattie acute o periodi di digiuno prolungato sul rischio nutrizionale. Punteggio: Sì = 2 punti, No = 0 punti.',
            CURRENT_TIMESTAMP
        );
        
        RAISE NOTICE 'Added third MUST question: Acute disease effect/no nutritional intake';
    ELSE
        RAISE NOTICE 'Third MUST question already exists, skipping';
    END IF;
    
    -- Verify we now have exactly 3 questions
    DECLARE
        question_count INT;
    BEGIN
        SELECT COUNT(*) INTO question_count
        FROM questionnaire_questions 
        WHERE template_id = must_template_id;
        
        RAISE NOTICE 'MUST questionnaire now has % questions total', question_count;
        
        IF question_count = 3 THEN
            RAISE NOTICE 'SUCCESS: MUST questionnaire progress will now show "3/3"';
        ELSE
            RAISE NOTICE 'WARNING: Expected 3 questions, but found %', question_count;
        END IF;
    END;
END $$;

-- Update any existing assessment sessions to recalculate progress
DO $$
DECLARE 
    session_record RECORD;
    must_template_id UUID;
BEGIN
    -- Get MUST template ID
    SELECT id INTO must_template_id 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must' 
    AND is_active = true 
    LIMIT 1;
    
    IF must_template_id IS NOT NULL THEN
        -- Update status of incomplete MUST sessions to allow them to continue with the new question
        UPDATE assessment_sessions 
        SET updated_at = CURRENT_TIMESTAMP
        WHERE questionnaire_type = 'must' 
        AND status = 'in_progress';
        
        RAISE NOTICE 'Updated incomplete MUST sessions to recognize new question structure';
    END IF;
END $$;

-- Refresh the questionnaire progress calculation functions
DO $$
BEGIN
    -- Force refresh of any cached progress calculations
    PERFORM pg_notify('questionnaire_structure_changed', 'must_questionnaire_updated');
    RAISE NOTICE 'Notified system of MUST questionnaire structure change';
END $$;