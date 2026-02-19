-- Location: supabase/migrations/20250924130346_update_italian_questionnaire_data.sql
-- Schema Analysis: Existing questionnaire system with templates, questions, and responses tables
-- Integration Type: Data replacement for questionnaire templates and questions
-- Dependencies: Existing questionnaire_templates, questionnaire_questions tables

-- This migration replaces existing questionnaire data with comprehensive Italian questionnaires
-- organized in 8 categories as specified by the user requirements

-- Clean up existing questionnaire data first
DELETE FROM public.questionnaire_responses;
DELETE FROM public.questionnaire_questions;
DELETE FROM public.questionnaire_templates;

-- Insert new Italian questionnaire templates organized by categories
DO $$
DECLARE
    -- Diario Alimentare
    diario_template_id UUID := gen_random_uuid();
    
    -- MUST
    must_template_id UUID := gen_random_uuid();
    
    -- NRS 2002
    nrs_template_id UUID := gen_random_uuid();
    
    -- Valutazione Rischio Nutrizionale
    vrn_template_id UUID := gen_random_uuid();
    
    -- ESAS
    esas_template_id UUID := gen_random_uuid();
    
    -- SF-12
    sf12_template_id UUID := gen_random_uuid();
    
    -- SARC-F
    sarc_template_id UUID := gen_random_uuid();
