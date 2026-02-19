-- Location: supabase/migrations/20250929153145_add_meal_image_storage.sql
-- Schema Analysis: Existing meal management system with meal_entries and meal_foods tables
-- Integration Type: Addition - Adding image storage capability to existing meal system
-- Dependencies: meal_entries, user_profiles (existing tables)

-- Create storage bucket for meal images (private bucket for user photos)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'meal-images',
    'meal-images',
    false, -- Private bucket for user meal photos
    10485760, -- 10MB limit per image
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
);

-- Add image path column to meal_entries table
ALTER TABLE public.meal_entries
ADD COLUMN image_path TEXT;

-- Add index for image path queries
CREATE INDEX idx_meal_entries_image_path ON public.meal_entries(image_path) WHERE image_path IS NOT NULL;

-- RLS Policies for meal images storage bucket
-- Pattern 1: Users can view their own meal images
CREATE POLICY "users_view_own_meal_images"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'meal-images' 
    AND owner = auth.uid()
);

-- Pattern 2: Users can upload meal images to their folder
CREATE POLICY "users_upload_own_meal_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'meal-images' 
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Pattern 3: Users can update their own meal images
CREATE POLICY "users_update_own_meal_images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'meal-images' 
    AND owner = auth.uid()
)
WITH CHECK (
    bucket_id = 'meal-images' 
    AND owner = auth.uid()
);

-- Pattern 4: Users can delete their own meal images
CREATE POLICY "users_delete_own_meal_images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'meal-images' 
    AND owner = auth.uid()
);