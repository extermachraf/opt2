-- Migration: Fix Dashboard Widget Interaction Tracking
-- Timestamp: 2025-09-26 11:47:06

BEGIN;

-- Create function to generate or validate widget IDs for dashboard interactions
CREATE OR REPLACE FUNCTION get_or_create_widget_id(widget_identifier TEXT)
RETURNS UUID AS $$
DECLARE
    widget_uuid UUID;
    default_config_id UUID;
BEGIN
    -- Try to find existing widget by identifier in widget_config
    SELECT id INTO widget_uuid
    FROM dashboard_widgets 
    WHERE widget_config->>'identifier' = widget_identifier
    LIMIT 1;
    
    IF widget_uuid IS NOT NULL THEN
        RETURN widget_uuid;
    END IF;
    
    -- If no widget found, create a default widget
    -- First, get or create a default dashboard configuration
    SELECT id INTO default_config_id
    FROM dashboard_configurations
    WHERE user_id IS NULL -- System default
    LIMIT 1;
    
    IF default_config_id IS NULL THEN
        INSERT INTO dashboard_configurations (
            id,
            user_id,
            is_active,
            layout_config,
            created_at
        ) VALUES (
            gen_random_uuid(),
            NULL, -- System configuration
            true,
            jsonb_build_object('layout', 'grid', 'system_default', true),
            CURRENT_TIMESTAMP
        ) RETURNING id INTO default_config_id;
    END IF;
    
    -- Create the widget
    INSERT INTO dashboard_widgets (
        id,
        title,
        widget_type,
        dashboard_config_id,
        widget_config,
        position_x,
        position_y,
        width,
        height,
        is_visible,
        created_at
    ) VALUES (
        gen_random_uuid(),
        CASE 
            WHEN widget_identifier = 'quick_action_quiz' THEN 'Quick Action - Quiz'
            WHEN widget_identifier = 'quick_action_questionnaire' THEN 'Quick Action - Questionario'
            ELSE 'System Widget - ' || widget_identifier
        END,
        'quick_action',
        default_config_id,
        jsonb_build_object('identifier', widget_identifier, 'auto_created', true),
        0,
        0,
        1,
        1,
        true,
        CURRENT_TIMESTAMP
    ) RETURNING id INTO widget_uuid;
    
    RETURN widget_uuid;
END;
$$ LANGUAGE plpgsql;

-- Create function to safely log dashboard interactions
CREATE OR REPLACE FUNCTION safe_log_dashboard_interaction(
    p_user_id UUID,
    p_widget_identifier TEXT,
    p_interaction_type TEXT,
    p_interaction_data JSONB DEFAULT '{}'::jsonb
) RETURNS UUID AS $$
DECLARE
    widget_uuid UUID;
    interaction_id UUID;
BEGIN
    -- Get or create widget ID
    widget_uuid := get_or_create_widget_id(p_widget_identifier);
    
    -- Log the interaction
    INSERT INTO dashboard_interactions (
        id,
        user_id,
        widget_id,
        interaction_type,
        interaction_data,
        timestamp
    ) VALUES (
        gen_random_uuid(),
        p_user_id,
        widget_uuid,
        p_interaction_type,
        p_interaction_data,
        CURRENT_TIMESTAMP
    ) RETURNING id INTO interaction_id;
    
    RETURN interaction_id;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the main operation
        RAISE WARNING 'Failed to log dashboard interaction: %', SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Add new widget type for quick actions
ALTER TYPE dashboard_widget_type ADD VALUE IF NOT EXISTS 'quick_action';

-- Update existing dashboard widgets to include identifiers for common interactions
UPDATE dashboard_widgets 
SET widget_config = widget_config || jsonb_build_object('identifier', 'kpi_card_' || lower(replace(title, ' ', '_')))
WHERE widget_config->>'identifier' IS NULL 
AND widget_type = 'kpi_card';

-- Create default system dashboard configuration if it doesn't exist
INSERT INTO dashboard_configurations (
    id,
    user_id,
    is_active,
    layout_config,
    created_at
) 
SELECT 
    gen_random_uuid(),
    NULL,
    true,
    jsonb_build_object('layout', 'grid', 'system_default', true),
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM dashboard_configurations WHERE user_id IS NULL
);

-- Add helpful comment
COMMENT ON FUNCTION get_or_create_widget_id(TEXT) IS 'Gets existing widget ID by identifier or creates a new widget for interaction tracking';
COMMENT ON FUNCTION safe_log_dashboard_interaction(UUID, TEXT, TEXT, JSONB) IS 'Safely logs dashboard interactions with automatic widget creation if needed';

COMMIT;