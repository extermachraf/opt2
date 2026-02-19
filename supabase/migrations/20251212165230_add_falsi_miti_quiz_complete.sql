-- Location: supabase/migrations/20251212165230_add_falsi_miti_quiz_complete.sql
-- Schema Analysis: Existing quiz tables (quiz_templates, quiz_questions, quiz_attempts) with proper relationships
-- Integration Type: Addition of new quiz template and questions with explanations
-- Dependencies: Existing quiz_templates, quiz_questions tables

-- Create the "Falsi Miti" quiz template
DO $$
DECLARE
    falsi_miti_template_id UUID := gen_random_uuid();
BEGIN
    -- Insert the Falsi Miti quiz template
    INSERT INTO public.quiz_templates (
        id,
        title,
        category,
        topic,
        description,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        falsi_miti_template_id,
        'Quiz Falsi Miti',
        'false_myths'::public.quiz_category,
        NULL,
        'Quiz educativo per sfatare i falsi miti sulla nutrizione e il cancro',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    -- Insert all 10 questions from the user attachment with explanations
    INSERT INTO public.quiz_questions (
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
    -- Question 1
    (
        falsi_miti_template_id,
        'I ''supercibi'' prevengono i tumori?',
        '["Vero","Falso"]',
        'Falso',
        'Nonostante alcuni alimenti abbiano proprietà benefiche, nessun singolo alimento può prevenire completamente i tumori. È importante seguire una dieta equilibrata e varia piuttosto che concentrarsi su singoli ''supercibi''. La prevenzione dei tumori richiede uno stile di vita sano complessivo che include una dieta equilibrata, attività fisica regolare e l''evitare fattori di rischio noti.',
        1,
        '1',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 2  
    (
        falsi_miti_template_id,
        'Gli alimenti processati e ultraprocessati sono pericolosi per la salute?',
        '["Vero","Falso"]',
        'Vero',
        'Gli alimenti ultraprocessati sono generalmente ricchi di zuccheri aggiunti, grassi saturi, sodio e additivi, mentre sono poveri di nutrienti essenziali. Il consumo regolare di questi alimenti è associato a un maggior rischio di obesità, malattie cardiovascolari e alcuni tipi di cancro. È consigliabile limitarne il consumo e privilegiare alimenti freschi e minimamente elaborati.',
        2,
        '2',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 3
    (
        falsi_miti_template_id,
        'Esistono cibi che possono ridurre gli effetti indesiderati delle terapie antitumorali?',
        '["Vero","Falso"]',
        'Falso',
        'Non esistono alimenti specifici scientificamente provati che possano ridurre gli effetti collaterali delle terapie oncologiche. Tuttavia, mantenere uno stato nutrizionale ottimale può aiutare il corpo a tollerare meglio i trattamenti. È importante seguire le indicazioni del team medico e del nutrizionista per gestire al meglio l''alimentazione durante le terapie.',
        3,
        '3',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 4
    (
        falsi_miti_template_id,
        'Esiste una dieta anti-tumore?',
        '["Vero","Falso"]',
        'Falso',
        'Non esiste una dieta specifica ''anti-tumore'' scientificamente provata che possa curare o prevenire completamente il cancro. Tuttavia, seguire un''alimentazione sana ed equilibrata, come la dieta mediterranea, può contribuire alla prevenzione generale delle malattie. Durante i trattamenti oncologici, l''obiettivo principale è mantenere un buono stato nutrizionale.',
        4,
        '4',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 5
    (
        falsi_miti_template_id,
        'Una dieta ''acida'' provoca l''insorgenza di un tumore?',
        '["Vero","Falso"]',
        'Falso',
        'Il pH del sangue è finemente regolato dall''organismo e non può essere alterato significativamente dalla dieta. Il corpo mantiene automaticamente un equilibrio acido-base costante attraverso meccanismi fisiologici complessi. Non esistono prove scientifiche che colleghino una dieta ''acida'' allo sviluppo di tumori. È più importante concentrarsi su una dieta equilibrata e nutriente.',
        5,
        '5',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 6
    (
        falsi_miti_template_id,
        'La dieta alcalina può prevenire/combattere un tumore?',
        '["Vero","Falso"]',
        'Falso',
        'Non esistono prove scientifiche che la dieta alcalina possa prevenire o curare i tumori. Come già spiegato, il pH del corpo è strettamente controllato da meccanismi fisiologici e non può essere modificato significativamente dalla dieta. Concentrarsi su una dieta equilibrata ricca di frutta, verdura e nutrienti è più importante che cercare di modificare il pH corporeo.',
        6,
        '6',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 7
    (
        falsi_miti_template_id,
        'Gli acidi grassi omega-3 contenuti nel pesce aiutano a combattere un tumore?',
        '["Vero","Falso"]',
        'Falso',
        'Sebbene gli omega-3 abbiano proprietà antinfiammatorie benefiche e possano contribuire alla salute generale, non esistono prove conclusive che ''combattano'' direttamente i tumori. Gli omega-3 fanno parte di una dieta equilibrata e possono aiutare a mantenere lo stato nutrizionale durante i trattamenti, ma non devono essere considerati un trattamento antitumorale.',
        7,
        '7',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 8
    (
        falsi_miti_template_id,
        'Esiste un rapporto tra vitamine e tumore?',
        '["Vero","Falso"]',
        'Vero',
        'Sì, esiste una relazione tra vitamine e tumori. Alcune vitamine hanno proprietà antiossidanti che possono aiutare a proteggere le cellule dai danni. Tuttavia, è preferibile ottenere le vitamine da una dieta varia ed equilibrata piuttosto che da integratori. L''uso di supplementi vitaminici dovrebbe sempre essere discusso con il medico, poiché alcuni potrebbero interferire con le terapie oncologiche.',
        8,
        '8',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 9
    (
        falsi_miti_template_id,
        'Assumere alimenti dolci fa crescere il tumore?',
        '["Vero","Falso"]',
        'Falso',
        'Non esistono prove scientifiche dirette che gli zuccheri facciano ''crescere'' i tumori. Tuttavia, è importante mantenere una glicemia stabile e evitare picchi glicemici frequenti. I pazienti oncologici dovrebbero moderare il consumo di zuccheri semplici come parte di una dieta equilibrata, ma non è necessario eliminarli completamente se consumati con moderazione.',
        9,
        '9',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    -- Question 10
    (
        falsi_miti_template_id,
        'La carne rossa fa male e provoca il tumore?',
        '["Vero","Falso"]',
        'Falso',
        'La carne rossa, consumata con moderazione (non più di 500 grammi alla settimana) e preparata correttamente, non rappresenta un rischio significativo. Il problema sorge con il consumo eccessivo e con le carni processate, che dovrebbero essere limitate. È importante variare le fonti proteiche includendo pesce, legumi, carni bianche e altre proteine vegetali.',
        10,
        '10',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    -- Log success message
    RAISE NOTICE 'Falsi Miti quiz created successfully with template ID: %', falsi_miti_template_id;

END $$;

-- Add comment to track this migration
COMMENT ON TABLE public.quiz_templates IS 'Contains Falsi Miti quiz template with complete Italian nutritional myth questions and detailed explanations';