BEGIN
    -- Insert questionnaire templates with Italian categorization
    INSERT INTO public.questionnaire_templates (
        id, title, description, category, questionnaire_type, is_active, version
    ) VALUES
        -- Categoria 1: Diario Alimentare
        (diario_template_id, 'Diario Alimentare', 
         'Registrazione dei pasti quotidiani e selezione degli alimenti dal database BDA', 
         'Categoria 1 - Diario Alimentare', 
         'dietary_diary'::public.questionnaire_type, true, 1),
        
        -- Categoria 2: MUST
        (must_template_id, 'MUST - Malnutrition Universal Screening Tool', 
         'Screening universale per la malnutrizione con valutazione BMI e calo di peso', 
         'Categoria 2 - Valutazioni Nutrizionali MUST', 
         'must'::public.questionnaire_type, true, 1),
        
        -- Categoria 3: NRS 2002
        (nrs_template_id, 'NRS 2002 - Nutritional Risk Screening', 
         'Screening del rischio nutrizionale per pazienti ospedalizzati secondo linee guida NRS 2002', 
         'Categoria 3 - NRS 2002 Screening', 
         'nrs_2002'::public.questionnaire_type, true, 1),
        
        -- Categoria 4: Valutazione Rischio Nutrizionale
        (vrn_template_id, 'Valutazione Rischio Nutrizionale', 
         'Valutazione completa del rischio nutrizionale con parametri clinici e alimentari', 
         'Categoria 4 - Valutazione del Rischio', 
         'nutritional_risk_assessment'::public.questionnaire_type, true, 1),
        
        -- Categoria 5: ESAS
        (esas_template_id, 'ESAS - Edmonton Symptom Assessment System', 
         'Valutazione dei sintomi e del benessere psicofisico del paziente su scala 0-10', 
         'Categoria 5 - Qualità della Vita ESAS', 
         'esas'::public.questionnaire_type, true, 1),
        
        -- Categoria 6: SF-12
        (sf12_template_id, 'SF-12 - Short Form Health Survey', 
         'Questionario breve per la valutazione della salute generale e qualità della vita', 
         'Categoria 6 - SF-12 Salute Generale', 
         'sf12'::public.questionnaire_type, true, 1),
        
        -- Categoria 7: SARC-F
        (sarc_template_id, 'SARC-F - Sarcopenia Screening', 
         'Screening per sarcopenia e valutazione della forza muscolare (per pazienti > 70 anni)', 
         'Categoria 7 - SARC-F Sarcopenia', 
         'sarc_f'::public.questionnaire_type, true, 1);

    -- Insert questions for Diario Alimentare
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes
    ) VALUES
        (diario_template_id, 'diary_meal_colazione', 'Aggiungere pasto: selezionare il pasto', 'single_choice', 
         '["Colazione"]'::jsonb, 1, true, null),
        (diario_template_id, 'diary_meal_pranzo', 'Aggiungere pasto: selezionare il pasto', 'single_choice', 
         '["Pranzo"]'::jsonb, 2, true, null),
        (diario_template_id, 'diary_meal_cena', 'Aggiungere pasto: selezionare il pasto', 'single_choice', 
         '["Cena"]'::jsonb, 3, true, null),
        (diario_template_id, 'diary_meal_spuntino', 'Aggiungere pasto: selezionare il pasto', 'single_choice', 
         '["Spuntino/Merenda"]'::jsonb, 4, true, null),
        (diario_template_id, 'diary_meal_altro', 'Aggiungere pasto: selezionare il pasto', 'single_choice', 
         '["Altro (specificare)"]'::jsonb, 5, true, 
         'Se selezionato "Altro", deve essere previsto un campo di inserimento di testo libero'),
        (diario_template_id, 'diary_food_selection', 'Aggiungere pasto: selezione alimento', 'food_database', 
         '[]'::jsonb, 6, true, 'Per questo menu, fare riferimento al file BDA dischetto V1.2022 finalfinal.xlsx');

    -- Insert questions for MUST
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes, score_value
    ) VALUES
        (must_template_id, 'must_fasting_5_days', 'Digiuno >5 giorni (già verificato o previsto)?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 1, true, 'Punteggio del digiuno = 2', 2),
        (must_template_id, 'must_bmi_under_18_5', 'Punteggio IMC < 18,5', 'yes_no', 
         '["Sì", "No"]'::jsonb, 2, true, 'Punteggio IMC = 2', 2),
        (must_template_id, 'must_bmi_over_20', 'Punteggio IMC > 20', 'yes_no', 
         '["Sì", "No"]'::jsonb, 3, true, 'Punteggio IMC = 0', 0),
        (must_template_id, 'must_bmi_18_5_20', 'Punteggio IMC compreso fra 18,5 e 20', 'yes_no', 
         '["Sì", "No"]'::jsonb, 4, true, 'Punteggio IMC = 1', 1),
        (must_template_id, 'must_weight_loss_under_5', 'Punteggio del calo di peso: Calo di peso non programmato nei 3-6 mesi precedenti <5%', 'yes_no', 
         '["Sì", "No"]'::jsonb, 5, true, 'Punteggio del calo di peso = 0', 0),
        (must_template_id, 'must_weight_loss_over_10', 'Punteggio del calo di peso: Calo di peso non programmato nei 3-6 mesi precedenti >10%', 'yes_no', 
         '["Sì", "No"]'::jsonb, 6, true, 'Punteggio del calo di peso = 2', 2),
        (must_template_id, 'must_weight_loss_5_10', 'Punteggio del calo di peso: Calo di peso non programmato nei 3-6 mesi precedenti compreso fra 5% e 10%', 'yes_no', 
         '["Sì", "No"]'::jsonb, 7, true, 'Punteggio del calo di peso = 1', 1),
        (must_template_id, 'must_malnutrition_risk', 'Rischio globale di malnutrizione', 'calculated', 
         '[]'::jsonb, 8, true, 'E'' la somma dei punteggi dei fattori sopra', null);

    -- Insert questions for NRS 2002
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes, score_value
    ) VALUES
        (nrs_template_id, 'nrs_nutritional_severe', 'Alterato stato nutrizionale: Perdita di peso >5 % in 1 mese (>15% in 3 mesi) oppure BMI< 18,5 + alterate cond. generali oppure Introiti alimentari tra 0-25% dei normali fabbisogni nelle settimane precedenti', 'yes_no', 
         '["Sì", "No"]'::jsonb, 1, true, 'Score = 3', 3),
        (nrs_template_id, 'nrs_nutritional_moderate', 'Alterato stato nutrizionale: Perdita di peso >5 % in 2 mesi oppure BMI 18,5-20 + alterate cond. generali oppure Introiti alimentari tra 25-50% dei normali fabbisogni nelle settimane precedenti', 'yes_no', 
         '["Sì", "No"]'::jsonb, 2, true, 'Score = 2', 2),
        (nrs_template_id, 'nrs_nutritional_mild', 'Alterato stato nutrizionale: Perdita di peso >5 % in 3 mesi oppure Introiti alimentari tra 50-75% dei normali fabbisogni nelle settimane precedenti', 'yes_no', 
         '["Sì", "No"]'::jsonb, 3, true, 'Score = 1', 1),
        (nrs_template_id, 'nrs_nutritional_normal', 'Alterato stato nutrizionale: Stato nutrizionale normale', 'yes_no', 
         '["Sì", "No"]'::jsonb, 4, true, 'Score = 0', 0),
        (nrs_template_id, 'nrs_disease_severe_1', 'Gravità della patologia: Chirurgia addominale maggiore \nIctus \nPolmoniti gravi, onco-ematologia', 'yes_no', 
         '["Sì", "No"]'::jsonb, 5, true, 'Score = 2', 2),
        (nrs_template_id, 'nrs_disease_normal', 'Gravità della patologia: Fabbisogni nutrizionali normali', 'yes_no', 
         '["Sì", "No"]'::jsonb, 6, true, 'Score = 0', 0),
        (nrs_template_id, 'nrs_disease_severe_2', 'Gravità della patologia: Trauma cranico \nTrapianto di midollo \nPazienti della terapia intensiva (APACHE > 10)', 'yes_no', 
         '["Sì", "No"]'::jsonb, 7, true, 'Score = 3', 3),
        (nrs_template_id, 'nrs_disease_moderate', 'Gravità della patologia: Traumi con fratture\nPaziente cronico, in particolare con complicazioni acute: cirrosi, COPD. \nEmodialisi cronica, diabete, oncologia', 'yes_no', 
         '["Sì", "No"]'::jsonb, 8, true, 'Score = 1', 1),
        (nrs_template_id, 'nrs_bmi_check', 'Il BMI è < 20,5?', 'calculated', 
         '["Sì", "No"]'::jsonb, 9, true, 'Calcolo automatico', null),
        (nrs_template_id, 'nrs_weight_loss_3m', 'Il paziente ha perso peso negli ultimi 3 mesi?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 10, true, null, null),
        (nrs_template_id, 'nrs_reduced_intake', 'Il paziente ha ridotto gli introiti alimentari nell''ultima settimana?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 11, true, null, null),
        (nrs_template_id, 'nrs_severe_illness', 'Il paziente presenta una patologia acuta grave?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 12, true, null, null);

    -- Insert questions for Valutazione Rischio Nutrizionale
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes, score_value
    ) VALUES
        (vrn_template_id, 'vrn_pathology_none', 'Gravità della patologia concomitante', 'single_choice', 
         '["Patologie non impattanti sui fabbisogni nutrizionali (cioè diverse da quelle seguenti)"]'::jsonb, 1, true, 
         'Se una delle risposte ai quattro quesiti sopra è "Sì", deve comparire questa domanda. Punteggio per questa risposta: 0', 0),
        (vrn_template_id, 'vrn_pathology_moderate', 'Gravità della patologia concomitante', 'single_choice', 
         '["Patologie croniche con complicanze (es. cirrosi, BPCO, insufficienza renale in dialisi, diabete scompensato, patologie gastroenterologiche, neurologiche e reumatologiche), patologie oncologiche, patologie acute (es. infettive, respiratorie, cardiologiche), chirurgia minore, frattura del femore"]'::jsonb, 2, true, 'Punteggio per questa risposta: 1', 1),
        (vrn_template_id, 'vrn_pathology_severe', 'Gravità della patologia concomitante', 'single_choice', 
         '["Chirurgia maggiore, ictus, patologie onco-ematologiche, polmonite grave, trapianto d''organo (non midollo osseo), sepsi"]'::jsonb, 3, true, 'Punteggio per questa risposta: 2', 2),
        (vrn_template_id, 'vrn_pathology_critical', 'Gravità della patologia concomitante', 'single_choice', 
         '["Trauma grave, trapianto di midollo osseo, ricovero in Terapia Intensiva"]'::jsonb, 4, true, 'Punteggio per questa risposta: 3', 3),
        (vrn_template_id, 'vrn_weight_loss', 'Hai perso involontariamente peso negli ultimi 3 mesi?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 5, true, null, null),
        (vrn_template_id, 'vrn_reduced_intake', 'Hai ridotto i consumi alimentari rispetto alle tue abitudini (non per perdere peso)?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 6, true, null, null),
        (vrn_template_id, 'vrn_bmi_check', 'Il BMI è < 20,5?', 'calculated', 
         '["Sì", "No"]'::jsonb, 7, true, 'Calcolo automatico a partire dai valori di Altezza paziente [cm] e Peso attuale paziente [kg]', null),
        (vrn_template_id, 'vrn_has_pathology', 'Il paziente presenta una patologia?', 'calculated', 
         '["Sì", "No"]'::jsonb, 8, true, 'Compiliazione automatica se il paziente ha selezionato un''opzione fra le Patologie concomitanti', null),
        (vrn_template_id, 'vrn_nutritional_normal', 'In quale stato nutrizionale ti ritrovi? Com''è stata la tua alimentazione nell''ultima settimana?', 'single_choice', '["Normale"]'::jsonb, 9, true, 'Se una delle risposte ai quattro quesiti sopra è "Sì", deve comparire questa domanda. Punteggio per questa risposta: 0', 0), (vrn_template_id, 'vrn_nutritional_mild', 'In quale stato nutrizionale ti ritrovi? Com''è stata la tua alimentazione nell''ultima settimana?', 'single_choice', '["Calo > 5% del peso corporeo negli ultimi 3 mesi/Alimentazione diminuita lievemente"]'::jsonb, 10, true, 'Punteggio per questa risposta: 1', 1), (vrn_template_id, 'vrn_nutritional_moderate', 'In quale stato nutrizionale ti ritrovi? Com''è stata la tua alimentazione nell''ultima settimana?', 'single_choice', '["Calo > 5% del peso corporeo negli ultimi 2 mesi/Alimentazione diminuita moderatamente"]'::jsonb, 11, true, 'Punteggio per questa risposta: 2', 2), (vrn_template_id, 'vrn_nutritional_severe', 'In quale stato nutrizionale ti ritrovi? Com''è stata la tua alimentazione nell''ultima settimana?', 'single_choice', '["Calo > 5% del peso corporeo nell''ultimo mese (o > 15% negli ultimi 3 mesi)/Alimentazione diminuita gravemente"]'::jsonb, 12, true, 'Punteggio per questa risposta: 3', 3);
    -- Insert questions for ESAS (all scale 0-10)
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes
    ) VALUES
        (esas_template_id, 'esas_anxiety', 'Selezionare un valore che descriva il suo livello di ansia (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 1, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_appetite', 'Selezionare un valore che descriva il suo livello di appetito (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 2, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_depression', 'Selezionare un valore che descriva il suo livello di depressione (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 3, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_pain', 'Selezionare un valore che descriva il suo livello di dolore (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 4, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_nausea', 'Selezionare un valore che descriva il suo livello di nausea (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 5, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_breathlessness', 'Selezionare un valore che descriva il suo livello di respiro corto (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 6, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_wellbeing', 'Selezionare un valore che descriva il suo livello di sensazione di benessere (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 7, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_drowsiness', 'Selezionare un valore che descriva il suo livello di sonnolenza (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 8, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_tiredness', 'Selezionare un valore che descriva il suo livello di stanchezza (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 9, true, 'Una sola scelta possibile fra i valori elencati'),
        (esas_template_id, 'esas_other_problems', 'Selezionare un valore che descriva la sua condizione associata ad altri problemi (0 min, 10 max)', 'scale_0_10', 
         '["0","1","2","3","4","5","6","7","8","9","10"]'::jsonb, 10, true, 'Una sola scelta possibile fra i valori elencati');

    -- Insert questions for SF-12
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes
    ) VALUES
        (sf12_template_id, 'sf12_general_health', 'In generale, direbbe che la Sua salute è', 'single_choice', 
         '["Eccellente", "Molto buona", "Buona", "Passabile", "Scadente"]'::jsonb, 1, true, null),
        (sf12_template_id, 'sf12_stairs_limitation', 'La sua salute La limita attualmente nel salire qualche\npiano di scale?', 'single_choice', 
         '["Sì parecchio", "Sì parzialmente", "No per nulla"]'::jsonb, 2, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_moderate_activities', 'La sua salute La limita attualmente nello svolgimento di\nattività di moderato impegno fisico (come spostare un\ntavolo, usare l''aspirapolvere, giocare a bocce o fare un\ngiro in bicicletta, ecc.)', 'single_choice', 
         '["Sì parecchio", "Sì parzialmente", "No per nulla"]'::jsonb, 3, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_social_interference', 'Nelle ultime 4 settimane per quanto tempo la sua salute fisica o il suo stato emotivo hanno interferito nelle sue attività sociali, in famiglia, con gli amici?', 'single_choice', 
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb, 4, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_concentration_problem', 'Nelle ultime 4 settimane, ha avuto un calo di\nconcentrazione sul lavoro o nelle altre attività quotidiane,\na causa del suo stato emotivo (quale il sentirsi depresso, ansioso?)', 'single_choice', 
         '["Eccellente", "Molto buona", "Buona", "Passabile", "Scadente"]'::jsonb, 5, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_work_limitation_physical', 'Nelle ultime 4 settimane, ha dovuto limitare alcuni tipi di\nlavoro o di altre attività, a causa della sua salute?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 6, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_work_limitation_emotional', 'Nelle ultime 4 settimane, ha reso meno di quanto avrebbe\nvoluto sul lavoro o nelle altre attività quotidiane, a causa\ndel suo stato emotivo (quale il sentirsi depresso, ansioso?)', 'yes_no', 
         '["Sì", "No"]'::jsonb, 7, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_work_performance', 'Nelle ultime 4 settimane, ha reso meno di quanto avrebbe\nvoluto sul lavoro o nelle altre attività quotidiane, a causa\ndella sua salute?', 'yes_no', 
         '["Sì", "No"]'::jsonb, 8, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_pain_interference', 'Nelle ultime 4 settimane, in che misura il dolore l''ha ostacolata nel lavoro che svolge abitualmente (sia in casa sia fuori casa)?', 'single_choice', 
         '["Per nulla", "Molto poco", "Un po''", "Molto", "Moltissimo"]'::jsonb, 9, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_calm_peaceful', 'Per quanto tempo nelle ultime 4 settimane si è sentito calmo e sereno?', 'single_choice', 
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb, 10, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_energy', 'Per quanto tempo nelle ultime 4 settimane si è sentito pieno di energia?', 'single_choice', 
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb, 11, true, 'Una sola scelta possibile fra i valori elencati'),
        (sf12_template_id, 'sf12_downhearted', 'Per quanto tempo nelle ultime 4 settimane si è sentito scoraggiato e triste?', 'single_choice', 
         '["Sempre", "Quasi sempre", "Molto tempo", "Una parte del tempo", "Quasi mai", "Mai"]'::jsonb, 12, true, 'Una sola scelta possibile fra i valori elencati');

    -- Insert questions for SARC-F
    INSERT INTO public.questionnaire_questions (
        template_id, question_id, question_text, question_type, options, order_index, is_required, notes
    ) VALUES
        (sarc_template_id, 'sarc_calf_circumference', 'Circonferenza del polpaccio [cm]', 'number_input', 
         '[]'::jsonb, 1, true, 'Controllo: questionario disponibile se età > 70'),
        (sarc_template_id, 'sarc_walking_room', 'Fa difficoltà a camminare all''interno di una stanza?', 'single_choice', 
         '["Mai", "A volte", "Spesso - Con ausili", "Inabile"]'::jsonb, 2, true, 'Controllo: questionario disponibile se età > 70'),
        (sarc_template_id, 'sarc_climbing_stairs', 'Fa difficoltà a salire 10 scalini?', 'single_choice', 
         '["Mai", "A volte", "Spesso - Con ausili", "Inabile"]'::jsonb, 3, true, 'Controllo: questionario disponibile se età > 70'),
        (sarc_template_id, 'sarc_lifting_carrying', 'Fa difficoltà a sollevare/trasportare 4,5 kg?', 'single_choice', 
         '["Mai", "A volte", "Spesso - Con ausili", "Inabile"]'::jsonb, 4, true, 'Controllo: questionario disponibile se età > 70'),
        (sarc_template_id, 'sarc_chair_bed', 'Fa difficoltà ad alzarsi dal letto/dalla sedia?', 'single_choice', 
         '["Mai", "A volte", "Spesso - Con ausili", "Inabile"]'::jsonb, 5, true, 'Controllo: questionario disponibile se età > 70'),
        (sarc_template_id, 'sarc_falls', 'Quante volte è caduto/a nell''ultimo anno?', 'single_choice', 
         '["Mai", "1-3 volte", "4 o più volte"]'::jsonb, 6, true, 'Controllo: questionario disponibile se età > 70');

END $$;

-- Update existing assessment sessions to use new template structure (optional)
-- Clean existing sessions that may reference old templates
DELETE FROM public.assessment_sessions WHERE questionnaire_type NOT IN (
    'dietary_diary', 'must', 'nrs_2002', 'nutritional_risk_assessment', 
    'esas', 'sf12', 'sarc_f'
);