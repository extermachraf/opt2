-- Location: supabase/migrations/20260121143820_fix_recipe_nutritional_values.sql
-- Purpose: Update recipe nutritional values based on ingredient calculations
-- Generated: 2026-01-21T14:38:20.681276

-- This migration fixes the nutritional values for all recipes
-- Previously, recipes had correct calories but protein, carbs, fat, and fiber were set to 0

DO $$
BEGIN
    RAISE NOTICE 'Updating nutritional values for 118 recipes...';
    
    -- Update: Biscotto frollino 
    UPDATE public.recipes
    SET 
        total_protein_g = 0.77,
        total_carbs_g = 3.29,
        total_fat_g = 0.05,
        total_fiber_g = 3.10
    WHERE title = 'Biscotto frollino ';
    
    -- Update: Bollito magro a cubettini freddo con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.07,
        total_carbs_g = 0.00,
        total_fat_g = 10.00,
        total_fiber_g = 76.80
    WHERE title = 'Bollito magro a cubettini freddo con extravergine';
    
    -- Update: Bollito misto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.08,
        total_fat_g = 0.00,
        total_fiber_g = 69.22
    WHERE title = 'Bollito misto';
    
    -- Update: Bollito, tagli magri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 75.40
    WHERE title = 'Bollito, tagli magri';
    
    -- Update: Brasato
    UPDATE public.recipes
    SET 
        total_protein_g = 0.69,
        total_carbs_g = 3.93,
        total_fat_g = 0.14,
        total_fiber_g = 50.88
    WHERE title = 'Brasato';
    
    -- Update: Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.29,
        total_carbs_g = 0.64,
        total_fat_g = 10.08,
        total_fiber_g = 48.69
    WHERE title = 'Bresaola condita (pomodorini, rucola, scaglie di grana, limone e olio)';
    
    -- Update: Broccoli lessati o al vapore, conditi con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 6.00,
        total_carbs_g = 6.20,
        total_fat_g = 10.79,
        total_fiber_g = 180.60
    WHERE title = 'Broccoli lessati o al vapore, conditi con extravergine';
    
    -- Update: Bruschetta
    UPDATE public.recipes
    SET 
        total_protein_g = 0.11,
        total_carbs_g = 0.49,
        total_fat_g = 10.09,
        total_fiber_g = 0.07
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
        total_protein_g = 1.02,
        total_carbs_g = 0.00,
        total_fat_g = 1.28,
        total_fiber_g = 0.12
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
        total_protein_g = 0.07,
        total_carbs_g = 0.14,
        total_fat_g = 10.01,
        total_fiber_g = 1.77
    WHERE title = 'Caprese';
    
    -- Update: Carciofi in padella con aglio e prezzemolo
    UPDATE public.recipes
    SET 
        total_protein_g = 5.56,
        total_carbs_g = 4.22,
        total_fat_g = 10.44,
        total_fiber_g = 174.62
    WHERE title = 'Carciofi in padella con aglio e prezzemolo';
    
    -- Update: Carciofi, in pinzimonio
    UPDATE public.recipes
    SET 
        total_protein_g = 5.40,
        total_carbs_g = 3.80,
        total_fat_g = 10.39,
        total_fiber_g = 168.00
    WHERE title = 'Carciofi, in pinzimonio';
    
    -- Update: Carote alla julienne, con olio e limone
    UPDATE public.recipes
    SET 
        total_protein_g = 2.23,
        total_carbs_g = 15.31,
        total_fat_g = 9.99,
        total_fiber_g = 187.67
    WHERE title = 'Carote alla julienne, con olio e limone';
    
    -- Update: Carote lessate o al vapore, con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 2.20,
        total_carbs_g = 15.20,
        total_fat_g = 9.99,
        total_fiber_g = 183.20
    WHERE title = 'Carote lessate o al vapore, con extravergine';
    
    -- Update: Carpaccio di manzo condito con scaglie di parmigiano e rucola
    UPDATE public.recipes
    SET 
        total_protein_g = 0.27,
        total_carbs_g = 0.25,
        total_fat_g = 10.07,
        total_fiber_g = 13.74
    WHERE title = 'Carpaccio di manzo condito con scaglie di parmigiano e rucola';
    
    -- Update: Carpaccio di pesce spada, condito
    UPDATE public.recipes
    SET 
        total_protein_g = 0.22,
        total_carbs_g = 1.77,
        total_fat_g = 10.02,
        total_fiber_g = 124.95
    WHERE title = 'Carpaccio di pesce spada, condito';
    
    -- Update: Carpaccio di spigola o branzino, condito
    UPDATE public.recipes
    SET 
        total_protein_g = 0.22,
        total_carbs_g = 1.17,
        total_fat_g = 10.02,
        total_fiber_g = 130.95
    WHERE title = 'Carpaccio di spigola o branzino, condito';
    
    -- Update: Cavolfiore lessato o al vapore, con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 6.40,
        total_carbs_g = 4.80,
        total_fat_g = 10.39,
        total_fiber_g = 181.00
    WHERE title = 'Cavolfiore lessato o al vapore, con extravergine';
    
    -- Update: Cavolini di Bruxelles lessati o al vapore, con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 8.40,
        total_carbs_g = 6.60,
        total_fat_g = 10.99,
        total_fiber_g = 171.40
    WHERE title = 'Cavolini di Bruxelles lessati o al vapore, con extravergine';
    
    -- Update: Cavolo cappuccio in insalata, tagliato finemente, con extravergne
    UPDATE public.recipes
    SET 
        total_protein_g = 0.03,
        total_carbs_g = 0.07,
        total_fat_g = 9.99,
        total_fiber_g = 4.96
    WHERE title = 'Cavolo cappuccio in insalata, tagliato finemente, con extravergne';
    
    -- Update: Ceci in umido con sugo al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 11.19,
        total_carbs_g = 2.86,
        total_fat_g = 12.48,
        total_fiber_g = 24.78
    WHERE title = 'Ceci in umido con sugo al pomodoro';
    
    -- Update: Cicoria o catalogna cotta e condita
    UPDATE public.recipes
    SET 
        total_protein_g = 3.61,
        total_carbs_g = 6.04,
        total_fat_g = 10.99,
        total_fiber_g = 180.01
    WHERE title = 'Cicoria o catalogna cotta e condita';
    
    -- Update: Cime di Rapa
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 0.00
    WHERE title = 'Cime di Rapa';
    
    -- Update: Cioccolata calda
    UPDATE public.recipes
    SET 
        total_protein_g = 1.48,
        total_carbs_g = 7.32,
        total_fat_g = 1.79,
        total_fiber_g = 0.85
    WHERE title = 'Cioccolata calda';
    
    -- Update: Cipolle al forno
    UPDATE public.recipes
    SET 
        total_protein_g = 2.04,
        total_carbs_g = 11.54,
        total_fat_g = 10.22,
        total_fiber_g = 184.99
    WHERE title = 'Cipolle al forno';
    
    -- Update: Cipolle lessate, condite con extravergine 
    UPDATE public.recipes
    SET 
        total_protein_g = 2.12,
        total_carbs_g = 11.44,
        total_fat_g = 10.21,
        total_fiber_g = 186.83
    WHERE title = 'Cipolle lessate, condite con extravergine ';
    
    -- Update: Coniglio arrosto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.04,
        total_carbs_g = 0.86,
        total_fat_g = 10.08,
        total_fiber_g = 73.35
    WHERE title = 'Coniglio arrosto';
    
    -- Update: Coscia di pollo arrosto (con pelle)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.03,
        total_carbs_g = 0.10,
        total_fat_g = 10.01,
        total_fiber_g = 75.68
    WHERE title = 'Coscia di pollo arrosto (con pelle)';
    
    -- Update: Coscia di pollo arrosto (senza pelle)
    UPDATE public.recipes
    SET 
        total_protein_g = 0.03,
        total_carbs_g = 0.10,
        total_fat_g = 10.01,
        total_fiber_g = 77.78
    WHERE title = 'Coscia di pollo arrosto (senza pelle)';
    
    -- Update: Coscia di tacchino al forno
    UPDATE public.recipes
    SET 
        total_protein_g = 0.03,
        total_carbs_g = 0.10,
        total_fat_g = 10.01,
        total_fiber_g = 0.78
    WHERE title = 'Coscia di tacchino al forno';
    
    -- Update: Coste o biete lessate con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 0.00
    WHERE title = 'Coste o biete lessate con extravergine';
    
    -- Update: Costine di maiale ai ferri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 0.00,
        total_fiber_g = 60.00
    WHERE title = 'Costine di maiale ai ferri';
    
    -- Update: Cotoletta alla milanese
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.17,
        total_fat_g = 0.00,
        total_fiber_g = 98.29
    WHERE title = 'Cotoletta alla milanese';
    
    -- Update: Crema di ceci 
    UPDATE public.recipes
    SET 
        total_protein_g = 11.66,
        total_carbs_g = 3.62,
        total_fat_g = 12.59,
        total_fiber_g = 156.77
    WHERE title = 'Crema di ceci ';
    
    -- Update: Crema di fagioli cannellini 
    UPDATE public.recipes
    SET 
        total_protein_g = 12.56,
        total_carbs_g = 3.77,
        total_fat_g = 11.39,
        total_fiber_g = 155.62
    WHERE title = 'Crema di fagioli cannellini ';
    
    -- Update: Crema di piselli
    UPDATE public.recipes
    SET 
        total_protein_g = 9.33,
        total_carbs_g = 7.92,
        total_fat_g = 10.74,
        total_fiber_g = 270.72
    WHERE title = 'Crema di piselli';
    
    -- Update: Crema di piselli con patate
    UPDATE public.recipes
    SET 
        total_protein_g = 10.85,
        total_carbs_g = 8.20,
        total_fat_g = 10.82,
        total_fiber_g = 326.98
    WHERE title = 'Crema di piselli con patate';
    
    -- Update: Crema di zucca
    UPDATE public.recipes
    SET 
        total_protein_g = 0.84,
        total_carbs_g = 2.09,
        total_fat_g = 10.23,
        total_fiber_g = 153.11
    WHERE title = 'Crema di zucca';
    
    -- Update: Crema porri e patate
    UPDATE public.recipes
    SET 
        total_protein_g = 7.18,
        total_carbs_g = 8.09,
        total_fat_g = 10.53,
        total_fiber_g = 398.79
    WHERE title = 'Crema porri e patate';
    
    -- Update: Crostata alla marmellata 
    UPDATE public.recipes
    SET 
        total_protein_g = 2.75,
        total_carbs_g = 12.06,
        total_fat_g = 0.17,
        total_fiber_g = 15.55
    WHERE title = 'Crostata alla marmellata ';
    
    -- Update: Fagioli all
    UPDATE public.recipes
    SET 
        total_protein_g = 11.93,
        total_carbs_g = 2.77,
        total_fat_g = 11.37,
        total_fiber_g = 10.69
    WHERE title = 'Fagioli all';
    
    -- Update: Fagioli con nervetti
    UPDATE public.recipes
    SET 
        total_protein_g = 11.80,
        total_carbs_g = 2.00,
        total_fat_g = 11.24,
        total_fiber_g = 5.35
    WHERE title = 'Fagioli con nervetti';
    
    -- Update: Fagioli in umido con sugo al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 12.03,
        total_carbs_g = 2.89,
        total_fat_g = 11.27,
        total_fiber_g = 20.92
    WHERE title = 'Fagioli in umido con sugo al pomodoro';
    
    -- Update: Fagiolini in padella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.30,
        total_carbs_g = 0.43,
        total_fat_g = 10.08,
        total_fiber_g = 54.79
    WHERE title = 'Fagiolini in padella';
    
    -- Update: Fagiolini lessati e conditi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.01,
        total_carbs_g = 0.04,
        total_fat_g = 9.99,
        total_fiber_g = 0.01
    WHERE title = 'Fagiolini lessati e conditi';
    
    -- Update: Farro bollito condito con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 0.00
    WHERE title = 'Farro bollito condito con extravergine';
    
    -- Update: Fegato alla veneta
    UPDATE public.recipes
    SET 
        total_protein_g = 0.85,
        total_carbs_g = 8.40,
        total_fat_g = 0.07,
        total_fiber_g = 108.83
    WHERE title = 'Fegato alla veneta';
    
    -- Update: Filetti di merluzzo con pomodori, olive e capperi
    UPDATE public.recipes
    SET 
        total_protein_g = 0.30,
        total_carbs_g = 1.47,
        total_fat_g = 10.06,
        total_fiber_g = 142.72
    WHERE title = 'Filetti di merluzzo con pomodori, olive e capperi';
    
    -- Update: Filetto di manzo ai ferri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.01,
        total_carbs_g = 0.04,
        total_fat_g = 9.99,
        total_fiber_g = 72.71
    WHERE title = 'Filetto di manzo ai ferri';
    
    -- Update: Finocchi gratinati
    UPDATE public.recipes
    SET 
        total_protein_g = 2.40,
        total_carbs_g = 2.11,
        total_fat_g = 0.00,
        total_fiber_g = 189.33
    WHERE title = 'Finocchi gratinati';
    
    -- Update: Finocchi in insalata 
    UPDATE public.recipes
    SET 
        total_protein_g = 2.41,
        total_carbs_g = 2.04,
        total_fat_g = 9.99,
        total_fiber_g = 186.41
    WHERE title = 'Finocchi in insalata ';
    
    -- Update: Finocchi in insalata con arance
    UPDATE public.recipes
    SET 
        total_protein_g = 2.16,
        total_carbs_g = 5.44,
        total_fat_g = 10.09,
        total_fiber_g = 183.41
    WHERE title = 'Finocchi in insalata con arance';
    
    -- Update: Finocchi in padella
    UPDATE public.recipes
    SET 
        total_protein_g = 2.42,
        total_carbs_g = 2.17,
        total_fat_g = 10.00,
        total_fiber_g = 188.00
    WHERE title = 'Finocchi in padella';
    
    -- Update: Fragole con gelato fiordilatte
    UPDATE public.recipes
    SET 
        total_protein_g = 1.35,
        total_carbs_g = 7.95,
        total_fat_g = 0.60,
        total_fiber_g = 135.75
    WHERE title = 'Fragole con gelato fiordilatte';
    
    -- Update: Fragole zucchero e limone
    UPDATE public.recipes
    SET 
        total_protein_g = 1.36,
        total_carbs_g = 13.25,
        total_fat_g = 0.60,
        total_fiber_g = 140.38
    WHERE title = 'Fragole zucchero e limone';
    
    -- Update: Frittata
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 5.00,
        total_fiber_g = 40.07
    WHERE title = 'Frittata';
    
    -- Update: Frittata con porri
    UPDATE public.recipes
    SET 
        total_protein_g = 0.84,
        total_carbs_g = 2.08,
        total_fat_g = 5.04,
        total_fiber_g = 75.19
    WHERE title = 'Frittata con porri';
    
    -- Update: Funghi misti trifolati
    UPDATE public.recipes
    SET 
        total_protein_g = 0.08,
        total_carbs_g = 0.42,
        total_fat_g = 10.03,
        total_fiber_g = 4.87
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
        total_protein_g = 0.01,
        total_carbs_g = 1.01,
        total_fat_g = 0.00,
        total_fiber_g = 35.26
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
        total_protein_g = 0.15,
        total_carbs_g = 0.85,
        total_fat_g = 10.01,
        total_fiber_g = 15.33
    WHERE title = 'Gnocchi di patate al pomodoro';
    
    -- Update: Gnocchi di patate al ragù
    UPDATE public.recipes
    SET 
        total_protein_g = 0.67,
        total_carbs_g = 2.36,
        total_fat_g = 10.04,
        total_fiber_g = 42.33
    WHERE title = 'Gnocchi di patate al ragù';
    
    -- Update: Gnocchi di patate con burro e salvia
    UPDATE public.recipes
    SET 
        total_protein_g = 0.20,
        total_carbs_g = 0.89,
        total_fat_g = 0.23,
        total_fiber_g = 6.25
    WHERE title = 'Gnocchi di patate con burro e salvia';
    
    -- Update: Gnocchi di patate olio e parmigiano
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 1.52
    WHERE title = 'Gnocchi di patate olio e parmigiano';
    
    -- Update: Hamburger di manzo da polpa scelta
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 0.00
    WHERE title = 'Hamburger di manzo da polpa scelta';
    
    -- Update: Insalata di baccalà con prezzemolo e olive
    UPDATE public.recipes
    SET 
        total_protein_g = 0.11,
        total_carbs_g = 0.00,
        total_fat_g = 10.01,
        total_fiber_g = 2.62
    WHERE title = 'Insalata di baccalà con prezzemolo e olive';
    
    -- Update: Insalata di fagioli con cipolle
    UPDATE public.recipes
    SET 
        total_protein_g = 12.87,
        total_carbs_g = 7.70,
        total_fat_g = 11.35,
        total_fiber_g = 99.19
    WHERE title = 'Insalata di fagioli con cipolle';
    
    -- Update: Insalata di fagioli e pomodori
    UPDATE public.recipes
    SET 
        total_protein_g = 11.98,
        total_carbs_g = 3.03,
        total_fat_g = 11.26,
        total_fiber_g = 21.93
    WHERE title = 'Insalata di fagioli e pomodori';
    
    -- Update: Insalata di farro con verdure a cubetti saltate o grigliate
    UPDATE public.recipes
    SET 
        total_protein_g = 0.80,
        total_carbs_g = 1.63,
        total_fat_g = 10.07,
        total_fiber_g = 58.47
    WHERE title = 'Insalata di farro con verdure a cubetti saltate o grigliate';
    
    -- Update: Insalata di farro riso e orzo con dadini di verdure
    UPDATE public.recipes
    SET 
        total_protein_g = 0.93,
        total_carbs_g = 3.21,
        total_fat_g = 10.17,
        total_fiber_g = 84.51
    WHERE title = 'Insalata di farro riso e orzo con dadini di verdure';
    
    -- Update: Insalata di farro riso e orzo con piselli e olio a crudo
    UPDATE public.recipes
    SET 
        total_protein_g = 2.85,
        total_carbs_g = 2.05,
        total_fat_g = 10.19,
        total_fiber_g = 41.02
    WHERE title = 'Insalata di farro riso e orzo con piselli e olio a crudo';
    
    -- Update: Insalata di gamberetti con olio, prezzemolo e limone
    UPDATE public.recipes
    SET 
        total_protein_g = 0.12,
        total_carbs_g = 0.07,
        total_fat_g = 10.01,
        total_fiber_g = 7.22
    WHERE title = 'Insalata di gamberetti con olio, prezzemolo e limone';
    
    -- Update: Insalata di mare
    UPDATE public.recipes
    SET 
        total_protein_g = 0.78,
        total_carbs_g = 2.13,
        total_fat_g = 10.07,
        total_fiber_g = 135.65
    WHERE title = 'Insalata di mare';
    
    -- Update: Insalata di polpo con patate
    UPDATE public.recipes
    SET 
        total_protein_g = 4.29,
        total_carbs_g = 3.01,
        total_fat_g = 10.21,
        total_fiber_g = 286.36
    WHERE title = 'Insalata di polpo con patate';
    
    -- Update: Insalata di riso 
    UPDATE public.recipes
    SET 
        total_protein_g = 1.62,
        total_carbs_g = 2.74,
        total_fat_g = 10.09,
        total_fiber_g = 77.59
    WHERE title = 'Insalata di riso ';
    
    -- Update: Insalata fredda di ceci con extravergine
    UPDATE public.recipes
    SET 
        total_protein_g = 11.06,
        total_carbs_g = 1.89,
        total_fat_g = 12.47,
        total_fiber_g = 10.00
    WHERE title = 'Insalata fredda di ceci con extravergine';
    
    -- Update: Insalata fredda di ceci con peperonata
    UPDATE public.recipes
    SET 
        total_protein_g = 10.91,
        total_carbs_g = 1.89,
        total_fat_g = 12.44,
        total_fiber_g = 6.51
    WHERE title = 'Insalata fredda di ceci con peperonata';
    
    -- Update: Insalata mista con carote e pomodori, condita
    UPDATE public.recipes
    SET 
        total_protein_g = 1.74,
        total_carbs_g = 4.59,
        total_fat_g = 10.19,
        total_fiber_g = 116.91
    WHERE title = 'Insalata mista con carote e pomodori, condita';
    
    -- Update: Insalata, condita
    UPDATE public.recipes
    SET 
        total_protein_g = 0.02,
        total_carbs_g = 0.03,
        total_fat_g = 9.99,
        total_fiber_g = 4.95
    WHERE title = 'Insalata, condita';
    
    -- Update: Involtini di carne con spinaci
    UPDATE public.recipes
    SET 
        total_protein_g = 2.39,
        total_carbs_g = 0.48,
        total_fat_g = 10.48,
        total_fiber_g = 71.30
    WHERE title = 'Involtini di carne con spinaci';
    
    -- Update: Involtini di pollo con prosciutto e formaggio
    UPDATE public.recipes
    SET 
        total_protein_g = 0.01,
        total_carbs_g = 0.38,
        total_fat_g = 9.99,
        total_fiber_g = 95.57
    WHERE title = 'Involtini di pollo con prosciutto e formaggio';
    
    -- Update: Lasagne alla bolognese
    UPDATE public.recipes
    SET 
        total_protein_g = 0.49,
        total_carbs_g = 2.09,
        total_fat_g = 5.03,
        total_fiber_g = 70.69
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
        total_protein_g = 1.46,
        total_carbs_g = 1.79,
        total_fat_g = 10.31,
        total_fiber_g = 80.39
    WHERE title = 'Lattuga, condita';
    
    -- Update: Lenticchie in umido con sugo al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 12.80,
        total_carbs_g = 2.26,
        total_fat_g = 11.28,
        total_fiber_g = 25.00
    WHERE title = 'Lenticchie in umido con sugo al pomodoro';
    
    -- Update: Lonza di maiale in padella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.07,
        total_carbs_g = 0.24,
        total_fat_g = 10.04,
        total_fiber_g = 71.16
    WHERE title = 'Lonza di maiale in padella';
    
    -- Update: Macedonia
    UPDATE public.recipes
    SET 
        total_protein_g = 1.08,
        total_carbs_g = 24.18,
        total_fat_g = 0.40,
        total_fiber_g = 128.70
    WHERE title = 'Macedonia';
    
    -- Update: Macedonia con due palline di gelato
    UPDATE public.recipes
    SET 
        total_protein_g = 1.06,
        total_carbs_g = 18.65,
        total_fat_g = 0.38,
        total_fiber_g = 124.05
    WHERE title = 'Macedonia con due palline di gelato';
    
    -- Update: Mela cotta con cannella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.38,
        total_carbs_g = 21.34,
        total_fat_g = 0.06,
        total_fiber_g = 128.03
    WHERE title = 'Mela cotta con cannella';
    
    -- Update: Melanzane al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 2.40,
        total_carbs_g = 5.88,
        total_fat_g = 10.26,
        total_fiber_g = 193.80
    WHERE title = 'Melanzane al pomodoro';
    
    -- Update: Melanzane grigliate
    UPDATE public.recipes
    SET 
        total_protein_g = 2.22,
        total_carbs_g = 5.37,
        total_fat_g = 10.20,
        total_fiber_g = 187.00
    WHERE title = 'Melanzane grigliate';
    
    -- Update: Melanzane in carrozza
    UPDATE public.recipes
    SET 
        total_protein_g = 3.36,
        total_carbs_g = 5.47,
        total_fat_g = 25.26,
        total_fiber_g = 204.00
    WHERE title = 'Melanzane in carrozza';
    
    -- Update: Merluzzo al vapore con olio
    UPDATE public.recipes
    SET 
        total_protein_g = 0.11,
        total_carbs_g = 0.00,
        total_fat_g = 10.01,
        total_fiber_g = 124.87
    WHERE title = 'Merluzzo al vapore con olio';
    
    -- Update: Minestrone di verdure con patate e legumi
    UPDATE public.recipes
    SET 
        total_protein_g = 4.46,
        total_carbs_g = 8.65,
        total_fat_g = 10.76,
        total_fiber_g = 295.85
    WHERE title = 'Minestrone di verdure con patate e legumi';
    
    -- Update: Minestrone di verdure senza patate e legumi
    UPDATE public.recipes
    SET 
        total_protein_g = 2.25,
        total_carbs_g = 6.57,
        total_fat_g = 10.23,
        total_fiber_g = 246.67
    WHERE title = 'Minestrone di verdure senza patate e legumi';
    
    -- Update: Minestrone di verdure senza patate e legumi con orzo
    UPDATE public.recipes
    SET 
        total_protein_g = 1.93,
        total_carbs_g = 4.48,
        total_fat_g = 10.22,
        total_fiber_g = 219.14
    WHERE title = 'Minestrone di verdure senza patate e legumi con orzo';
    
    -- Update: Minestrone di verdure senza patate e legumi con pastina 
    UPDATE public.recipes
    SET 
        total_protein_g = 1.93,
        total_carbs_g = 4.48,
        total_fat_g = 10.22,
        total_fiber_g = 219.14
    WHERE title = 'Minestrone di verdure senza patate e legumi con pastina ';
    
    -- Update: Minestrone di verdure senza patate e legumi con riso
    UPDATE public.recipes
    SET 
        total_protein_g = 1.93,
        total_carbs_g = 4.48,
        total_fat_g = 10.22,
        total_fiber_g = 219.14
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
        total_protein_g = 0.01,
        total_carbs_g = 0.04,
        total_fat_g = 9.99,
        total_fiber_g = 76.91
    WHERE title = 'Nodino di vitello ai ferri';
    
    -- Update: Orata al forno, sfilettata
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 0.00
    WHERE title = 'Orata al forno, sfilettata';
    
    -- Update: Orecchiette con i broccoli
    UPDATE public.recipes
    SET 
        total_protein_g = 4.53,
        total_carbs_g = 4.86,
        total_fat_g = 10.61,
        total_fiber_g = 137.06
    WHERE title = 'Orecchiette con i broccoli';
    
    -- Update: Ortaggi misti, conditi
    UPDATE public.recipes
    SET 
        total_protein_g = 1.25,
        total_carbs_g = 4.16,
        total_fat_g = 10.20,
        total_fiber_g = 127.42
    WHERE title = 'Ortaggi misti, conditi';
    
    -- Update: Orzo bollito con olio a crudo
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.00,
        total_fat_g = 9.99,
        total_fiber_g = 0.00
    WHERE title = 'Orzo bollito con olio a crudo';
    
    -- Update: Pancotto bianco
    UPDATE public.recipes
    SET 
        total_protein_g = 0.39,
        total_carbs_g = 0.27,
        total_fat_g = 0.50,
        total_fiber_g = 123.88
    WHERE title = 'Pancotto bianco';
    
    -- Update: Pancotto rosso
    UPDATE public.recipes
    SET 
        total_protein_g = 0.04,
        total_carbs_g = 0.29,
        total_fat_g = 10.01,
        total_fiber_g = 2.41
    WHERE title = 'Pancotto rosso';
    
    -- Update: Panino con hamburger
    UPDATE public.recipes
    SET 
        total_protein_g = 0.28,
        total_carbs_g = 0.92,
        total_fat_g = 0.05,
        total_fiber_g = 28.27
    WHERE title = 'Panino con hamburger';
    
    -- Update: Panino rosetta con prosciutto cotto
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.23,
        total_fat_g = 0.00,
        total_fiber_g = 15.55
    WHERE title = 'Panino rosetta con prosciutto cotto';
    
    -- Update: Panino rosetta con prosciutto cotto e fontina
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.43,
        total_fat_g = 0.00,
        total_fiber_g = 25.83
    WHERE title = 'Panino rosetta con prosciutto cotto e fontina';
    
    -- Update: Panino rosetta con salame
    UPDATE public.recipes
    SET 
        total_protein_g = 0.00,
        total_carbs_g = 0.25,
        total_fat_g = 0.00,
        total_fiber_g = 9.07
    WHERE title = 'Panino rosetta con salame';
    
    -- Update: Panzanella
    UPDATE public.recipes
    SET 
        total_protein_g = 0.42,
        total_carbs_g = 0.96,
        total_fat_g = 10.04,
        total_fiber_g = 24.76
    WHERE title = 'Panzanella';
    
    -- Update: Pappa al pomodoro
    UPDATE public.recipes
    SET 
        total_protein_g = 0.58,
        total_carbs_g = 0.47,
        total_fat_g = 10.15,
        total_fiber_g = 127.68
    WHERE title = 'Pappa al pomodoro';
    
    -- Update: Parmigiana di melanzane
    UPDATE public.recipes
    SET 
        total_protein_g = 3.54,
        total_carbs_g = 6.53,
        total_fat_g = 25.29,
        total_fiber_g = 210.09
    WHERE title = 'Parmigiana di melanzane';
    
    -- Update: Passato di verdure senza patate e legumi
    UPDATE public.recipes
    SET 
        total_protein_g = 2.57,
        total_carbs_g = 6.25,
        total_fat_g = 10.26,
        total_fiber_g = 254.30
    WHERE title = 'Passato di verdure senza patate e legumi';
    
    RAISE NOTICE 'Recipe nutritional values updated successfully!';
END $$;
