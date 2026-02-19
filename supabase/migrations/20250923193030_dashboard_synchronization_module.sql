-- Location: supabase/migrations/20250923193030_dashboard_synchronization_module.sql
-- Schema Analysis: Existing NutriVita schema with user_profiles, medical_profiles, weight_entries, meal_entries
-- Integration Type: addition
-- Dependencies: user_profiles, meal_entries, weight_entries, medical_profiles

-- 1. CREATE TYPES FOR DASHBOARD MODULE
CREATE TYPE public.dashboard_widget_type AS ENUM (
    'kpi_card',
    'chart_line',
    'chart_bar',
    'chart_pie',
    'chart_donut',
    'metric_display',
    'progress_bar',
    'achievement_badge',
    'meal_summary',
    'weight_tracker'
);

CREATE TYPE public.chart_time_range AS ENUM (
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly'
);

-- 2. DASHBOARD CONFIGURATIONS TABLE
CREATE TABLE public.dashboard_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    layout_config JSONB NOT NULL DEFAULT '{}',
    theme_settings JSONB DEFAULT '{"primaryColor": "#4CAF50", "darkMode": false}',
    auto_refresh_interval INTEGER DEFAULT 300, -- seconds
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. DASHBOARD WIDGETS TABLE
CREATE TABLE public.dashboard_widgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dashboard_config_id UUID REFERENCES public.dashboard_configurations(id) ON DELETE CASCADE,
    widget_type public.dashboard_widget_type NOT NULL,
    title TEXT NOT NULL,
    position_x INTEGER NOT NULL DEFAULT 0,
    position_y INTEGER NOT NULL DEFAULT 0,
    width INTEGER NOT NULL DEFAULT 1,
    height INTEGER NOT NULL DEFAULT 1,
    widget_config JSONB NOT NULL DEFAULT '{}',
    data_source_config JSONB DEFAULT '{}',
    is_visible BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. DASHBOARD INTERACTIONS TABLE (for tracking user interactions)
CREATE TABLE public.dashboard_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    widget_id UUID REFERENCES public.dashboard_widgets(id) ON DELETE CASCADE,
    interaction_type TEXT NOT NULL, -- 'click', 'filter', 'sort', 'export'
    interaction_data JSONB DEFAULT '{}',
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. DASHBOARD FILTERS TABLE
CREATE TABLE public.dashboard_filters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    filter_name TEXT NOT NULL,
    filter_config JSONB NOT NULL,
    date_range_start DATE,
    date_range_end DATE,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. CHART CONFIGURATIONS TABLE  
CREATE TABLE public.chart_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    widget_id UUID REFERENCES public.dashboard_widgets(id) ON DELETE CASCADE,
    chart_type TEXT NOT NULL, -- 'line', 'bar', 'pie', 'donut', 'area'
    data_points_config JSONB NOT NULL,
    styling_config JSONB DEFAULT '{}',
    time_range public.chart_time_range DEFAULT 'weekly',
    aggregation_method TEXT DEFAULT 'sum', -- 'sum', 'avg', 'count', 'min', 'max'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. ESSENTIAL INDEXES
CREATE INDEX idx_dashboard_configurations_user_id ON public.dashboard_configurations(user_id);
CREATE INDEX idx_dashboard_configurations_active ON public.dashboard_configurations(user_id, is_active);

CREATE INDEX idx_dashboard_widgets_config_id ON public.dashboard_widgets(dashboard_config_id);
CREATE INDEX idx_dashboard_widgets_type ON public.dashboard_widgets(widget_type);
CREATE INDEX idx_dashboard_widgets_position ON public.dashboard_widgets(position_x, position_y);

CREATE INDEX idx_dashboard_interactions_user_id ON public.dashboard_interactions(user_id);
CREATE INDEX idx_dashboard_interactions_timestamp ON public.dashboard_interactions(timestamp DESC);
CREATE INDEX idx_dashboard_interactions_widget ON public.dashboard_interactions(widget_id, timestamp DESC);

CREATE INDEX idx_dashboard_filters_user_id ON public.dashboard_filters(user_id);
CREATE INDEX idx_dashboard_filters_default ON public.dashboard_filters(user_id, is_default);

CREATE INDEX idx_chart_configurations_widget_id ON public.chart_configurations(widget_id);

