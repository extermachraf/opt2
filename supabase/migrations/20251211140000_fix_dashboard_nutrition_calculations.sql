-- Migration to fix calorie totals discrepancy between Dashboard and Riassunto giornaliero
-- The issue: sync_dashboard_data function only calculated nutrition from food_items, 
-- but ignored recipes and pre-calculated meal_foods values

-- Replace the sync_dashboard_data function with corrected version
CREATE OR REPLACE FUNCTION public.sync_dashboard_data(user_uuid uuid DEFAULT auth.uid())
RETURNS TABLE(nutrition_summary jsonb, weight_progress jsonb, meal_counts jsonb, assessment_status jsonb)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    today_date DATE := CURRENT_DATE;
    week_start DATE := today_date - INTERVAL '7 days';
    nutrition_data JSONB;
    weight_data JSONB;
    meal_data JSONB;
    assessment_data JSONB;
BEGIN
    -- FIXED: Get nutrition summary using pre-calculated meal_foods values
    -- This ensures consistency with MealDiaryService.getNutritionalSummary()
    SELECT jsonb_build_object(
        'total_calories', COALESCE(SUM(mf.calories), 0),
        'total_protein', COALESCE(SUM(mf.protein_g), 0),
        'total_carbs', COALESCE(SUM(mf.carbs_g), 0),
        'total_fat', COALESCE(SUM(mf.fat_g), 0),
        'meals_logged', COUNT(DISTINCT me.id)
    )
    INTO nutrition_data
    FROM public.meal_entries me
    INNER JOIN public.meal_foods mf ON me.id = mf.meal_entry_id  
    WHERE me.user_id = user_uuid AND me.meal_date = today_date;

    -- Get weight progress for past 7 days (unchanged)
    SELECT jsonb_agg(
        jsonb_build_object(
            'date', we.recorded_at::date,
            'weight', we.weight_kg,
            'body_fat', we.body_fat_percentage,
            'muscle_mass', we.muscle_mass_kg
        ) 
        ORDER BY we.recorded_at DESC
    )
    INTO weight_data
    FROM public.weight_entries we
    WHERE we.user_id = user_uuid 
    AND we.recorded_at >= week_start;

    -- Get meal counts by type for today (unchanged)
    SELECT jsonb_build_object(
        'breakfast', COUNT(CASE WHEN me.meal_type = 'breakfast' THEN 1 END),
        'lunch', COUNT(CASE WHEN me.meal_type = 'lunch' THEN 1 END),
        'dinner', COUNT(CASE WHEN me.meal_type = 'dinner' THEN 1 END),
        'snack', COUNT(CASE WHEN me.meal_type = 'snack' THEN 1 END)
    )
    INTO meal_data
    FROM public.meal_entries me
    WHERE me.user_id = user_uuid AND me.meal_date = today_date;

    -- Get assessment completion status (unchanged)
    SELECT jsonb_build_object(
        'completed_assessments', COUNT(CASE WHEN ase.status = 'completed' THEN 1 END),
        'total_assessments', COUNT(*),
        'completion_rate', 
        CASE 
            WHEN COUNT(*) > 0 
            THEN ROUND((COUNT(CASE WHEN ase.status = 'completed' THEN 1 END) * 100.0 / COUNT(*)), 2)
            ELSE 0 
        END
    )
    INTO assessment_data
    FROM public.assessment_sessions ase
    WHERE ase.user_id = user_uuid;

    RETURN QUERY SELECT 
        COALESCE(nutrition_data, '{}'::jsonb),
        COALESCE(weight_data, '[]'::jsonb),
        COALESCE(meal_data, '{}'::jsonb),
        COALESCE(assessment_data, '{}'::jsonb);
END;
$function$;

-- Add comment explaining the fix
COMMENT ON FUNCTION public.sync_dashboard_data(uuid) IS 
'FIXED: Now uses pre-calculated meal_foods values instead of calculating from food_items directly. This ensures consistency between Dashboard and Meal Diary nutritional summaries, properly including both regular food items and recipes.';