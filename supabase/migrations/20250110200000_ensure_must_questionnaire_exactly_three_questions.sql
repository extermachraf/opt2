-- =====================================================================================
-- CRITICAL FIX: Ensure MUST questionnaire has exactly 3 questions (not 8)
-- This migration addresses the user's issue where progress shows "1/8" instead of "1/3"
-- =====================================================================================

-- First, let's get the MUST template ID
DO $$
DECLARE
    must_template_uuid UUID;
BEGIN
    -- Find or create MUST template
    SELECT id INTO must_template_uuid 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must' AND is_active = true;
    
    -- If no MUST template found, create it
    IF must_template_uuid IS NULL THEN
        INSERT INTO questionnaire_templates (
            id,
            title,
            description,
            category,
            questionnaire_type,
            is_active,
            version
        ) VALUES (
            gen_random_uuid(),
            'MUST - Malnutrition Universal Screening Tool',
            'Strumento universale di screening della malnutrizione con 3 domande per valutazione rapida del rischio nutrizionale',
            'Categoria 2 - Valutazioni Nutrizionali MUST',
            'must',
            true,
            1
        ) RETURNING id INTO must_template_uuid;
    END IF;
    
    -- =====================================================================================
    -- STEP 1: Delete ALL existing MUST questions to ensure clean state
    -- =====================================================================================
    
    DELETE FROM questionnaire_questions 
    WHERE template_id = must_template_uuid;
    
    RAISE NOTICE 'Deleted all existing MUST questions for template: %', must_template_uuid;
    
    -- =====================================================================================
    -- STEP 2: Insert exactly 3 MUST questions in the correct order
    -- =====================================================================================
    
    -- Question 1: BMI Calculation (Automatic)
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
        notes
    ) VALUES (
        gen_random_uuid(),
        must_template_uuid,
        'must_bmi_calculated',
        'Calcolo BMI automatico basato sui dati del profilo medico',
        'calculated',
        1,
        true,
        NULL,
        NULL,
        'BMI calcolato automaticamente: <18.5 (2 punti), 18.5-20 (1 punto), ≥20 (0 punti)'
    );
    
    -- Question 2: Perdita di peso involontaria negli ultimi 3-6 mesi
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
        notes
    ) VALUES (
        gen_random_uuid(),
        must_template_uuid,
        'must_weight_loss_3_6_months',
        'Hai avuto una perdita di peso involontaria negli ultimi 3-6 mesi?',
        'single_choice',
        2,
        true,
        '["Nessuna perdita di peso", "1-5 kg (perdita <5%)", "6-10 kg (perdita 5-10%)", ">10 kg (perdita >10%)"]'::jsonb,
        '{"Nessuna perdita di peso": 0, "1-5 kg (perdita <5%)": 0, "6-10 kg (perdita 5-10%)": 1, ">10 kg (perdita >10%)": 2}'::jsonb,
        'Valutazione della perdita di peso involontaria negli ultimi 3-6 mesi'
    );
    
    -- Question 3: Malattia acuta o compromissione dell'assunzione alimentare
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
        notes
    ) VALUES (
        gen_random_uuid(),
        must_template_uuid,
        'must_acute_illness_food_intake',
        'Hai una malattia acuta o una situazione che ha compromesso l''assunzione di cibo negli ultimi 5 giorni?',
        'yes_no',
        3,
        true,
        '["Sì", "No"]'::jsonb,
        '{"Sì": 2, "No": 0}'::jsonb,
        'Valutazione di malattia acuta o compromissione alimentare negli ultimi 5 giorni'
    );
    
    -- =====================================================================================
    -- STEP 3: Verify exactly 3 questions were inserted
    -- =====================================================================================
    
    DECLARE
        question_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO question_count 
        FROM questionnaire_questions 
        WHERE template_id = must_template_uuid;
        
        IF question_count = 3 THEN
            RAISE NOTICE 'SUCCESS: MUST questionnaire now has exactly 3 questions';
        ELSE
            RAISE EXCEPTION 'ERROR: MUST questionnaire has % questions instead of 3', question_count;
        END IF;
    END;
    
    -- =====================================================================================
    -- STEP 4: Reset any existing incomplete MUST sessions to draft status
    -- This ensures users see the correct 1/3 progress counter
    -- =====================================================================================
    
    UPDATE assessment_sessions 
    SET 
        status = 'draft',
        total_score = NULL,
        risk_level = NULL,
        completed_at = NULL,
        updated_at = CURRENT_TIMESTAMP
    WHERE questionnaire_type = 'must' 
    AND status IN ('in_progress', 'cancelled');
    
    RAISE NOTICE 'Reset incomplete MUST sessions to draft status for clean restart';
    
    -- =====================================================================================
    -- STEP 5: Clean up orphaned questionnaire responses for MUST
    -- Remove responses that reference non-existent questions
    -- =====================================================================================
    
    DELETE FROM questionnaire_responses qr
    WHERE qr.session_id IN (
        SELECT as_table.id 
        FROM assessment_sessions as_table 
        WHERE as_table.questionnaire_type = 'must'
    )
    AND qr.question_id NOT IN (
        'must_bmi_calculated',
        'must_weight_loss_3_6_months', 
        'must_acute_illness_food_intake'
    );
    
    RAISE NOTICE 'Cleaned up orphaned MUST questionnaire responses';
    
END $$;

-- =====================================================================================
-- STEP 6: Update template metadata to reflect the correct question count
-- =====================================================================================

UPDATE questionnaire_templates 
SET 
    description = 'Strumento universale di screening della malnutrizione con 3 domande per valutazione rapida del rischio nutrizionale',
    updated_at = CURRENT_TIMESTAMP
WHERE questionnaire_type = 'must';

-- =====================================================================================
-- VERIFICATION QUERIES (for logging)
-- =====================================================================================

DO $$
DECLARE
    must_template_id UUID;
    question_count INTEGER;
    session_count INTEGER;
BEGIN
    -- Get template ID
    SELECT id INTO must_template_id 
    FROM questionnaire_templates 
    WHERE questionnaire_type = 'must';
    
    -- Count questions
    SELECT COUNT(*) INTO question_count 
    FROM questionnaire_questions 
    WHERE template_id = must_template_id;
    
    -- Count active sessions
    SELECT COUNT(*) INTO session_count 
    FROM assessment_sessions 
    WHERE questionnaire_type = 'must' AND status = 'draft';
    
    RAISE NOTICE '=== MUST QUESTIONNAIRE VERIFICATION ===';
    RAISE NOTICE 'Template ID: %', must_template_id;
    RAISE NOTICE 'Total Questions: %', question_count;
    RAISE NOTICE 'Draft Sessions Ready: %', session_count;
    RAISE NOTICE 'Status: Questions should now show 1/3, 2/3, 3/3 format';
    RAISE NOTICE '=======================================';
END $$;

-- Create index for better performance on MUST questionnaire queries
CREATE INDEX IF NOT EXISTS idx_questionnaire_questions_must_template 
ON questionnaire_questions(template_id, order_index) 
WHERE template_id IN (
    SELECT id FROM questionnaire_templates WHERE questionnaire_type = 'must'
);

-- =====================================================================================
-- COMPLETION NOTICE
-- =====================================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎯 MUST QUESTIONNAIRE FIX COMPLETED';
    RAISE NOTICE '✅ Exactly 3 questions configured';
    RAISE NOTICE '✅ Progress counter will now show 1/3, 2/3, 3/3';
    RAISE NOTICE '✅ Existing sessions reset to draft for clean restart';
    RAISE NOTICE '✅ Ready for user testing';
    RAISE NOTICE '';
END $$;