-- 8. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.dashboard_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_widgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_filters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chart_configurations ENABLE ROW LEVEL SECURITY;

-- 9. CREATE RLS POLICIES
CREATE POLICY "users_manage_own_dashboard_configurations"
ON public.dashboard_configurations
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_dashboard_widgets"
ON public.dashboard_widgets
FOR ALL
TO authenticated
USING (dashboard_config_id IN (
    SELECT id FROM public.dashboard_configurations 
    WHERE user_id = auth.uid()
))
WITH CHECK (dashboard_config_id IN (
    SELECT id FROM public.dashboard_configurations 
    WHERE user_id = auth.uid()
));

CREATE POLICY "users_manage_own_dashboard_interactions"
ON public.dashboard_interactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_dashboard_filters"
ON public.dashboard_filters
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_chart_configurations"
ON public.chart_configurations
FOR ALL
TO authenticated
USING (widget_id IN (
    SELECT dw.id FROM public.dashboard_widgets dw
    JOIN public.dashboard_configurations dc ON dw.dashboard_config_id = dc.id
    WHERE dc.user_id = auth.uid()
))
WITH CHECK (widget_id IN (
    SELECT dw.id FROM public.dashboard_widgets dw
    JOIN public.dashboard_configurations dc ON dw.dashboard_config_id = dc.id
    WHERE dc.user_id = auth.uid()
));

