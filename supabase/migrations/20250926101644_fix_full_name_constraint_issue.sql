-- Migration to fix full_name constraint issue and ensure data integrity
-- File: 20250926101644_fix_full_name_constraint_issue.sql

-- Fix any existing NULL full_name values in user_profiles
UPDATE public.user_profiles 
SET full_name = COALESCE(
  NULLIF(CONCAT_WS(' ', name, surname), ''),
  SPLIT_PART(email, '@', 1)
)
WHERE full_name IS NULL OR full_name = '';

-- Add a trigger to automatically set full_name if not provided during insert/update
CREATE OR REPLACE FUNCTION ensure_full_name_not_null()
RETURNS TRIGGER AS $$
BEGIN
  -- If full_name is NULL or empty, generate it from name/surname or email
  IF NEW.full_name IS NULL OR NEW.full_name = '' THEN
    NEW.full_name := COALESCE(
      NULLIF(CONCAT_WS(' ', NEW.name, NEW.surname), ''),
      SPLIT_PART(NEW.email, '@', 1)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to ensure full_name is never null
CREATE TRIGGER ensure_full_name_before_insert_update
  BEFORE INSERT OR UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION ensure_full_name_not_null();

-- Update any demo or existing users to ensure they have proper full_name
UPDATE public.user_profiles 
SET 
  full_name = CASE 
    WHEN email = 'yassine00kriouet@gmail.com' THEN 'Yassine Kriouet'
    WHEN email = 'demo@nutrivita.com' THEN 'Demo User'
    ELSE SPLIT_PART(email, '@', 1)
  END,
  updated_at = CURRENT_TIMESTAMP
WHERE email IN ('yassine00kriouet@gmail.com', 'demo@nutrivita.com')
   OR full_name IS NULL 
   OR full_name = '';

-- Add helpful comment
COMMENT ON TRIGGER ensure_full_name_before_insert_update ON public.user_profiles 
IS 'Automatically generates full_name from name+surname or email if not provided, preventing NOT NULL constraint violations';

-- Verify no NULL full_name values remain
DO $$
DECLARE
  null_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO null_count 
  FROM public.user_profiles 
  WHERE full_name IS NULL OR full_name = '';
  
  IF null_count > 0 THEN
    RAISE EXCEPTION 'Migration failed: % user_profiles still have NULL or empty full_name', null_count;
  ELSE
    RAISE NOTICE 'Migration successful: All user_profiles have valid full_name values';
  END IF;
END $$;