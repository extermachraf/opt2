-- Location: supabase/migrations/20260202000003_create_avatars_storage_bucket.sql
-- Purpose: Create storage bucket for user profile avatars/images
-- Integration Type: Addition - Adding storage capability for profile pictures
-- Dependencies: user_profiles table (existing)

-- Create storage bucket for profile avatars (public bucket for user profile images)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true, -- Public bucket so profile images can be displayed
    5242880, -- 5MB limit per image
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for avatars storage bucket
-- Pattern 1: Anyone can view profile avatars (public bucket)
CREATE POLICY "anyone_can_view_avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Pattern 2: Authenticated users can upload avatars to their own folder
CREATE POLICY "users_upload_own_avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = 'profiles'
    AND (storage.foldername(name))[2] = auth.uid()::text
);

-- Pattern 3: Users can update their own avatars
CREATE POLICY "users_update_own_avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = 'profiles'
    AND (storage.foldername(name))[2] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = 'profiles'
    AND (storage.foldername(name))[2] = auth.uid()::text
);

-- Pattern 4: Users can delete their own avatars
CREATE POLICY "users_delete_own_avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = 'profiles'
    AND (storage.foldername(name))[2] = auth.uid()::text
);

-- Verification block
DO $$
DECLARE
    bucket_exists BOOLEAN;
    policy_count INTEGER;
BEGIN
    -- Check if bucket was created
    SELECT EXISTS (
        SELECT 1 FROM storage.buckets WHERE id = 'avatars'
    ) INTO bucket_exists;
    
    -- Count policies for avatars bucket
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'storage'
    AND tablename = 'objects'
    AND policyname LIKE '%avatars%';
    
    -- Log results
    RAISE NOTICE 'Avatars bucket verification:';
    RAISE NOTICE '- Bucket exists: %', bucket_exists;
    RAISE NOTICE '- Policies created: %', policy_count;
    
    IF bucket_exists AND policy_count >= 4 THEN
        RAISE NOTICE '✅ SUCCESS: Avatars storage bucket created with % RLS policies', policy_count;
    ELSE
        RAISE NOTICE '⚠️ WARNING: Bucket creation may have issues';
        IF NOT bucket_exists THEN
            RAISE NOTICE '  - Bucket does not exist';
        END IF;
        IF policy_count < 4 THEN
            RAISE NOTICE '  - Expected 4 policies, found %', policy_count;
        END IF;
    END IF;
END $$;

-- Add comment for documentation
COMMENT ON TABLE storage.buckets IS 'Storage buckets including avatars bucket for user profile images (created 2026-02-02)';

