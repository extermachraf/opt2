-- Location: supabase/migrations/20251212190000_fix_falsi_miti_quiz_explanations_complete.sql
-- Schema Analysis: Existing quiz system with quiz_templates, quiz_questions, quiz_attempts tables
-- Integration Type: Update existing quiz_questions to add missing explanations
-- Dependencies: Modifies existing public.quiz_questions table for Falsi Miti category

-- Update Falsi Miti quiz questions with comprehensive Italian explanations
UPDATE public.quiz_questions 
SET explanation = CASE 
    WHEN question_text LIKE '%carboidrati%funzione principale%' THEN
        'I carboidrati sono la principale fonte di energia per il nostro corpo. Vengono rapidamente convertiti in glucosio, che fornisce energia immediata per il cervello, i muscoli e tutti gli organi. Mentre le proteine riparano i tessuti e i grassi forniscono energia a lungo termine, i carboidrati sono essenziali per il funzionamento quotidiano del corpo.'
        
    WHEN question_text LIKE '%macronutriente%più calorie%grammo%' THEN
        'I grassi forniscono 9 calorie per grammo, più del doppio rispetto ai carboidrati e alle proteine che forniscono entrambi 4 calorie per grammo. Questo è il motivo per cui i grassi sono una fonte di energia molto concentrata e devono essere consumati con moderazione in una dieta equilibrata.'
        
    WHEN question_text LIKE '%vitamine liposolubili%' THEN
        'Le vitamine liposolubili sono A, D, E e e K. Queste vitamine vengono assorbite insieme ai grassi alimentari e possono essere immagazzinate nel tessuto adiposo del corpo. A differenza delle vitamine idrosolubili (come la vitamina C e le vitamine del gruppo B), le liposolubili non vengono eliminate rapidamente dal corpo.'
        
    WHEN question_text LIKE '%fibra%beneficio principale%' THEN
        'La fibra alimentare migliora significativamente la digestione rallentando l''assorbimento dei nutrienti, aumentando il senso di sazietà e favorendo la regolarità intestinale. Inoltre, la fibra aiuta a controllare i livelli di colesterolo e glucosio nel sangue, contribuendo alla salute cardiovascolare e metabolica.'
        
    WHEN question_text LIKE '%acqua%percentuale%corpo umano%' THEN
        'Il corpo umano adulto è composto per circa il 60% di acqua. Questa percentuale può variare leggermente in base all''età, al sesso e alla composizione corporea, ma l''acqua rappresenta la componente principale del nostro organismo, essenziale per tutti i processi vitali.'
        
    WHEN question_text LIKE '%proteina completa%contiene%' THEN
        'Una proteina completa contiene tutti e 9 gli aminoacidi essenziali in proporzioni adeguate per le esigenze del corpo umano. Gli aminoacidi essenziali non possono essere prodotti dal nostro organismo e devono essere ottenuti attraverso l''alimentazione. Le proteine animali sono generalmente complete, mentre quelle vegetali spesso necessitano di essere combinate.'
        
    WHEN question_text LIKE '%antiossidanti%funzione%' THEN
        'Gli antiossidanti proteggono le cellule dai danni causati dai radicali liberi, molecole instabili che possono danneggiare il DNA e accelerare l''invecchiamento. Gli antiossidanti neutralizzano questi radicali liberi, riducendo il rischio di malattie croniche come cancro, malattie cardiache e disturbi neurodegenerativi.'
        
    WHEN question_text LIKE '%metabolismo basale%' THEN
        'Il metabolismo basale rappresenta l''energia minima necessaria per mantenere le funzioni vitali del corpo a riposo, come la respirazione, la circolazione sanguigna, la produzione cellulare e la regolazione della temperatura. Rappresenta circa il 60-70% del dispendio energetico totale giornaliero nella maggior parte delle persone.'
        
    WHEN question_text LIKE '%indice glicemico%misura%' THEN
        'L''indice glicemico misura la velocità con cui un alimento contenente carboidrati aumenta i livelli di glucosio nel sangue rispetto al glucosio puro (IG = 100). Gli alimenti ad alto indice glicemico causano picchi rapidi di glicemia, mentre quelli a basso indice glicemico provocano aumenti più graduali e sostenuti.'
        
    WHEN question_text LIKE '%omega-3%beneficio%' THEN
        'Gli acidi grassi omega-3 sono essenziali per la salute cardiovascolare, riducendo l''infiammazione, migliorando la funzione cardiaca e diminuendo il rischio di aritmie. Inoltre, sono fondamentali per la salute del cervello, la funzione cognitiva e lo sviluppo del sistema nervoso, particolarmente importante durante la gravidanza e l''infanzia.'
        
    -- Falsi Miti Nutritional Myths Questions
    WHEN question_text LIKE '%carboidrati%fanno ingrassare%' OR question_text LIKE '%carboidrati%sempre%evitare%' THEN
        'FALSO: I carboidrati non fanno automaticamente ingrassare. L''aumento di peso dipende dall''eccesso calorico totale, non da un singolo macronutriente. I carboidrati complessi (cereali integrali, legumi) sono essenziali per l''energia e dovrebbero rappresentare il 45-65% delle calorie giornaliere. È la qualità e la quantità che conta.'
        
    WHEN question_text LIKE '%saltare%colazione%aiuta%dimagrire%' OR question_text LIKE '%saltare%pasti%dimagrire%' THEN
        'FALSO: Saltare la colazione può portare a maggiore fame durante il giorno e scelte alimentari poco salutari. La ricerca mostra che chi fa colazione regolarmente ha un BMI più basso e migliori abitudini alimentari. È meglio distribuire le calorie nell''arco della giornata per mantenere stabili i livelli di energia e glicemia.'
        
    WHEN question_text LIKE '%grassi%completamente%eliminati%dieta%' OR question_text LIKE '%dieta%senza%grassi%' THEN
        'FALSO: I grassi sono essenziali per la salute. Forniscono acidi grassi essenziali, aiutano l''assorbimento delle vitamine liposolubili (A, D, E, K) e sono necessari per la produzione di ormoni. Il 20-35% delle calorie dovrebbe provenire da grassi salutari come olio d''oliva, noci, pesce e avocado.'
        
    WHEN question_text LIKE '%detox%necessarie%purificare%corpo%' OR question_text LIKE '%diete%detox%' THEN
        'FALSO: Il corpo ha già sistemi naturali di disintossicazione molto efficaci: fegato, reni, polmoni e intestino. Non esistono evidenze scientifiche che le diete "detox" o i "cleanse" migliorino questi processi naturali. Una dieta equilibrata e ricca di frutta e verdura supporta naturalmente la disintossicazione.'
        
    WHEN question_text LIKE '%proteine%vegetali%incomplete%' OR question_text LIKE '%proteine%solo%carne%' THEN
        'FALSO: Molte proteine vegetali possono fornire tutti gli aminoacidi essenziali. Legumi, quinoa, semi di chia, e la combinazione di cereali e legumi forniscono proteine complete. Con una dieta vegetale varia è possibile soddisfare facilmente il fabbisogno proteico senza carenze.'
        
    WHEN question_text LIKE '%frutta%troppo%zucchero%evitare%' OR question_text LIKE '%frutta%fa%male%' THEN
        'FALSO: La frutta contiene zuccheri naturali insieme a fibre, vitamine, minerali e antiossidanti. Le fibre rallentano l''assorbimento degli zuccheri, evitando picchi glicemici. L''OMS raccomanda 5 porzioni al giorno di frutta e verdura. È molto diverso dal consumo di zuccheri aggiunti o raffinati.'
        
    WHEN question_text LIKE '%glutine%dannoso%tutti%' OR question_text LIKE '%tutti%dovrebbero%evitare%glutine%' THEN
        'FALSO: Il glutine è dannoso solo per persone con celiachia (1% della popolazione) o sensibilità al glutine non celiaca. Per la maggior parte delle persone, gli alimenti contenenti glutine come cereali integrali fanno parte di una dieta sana. Eliminare il glutine senza necessità medica può portare a carenze nutrizionali.'
        
    WHEN question_text LIKE '%mangiare%dopo%18%fa%ingrassare%' OR question_text LIKE '%non%mangiare%sera%' THEN
        'FALSO: L''orario dei pasti non influisce direttamente sull''aumento di peso. Ciò che conta è il bilancio calorico totale giornaliero. Mangiare di sera può essere problematico solo se porta a un eccesso calorico o interferisce con il sonno. Una cena leggera e bilanciata 2-3 ore prima di dormire è perfettamente salutare.'
        
    WHEN question_text LIKE '%prodotti%light%sempre%più%sani%' OR question_text LIKE '%light%automaticamente%salutare%' THEN
        'FALSO: I prodotti "light" possono essere ridotti in grassi o zuccheri ma spesso contengono additivi, dolcificanti artificiali o più sodio per mantenere il sapore. "Light" non significa automaticamente più salutare. È importante leggere sempre l''etichetta nutrizionale completa e la lista degli ingredienti.'
        
    WHEN question_text LIKE '%bere%molta%acqua%fa%dimagrire%' OR question_text LIKE '%acqua%brucia%grassi%' THEN
        'PARZIALMENTE FALSO: L''acqua non brucia grassi direttamente, ma può aiutare indirettamente nella perdita di peso aumentando il senso di sazietà, migliorando il metabolismo e sostituendo bevande caloriche. Bere acqua prima dei pasti può ridurre l''appetito. È importante per la salute generale, ma non è una soluzione magica per dimagrire.'
        
    ELSE 'La spiegazione nutrizionale è importante per comprendere i principi di una alimentazione equilibrata e basata su evidenze scientifiche.'
