-- Location: supabase/migrations/20250923164500_questionnaire_assessment_system.sql
-- Schema Analysis: Existing schema has user_profiles, medical_profiles, weight_entries tables
-- Integration Type: Addition - Adding questionnaire and assessment functionality
-- Dependencies: user_profiles, medical_profiles, weight_entries

-- 1. Types for questionnaire system
CREATE TYPE public.questionnaire_type AS ENUM (
    'nrs_2002',
    'nutritional_risk_assessment', 
    'esas',
    'sf12',
    'sarc_f',
    'must',
    'dietary_diary'
);

CREATE TYPE public.assessment_status AS ENUM (
    'draft',
    'in_progress', 
    'completed',
    'cancelled'
);

CREATE TYPE public.question_type AS ENUM (
    'yes_no',
    'single_choice',
    'multiple_choice',
    'scale_0_10',
    'number_input',
    'text_input',
    'calculated',
    'food_database'
);

-- 2. Core questionnaire tables
CREATE TABLE public.questionnaire_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    questionnaire_type public.questionnaire_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    age_restriction TEXT, -- e.g., ">70" for SARC-F
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.questionnaire_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID REFERENCES public.questionnaire_templates(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL, -- e.g., 'nrs_bmi_check', 'esas_pain'
    question_text TEXT NOT NULL,
    question_type public.question_type NOT NULL,
    options JSONB, -- Array of options for choice questions
    scores JSONB, -- Array of scores corresponding to options
    score_value INTEGER, -- Fixed score for yes/no questions
    is_required BOOLEAN DEFAULT true,
    depends_on TEXT, -- Question ID this depends on
    depends_value TEXT, -- Value that triggers this question
    notes TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.assessment_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    questionnaire_type public.questionnaire_type NOT NULL,
    status public.assessment_status DEFAULT 'draft',
    started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    total_score INTEGER,
    risk_level TEXT, -- 'low', 'medium', 'high'
    recommendations TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.questionnaire_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.assessment_sessions(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL,
    response_value TEXT,
    response_score INTEGER,
    calculated_value DECIMAL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_questionnaire_questions_template_id ON public.questionnaire_questions(template_id);
CREATE INDEX idx_questionnaire_questions_question_id ON public.questionnaire_questions(question_id);
CREATE INDEX idx_assessment_sessions_user_id ON public.assessment_sessions(user_id);
CREATE INDEX idx_assessment_sessions_type ON public.assessment_sessions(questionnaire_type);
CREATE INDEX idx_assessment_sessions_status ON public.assessment_sessions(status);
CREATE INDEX idx_questionnaire_responses_session_id ON public.questionnaire_responses(session_id);
CREATE INDEX idx_questionnaire_responses_question_id ON public.questionnaire_responses(question_id);

-- 4. Calculation Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.calculate_bmi(user_uuid UUID)
RETURNS DECIMAL
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    CASE 
        WHEN mp.height_cm IS NOT NULL AND mp.height_cm > 0 AND mp.current_weight_kg IS NOT NULL AND mp.current_weight_kg > 0
        THEN ROUND((mp.current_weight_kg / POWER(mp.height_cm / 100.0, 2))::DECIMAL, 2)
        ELSE NULL
    END
FROM public.medical_profiles mp
WHERE mp.user_id = user_uuid
LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.calculate_weight_loss_percentage(user_uuid UUID, months_back INTEGER)
RETURNS DECIMAL
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
WITH weight_data AS (
    SELECT 
        we.weight_kg,
        we.recorded_at,
        ROW_NUMBER() OVER (ORDER BY we.recorded_at DESC) as rn
    FROM public.weight_entries we
    WHERE we.user_id = user_uuid
    AND we.recorded_at >= CURRENT_DATE - INTERVAL '1 month' * months_back
    ORDER BY we.recorded_at DESC
)
SELECT 
    CASE 
        WHEN current_w.weight_kg IS NOT NULL AND past_w.weight_kg IS NOT NULL AND past_w.weight_kg > 0
        THEN ROUND(((past_w.weight_kg - current_w.weight_kg) / past_w.weight_kg * 100)::DECIMAL, 2)
        ELSE 0
    END
FROM 
    (SELECT weight_kg FROM weight_data WHERE rn = 1) current_w,
    (SELECT weight_kg FROM weight_data ORDER BY recorded_at ASC LIMIT 1) past_w;
$$;

CREATE OR REPLACE FUNCTION public.calculate_questionnaire_score(session_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_score INTEGER := 0;
    response_score INTEGER;
BEGIN
    -- Sum all response scores for the session
    SELECT COALESCE(SUM(qr.response_score), 0) INTO total_score
    FROM public.questionnaire_responses qr
    WHERE qr.session_id = session_uuid;
    
    RETURN total_score;
END;
$$;

CREATE OR REPLACE FUNCTION public.determine_risk_level(questionnaire_type_param public.questionnaire_type, total_score INTEGER)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Risk level determination based on questionnaire type and score
    CASE questionnaire_type_param
        WHEN 'nrs_2002' THEN
            IF total_score >= 3 THEN RETURN 'high';
            ELSIF total_score >= 2 THEN RETURN 'medium';  
            ELSE RETURN 'low';
            END IF;
        WHEN 'must' THEN
            IF total_score >= 2 THEN RETURN 'high';
            ELSIF total_score >= 1 THEN RETURN 'medium';
            ELSE RETURN 'low';
            END IF;
        WHEN 'sarc_f' THEN
            IF total_score >= 4 THEN RETURN 'high';
            ELSIF total_score >= 2 THEN RETURN 'medium';
            ELSE RETURN 'low';
            END IF;
        ELSE
            -- Default risk assessment for other questionnaires
            IF total_score >= 60 THEN RETURN 'high';
            ELSIF total_score >= 30 THEN RETURN 'medium';
            ELSE RETURN 'low';
            END IF;
    END CASE;
END;
$$;

CREATE OR REPLACE FUNCTION public.auto_calculate_responses(session_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    session_record RECORD;
    bmi_value DECIMAL;
    weight_loss_1m DECIMAL;
    weight_loss_2m DECIMAL;
    weight_loss_3m DECIMAL;
BEGIN
    -- Get session info
    SELECT user_id, questionnaire_type INTO session_record
    FROM public.assessment_sessions
    WHERE id = session_uuid;
    
    -- Calculate BMI for BMI-related questions
    bmi_value := public.calculate_bmi(session_record.user_id);
    
    -- Calculate weight loss percentages
    weight_loss_1m := public.calculate_weight_loss_percentage(session_record.user_id, 1);
    weight_loss_2m := public.calculate_weight_loss_percentage(session_record.user_id, 2);
    weight_loss_3m := public.calculate_weight_loss_percentage(session_record.user_id, 3);
    
    -- Insert/Update calculated responses
    IF bmi_value IS NOT NULL THEN
        INSERT INTO public.questionnaire_responses (session_id, question_id, response_value, calculated_value)
        VALUES (session_uuid, 'calculated_bmi', bmi_value::TEXT, bmi_value)
        ON CONFLICT (session_id, question_id) DO UPDATE SET
            response_value = EXCLUDED.response_value,
            calculated_value = EXCLUDED.calculated_value,
            updated_at = CURRENT_TIMESTAMP;
            
        -- Auto-answer BMI-related questions
        INSERT INTO public.questionnaire_responses (session_id, question_id, response_value, response_score)
        VALUES (
            session_uuid, 
            'nrs_bmi_check', 
            CASE WHEN bmi_value < 20.5 THEN 'Sì' ELSE 'No' END,
            CASE WHEN bmi_value < 20.5 THEN 1 ELSE 0 END
        )
        ON CONFLICT (session_id, question_id) DO UPDATE SET
            response_value = EXCLUDED.response_value,
            response_score = EXCLUDED.response_score,
            updated_at = CURRENT_TIMESTAMP;
    END IF;
    
    -- Auto-calculate weight loss responses
    IF weight_loss_3m IS NOT NULL THEN
        INSERT INTO public.questionnaire_responses (session_id, question_id, response_value, response_score)
        VALUES (
            session_uuid,
            'weight_loss_3m_auto',
            CASE WHEN weight_loss_3m > 5 THEN 'Sì' ELSE 'No' END,
            CASE WHEN weight_loss_3m > 5 THEN 1 ELSE 0 END
        )
        ON CONFLICT (session_id, question_id) DO UPDATE SET
            response_value = EXCLUDED.response_value,
            response_score = EXCLUDED.response_score,
            updated_at = CURRENT_TIMESTAMP;
    END IF;
END;
$$;

-- 5. Enable RLS
ALTER TABLE public.questionnaire_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questionnaire_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questionnaire_responses ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Using Pattern 2 and Pattern 4)
-- Public read for questionnaire templates and questions (Pattern 4)
CREATE POLICY "public_can_read_questionnaire_templates"
ON public.questionnaire_templates
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "public_can_read_questionnaire_questions"
ON public.questionnaire_questions
FOR SELECT
TO public
USING (true);

-- User ownership for assessment sessions (Pattern 2)
CREATE POLICY "users_manage_own_assessment_sessions"
ON public.assessment_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- User ownership for questionnaire responses (Pattern 2)
CREATE POLICY "users_manage_own_questionnaire_responses"
ON public.questionnaire_responses
FOR ALL
TO authenticated
USING (
    session_id IN (
        SELECT id FROM public.assessment_sessions WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    session_id IN (
        SELECT id FROM public.assessment_sessions WHERE user_id = auth.uid()
    )
);

-- 7. Triggers
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_questionnaire_templates_updated_at
    BEFORE UPDATE ON public.questionnaire_templates
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_assessment_sessions_updated_at
    BEFORE UPDATE ON public.assessment_sessions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_questionnaire_responses_updated_at
    BEFORE UPDATE ON public.questionnaire_responses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 8. Sample questionnaire data
DO $$
DECLARE
    nrs2002_template_id UUID := gen_random_uuid();
    esas_template_id UUID := gen_random_uuid();
    existing_user_id UUID;
    sample_session_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user for testing
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    -- Insert questionnaire templates
    INSERT INTO public.questionnaire_templates (id, questionnaire_type, title, description, category) VALUES
        (nrs2002_template_id, 'nrs_2002', 'NRS 2002 - Nutritional Risk Screening', 'Screening del rischio nutrizionale secondo NRS 2002', 'nutrition'),
        (esas_template_id, 'esas', 'ESAS - Edmonton Symptom Assessment', 'Edmonton Symptom Assessment System - Valutazione sintomi', 'qol');

    -- Insert sample questions for NRS 2002
    INSERT INTO public.questionnaire_questions (template_id, question_id, question_text, question_type, is_required, score_value) VALUES
        (nrs2002_template_id, 'nrs_bmi_check', 'Il BMI è < 20,5?', 'calculated', true, NULL),
        (nrs2002_template_id, 'nrs_weight_loss_3m', 'Il paziente ha perso peso negli ultimi 3 mesi?', 'yes_no', true, NULL),
        (nrs2002_template_id, 'nrs_reduced_intake', 'Il paziente ha ridotto gli introiti alimentari nell''ultima settimana?', 'yes_no', true, NULL),
        (nrs2002_template_id, 'nrs_severe_illness', 'Il paziente presenta una patologia acuta grave?', 'yes_no', true, NULL);

    -- Insert sample questions for ESAS  
    INSERT INTO public.questionnaire_questions (template_id, question_id, question_text, question_type, is_required) VALUES
        (esas_template_id, 'esas_pain', 'Selezionare un valore che descriva il suo livello di dolore (0 min, 10 max)', 'scale_0_10', true),
        (esas_template_id, 'esas_tiredness', 'Selezionare un valore che descriva il suo livello di stanchezza (0 min, 10 max)', 'scale_0_10', true),
        (esas_template_id, 'esas_nausea', 'Selezionare un valore che descriva il suo livello di nausea (0 min, 10 max)', 'scale_0_10', true);

    -- Create sample assessment session if user exists
    IF existing_user_id IS NOT NULL THEN
        INSERT INTO public.assessment_sessions (id, user_id, questionnaire_type, status) VALUES
            (sample_session_id, existing_user_id, 'nrs_2002', 'in_progress');
            
        -- Trigger automatic calculations
        PERFORM public.auto_calculate_responses(sample_session_id);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating sample data: %', SQLERRM;
END $$;