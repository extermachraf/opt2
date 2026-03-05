-- Migration: Fix NRS 2002 Q6 and Q7 options/scores key mismatch
-- Problem: The options array for Q6 had "(non con l'obiettivo di perdere peso)"
--          appended to the score-3 option text, but the scores JSONB map still
--          used the OLD shorter text as its key. Flutter does scores[optionText]
--          which returns null → optionScore = 0 → score saved as 0 → total = 0.
-- Fix: Re-set BOTH options and scores for Q6 and Q7 so their keys are identical.
-- Template: d4917df5-5a84-41f7-aa8b-c20bd96d0ddf

UPDATE public.questionnaire_questions
SET
    options = '[
        "Il mio stato nutrizionale è normale",
        "Ho perso più del 5% del mio peso involontariamente negli ultimi 3 mesi oppure ho diminuito lievemente i miei introiti alimentari",
        "Ho perso più del 5% del mio peso involontariamente negli ultimi 2 mesi oppure ho diminuito moderatamente i miei introiti alimentari",
        "Ho perso più del 5% del mio peso involontariamente nell''ultimo mese oppure ho diminuito gravemente i miei introiti alimentari (non con l''obiettivo di perdere peso)"
    ]'::jsonb,
    scores = '{
        "Il mio stato nutrizionale è normale": 0,
        "Ho perso più del 5% del mio peso involontariamente negli ultimi 3 mesi oppure ho diminuito lievemente i miei introiti alimentari": 1,
        "Ho perso più del 5% del mio peso involontariamente negli ultimi 2 mesi oppure ho diminuito moderatamente i miei introiti alimentari": 2,
        "Ho perso più del 5% del mio peso involontariamente nell''ultimo mese oppure ho diminuito gravemente i miei introiti alimentari (non con l''obiettivo di perdere peso)": 3
    }'::jsonb
WHERE question_id = 'nrs_nutritional_status'
  AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

UPDATE public.questionnaire_questions
SET
    options = '[
        "Stato normale",
        "Patologia cronica con complicanza, patologia oncologica, chirurgia minore",
        "Chirurgia maggiore, patologia onco-ematologica, infezione grave, sepsi, trapianto",
        "Trauma grave, trapianto di midollo osseo, ricovero in terapia intensiva"
    ]'::jsonb,
    scores = '{
        "Stato normale": 0,
        "Patologia cronica con complicanza, patologia oncologica, chirurgia minore": 1,
        "Chirurgia maggiore, patologia onco-ematologica, infezione grave, sepsi, trapianto": 2,
        "Trauma grave, trapianto di midollo osseo, ricovero in terapia intensiva": 3
    }'::jsonb
WHERE question_id = 'nrs_disease_severity'
  AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

-- Verification
DO $$
DECLARE
    q6_options  JSONB;
    q6_scores   JSONB;
    q7_options  JSONB;
    q7_scores   JSONB;
BEGIN
    SELECT options, scores INTO q6_options, q6_scores
    FROM public.questionnaire_questions
    WHERE question_id = 'nrs_nutritional_status'
      AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

    SELECT options, scores INTO q7_options, q7_scores
    FROM public.questionnaire_questions
    WHERE question_id = 'nrs_disease_severity'
      AND template_id = 'd4917df5-5a84-41f7-aa8b-c20bd96d0ddf';

    RAISE NOTICE '=== NRS 2002 Q6/Q7 options+scores fix ===';
    RAISE NOTICE 'Q6 options count: %', jsonb_array_length(q6_options);
    RAISE NOTICE 'Q6 scores count: %', (SELECT count(*) FROM jsonb_each(q6_scores));
    RAISE NOTICE 'Q6 score-3 key match: %',
        (q6_scores->>((q6_options->>3)) IS NOT NULL)::TEXT;
    RAISE NOTICE 'Q7 options count: %', jsonb_array_length(q7_options);
    RAISE NOTICE 'Q7 scores count: %', (SELECT count(*) FROM jsonb_each(q7_scores));
    RAISE NOTICE 'Q7 score-3 key match: %',
        (q7_scores->>((q7_options->>3)) IS NOT NULL)::TEXT;

    IF (q6_scores->>((q6_options->>3)) IS NOT NULL) AND
       (q7_scores->>((q7_options->>3)) IS NOT NULL) THEN
        RAISE NOTICE '✅ SUCCESS: Q6 and Q7 options/scores keys are now consistent.';
    ELSE
        RAISE WARNING '❌ PROBLEM: Key mismatch still detected after update!';
    END IF;
END $$;