END
WHERE template_id IN (
    SELECT id FROM public.quiz_templates 
    WHERE category = 'false_myths'::public.quiz_category
)
AND (explanation IS NULL OR explanation = '');

-- Verify the update worked by checking how many records were updated
DO $$
DECLARE
    updated_count INTEGER;
    null_count INTEGER;
BEGIN
    -- Count updated records
    SELECT COUNT(*) INTO updated_count
    FROM public.quiz_questions qq
    JOIN public.quiz_templates qt ON qq.template_id = qt.id
    WHERE qt.category = 'false_myths'::public.quiz_category
    AND qq.explanation IS NOT NULL 
    AND qq.explanation != '';
    
    -- Count remaining null explanations
    SELECT COUNT(*) INTO null_count
    FROM public.quiz_questions qq
    JOIN public.quiz_templates qt ON qq.template_id = qt.id
    WHERE qt.category = 'false_myths'::public.quiz_category
    AND (qq.explanation IS NULL OR qq.explanation = '');
    
    RAISE NOTICE 'Falsi Miti Quiz Update Complete:';
    RAISE NOTICE '  - Updated questions with explanations: %', updated_count;
    RAISE NOTICE '  - Remaining questions without explanations: %', null_count;
    
    IF null_count > 0 THEN
        RAISE NOTICE 'Warning: Some Falsi Miti questions still have null explanations. Manual review may be needed.';
    ELSE
        RAISE NOTICE 'Success: All Falsi Miti quiz questions now have explanations!';
    END IF;
END $$;