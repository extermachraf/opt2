-- Location: supabase/migrations/20250102160000_add_accessibility_settings.sql
-- Schema Analysis: Existing user_settings table with basic fields
-- Integration Type: Adding accessibility columns to existing table
-- Dependencies: user_settings table

-- Add accessibility columns to existing user_settings table
ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS high_contrast_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS large_text_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS reduced_animation_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS text_scale_factor NUMERIC(3,2) DEFAULT 1.0 CHECK (text_scale_factor >= 0.5 AND text_scale_factor <= 2.0);

-- Add indexes for accessibility settings for better performance
CREATE INDEX IF NOT EXISTS idx_user_settings_high_contrast ON public.user_settings(high_contrast_enabled) WHERE high_contrast_enabled = true;
CREATE INDEX IF NOT EXISTS idx_user_settings_large_text ON public.user_settings(large_text_enabled) WHERE large_text_enabled = true;
CREATE INDEX IF NOT EXISTS idx_user_settings_reduced_animation ON public.user_settings(reduced_animation_enabled) WHERE reduced_animation_enabled = true;

-- Update existing user settings with default accessibility values
UPDATE public.user_settings 
SET 
    high_contrast_enabled = false,
    large_text_enabled = false,
    reduced_animation_enabled = false,
    text_scale_factor = 1.0
WHERE 
    high_contrast_enabled IS NULL 
    OR large_text_enabled IS NULL 
    OR reduced_animation_enabled IS NULL 
    OR text_scale_factor IS NULL;

COMMENT ON COLUMN public.user_settings.high_contrast_enabled IS 'Enable high contrast mode for improved visibility for patients with vision changes';
COMMENT ON COLUMN public.user_settings.large_text_enabled IS 'Enable larger text size for easier reading';
COMMENT ON COLUMN public.user_settings.reduced_animation_enabled IS 'Enable reduced animations for motion-sensitive patients';
COMMENT ON COLUMN public.user_settings.text_scale_factor IS 'Text scaling factor (0.5 to 2.0) for fine-tuned text size control';