-- 10. CREATE FUNCTIONS FOR DASHBOARD DATA SYNCHRONIZATION
CREATE OR REPLACE FUNCTION public.sync_dashboard_data(user_uuid UUID DEFAULT auth.uid())
RETURNS TABLE(
    nutrition_summary JSONB,
    weight_progress JSONB,
    meal_counts JSONB,
    assessment_status JSONB
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    today_date DATE := CURRENT_DATE;
    week_start DATE := today_date - INTERVAL '7 days';
    nutrition_data JSONB;
    weight_data JSONB;
    meal_data JSONB;
    assessment_data JSONB;
BEGIN
    -- Get nutrition summary for today
    SELECT jsonb_build_object(
        'total_calories', COALESCE(SUM(
            CASE 
                WHEN fi.calories_per_100g IS NOT NULL AND mf.quantity_grams IS NOT NULL 
                THEN (fi.calories_per_100g * mf.quantity_grams / 100.0)
                ELSE 0 
            END
        ), 0),
        'total_protein', COALESCE(SUM(
            CASE 
                WHEN fi.protein_per_100g IS NOT NULL AND mf.quantity_grams IS NOT NULL 
                THEN (fi.protein_per_100g * mf.quantity_grams / 100.0)
                ELSE 0 
            END
        ), 0),
        'total_carbs', COALESCE(SUM(
            CASE 
                WHEN fi.carbs_per_100g IS NOT NULL AND mf.quantity_grams IS NOT NULL 
                THEN (fi.carbs_per_100g * mf.quantity_grams / 100.0)
                ELSE 0 
            END
        ), 0),
        'total_fat', COALESCE(SUM(
            CASE 
                WHEN fi.fat_per_100g IS NOT NULL AND mf.quantity_grams IS NOT NULL 
                THEN (fi.fat_per_100g * mf.quantity_grams / 100.0)
                ELSE 0 
            END
        ), 0),
        'meals_logged', COUNT(DISTINCT me.id)
    )
    INTO nutrition_data
    FROM public.meal_entries me
    LEFT JOIN public.meal_foods mf ON me.id = mf.meal_entry_id  
    LEFT JOIN public.food_items fi ON mf.food_item_id = fi.id
    WHERE me.user_id = user_uuid AND me.meal_date = today_date;

    -- Get weight progress for past 7 days
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

    -- Get meal counts by type for today
    SELECT jsonb_build_object(
        'breakfast', COUNT(CASE WHEN me.meal_type = 'breakfast' THEN 1 END),
        'lunch', COUNT(CASE WHEN me.meal_type = 'lunch' THEN 1 END),
        'dinner', COUNT(CASE WHEN me.meal_type = 'dinner' THEN 1 END),
        'snack', COUNT(CASE WHEN me.meal_type = 'snack' THEN 1 END)
    )
    INTO meal_data
    FROM public.meal_entries me
    WHERE me.user_id = user_uuid AND me.meal_date = today_date;

    -- Get assessment completion status
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
$$;

-- 11. CREATE TRIGGER FUNCTION FOR AUTOMATIC DASHBOARD CREATION
CREATE OR REPLACE FUNCTION public.create_default_dashboard()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    config_id UUID;
    widget_id UUID;
BEGIN
    -- Create default dashboard configuration
    INSERT INTO public.dashboard_configurations (user_id, layout_config)
    VALUES (
        NEW.id,
        '{"layout": "grid", "columns": 2, "autoResize": true}'::jsonb
    )
    RETURNING id INTO config_id;

    -- Create default KPI widgets
    INSERT INTO public.dashboard_widgets (dashboard_config_id, widget_type, title, position_x, position_y, width, height, widget_config)
    VALUES 
    (config_id, 'kpi_card', 'Daily Calories', 0, 0, 1, 1, '{"metric": "calories", "showProgress": true}'::jsonb),
    (config_id, 'kpi_card', 'Current Weight', 1, 0, 1, 1, '{"metric": "weight", "showTrend": true}'::jsonb),
    (config_id, 'chart_line', 'Weight Progress', 0, 1, 2, 2, '{"timeRange": "weekly", "showPoints": true}'::jsonb),
    (config_id, 'meal_summary', 'Today''s Meals', 0, 3, 2, 1, '{"showNutrition": true}'::jsonb);

    RETURN NEW;
END;
$$;

-- 12. CREATE TRIGGER FOR NEW USER DASHBOARD
CREATE TRIGGER create_user_default_dashboard
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.create_default_dashboard();

-- 13. CREATE UPDATE TRIGGERS
CREATE OR REPLACE FUNCTION public.update_dashboard_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_dashboard_configurations_updated_at
    BEFORE UPDATE ON public.dashboard_configurations
    FOR EACH ROW EXECUTE FUNCTION public.update_dashboard_updated_at();

CREATE TRIGGER update_dashboard_widgets_updated_at
    BEFORE UPDATE ON public.dashboard_widgets
    FOR EACH ROW EXECUTE FUNCTION public.update_dashboard_updated_at();

CREATE TRIGGER update_dashboard_filters_updated_at
    BEFORE UPDATE ON public.dashboard_filters
    FOR EACH ROW EXECUTE FUNCTION public.update_dashboard_updated_at();

CREATE TRIGGER update_chart_configurations_updated_at
    BEFORE UPDATE ON public.chart_configurations
    FOR EACH ROW EXECUTE FUNCTION public.update_dashboard_updated_at();

-- 14. MOCK DATA FOR EXISTING USERS
DO $$
DECLARE
    existing_user_id UUID;
    config_id UUID;
BEGIN
    -- Create default dashboards for existing users
    FOR existing_user_id IN 
        SELECT id FROM public.user_profiles 
        WHERE id NOT IN (SELECT user_id FROM public.dashboard_configurations)
    LOOP
        -- Create dashboard configuration
        INSERT INTO public.dashboard_configurations (user_id, layout_config)
        VALUES (
            existing_user_id,
            '{"layout": "grid", "columns": 2, "autoResize": true}'::jsonb
        )
        RETURNING id INTO config_id;

        -- Create default widgets
        INSERT INTO public.dashboard_widgets (dashboard_config_id, widget_type, title, position_x, position_y, width, height, widget_config)
        VALUES 
        (config_id, 'kpi_card', 'Daily Calories', 0, 0, 1, 1, '{"metric": "calories", "showProgress": true}'::jsonb),
        (config_id, 'kpi_card', 'Current Weight', 1, 0, 1, 1, '{"metric": "weight", "showTrend": true}'::jsonb),
        (config_id, 'chart_line', 'Weight Progress', 0, 1, 2, 2, '{"timeRange": "weekly", "showPoints": true}'::jsonb),
        (config_id, 'meal_summary', 'Today''s Meals', 0, 3, 2, 1, '{"showNutrition": true}'::jsonb);

        -- Create default filter
        INSERT INTO public.dashboard_filters (user_id, filter_name, filter_config, is_default)
        VALUES (
            existing_user_id,
            'Last 7 Days',
            '{"dateRange": "7days", "includeAll": true}'::jsonb,
            true
        );
    END LOOP;
END $$;