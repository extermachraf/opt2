-- Migration: Populate complete explanations for Falsi Miti quiz questions
-- This addresses the missing explanation issue after answer selection

-- First, let's get the template ID for Falsi Miti quiz
DO $$ 
DECLARE 
    falsi_miti_template_id UUID;
BEGIN
    -- Get the Falsi Miti template ID (should be the false_myths category)
    SELECT id INTO falsi_miti_template_id 
    FROM quiz_templates 
    WHERE category = 'false_myths' 
    AND title ILIKE '%falsi miti%' 
    LIMIT 1;
    
    -- If template doesn't exist, create it
    IF falsi_miti_template_id IS NULL THEN
        INSERT INTO quiz_templates (
            id,
            title,
            description,
            category,
            topic,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            gen_random_uuid(),
            'Falsi Miti Nutrizionali',
            'Quiz educativo sui più comuni miti e false credenze in campo nutrizionale',
            'false_myths',
            NULL,
            true,
            NOW(),
            NOW()
        ) RETURNING id INTO falsi_miti_template_id;
    END IF;

    -- Clear any existing questions for this template to avoid duplicates
    DELETE FROM quiz_questions WHERE template_id = falsi_miti_template_id;

    -- Insert the complete Falsi Miti quiz with explanations
    INSERT INTO quiz_questions (
        id,
        template_id,
        question_text,
        options,
        correct_answer,
        explanation,
        order_index,
        topic_id,
        created_at,
        updated_at
    ) VALUES 
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'La carne rossa fa male e provoca il tumore?',
        '["Vero", "Falso"]',
        'Falso',
        'La carne rossa, consumata con moderazione e come parte di una dieta equilibrata, non è intrinsecamente dannosa. Gli studi che collegano la carne rossa al cancro si riferiscono principalmente al consumo eccessivo di carni rosse lavorate (come salumi e insaccati) e a modalità di cottura ad alte temperature. Una porzione di carne rossa 2-3 volte a settimana, cotta in modo sano, può far parte di una dieta bilanciata.',
        1,
        'myth_1',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'I carboidrati fanno sempre ingrassare?',
        '["Vero", "Falso"]',
        'Falso',
        'I carboidrati sono la principale fonte di energia per il nostro organismo e non fanno ingrassare di per sé. Il problema sorge quando si consumano carboidrati raffinati in eccesso o si superano le calorie giornaliere necessarie. I carboidrati complessi (cereali integrali, legumi, verdure) sono essenziali per una dieta sana e forniscono energia duratura, fibre e micronutrienti importanti.',
        2,
        'myth_2',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'Saltare i pasti aiuta a perdere peso più velocemente?',
        '["Vero", "Falso"]',
        'Falso',
        'Saltare i pasti è controproducente per la perdita di peso. Quando si salta un pasto, il metabolismo rallenta per conservare energia e si tende a mangiare di più al pasto successivo. Inoltre, lunghi periodi senza cibo possono causare ipoglicemia, stanchezza e difficoltà di concentrazione. È meglio fare pasti regolari e bilanciati per mantenere il metabolismo attivo.',
        3,
        'myth_3',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'I grassi devono essere completamente eliminati dalla dieta?',
        '["Vero", "Falso"]',
        'Falso',
        'I grassi sono macronutrienti essenziali per il nostro organismo. Servono per l''assorbimento delle vitamine liposolubili (A, D, E, K), la produzione di ormoni e la salute delle membrane cellulari. È importante distinguere tra grassi "buoni" (omega-3, grassi monoinsaturi da olio d''oliva, avocado, noci) e grassi da limitare (grassi saturi e trans). I grassi dovrebbero rappresentare circa il 20-35% delle calorie totali.',
        4,
        'myth_4',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'La frutta fa ingrassare per via degli zuccheri?',
        '["Vero", "Falso"]',
        'Falso',
        'La frutta contiene zuccheri naturali (fruttosio) ma anche fibre, vitamine, minerali e antiossidanti preziosi. Le fibre rallentano l''assorbimento degli zuccheri, evitando picchi glicemici. La frutta è inoltre ricca di acqua e relativamente povera di calorie. Le linee guida nutrizionali raccomandano 2-3 porzioni di frutta al giorno come parte di una dieta sana.',
        5,
        'myth_5',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'I prodotti "light" o "senza zucchero" fanno sempre bene?',
        '["Vero", "Falso"]',
        'Falso',
        'I prodotti "light" o "senza zucchero" non sono automaticamente più sani. Spesso contengono dolcificanti artificiali, conservanti aggiuntivi o altri ingredienti per compensare la riduzione di zuccheri o grassi. Inoltre, possono indurre a consumarne di più pensando che siano "innocui". È sempre meglio leggere attentamente l''etichetta e preferire alimenti naturali e poco processati.',
        6,
        'myth_6',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'Mangiare dopo le 18:00 fa ingrassare?',
        '["Vero", "Falso"]',
        'Falso',
        'Non esiste un orario magico dopo il quale il cibo fa ingrassare. Ciò che conta è il bilancio energetico totale della giornata: se si consumano più calorie di quelle che si bruciano, si aumenta di peso, indipendentemente dall''orario. Tuttavia, mangiare troppo tardi può interferire con il sonno e la digestione. È meglio fare l''ultimo pasto almeno 2-3 ore prima di andare a dormire.',
        7,
        'myth_7',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'Gli integratori possono sostituire completamente una dieta varia?',
        '["Vero", "Falso"]',
        'Falso',
        'Gli integratori non possono mai sostituire completamente una dieta varia ed equilibrata. Gli alimenti forniscono non solo vitamine e minerali, ma anche fibre, antiossidanti, fitochimici e altri composti benefici che lavorano in sinergia. Gli integratori dovrebbero essere utilizzati solo quando necessario e sotto supervisione medica, per colmare specifiche carenze nutrizionali.',
        8,
        'myth_8',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'Il glutine è dannoso per tutti?',
        '["Vero", "Falso"]',
        'Falso',
        'Il glutine è dannoso solo per le persone con celiachia (circa 1% della popolazione) o con sensibilità al glutine non celiaca. Per la maggior parte delle persone, il glutine è perfettamente sicuro. I cereali contenenti glutine (frumento, orzo, segale) forniscono importanti nutrienti come fibre, vitamine del gruppo B e minerali. Eliminare il glutine senza necessità può portare a carenze nutrizionali.',
        9,
        'myth_9',
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        falsi_miti_template_id,
        'Bere molta acqua aiuta sempre a perdere peso?',
        '["Vero", "Falso"]',
        'Falso',
        'Mentre bere acqua è essenziale per la salute e può aiutare nel controllo del peso (aumentando il senso di sazietà e sostituendo bevande caloriche), da sola non fa perdere peso. La perdita di peso dipende dal creare un deficit calorico. L''acqua può supportare il processo, ma è necessario combinare una dieta equilibrata con attività fisica. Bere quantità eccessive di acqua può anche essere pericoloso.',
        10,
        'myth_10',
        NOW(),
        NOW()
    );

    RAISE NOTICE 'Successfully populated Falsi Miti quiz with 10 questions and detailed explanations';
END $$;