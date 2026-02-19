-- Location: supabase/migrations/20250926102751_user_settings_preferences_module.sql
-- Schema Analysis: Existing user_profiles table found, adding user settings/preferences functionality
-- Integration Type: Addition - extending existing schema with user preferences
-- Dependencies: user_profiles table (existing)

-- 1. Create enums for user preference types
CREATE TYPE public.sync_frequency AS ENUM ('realtime', 'hourly', 'daily', 'weekly');
CREATE TYPE public.theme_mode AS ENUM ('light', 'dark', 'system');

-- 2. Create user_settings table for app preferences
CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    biometric_enabled BOOLEAN DEFAULT false,
    theme_mode public.theme_mode DEFAULT 'system'::public.theme_mode,
    sync_frequency public.sync_frequency DEFAULT 'realtime'::public.sync_frequency,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 3. Create user_notification_preferences table
CREATE TABLE public.user_notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    meal_reminders BOOLEAN DEFAULT true,
    medication_alerts BOOLEAN DEFAULT true,
    progress_celebrations BOOLEAN DEFAULT true,
    healthcare_provider_messages BOOLEAN DEFAULT true,
    weekly_reports BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 4. Create indexes for performance
CREATE INDEX idx_user_settings_user_id ON public.user_settings(user_id);
CREATE INDEX idx_user_notification_preferences_user_id ON public.user_notification_preferences(user_id);

-- 5. Enable RLS on new tables
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_preferences ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_user_settings"
ON public.user_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_notification_preferences"
ON public.user_notification_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Create function to automatically create default settings for new users
CREATE OR REPLACE FUNCTION public.create_default_user_settings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Create default user settings
  INSERT INTO public.user_settings (user_id, biometric_enabled, theme_mode, sync_frequency)
  VALUES (NEW.id, false, 'system'::public.theme_mode, 'realtime'::public.sync_frequency)
  ON CONFLICT (user_id) DO NOTHING;
  
  -- Create default notification preferences
  INSERT INTO public.user_notification_preferences (
    user_id, meal_reminders, medication_alerts, progress_celebrations, 
    healthcare_provider_messages, weekly_reports
  )
  VALUES (NEW.id, true, true, true, true, true)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$;

-- 8. Create trigger to automatically create settings for new users
CREATE TRIGGER create_user_settings_on_signup
  AFTER INSERT ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.create_default_user_settings();

-- 9. Create update trigger for timestamps
CREATE OR REPLACE FUNCTION public.update_settings_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_user_settings_timestamp
  BEFORE UPDATE ON public.user_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_settings_updated_at();

CREATE TRIGGER update_notification_preferences_timestamp
  BEFORE UPDATE ON public.user_notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION public.update_settings_updated_at();

-- 10. Create default settings for existing users
DO $$
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN SELECT id FROM public.user_profiles
    LOOP
        -- Create default user settings for existing users
        INSERT INTO public.user_settings (user_id, biometric_enabled, theme_mode, sync_frequency)
        VALUES (user_record.id, false, 'system'::public.theme_mode, 'realtime'::public.sync_frequency)
        ON CONFLICT (user_id) DO NOTHING;
        
        -- Create default notification preferences for existing users
        INSERT INTO public.user_notification_preferences (
            user_id, meal_reminders, medication_alerts, progress_celebrations, 
            healthcare_provider_messages, weekly_reports
        )
        VALUES (user_record.id, true, true, true, true, true)
        ON CONFLICT (user_id) DO NOTHING;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating default settings: %', SQLERRM;
END $$;