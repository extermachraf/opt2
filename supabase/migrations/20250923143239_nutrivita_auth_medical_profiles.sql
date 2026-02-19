-- Location: supabase/migrations/20250923143239_nutrivita_auth_medical_profiles.sql
-- Schema Analysis: Fresh project with no existing tables
-- Integration Type: FRESH_PROJECT - Complete new schema  
-- Dependencies: None (first migration)
-- IMPLEMENTING MODULE: Authentication (user management, medical profiles, basic health data)

-- 1. Custom Types for Medical App
CREATE TYPE public.user_role AS ENUM ('patient', 'doctor', 'admin', 'nutritionist');
CREATE TYPE public.gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE public.activity_level AS ENUM ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active');
CREATE TYPE public.meal_type AS ENUM ('breakfast', 'lunch', 'dinner', 'snack');
CREATE TYPE public.goal_type AS ENUM ('weight_loss', 'weight_gain', 'maintain_weight', 'muscle_gain', 'general_health');

-- 2. Core User Profiles Table (PostgREST compatible intermediary)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'patient'::public.user_role,
    date_of_birth DATE,
    gender public.gender,
    phone_number TEXT,
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Medical Information Tables
CREATE TABLE public.medical_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    height_cm DECIMAL(5,2),
    current_weight_kg DECIMAL(5,2),
    target_weight_kg DECIMAL(5,2),
    activity_level public.activity_level DEFAULT 'moderately_active'::public.activity_level,
    goal_type public.goal_type DEFAULT 'general_health'::public.goal_type,
    allergies TEXT[],
    medical_conditions TEXT[],
    medications TEXT[],
    dietary_restrictions TEXT[],
    bmr_calories INTEGER, -- Basal Metabolic Rate
    target_daily_calories INTEGER,
    target_protein_g INTEGER,
    target_carbs_g INTEGER,
    target_fat_g INTEGER,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 4. Weight Tracking Table
CREATE TABLE public.weight_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    weight_kg DECIMAL(5,2) NOT NULL,
    body_fat_percentage DECIMAL(4,2),
    muscle_mass_kg DECIMAL(5,2),
    notes TEXT,
    recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Food Database Tables
CREATE TABLE public.food_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    brand TEXT,
    barcode TEXT,
    calories_per_100g INTEGER NOT NULL,
    protein_per_100g DECIMAL(5,2) DEFAULT 0,
    carbs_per_100g DECIMAL(5,2) DEFAULT 0,
    fat_per_100g DECIMAL(5,2) DEFAULT 0,
    fiber_per_100g DECIMAL(5,2) DEFAULT 0,
    sugar_per_100g DECIMAL(5,2) DEFAULT 0,
    sodium_per_100g DECIMAL(8,2) DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Meal Logging Tables
CREATE TABLE public.meal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    meal_type public.meal_type NOT NULL,
    meal_date DATE NOT NULL,
    meal_time TIME,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.meal_foods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_entry_id UUID REFERENCES public.meal_entries(id) ON DELETE CASCADE,
    food_item_id UUID REFERENCES public.food_items(id) ON DELETE CASCADE,
    quantity_grams DECIMAL(8,2) NOT NULL,
    calories DECIMAL(8,2) NOT NULL,
    protein_g DECIMAL(6,2) DEFAULT 0,
    carbs_g DECIMAL(6,2) DEFAULT 0,
    fat_g DECIMAL(6,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Essential Indexes for Performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_medical_profiles_user_id ON public.medical_profiles(user_id);
CREATE INDEX idx_weight_entries_user_id ON public.weight_entries(user_id);
CREATE INDEX idx_weight_entries_recorded_at ON public.weight_entries(recorded_at);
CREATE INDEX idx_food_items_name ON public.food_items USING gin(to_tsvector('english', name));
CREATE INDEX idx_meal_entries_user_id_date ON public.meal_entries(user_id, meal_date);
CREATE INDEX idx_meal_foods_meal_entry_id ON public.meal_foods(meal_entry_id);
CREATE INDEX idx_meal_foods_food_item_id ON public.meal_foods(food_item_id);

-- 8. Functions (MUST be created before RLS policies)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'patient')::public.user_role
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

-- 9. Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_foods ENABLE ROW LEVEL SECURITY;

-- 10. RLS Policies (Pattern 1: Core User Tables)
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- RLS Policies (Pattern 2: Simple User Ownership)
CREATE POLICY "users_manage_own_medical_profiles"
ON public.medical_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_weight_entries"
ON public.weight_entries
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_meal_entries"
ON public.meal_entries
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- RLS Policies (Pattern 4: Public Read, Private Write)
CREATE POLICY "public_can_read_food_items"
ON public.food_items
FOR SELECT
TO public
USING (true);

