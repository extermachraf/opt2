-- Location: supabase/migrations/20250926102751_add_user_settings_and_notification_preferences.sql
-- Schema Analysis: Existing user_profiles table with id column referencing auth.uid()
-- Integration Type: Addition - Creating new user settings functionality
-- Dependencies: user_profiles table (existing)

-- Create enum types for user settings
CREATE TYPE public.sync_frequency_type AS ENUM ('realtime', 'every_15_minutes', 'hourly', 'manual_only');
CREATE TYPE public.theme_mode_type AS ENUM ('light', 'dark', 'system');

-- Create user_settings table for app preferences
CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    biometric_enabled BOOLEAN DEFAULT false,
    theme_mode public.theme_mode_type DEFAULT 'system'::public.theme_mode_type,
    sync_frequency public.sync_frequency_type DEFAULT 'realtime'::public.sync_frequency_type,
    language TEXT DEFAULT 'it',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create user_notification_preferences table for notification settings
CREATE TABLE public.user_notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    meal_reminders BOOLEAN DEFAULT true,
    medication_alerts BOOLEAN DEFAULT true,
    progress_celebrations BOOLEAN DEFAULT true,
    healthcare_provider_messages BOOLEAN DEFAULT true,
    weekly_reports BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_user_settings_user_id ON public.user_settings(user_id);
CREATE INDEX idx_user_notification_preferences_user_id ON public.user_notification_preferences(user_id);

-- Create unique constraints
CREATE UNIQUE INDEX idx_user_settings_user_unique ON public.user_settings(user_id);
CREATE UNIQUE INDEX idx_user_notification_preferences_user_unique ON public.user_notification_preferences(user_id);

-- Enable RLS
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_preferences ENABLE ROW LEVEL SECURITY;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Create triggers for updated_at
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_notification_preferences_updated_at
    BEFORE UPDATE ON public.user_notification_preferences
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- RLS policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_user_settings"
ON public.user_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_notification_preferences"
ON public.user_notification_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Function to create default user settings when a new user signs up
CREATE OR REPLACE FUNCTION public.create_default_user_settings()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create default user settings
    INSERT INTO public.user_settings (user_id, biometric_enabled, theme_mode, sync_frequency, language)
    VALUES (NEW.id, false, 'system'::public.theme_mode_type, 'realtime'::public.sync_frequency_type, 'it');
    
    -- Create default notification preferences
    INSERT INTO public.user_notification_preferences (
        user_id, meal_reminders, medication_alerts, progress_celebrations, 
        healthcare_provider_messages, weekly_reports, email_notifications, push_notifications
    )
    VALUES (NEW.id, true, true, true, true, true, true, true);
    
    RETURN NEW;
END;
$$;

-- Create trigger to auto-create default settings for new users
CREATE TRIGGER create_default_settings_for_new_user
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.create_default_user_settings();

-- Add sample settings for existing users
DO $$
DECLARE
    user_record RECORD;
BEGIN
    -- Add default settings for existing users who don't have settings yet
    FOR user_record IN SELECT id FROM public.user_profiles LOOP
        -- Insert user settings if they don't exist
        INSERT INTO public.user_settings (user_id, biometric_enabled, theme_mode, sync_frequency, language)
        VALUES (user_record.id, false, 'system'::public.theme_mode_type, 'realtime'::public.sync_frequency_type, 'it')
        ON CONFLICT (user_id) DO NOTHING;
        
        -- Insert notification preferences if they don't exist
        INSERT INTO public.user_notification_preferences (
            user_id, meal_reminders, medication_alerts, progress_celebrations,
            healthcare_provider_messages, weekly_reports, email_notifications, push_notifications
        )
        VALUES (user_record.id, true, true, true, true, true, true, true)
        ON CONFLICT (user_id) DO NOTHING;
    END LOOP;
END $$;