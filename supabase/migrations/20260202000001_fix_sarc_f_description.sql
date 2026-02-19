-- Location: supabase/migrations/20260202000001_fix_sarc_f_description.sql
-- Purpose: Fix SARC-F questionnaire description - remove age restriction text
-- Change from: "Screening per sarcopenia e valutazione della forza muscolare (per pazienti > 70 anni)"
-- Change to: "Screening per sarcopenia e valutazione della forza muscolare"

-- Update SARC-F template description
UPDATE public.questionnaire_templates
SET description = 'Screening per sarcopenia e valutazione della forza muscolare'
WHERE questionnaire_type = 'sarc_f'::public.questionnaire_type;

-- Verify the change
DO $$
DECLARE
    sarc_description TEXT;
BEGIN
    -- Get the updated description
    SELECT description INTO sarc_description
    FROM public.questionnaire_templates
    WHERE questionnaire_type = 'sarc_f'::public.questionnaire_type;
    
    -- Log the result
    RAISE NOTICE 'SARC-F description updated to: %', sarc_description;
    
    -- Verify it matches the expected value
    IF sarc_description = 'Screening per sarcopenia e valutazione della forza muscolare' THEN
        RAISE NOTICE '✅ SUCCESS: SARC-F description updated correctly';
    ELSE
        RAISE NOTICE '❌ ERROR: SARC-F description does not match expected value';
        RAISE NOTICE 'Expected: "Screening per sarcopenia e valutazione della forza muscolare"';
        RAISE NOTICE 'Got: "%"', sarc_description;
    END IF;
END $$;

-- Add comment for documentation
COMMENT ON TABLE questionnaire_templates IS 'SARC-F description updated to remove age restriction text - Updated 2026-02-02';

