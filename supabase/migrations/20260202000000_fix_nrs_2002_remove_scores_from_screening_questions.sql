-- Location: supabase/migrations/20260202000000_fix_nrs_2002_remove_scores_from_screening_questions.sql
-- Purpose: Fix NRS 2002 questionnaire - remove scores from screening questions (Q1-Q5)
-- Only Questions 6 and 7 should have scores
-- Questions 1-5 are screening questions with NO scores

-- Update Question 1 (BMI < 20,5) - Remove scores
UPDATE public.questionnaire_questions
SET scores = '{}'::jsonb
WHERE template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf'
AND question_id = 'nrs_bmi_under_20_5';

-- Update Question 2 (Weight loss in last 3 months) - Remove scores
UPDATE public.questionnaire_questions
SET scores = '{}'::jsonb
WHERE template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf'
AND question_id = 'nrs_weight_loss_3m';

-- Update Question 3 (Reduced food intake) - Remove scores
UPDATE public.questionnaire_questions
SET scores = '{}'::jsonb
WHERE template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf'
AND question_id = 'nrs_reduced_intake';

-- Update Question 4 (Acute pathology) - Remove scores
UPDATE public.questionnaire_questions
SET scores = '{}'::jsonb
WHERE template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf'
AND question_id = 'nrs_acute_pathology';

-- Update Question 5 (Intensive care) - Remove scores
UPDATE public.questionnaire_questions
SET scores = '{}'::jsonb
WHERE template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf'
AND question_id = 'nrs_intensive_care';

-- Verify the changes
DO $$
DECLARE
    q1_scores jsonb;
    q2_scores jsonb;
    q3_scores jsonb;
    q4_scores jsonb;
    q5_scores jsonb;
    q6_scores jsonb;
    q7_scores jsonb;
BEGIN
    -- Get scores for each question
    SELECT scores INTO q1_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_bmi_under_20_5';
    
    SELECT scores INTO q2_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_weight_loss_3m';
    
    SELECT scores INTO q3_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_reduced_intake';
    
    SELECT scores INTO q4_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_acute_pathology';
    
    SELECT scores INTO q5_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_intensive_care';
    
    SELECT scores INTO q6_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_nutritional_status';
    
    SELECT scores INTO q7_scores FROM public.questionnaire_questions 
    WHERE question_id = 'nrs_disease_severity';
    
    -- Log the results
    RAISE NOTICE 'NRS 2002 Scores Verification:';
    RAISE NOTICE 'Q1 (BMI) scores: %', q1_scores;
    RAISE NOTICE 'Q2 (Weight loss) scores: %', q2_scores;
    RAISE NOTICE 'Q3 (Reduced intake) scores: %', q3_scores;
    RAISE NOTICE 'Q4 (Acute pathology) scores: %', q4_scores;
    RAISE NOTICE 'Q5 (Intensive care) scores: %', q5_scores;
    RAISE NOTICE 'Q6 (Nutritional status) scores: %', q6_scores;
    RAISE NOTICE 'Q7 (Disease severity) scores: %', q7_scores;
    
    -- Verify Q1-Q5 have empty scores
    IF q1_scores = '{}'::jsonb AND q2_scores = '{}'::jsonb AND 
       q3_scores = '{}'::jsonb AND q4_scores = '{}'::jsonb AND 
       q5_scores = '{}'::jsonb THEN
        RAISE NOTICE '✅ SUCCESS: Questions 1-5 have NO scores (correct)';
    ELSE
        RAISE NOTICE '❌ ERROR: Questions 1-5 still have scores!';
    END IF;
    
    -- Verify Q6-Q7 still have scores
    IF q6_scores IS NOT NULL AND q6_scores != '{}'::jsonb AND
       q7_scores IS NOT NULL AND q7_scores != '{}'::jsonb THEN
        RAISE NOTICE '✅ SUCCESS: Questions 6-7 still have scores (correct)';
    ELSE
        RAISE NOTICE '❌ ERROR: Questions 6-7 are missing scores!';
    END IF;
END $$;

-- Add comment for documentation
COMMENT ON TABLE questionnaire_questions IS 'NRS 2002 fixed: Questions 1-5 have NO scores (screening only), Questions 6-7 have scores (0-3 points each) - Updated 2026-02-02';

