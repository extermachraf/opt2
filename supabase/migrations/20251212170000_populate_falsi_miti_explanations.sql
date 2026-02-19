-- Location: supabase/migrations/20251212170000_populate_falsi_miti_explanations.sql
-- Schema Analysis: Complete quiz system exists with quiz_templates, quiz_questions, quiz_attempts
-- Integration Type: Data update - populate missing explanations in existing quiz questions
-- Dependencies: quiz_questions table, quiz_templates table (false_myths category)

-- Populate explanations for Falsi Miti quiz questions
UPDATE public.quiz_questions 
SET explanation = CASE 
    WHEN question_text ILIKE '%supercibi%prevengono%tumori%' THEN 
        'Non esistono ''supercibi'' miracolosi. Una dieta equilibrata e varia, ricca di frutta, verdura, cereali integrali e legumi, insieme a uno stile di vita sano, contribuisce alla prevenzione dei tumori. È importante evitare affermazioni esagerate e concentrarsi su un approccio alimentare bilanciato nel lungo periodo.'
    
    WHEN question_text ILIKE '%glutine%fa%male%tutti%' THEN 
        'Il glutine è dannoso solo per chi soffre di celiachia (circa 1% della popolazione) o sensibilità al glutine non celiaca. Per la maggior parte delle persone, i prodotti contenenti glutine come pane, pasta e cereali integrali sono parte di una dieta sana e forniscono nutrienti importanti come fibre, vitamine del gruppo B e minerali.'
    
    WHEN question_text ILIKE '%carboidrati%fanno%ingrassare%' THEN 
        'I carboidrati sono la principale fonte di energia per il corpo e il cervello. Quelli complessi (cereali integrali, legumi, verdure) forniscono energia sostenibile e nutrienti essenziali. L''aumento di peso dipende dall''eccesso calorico totale, non da un singolo macronutriente. Una dieta bilanciata include carboidrati di qualità.'
    
    WHEN question_text ILIKE '%detox%depurano%organismo%' THEN 
        'Il nostro corpo ha già un sistema di disintossicazione naturale molto efficiente: fegato, reni, polmoni e intestino. Non esistono evidenze scientifiche che le diete detox siano necessarie o efficaci. Una alimentazione varia ed equilibrata, insieme a una buona idratazione, supporta naturalmente i processi di depurazione dell''organismo.'
    
    WHEN question_text ILIKE '%frutta%sera%fa%ingrassare%' THEN 
        'Non esiste un orario ''proibito'' per mangiare la frutta. La frutta fornisce vitamine, minerali, fibre e antiossidanti importanti in qualsiasi momento della giornata. L''aumento di peso dipende dal bilancio calorico complessivo, non dal momento in cui si consuma un alimento. È consigliato consumare 2-3 porzioni di frutta al giorno.'
    
    WHEN question_text ILIKE '%grassi%sono%sempre%dannosi%' THEN 
        'I grassi sono nutrienti essenziali per l''organismo. Quelli ''buoni'' (omega-3, grassi monoinsaturi da olio d''oliva, avocado, frutta secca) sono fondamentali per la salute cardiovascolare, cerebrale e per l''assorbimento delle vitamine liposolubili. È importante limitare i grassi saturi e trans, ma non eliminare completamente i grassi dalla dieta.'
    
    WHEN question_text ILIKE '%latte%causa%infiammazioni%' THEN 
        'Il latte e i latticini sono fonti importanti di calcio, proteine e vitamine, specialmente B12 e riboflavina. Non causano infiammazioni nella popolazione generale. Solo chi ha intolleranza al lattosio o allergia alle proteine del latte dovrebbe evitarli. Per gli altri, possono far parte di una dieta equilibrata, preferendo le versioni con meno grassi saturi.'
    
    WHEN question_text ILIKE '%saltare%pasti%aiuta%dimagrire%' THEN 
        'Saltare i pasti può rallentare il metabolismo e portare a abbuffate compensatorie. È più efficace mangiare regolarmente (3 pasti principali + 1-2 spuntini) per mantenere stabili i livelli di zucchero nel sangue e l''energia. Una perdita di peso sostenibile si ottiene con una riduzione calorica moderata e costante, non con restrizioni estreme.'
    
    WHEN question_text ILIKE '%integratori%sostituiscono%dieta%' THEN 
        'Gli integratori non possono sostituire una dieta varia ed equilibrata. Gli alimenti forniscono nutrienti in forme biodisponibili insieme a fibre, antiossidanti e composti benefici che lavorano in sinergia. Gli integratori possono essere utili in casi specifici (carenze diagnosticate, gravidanza, particolari condizioni mediche) ma sempre sotto controllo medico.'
    
    WHEN question_text ILIKE '%acqua%limone%mattino%dimagrisce%' THEN 
        'Bere acqua e limone al mattino può favorire l''idratazione e fornire vitamina C, ma non ha proprietà dimagranti miracolose. La perdita di peso avviene solo con un deficit calorico sostenuto nel tempo. L''acqua e limone può essere parte di uno stile di vita sano, ma non è una soluzione magica per dimagrire. L''idratazione adeguata è comunque importante per il benessere generale.'
    
    ELSE explanation -- Keep existing explanation if not null
END
WHERE template_id IN (
    SELECT id FROM public.quiz_templates 
    WHERE category = 'false_myths'::public.quiz_category
)
AND explanation IS NULL;

-- Verify the update
DO $$
DECLARE
    updated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO updated_count 
    FROM public.quiz_questions qq
    JOIN public.quiz_templates qt ON qq.template_id = qt.id
    WHERE qt.category = 'false_myths'::public.quiz_category 
    AND qq.explanation IS NOT NULL;
    
    RAISE NOTICE 'Updated % Falsi Miti questions with explanations', updated_count;
END $$;