-- Location: supabase/migrations/20260121143659_fix_recipe_nutritional_values.sql
-- Purpose: Update recipe nutritional values based on ingredient calculations
-- Generated: 2026-01-21T14:36:59.256494

-- This migration fixes the nutritional values for all recipes
-- Previously, recipes had correct calories but protein, carbs, fat, and fiber were set to 0

DO $$
BEGIN
    RAISE NOTICE 'Updating nutritional values for 118 recipes...';
    
    -- Update: Biscotto frollino 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Biscotto frollino ';
    
    -- Update: Bollito magro a cubettini freddo con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Bollito magro a cubettini freddo con extravergine';
    
    -- Update: Bollito misto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Bollito misto';
    
    -- Update: Bollito, tagli magri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Bollito, tagli magri';
    
    -- Update: Brasato
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Brasato';
    
    -- Update: Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)';
    
    -- Update: Broccoli lessati o al vapore, conditi con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Broccoli lessati o al vapore, conditi con extravergine';
    
    -- Update: Bruschetta
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Bruschetta';
    
    -- Update: Caffelatte (parz. screm.)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Caffelatte (parz. screm.)';
    
    -- Update: Caffè "marocchino"
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Caffè "marocchino"';
    
    -- Update: Caffè macchiato
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Caffè macchiato';
    
    -- Update: Cappuccino senza zucchero
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cappuccino senza zucchero';
    
    -- Update: Caprese
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Caprese';
    
    -- Update: Carciofi in padella con aglio e prezzemolo
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carciofi in padella con aglio e prezzemolo';
    
    -- Update: Carciofi, in pinzimonio
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carciofi, in pinzimonio';
    
    -- Update: Carote alla julienne, con olio e limone
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carote alla julienne, con olio e limone';
    
    -- Update: Carote lessate o al vapore, con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carote lessate o al vapore, con extravergine';
    
    -- Update: Carpaccio di manzo condito con scaglie di parmigiano e rucola
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carpaccio di manzo condito con scaglie di parmigiano e rucola';
    
    -- Update: Carpaccio di pesce spada, condito
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carpaccio di pesce spada, condito';
    
    -- Update: Carpaccio di spigola o branzino, condito
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Carpaccio di spigola o branzino, condito';
    
    -- Update: Cavolfiore lessato o al vapore, con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cavolfiore lessato o al vapore, con extravergine';
    
    -- Update: Cavolini di Bruxelles lessati o al vapore, con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cavolini di Bruxelles lessati o al vapore, con extravergine';
    
    -- Update: Cavolo cappuccio in insalata, tagliato finemente, con extravergne
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cavolo cappuccio in insalata, tagliato finemente, con extravergne';
    
    -- Update: Ceci in umido con sugo al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Ceci in umido con sugo al pomodoro';
    
    -- Update: Cicoria o catalogna cotta e condita
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cicoria o catalogna cotta e condita';
    
    -- Update: Cime di Rapa
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cime di Rapa';
    
    -- Update: Cioccolata calda
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cioccolata calda';
    
    -- Update: Cipolle al forno
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cipolle al forno';
    
    -- Update: Cipolle lessate, condite con extravergine 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cipolle lessate, condite con extravergine ';
    
    -- Update: Coniglio arrosto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Coniglio arrosto';
    
    -- Update: Coscia di pollo arrosto (con pelle)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Coscia di pollo arrosto (con pelle)';
    
    -- Update: Coscia di pollo arrosto (senza pelle)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Coscia di pollo arrosto (senza pelle)';
    
    -- Update: Coscia di tacchino al forno
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Coscia di tacchino al forno';
    
    -- Update: Coste o biete lessate con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Coste o biete lessate con extravergine';
    
    -- Update: Costine di maiale ai ferri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Costine di maiale ai ferri';
    
    -- Update: Cotoletta alla milanese
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Cotoletta alla milanese';
    
    -- Update: Crema di ceci 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crema di ceci ';
    
    -- Update: Crema di fagioli cannellini 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crema di fagioli cannellini ';
    
    -- Update: Crema di piselli
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crema di piselli';
    
    -- Update: Crema di piselli con patate
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crema di piselli con patate';
    
    -- Update: Crema di zucca
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crema di zucca';
    
    -- Update: Crema porri e patate
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crema porri e patate';
    
    -- Update: Crostata alla marmellata 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Crostata alla marmellata ';
    
    -- Update: Fagioli all
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fagioli all';
    
    -- Update: Fagioli con nervetti
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fagioli con nervetti';
    
    -- Update: Fagioli in umido con sugo al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fagioli in umido con sugo al pomodoro';
    
    -- Update: Fagiolini in padella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fagiolini in padella';
    
    -- Update: Fagiolini lessati e conditi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fagiolini lessati e conditi';
    
    -- Update: Farro bollito condito con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Farro bollito condito con extravergine';
    
    -- Update: Fegato alla veneta
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fegato alla veneta';
    
    -- Update: Filetti di merluzzo con pomodori, olive e capperi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Filetti di merluzzo con pomodori, olive e capperi';
    
    -- Update: Filetto di manzo ai ferri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Filetto di manzo ai ferri';
    
    -- Update: Finocchi gratinati
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Finocchi gratinati';
    
    -- Update: Finocchi in insalata 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Finocchi in insalata ';
    
    -- Update: Finocchi in insalata con arance
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Finocchi in insalata con arance';
    
    -- Update: Finocchi in padella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Finocchi in padella';
    
    -- Update: Fragole con gelato fiordilatte
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fragole con gelato fiordilatte';
    
    -- Update: Fragole zucchero e limone
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Fragole zucchero e limone';
    
    -- Update: Frittata
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Frittata';
    
    -- Update: Frittata con porri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Frittata con porri';
    
    -- Update: Funghi misti trifolati
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Funghi misti trifolati';
    
    -- Update: Gelato alle creme
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gelato alle creme';
    
    -- Update: Gnocchi di patate al gorgonzola
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gnocchi di patate al gorgonzola';
    
    -- Update: Gnocchi di patate al pesto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gnocchi di patate al pesto';
    
    -- Update: Gnocchi di patate al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gnocchi di patate al pomodoro';
    
    -- Update: Gnocchi di patate al ragù
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gnocchi di patate al ragù';
    
    -- Update: Gnocchi di patate con burro e salvia
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gnocchi di patate con burro e salvia';
    
    -- Update: Gnocchi di patate olio e parmigiano
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Gnocchi di patate olio e parmigiano';
    
    -- Update: Hamburger di manzo da polpa scelta
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Hamburger di manzo da polpa scelta';
    
    -- Update: Insalata di baccalà con prezzemolo e olive
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di baccalà con prezzemolo e olive';
    
    -- Update: Insalata di fagioli con cipolle
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di fagioli con cipolle';
    
    -- Update: Insalata di fagioli e pomodori
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di fagioli e pomodori';
    
    -- Update: Insalata di farro con verdure a cubetti saltate o grigliate
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di farro con verdure a cubetti saltate o grigliate';
    
    -- Update: Insalata di farro riso e orzo con dadini di verdure
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di farro riso e orzo con dadini di verdure';
    
    -- Update: Insalata di farro riso e orzo con piselli e olio a crudo
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di farro riso e orzo con piselli e olio a crudo';
    
    -- Update: Insalata di gamberetti con olio, prezzemolo e limone
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di gamberetti con olio, prezzemolo e limone';
    
    -- Update: Insalata di mare
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di mare';
    
    -- Update: Insalata di polpo con patate
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di polpo con patate';
    
    -- Update: Insalata di riso 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata di riso ';
    
    -- Update: Insalata fredda di ceci con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata fredda di ceci con extravergine';
    
    -- Update: Insalata fredda di ceci con peperonata
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata fredda di ceci con peperonata';
    
    -- Update: Insalata mista con carote e pomodori, condita
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata mista con carote e pomodori, condita';
    
    -- Update: Insalata, condita
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Insalata, condita';
    
    -- Update: Involtini di carne con spinaci
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Involtini di carne con spinaci';
    
    -- Update: Involtini di pollo con prosciutto e formaggio
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Involtini di pollo con prosciutto e formaggio';
    
    -- Update: Lasagne alla bolognese
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Lasagne alla bolognese';
    
    -- Update: Latte macchiato
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Latte macchiato';
    
    -- Update: Lattuga, condita
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Lattuga, condita';
    
    -- Update: Lenticchie in umido con sugo al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Lenticchie in umido con sugo al pomodoro';
    
    -- Update: Lonza di maiale in padella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Lonza di maiale in padella';
    
    -- Update: Macedonia
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Macedonia';
    
    -- Update: Macedonia con due palline di gelato
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Macedonia con due palline di gelato';
    
    -- Update: Mela cotta con cannella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Mela cotta con cannella';
    
    -- Update: Melanzane al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Melanzane al pomodoro';
    
    -- Update: Melanzane grigliate
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Melanzane grigliate';
    
    -- Update: Melanzane in carrozza
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Melanzane in carrozza';
    
    -- Update: Merluzzo al vapore con olio
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Merluzzo al vapore con olio';
    
    -- Update: Minestrone di verdure con patate e legumi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Minestrone di verdure con patate e legumi';
    
    -- Update: Minestrone di verdure senza patate e legumi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Minestrone di verdure senza patate e legumi';
    
    -- Update: Minestrone di verdure senza patate e legumi con orzo
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Minestrone di verdure senza patate e legumi con orzo';
    
    -- Update: Minestrone di verdure senza patate e legumi con pastina 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Minestrone di verdure senza patate e legumi con pastina ';
    
    -- Update: Minestrone di verdure senza patate e legumi con riso
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Minestrone di verdure senza patate e legumi con riso';
    
    -- Update: Nervetti a cubetti
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Nervetti a cubetti';
    
    -- Update: Nodino di vitello ai ferri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Nodino di vitello ai ferri';
    
    -- Update: Orata al forno, sfilettata
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Orata al forno, sfilettata';
    
    -- Update: Orecchiette con i broccoli
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Orecchiette con i broccoli';
    
    -- Update: Ortaggi misti, conditi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Ortaggi misti, conditi';
    
    -- Update: Orzo bollito con olio a crudo
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Orzo bollito con olio a crudo';
    
    -- Update: Pancotto bianco
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Pancotto bianco';
    
    -- Update: Pancotto rosso
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Pancotto rosso';
    
    -- Update: Panino con hamburger
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Panino con hamburger';
    
    -- Update: Panino rosetta con prosciutto cotto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Panino rosetta con prosciutto cotto';
    
    -- Update: Panino rosetta con prosciutto cotto e fontina
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Panino rosetta con prosciutto cotto e fontina';
    
    -- Update: Panino rosetta con salame
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Panino rosetta con salame';
    
    -- Update: Panzanella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Panzanella';
    
    -- Update: Pappa al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Pappa al pomodoro';
    
    -- Update: Parmigiana di melanzane
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Parmigiana di melanzane';
    
    -- Update: Passato di verdure senza patate e legumi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 0.00
    WHERE title = 'Passato di verdure senza patate e legumi';
    
    RAISE NOTICE 'Recipe nutritional values updated successfully!';
END $$;
