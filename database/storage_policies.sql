-- ============================================================================
-- KRONIUM APP - DETAILED STORAGE POLICIES
-- ============================================================================
-- Advanced storage policies for fine-grained access control
-- ============================================================================

-- ============================================================================
-- PROFILE IMAGES POLICIES
-- ============================================================================

-- Allow users to upload their own profile image
CREATE POLICY "Users can upload profile images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'profile_images' AND
  auth.role() = 'authenticated'
);

-- Allow users to view any profile image
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'profile_images'
);

-- Allow users to update/delete their own profile image
CREATE POLICY "Users can manage own profile image"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'profile_images' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Users can delete own profile image"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'profile_images' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- ============================================================================
-- SERVICE IMAGES/VIDEOS POLICIES
-- ============================================================================

-- Allow admins to upload service media
CREATE POLICY "Admins can upload service media"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  (
    (storage.foldername(name))[1] = 'service_images' OR
    (storage.foldername(name))[1] = 'service_videos'
  ) AND
  EXISTS (
    SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
  )
);

-- Allow public to view service media
CREATE POLICY "Public can view service media"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'public' AND
  (
    (storage.foldername(name))[1] = 'service_images' OR
    (storage.foldername(name))[1] = 'service_videos'
  )
);

-- Allow admins to manage service media
CREATE POLICY "Admins can manage service media"
ON storage.objects FOR ALL
USING (
  bucket_id = 'public' AND
  (
    (storage.foldername(name))[1] = 'service_images' OR
    (storage.foldername(name))[1] = 'service_videos'
  ) AND
  EXISTS (
    SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
  )
);

-- ============================================================================
-- PROJECT MEDIA POLICIES
-- ============================================================================

-- Allow authenticated users to upload project media
CREATE POLICY "Users can upload project media"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  (
    (storage.foldername(name))[1] = 'project_media' OR
    (storage.foldername(name))[1] = 'project_documents'
  ) AND
  auth.role() = 'authenticated'
);

-- Allow users to view project media
CREATE POLICY "Authenticated users can view project media"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'public' AND
  (
    (storage.foldername(name))[1] = 'project_media' OR
    (storage.foldername(name))[1] = 'project_documents'
  ) AND
  auth.role() = 'authenticated'
);

-- Allow admins to manage all project media
CREATE POLICY "Admins can manage project media"
ON storage.objects FOR ALL
USING (
  bucket_id = 'public' AND
  (
    (storage.foldername(name))[1] = 'project_media' OR
    (storage.foldername(name))[1] = 'project_documents'
  ) AND
  EXISTS (
    SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
  )
);

-- ============================================================================
-- BOOKING ATTACHMENTS POLICIES
-- ============================================================================

-- Allow authenticated users to upload booking attachments
CREATE POLICY "Users can upload booking attachments"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'booking_attachments' AND
  auth.role() = 'authenticated'
);

-- Allow users and admins to view booking attachments
CREATE POLICY "Authenticated users can view booking attachments"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'booking_attachments' AND
  auth.role() = 'authenticated'
);

-- ============================================================================
-- CHAT ATTACHMENTS POLICIES
-- ============================================================================

-- Allow authenticated users to upload chat attachments
CREATE POLICY "Users can upload chat attachments"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'chat_attachments' AND
  auth.role() = 'authenticated'
);

-- Allow authenticated users to view chat attachments
CREATE POLICY "Authenticated users can view chat attachments"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'chat_attachments' AND
  auth.role() = 'authenticated'
);

-- ============================================================================
-- FILE SIZE VALIDATION TRIGGER
-- ============================================================================

-- Function to validate file before upload
CREATE OR REPLACE FUNCTION validate_storage_object()
RETURNS TRIGGER AS $$
DECLARE
  max_size BIGINT := 52428800; -- 50 MB
  file_size BIGINT;
BEGIN
  -- Get file size from metadata
  file_size := (NEW.metadata->>'size')::bigint;
  
  -- Validate file size
  IF file_size > max_size THEN
    RAISE EXCEPTION 'File size % exceeds maximum allowed size of 50 MB', file_size;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for file validation
CREATE TRIGGER trigger_validate_storage_object
  BEFORE INSERT ON storage.objects
  FOR EACH ROW
  EXECUTE FUNCTION validate_storage_object();

-- ============================================================================
-- END OF STORAGE POLICIES
-- ============================================================================