CREATE POLICY "authenticated_users_can_create_food_items"
ON public.food_items
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "users_manage_own_created_food_items"
ON public.food_items
FOR ALL
TO authenticated
USING (created_by = auth.uid() OR created_by IS NULL)
WITH CHECK (created_by = auth.uid() OR created_by IS NULL);

-- RLS Policies (Pattern 7: Complex Relationships for meal_foods)
CREATE OR REPLACE FUNCTION public.can_access_meal_food(meal_food_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.meal_entries me
    JOIN public.meal_foods mf ON me.id = mf.meal_entry_id
    WHERE mf.id = meal_food_uuid
    AND me.user_id = auth.uid()
)
$$;

CREATE POLICY "users_access_own_meal_foods"
ON public.meal_foods
FOR ALL
TO authenticated
USING (public.can_access_meal_food(id))
WITH CHECK (EXISTS (
    SELECT 1 FROM public.meal_entries me
    WHERE me.id = meal_foods.meal_entry_id
    AND me.user_id = auth.uid()
));

-- 11. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_medical_profiles_updated_at
  BEFORE UPDATE ON public.medical_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 12. Complete Mock Data for Authentication Module
DO $$
DECLARE
    patient_uuid UUID := gen_random_uuid();
    doctor_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    nutritionist_uuid UUID := gen_random_uuid();
    
    -- Food items for testing
    apple_id UUID := gen_random_uuid();
    banana_id UUID := gen_random_uuid();
    chicken_breast_id UUID := gen_random_uuid();
    
    -- Meal entry for testing
    breakfast_entry_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with all required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (patient_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'patient@nutrivita.com', crypt('patient123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Patient", "role": "patient"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
         
        (doctor_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'doctor@nutrivita.com', crypt('doctor123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dr. Sarah Wilson", "role": "doctor"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
         
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@nutrivita.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
         
        (nutritionist_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'nutritionist@nutrivita.com', crypt('nutri123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Lisa Rodriguez", "role": "nutritionist"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create medical profiles for users
    INSERT INTO public.medical_profiles (
        user_id, height_cm, current_weight_kg, target_weight_kg, activity_level, goal_type,
        allergies, medical_conditions, dietary_restrictions,
        bmr_calories, target_daily_calories, target_protein_g, target_carbs_g, target_fat_g
    ) VALUES
        (patient_uuid, 175.0, 75.5, 70.0, 'moderately_active'::public.activity_level, 'weight_loss'::public.goal_type,
         ARRAY['peanuts', 'shellfish'], ARRAY['diabetes type 2'], ARRAY['gluten-free'],
         1650, 2100, 105, 262, 70),
         
        (doctor_uuid, 168.0, 62.0, 62.0, 'lightly_active'::public.activity_level, 'maintain_weight'::public.goal_type,
         ARRAY[]::TEXT[], ARRAY[]::TEXT[], ARRAY[]::TEXT[],
         1420, 1850, 92, 231, 62);

    -- Add some weight tracking entries
    INSERT INTO public.weight_entries (user_id, weight_kg, body_fat_percentage, notes, recorded_at) VALUES
        (patient_uuid, 76.2, 18.5, 'Starting weight', CURRENT_DATE - INTERVAL '30 days'),
        (patient_uuid, 75.8, 18.2, 'Good progress', CURRENT_DATE - INTERVAL '23 days'),
        (patient_uuid, 75.5, 17.9, 'Feeling great!', CURRENT_DATE - INTERVAL '16 days'),
        (patient_uuid, 75.1, 17.6, 'On track', CURRENT_DATE - INTERVAL '9 days'),
        (patient_uuid, 74.8, 17.3, 'Almost there', CURRENT_DATE - INTERVAL '2 days');

    -- Add sample food items
    INSERT INTO public.food_items (id, name, brand, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_verified) VALUES
        (apple_id, 'Apple', 'Generic', 52, 0.3, 14, 0.2, 2.4, true),
        (banana_id, 'Banana', 'Generic', 89, 1.1, 23, 0.3, 2.6, true),
        (chicken_breast_id, 'Chicken Breast', 'Generic', 165, 31, 0, 3.6, 0, true);

    -- Add sample meal entry with foods
    INSERT INTO public.meal_entries (id, user_id, meal_type, meal_date, meal_time, notes) VALUES
        (breakfast_entry_id, patient_uuid, 'breakfast'::public.meal_type, CURRENT_DATE, '08:30:00', 'Healthy breakfast');

    INSERT INTO public.meal_foods (meal_entry_id, food_item_id, quantity_grams, calories, protein_g, carbs_g, fat_g) VALUES
        (breakfast_entry_id, apple_id, 150, 78, 0.45, 21, 0.3),
        (breakfast_entry_id, banana_id, 120, 107, 1.32, 27.6, 0.36);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;