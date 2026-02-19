-- Location: supabase/migrations/20251003124545_fix_questionnaire_response_unique_constraint.sql
-- Schema Analysis: Existing questionnaire system with assessment_sessions, questionnaire_questions, questionnaire_responses tables
-- Integration Type: Fix - Adding missing unique constraint for questionnaire responses
-- Dependencies: questionnaire_responses table

-- CRITICAL FIX: Clean up duplicate responses and add unique constraint for questionnaire responses to enable proper upsert operations
-- This fixes the "relation does not exist" error and enables proper ON CONFLICT operations in saveQuestionnaireResponse and auto_calculate_responses

-- Step 1: Remove duplicate questionnaire responses, keeping the most recent one
-- Delete older duplicate responses based on session_id and question_id
DELETE FROM public.questionnaire_responses
WHERE id NOT IN (
    SELECT DISTINCT ON (session_id, question_id) id
    FROM public.questionnaire_responses
    ORDER BY session_id, question_id, updated_at DESC, created_at DESC
);

-- Step 2: Drop existing constraint if it exists to prevent conflicts
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'questionnaire_responses_session_question_unique'
    ) THEN
        ALTER TABLE public.questionnaire_responses 
        DROP CONSTRAINT questionnaire_responses_session_question_unique;
    END IF;
END
$$;

-- Step 3: Drop existing index if it exists to prevent conflicts  
DROP INDEX IF EXISTS idx_questionnaire_responses_session_question_unique;

-- Step 4: Add unique constraint directly (this will automatically create a backing index)
-- This approach avoids the "relation does not exist" error by letting PostgreSQL handle index creation
ALTER TABLE public.questionnaire_responses 
ADD CONSTRAINT questionnaire_responses_session_question_unique 
UNIQUE (session_id, question_id);

-- Step 5: Update the auto_calculate_responses function to handle the constraint properly
CREATE OR REPLACE FUNCTION public.auto_calculate_responses(session_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid UUID;
    user_profile RECORD;
    bmi_value NUMERIC;
    weight_loss_3m NUMERIC;
    has_pathology BOOLEAN := false;
    primary_pathology TEXT;
BEGIN
    -- Get user ID from session
    SELECT user_id INTO user_uuid 
    FROM public.assessment_sessions 
    WHERE id = session_uuid;

    IF user_uuid IS NULL THEN
        RAISE NOTICE 'Session not found: %', session_uuid;
        RETURN;
    END IF;

    -- Get user profile and medical data
    SELECT mp.height_cm, mp.current_weight_kg, mp.medical_conditions
    INTO user_profile
    FROM public.medical_profiles mp
    WHERE mp.user_id = user_uuid;

    -- Calculate BMI if height and weight are available
    IF user_profile.height_cm IS NOT NULL AND user_profile.current_weight_kg IS NOT NULL 
       AND user_profile.height_cm > 0 THEN
        bmi_value := user_profile.current_weight_kg / POWER(user_profile.height_cm / 100.0, 2);
        
        -- Insert/Update BMI response with proper constraint handling
        INSERT INTO public.questionnaire_responses (session_id, question_id, response_value, response_score, calculated_value)
        VALUES (session_uuid, 'calculated_bmi', bmi_value::TEXT, CASE WHEN bmi_value < 20.5 THEN 1 ELSE 0 END, bmi_value)
        ON CONFLICT (session_id, question_id) DO UPDATE SET
            response_value = EXCLUDED.response_value,
            response_score = EXCLUDED.response_score,
            calculated_value = EXCLUDED.calculated_value,
            updated_at = CURRENT_TIMESTAMP;
    END IF;

    -- Calculate weight loss percentage over 3 months
    SELECT 
        CASE 
            WHEN COUNT(*) >= 2 THEN
                ((FIRST_VALUE(weight_kg) OVER (ORDER BY recorded_at DESC) - 
                  LAST_VALUE(weight_kg) OVER (ORDER BY recorded_at DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) 
                 / LAST_VALUE(weight_kg) OVER (ORDER BY recorded_at DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) * 100
            ELSE 0
        END
    INTO weight_loss_3m
    FROM public.weight_entries 
    WHERE user_id = user_uuid 
      AND recorded_at >= NOW() - INTERVAL '3 months'
    LIMIT 1;

    -- Insert/Update weight loss response
    IF weight_loss_3m IS NOT NULL THEN
        INSERT INTO public.questionnaire_responses (session_id, question_id, response_value, response_score, calculated_value)
        VALUES (session_uuid, 'weight_loss_3m', weight_loss_3m::TEXT, CASE WHEN weight_loss_3m > 5 THEN 1 ELSE 0 END, weight_loss_3m)
        ON CONFLICT (session_id, question_id) DO UPDATE SET
            response_value = EXCLUDED.response_value,
            response_score = EXCLUDED.response_score,
            calculated_value = EXCLUDED.calculated_value,
            updated_at = CURRENT_TIMESTAMP;
    END IF;

    -- Check for pathology
    IF user_profile.medical_conditions IS NOT NULL AND array_length(user_profile.medical_conditions, 1) > 0 THEN
        has_pathology := true;
        primary_pathology := user_profile.medical_conditions[1];
        
        -- Insert/Update pathology response
        INSERT INTO public.questionnaire_responses (session_id, question_id, response_value, response_score, calculated_value)
        VALUES (session_uuid, 'has_pathology', 
                CASE WHEN has_pathology THEN 'Sì' ELSE 'No' END, 
                CASE WHEN has_pathology THEN 1 ELSE 0 END, 
                primary_pathology)
        ON CONFLICT (session_id, question_id) DO UPDATE SET
            response_value = EXCLUDED.response_value,
            response_score = EXCLUDED.response_score,
            calculated_value = EXCLUDED.calculated_value,
            updated_at = CURRENT_TIMESTAMP;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in auto_calculate_responses: %', SQLERRM;
END;
$$;

-- Step 6: Add comment explaining the fix
COMMENT ON CONSTRAINT questionnaire_responses_session_question_unique ON public.questionnaire_responses IS 
'Unique constraint to prevent duplicate responses for the same question in a session. Enables proper UPSERT operations in questionnaire response saving. Fixed by creating constraint directly instead of using separate index creation.';

-- source: api
-- user: 2f9e97cb-4061-44e9-89d2-1f478613549c
-- date: 2025-10-03T13:02:48.087Z

-- source: api
-- user: 2f9e97cb-4061-44e9-89d2-1f478613549c
-- date: 2025-10-03T13:13:53.781Z