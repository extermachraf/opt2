-- Migration: Add 8 new Falsi Miti quiz questions to existing template
-- The "Quiz Falsi Miti" template already exists with ID: 631d25b9-a6c2-4df4-b23e-880c3b07280a
-- Adding the remaining 8 questions from the user's Excel file to complete the 10-question quiz

-- Insert the 8 new questions for Falsi Miti quiz
INSERT INTO public.quiz_questions (
    template_id,
    question_text,
    options,
    correct_answer,
    explanation,
    order_index,
    topic_id
) VALUES
-- Question 3 (existing order_index 1 and 2 already exist)
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Esistono cibi che possono ridurre gli effetti indesiderati delle terapie antitumorali?',
    '["Vero","Falso"]',
    'Falso',
    'Non esistono alimenti specifici in grado di ridurre gli effetti collaterali delle terapie antitumorali. Tuttavia, mantenere un''alimentazione equilibrata e uno stato nutrizionale ottimale aiuta il paziente a tollerare meglio i trattamenti e a recuperare più rapidamente. È importante seguire le indicazioni del team medico riguardo l''alimentazione durante le terapie.',
    3,
    '3'
),
-- Question 4
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Esiste una dieta anti-tumore?',
    '["Vero","Falso"]',
    'Falso',
    'Non esiste una dieta specifica "anti-tumore" scientificamente provata. Quello che conta è seguire un''alimentazione sana, variata ed equilibrata, come la dieta mediterranea, che può contribuire alla prevenzione generale delle malattie. Durante il trattamento oncologico, l''obiettivo principale è mantenere un adeguato stato nutrizionale per supportare il corpo durante le terapie.',
    4,
    '4'
),
-- Question 5
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Una dieta acida provoca il tumore?',
    '["Vero","Falso"]',
    'Falso',
    'Gli alimenti non possono alterare significativamente il pH del sangue, che è finemente regolato dai meccanismi fisiologici dell''organismo. Il corpo umano mantiene automaticamente un equilibrio acido-base costante. Non esistono prove scientifiche che collegano una dieta "acida" allo sviluppo di tumori. È importante concentrarsi su una dieta equilibrata piuttosto che su teorie non supportate da evidenze.',
    5,
    '5'
),
-- Question 6
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Gli omega-3 del pesce combattono il tumore?',
    '["Vero","Falso"]',
    'Falso',
    'Sebbene gli acidi grassi omega-3 presenti nel pesce abbiano proprietà antinfiammatorie benefiche e possano aiutare a prevenire la perdita di peso nei pazienti oncologici, non esistono prove scientifiche dirette di un effetto specifico contro la crescita tumorale nell''uomo. Gli omega-3 fanno parte di una dieta equilibrata ma non devono essere considerati un trattamento antitumorale.',
    6,
    '6'
),
-- Question 7
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Assumere dolci fa crescere il tumore?',
    '["Vero","Falso"]',
    'Falso',
    'Non esiste evidenza scientifica diretta che gli zuccheri facciano crescere i tumori. Tuttavia, è importante evitare picchi glicemici elevati e livelli cronicamente alti di insulina. I pazienti oncologici dovrebbero moderare il consumo di zuccheri semplici e dolci come parte di una dieta equilibrata, ma non devono eliminarli completamente se consumati con moderazione.',
    7,
    '7'
),
-- Question 8
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'La carne rossa provoca il tumore?',
    '["Vero","Falso"]',
    'Falso',
    'La carne rossa, se consumata con moderazione (non più di 500 grammi alla settimana) e cotta in modo appropriato, non rappresenta un fattore di rischio significativo. Il problema sorge con il consumo eccessivo e con le carni processate o conservate, che dovrebbero essere limitate. È importante variare le fonti proteiche nella dieta includendo pesce, legumi e carni bianche.',
    8,
    '8'
),
-- Question 9
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Conviene diventare vegetariani per curare i tumori?',
    '["Vero","Falso"]',
    'Falso',
    'Una dieta vegetariana o vegana non è indicata come trattamento per i tumori. I pazienti oncologici hanno bisogno di un adeguato apporto di proteine e calorie, che può includere anche fonti animali. La scelta di seguire una dieta vegetariana deve essere ben pianificata con un nutrizionista per evitare carenze nutrizionali, specialmente durante i trattamenti che richiedono un maggiore fabbisogno energetico e proteico.',
    9,
    '9'
),
-- Question 10
(
    '631d25b9-a6c2-4df4-b23e-880c3b07280a',
    'Le vitamine prevengono i tumori?',
    '["Vero","Falso"]',
    'Falso',
    'Non esistono prove che l''assunzione di vitamine attraverso integratori prevenga i tumori. Le vitamine sono essenziali per il corretto funzionamento dell''organismo, ma è preferibile assumerle attraverso una dieta varia ed equilibrata piuttosto che tramite supplementi. L''uso di integratori vitaminici dovrebbe sempre essere discusso con il medico, poiché alcuni potrebbero interferire con le terapie oncologiche.',
    10,
    '10'
);

-- Update the quiz template to reflect the correct number of questions
-- (Optional: This helps maintain data consistency)
COMMENT ON TABLE quiz_questions IS 'Updated Falsi Miti quiz now contains 10 complete questions about nutritional myths';