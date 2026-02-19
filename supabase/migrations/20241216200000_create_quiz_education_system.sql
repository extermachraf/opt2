-- Location: supabase/migrations/20241216200000_create_quiz_education_system.sql
-- Schema Analysis: Existing schema has questionnaire system for medical assessments
-- Integration Type: Addition - New educational quiz system separate from medical questionnaires
-- Dependencies: References existing user_profiles table

-- Create enum types for quiz system
CREATE TYPE public.quiz_category AS ENUM ('false_myths', 'topic_based');
CREATE TYPE public.quiz_topic AS ENUM (
    'alimenti_nutrienti_supplementi', 
    'nutrizione_terapie_oncologiche', 
    'cosa_fare_prima_terapia',
    'mangiare_sano_salute'
);

-- Main quiz templates table
CREATE TABLE public.quiz_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    category public.quiz_category NOT NULL,
    topic public.quiz_topic,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Quiz questions table
CREATE TABLE public.quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID REFERENCES public.quiz_templates(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of answer options ["A", "B", "C", "D"]
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    topic_id TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User quiz attempts table (to track user progress)
CREATE TABLE public.quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.quiz_templates(id) ON DELETE CASCADE,
    score INTEGER DEFAULT 0,
    total_questions INTEGER DEFAULT 0,
    percentage INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    answers JSONB -- Store user answers and details
);

-- Indexes for performance
CREATE INDEX idx_quiz_questions_template_id ON public.quiz_questions(template_id);
CREATE INDEX idx_quiz_questions_template_order ON public.quiz_questions(template_id, order_index);
CREATE INDEX idx_quiz_attempts_user_id ON public.quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_template_id ON public.quiz_attempts(template_id);
CREATE INDEX idx_quiz_templates_category ON public.quiz_templates(category);
CREATE INDEX idx_quiz_templates_topic ON public.quiz_templates(topic);

-- Enable RLS
ALTER TABLE public.quiz_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

-- RLS Policies using Pattern 4: Public Read, Private Write for quiz content
-- Quiz templates and questions should be publicly readable but only manageable by admins
CREATE POLICY "public_can_read_quiz_templates"
ON public.quiz_templates
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "public_can_read_quiz_questions"
ON public.quiz_questions
FOR SELECT
TO public
USING (true);

-- User quiz attempts use Pattern 2: Simple User Ownership
CREATE POLICY "users_manage_own_quiz_attempts"
ON public.quiz_attempts
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION public.update_quiz_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Triggers for timestamp updates
CREATE TRIGGER update_quiz_templates_updated_at
    BEFORE UPDATE ON public.quiz_templates
    FOR EACH ROW EXECUTE FUNCTION public.update_quiz_updated_at();

CREATE TRIGGER update_quiz_questions_updated_at
    BEFORE UPDATE ON public.quiz_questions
    FOR EACH ROW EXECUTE FUNCTION public.update_quiz_updated_at();

-- Insert quiz templates and all 35 new questions
DO $$
DECLARE
    false_myths_template_id UUID := gen_random_uuid();
    topic1_template_id UUID := gen_random_uuid(); -- Alimenti, nutrienti, supplementi nutrizionali orali, nutraceutici
    topic2_template_id UUID := gen_random_uuid(); -- Nutrizione durante le terapie oncologiche
    topic3_template_id UUID := gen_random_uuid(); -- Che cosa fare prima e in corso di terapia
    topic4_template_id UUID := gen_random_uuid(); -- Mangiare sano per mantenersi in salute
BEGIN
    -- Insert quiz templates
    INSERT INTO public.quiz_templates (id, title, category, topic, description) VALUES
        (false_myths_template_id, 'Quiz Falsi Miti', 'false_myths'::public.quiz_category, NULL, 'Quiz sui falsi miti della nutrizione oncologica'),
        (topic1_template_id, 'Alimenti, nutrienti, supplementi nutrizionali orali, nutraceutici', 'topic_based'::public.quiz_category, 'alimenti_nutrienti_supplementi'::public.quiz_topic, 'Quiz su alimenti, nutrienti e supplementi'),
        (topic2_template_id, 'Nutrizione durante le terapie oncologiche', 'topic_based'::public.quiz_category, 'nutrizione_terapie_oncologiche'::public.quiz_topic, 'Quiz sulla nutrizione durante le terapie'),
        (topic3_template_id, 'Che cosa fare prima e in corso di terapia', 'topic_based'::public.quiz_category, 'cosa_fare_prima_terapia'::public.quiz_topic, 'Quiz su cosa fare prima e durante la terapia'),
        (topic4_template_id, 'Mangiare sano per mantenersi in salute', 'topic_based'::public.quiz_category, 'mangiare_sano_salute'::public.quiz_topic, 'Quiz su come mangiare sano per la salute');

    -- Insert False Myths Questions (existing questions)
    INSERT INTO public.quiz_questions (template_id, question_text, options, correct_answer, explanation, topic_id, order_index) VALUES
        (false_myths_template_id, 'I ''supercibi'' prevengono i tumori?', '["Vero", "Falso"]'::jsonb, 'Falso', 'Nonostante possiedano proprietà salutari per l''organismo, i ''supercibi'' non sono in grado di prevenire l''insorgenza di un tumore. L''importante è seguire un''alimentazione varia e bilanciata.', '1.0', 1),
        (false_myths_template_id, 'Gli alimenti processati e ultraprocessati sono pericolosi per la salute?', '["Vero", "Falso"]'::jsonb, 'Vero', 'Gli alimenti processati, se consumati con moderazione, non sono pericolosi. Gli alimenti ultraprocessati, invece, possono aumentare il rischio di sviluppare malattie come tumori, diabete di tipo 2 e disturbi cardiovascolari.', '2.0', 2),
        (false_myths_template_id, 'Esistono cibi che possono ridurre gli effetti indesiderati delle terapie antitumorali?', '["Vero", "Falso"]'::jsonb, 'Falso', 'Non esistono cibi in grado di ridurre gli effetti collaterali delle terapie antitumorali. Tuttavia, un paziente ben nutrito sopporta meglio gli effetti collaterali rispetto a un paziente malnutrito.', '3.0', 3),
        (false_myths_template_id, 'Esiste una dieta anti-tumore?', '["Vero", "Falso"]'::jsonb, 'Falso', 'Non esiste una dieta specifica per prevenire lo sviluppo di un tumore. È importante mantenere un''alimentazione sana ed equilibrata.', '4.0', 4),
        (false_myths_template_id, 'Una dieta ''acida'' provoca l''insorgenza di un tumore?', '["Vero", "Falso"]'::jsonb, 'Falso', 'I cibi non possono influenzare il livello di acidità del corpo. Il nostro organismo regola da solo il tasso di acidità di cui necessita.', '5.0', 5),
        (false_myths_template_id, 'La dieta alcalina può prevenire/combattere un tumore?', '["Vero", "Falso"]'::jsonb, 'Falso', 'Con la sola alimentazione non si può modificare l''acidità dei tessuti di cui è composto il nostro corpo.', '6.0', 6),
        (false_myths_template_id, 'Gli acidi grassi omega-3 contenuti nel pesce aiutano a combattere un tumore?', '["Vero", "Falso"]'::jsonb, 'Falso', 'Gli acidi grassi omega-3 hanno importanti effetti antinfiammatori e sono utili a prevenire la perdita di peso e di appetito, ma non aiutano a combattere la malattia.', '7.0', 7),
        (false_myths_template_id, 'Esiste un rapporto tra vitamine e tumore?', '["Vero", "Falso"]'::jsonb, 'Vero', 'Le cellule tumorali utilizzano gli stessi principi nutritivi delle cellule normali. In alcune condizioni di malattia, l''assunzione di integratori vitaminici può essere necessaria per prevenire le carenze.', '8.0', 8),
        (false_myths_template_id, 'Assumere alimenti dolci fa crescere il tumore?', '["Vero", "Falso"]'::jsonb, 'Falso', 'Non esiste evidenza diretta che assumere alimenti dolci faccia crescere il tumore. Tuttavia, è importante evitare di mantenere elevati livelli ematici di insulina, che possono favorire la crescita delle cellule neoplastiche.', '9.0', 9),
        (false_myths_template_id, 'La carne rossa fa male e provoca il tumore?', '["Vero", "Falso"]'::jsonb, 'Falso', 'La carne rossa non è un alimento da demonizzare in una dieta sana. È importante consumarla con moderazione e cuocerla in modo corretto.', '10.0', 10);

    -- Topic 1: Alimenti, nutrienti, supplementi nutrizionali orali, nutraceutici (10 questions)
    INSERT INTO public.quiz_questions (template_id, question_text, options, correct_answer, topic_id, order_index) VALUES
        (topic1_template_id, 'Qual è la funzione principale dei carboidrati?', '["Fornire energia", "Riparare i tessuti", "Favorire la digestione", "Trasportare ossigeno"]'::jsonb, 'Fornire energia', '1.1', 1),
        (topic1_template_id, 'Quale macronutriente fornisce più calorie per grammo?', '["Proteine", "Carboidrati", "Grassi", "Fibre"]'::jsonb, 'Grassi', '1.2', 2),
        (topic1_template_id, 'Quale tra questi alimenti è una fonte di proteine a più alto valore biologico?', '["Lenticchie", "Pasta integrale", "Olio d''oliva", "Yogurt"]'::jsonb, 'Yogurt', '1.3', 3),
        (topic1_template_id, 'Le vitamine liposolubili si trovano principalmente in:', '["Frutta secca e verdure grasse", "Alimenti grassi ricchi di grassi (es. olio, burro)", "Zuccheri semplici", "Cereali raffinati"]'::jsonb, 'Alimenti grassi ricchi di grassi (es. olio, burro)', '1.4', 4),
        (topic1_template_id, 'Qual è il ruolo delle proteine nell''organismo?', '["Regolare la temperatura", "Fornire energia a lungo termine", "Costruire e riparare i tessuti", "Stimolare la digestione"]'::jsonb, 'Costruire e riparare i tessuti', '1.5', 5),
        (topic1_template_id, 'Quale vitamina è essenziale per l''assorbimento del calcio?', '["Vitamina A", "Vitamina C", "Vitamina D", "Vitamina K"]'::jsonb, 'Vitamina D', '1.6', 6),
        (topic1_template_id, 'Gli omega-3 sono particolarmente abbondanti in:', '["Carne rossa", "Pesce azzurro", "Cereali integrali", "Legumi"]'::jsonb, 'Pesce azzurro', '1.7', 7),
        (topic1_template_id, 'Quale minerale è fondamentale per il trasporto dell''ossigeno nel sangue?', '["Calcio", "Ferro", "Magnesio", "Zinco"]'::jsonb, 'Ferro', '1.8', 8),
        (topic1_template_id, 'I supplementi nutrizionali orali sono indicati quando:', '["Si vuole perdere peso rapidamente", "C''è una carenza nutrizionale diagnosticata", "Si fa molto sport", "Si vuole aumentare la massa muscolare"]'::jsonb, 'C''è una carenza nutrizionale diagnosticata', '1.9', 9),
        (topic1_template_id, 'Cosa sono i nutraceutici?', '["Farmaci per dimagrire", "Alimenti con proprietà benefiche per la salute", "Integratori vitaminici", "Prodotti per sportivi"]'::jsonb, 'Alimenti con proprietà benefiche per la salute', '1.10', 10);

    -- Topic 2: Nutrizione durante le terapie oncologiche (10 questions)
    INSERT INTO public.quiz_questions (template_id, question_text, options, correct_answer, topic_id, order_index) VALUES
        (topic2_template_id, 'Perché è importante affrontare l''intervento chirurgico in uno stato di nutrizione ottimale?', '["Riduce il rischio di complicanze postoperatorie", "Aumenta il rischio di complicanze postoperatorie", "Non ha alcuna importanza", "Riduce il tempo di recupero"]'::jsonb, 'Riduce il rischio di complicanze postoperatorie', '2.1', 1),
        (topic2_template_id, 'Cosa fare per attenuare il bruciore alla bocca durante le terapie?', '["Evitare di bere liquidi", "Mangiare cibi molto salati", "Bere molti liquidi nutrienti", "Mangiare cibi ruvidi"]'::jsonb, 'Bere molti liquidi nutrienti', '2.2', 2),
        (topic2_template_id, 'Quali cibi sono da evitare se la bocca è secca?', '["Dolci e cioccolato", "Frutta fresca", "Verdure cotte", "Carne bianca"]'::jsonb, 'Dolci e cioccolato', '2.3', 3),
        (topic2_template_id, 'Durante la chemioterapia, quale problema alimentare è più comune?', '["Aumento dell''appetito", "Perdita del gusto", "Voglia di cibi piccanti", "Aumento di peso"]'::jsonb, 'Perdita del gusto', '2.4', 4),
        (topic2_template_id, 'Per combattere la nausea durante le terapie è consigliabile:', '["Mangiare pasti abbondanti", "Bere molto durante i pasti", "Fare pasti piccoli e frequenti", "Evitare completamente i liquidi"]'::jsonb, 'Fare pasti piccoli e frequenti', '2.5', 5),
        (topic2_template_id, 'Quale tipo di cottura è preferibile durante le terapie oncologiche?', '["Frittura", "Cottura al vapore", "Grigliatura", "Cottura alla brace"]'::jsonb, 'Cottura al vapore', '2.6', 6),
        (topic2_template_id, 'In caso di diarrea durante le terapie, è consigliabile:', '["Aumentare le fibre", "Ridurre i liquidi", "Evitare latticini", "Mangiare più frutta"]'::jsonb, 'Evitare latticini', '2.7', 7),
        (topic2_template_id, 'La perdita di peso durante le terapie oncologiche:', '["È sempre positiva", "Può compromettere l''efficacia delle cure", "Non ha importanza", "Accelera la guarigione"]'::jsonb, 'Può compromettere l''efficacia delle cure', '2.8', 8),
        (topic2_template_id, 'Durante la radioterapia alla zona addominale, è importante:', '["Mangiare cibi ricchi di fibre", "Ridurre l''apporto di liquidi", "Evitare cibi che causano gas", "Aumentare i grassi"]'::jsonb, 'Evitare cibi che causano gas', '2.9', 9),
        (topic2_template_id, 'Gli integratori proteici durante le terapie oncologiche:', '["Sono sempre necessari", "Devono essere prescritti dal medico", "Sono inutili", "Si possono assumere liberamente"]'::jsonb, 'Devono essere prescritti dal medico', '2.10', 10);

    -- Topic 3: Che cosa fare prima e in corso di terapia (10 questions)
    INSERT INTO public.quiz_questions (template_id, question_text, options, correct_answer, topic_id, order_index) VALUES
        (topic3_template_id, 'Prima di iniziare le terapie oncologiche è importante:', '["Iniziare una dieta dimagrante", "Valutare lo stato nutrizionale", "Eliminare tutti i carboidrati", "Assumere molti integratori"]'::jsonb, 'Valutare lo stato nutrizionale', '3.1', 1),
        (topic3_template_id, 'Durante le terapie, l''idratazione dovrebbe essere:', '["Ridotta al minimo", "Normale", "Aumentata se tollerata", "Solo attraverso cibi solidi"]'::jsonb, 'Aumentata se tollerata', '3.2', 2),
        (topic3_template_id, 'Il peso corporeo durante le terapie oncologiche:', '["Deve essere monitorato regolarmente", "Non è importante", "Deve sempre diminuire", "Deve sempre aumentare"]'::jsonb, 'Deve essere monitorato regolarmente', '3.3', 3),
        (topic3_template_id, 'In caso di difficoltà nella deglutizione, è consigliabile:', '["Forzare l''alimentazione normale", "Modificare la consistenza dei cibi", "Saltare i pasti", "Bere solo liquidi"]'::jsonb, 'Modificare la consistenza dei cibi', '3.4', 4),
        (topic3_template_id, 'L''attività fisica durante le terapie oncologiche:', '["È sempre vietata", "Può aiutare a mantenere l''appetito", "Deve essere intensa", "Non ha alcun beneficio"]'::jsonb, 'Può aiutare a mantenere l''appetito', '3.5', 5),
        (topic3_template_id, 'La consulenza nutrizionale durante le terapie oncologiche:', '["È inutile", "È utile solo per i pazienti obesi", "È importante per tutti i pazienti", "È necessaria solo dopo le terapie"]'::jsonb, 'È importante per tutti i pazienti', '3.6', 6),
        (topic3_template_id, 'Prima di un ciclo di chemioterapia è consigliabile:', '["Digiunare completamente", "Mangiare normalmente", "Bere molta acqua", "Assumere solo liquidi"]'::jsonb, 'Mangiare normalmente', '3.7', 7),
        (topic3_template_id, 'Durante le terapie, i pasti dovrebbero essere:', '["Molto abbondanti", "Piccoli e frequenti", "Solo una volta al giorno", "Ricchi di grassi"]'::jsonb, 'Piccoli e frequenti', '3.8', 8),
        (topic3_template_id, 'L''igiene alimentare durante le terapie oncologiche:', '["Non è importante", "È fondamentale per evitare infezioni", "È necessaria solo in ospedale", "Riguarda solo i latticini"]'::jsonb, 'È fondamentale per evitare infezioni', '3.9', 9),
        (topic3_template_id, 'Il supporto psicologico durante le terapie:', '["Non influisce sull''alimentazione", "Può migliorare l''approccio al cibo", "È inutile", "Peggiora l''appetito"]'::jsonb, 'Può migliorare l''approccio al cibo', '3.10', 10);

    -- Topic 4: Mangiare sano per mantenersi in salute (5 questions)
    INSERT INTO public.quiz_questions (template_id, question_text, options, correct_answer, topic_id, order_index) VALUES
        (topic4_template_id, 'Una dieta sana per mantenersi in salute dovrebbe includere:', '["Solo proteine animali", "Una varietà di alimenti", "Solo carboidrati", "Solo grassi"]'::jsonb, 'Una varietà di alimenti', '4.1', 1),
        (topic4_template_id, 'Quante porzioni di frutta e verdura sono consigliate al giorno?', '["1-2 porzioni", "3-4 porzioni", "5 o più porzioni", "Non sono necessarie"]'::jsonb, '5 o più porzioni', '4.2', 2),
        (topic4_template_id, 'L''attività fisica regolare:', '["Non influisce sulla salute nutrizionale", "Migliora l''utilizzo dei nutrienti", "È dannosa per la digestione", "Riduce l''assorbimento dei nutrienti"]'::jsonb, 'Migliora l''utilizzo dei nutrienti', '4.3', 3),
        (topic4_template_id, 'Il consumo di alcol per mantenersi in salute dovrebbe essere:', '["Illimitato", "Moderato o nullo", "Solo vino rosso", "Solo durante i pasti"]'::jsonb, 'Moderato o nullo', '4.4', 4),
        (topic4_template_id, 'Per mantenere un peso sano è importante:', '["Saltare i pasti", "Bilanciare calorie assunte e consumate", "Eliminare tutti i grassi", "Mangiare solo proteine"]'::jsonb, 'Bilanciare calorie assunte e consumate', '4.5', 5);

END $$;