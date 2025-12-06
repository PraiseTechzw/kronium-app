-- ============================================================================
-- KRONIUM APP - STORAGE SETUP SCRIPT
-- ============================================================================
-- This script sets up Supabase Storage buckets and policies for the application
-- ============================================================================

-- ============================================================================
-- 1. CREATE STORAGE BUCKETS
-- ============================================================================

-- Public bucket for all media files (images, videos, documents)
-- This bucket allows public access to uploaded files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'public',
  'public',
  true, -- Public access enabled
  52428800, -- 50 MB file size limit
  ARRAY[
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]::text[];

-- ============================================================================
-- 2. STORAGE FOLDER STRUCTURE
-- ============================================================================
-- The following folders will be created automatically when files are uploaded:
-- 
-- public/
--   ├── profile_images/          - User profile pictures
--   ├── service_images/          - Service listing images
--   ├── service_videos/          - Service demonstration videos
--   ├── project_media/           - Project photos and videos
--   ├── project_documents/       - Project-related documents
--   ├── booking_attachments/     - Booking-related files
--   └── chat_attachments/        - Chat message attachments

-- ============================================================================
-- 3. STORAGE POLICIES (ROW LEVEL SECURITY)
-- ============================================================================

-- Policy: Allow public read access to all files
CREATE POLICY "Public Access: Anyone can view files"
ON storage.objects FOR SELECT
USING (bucket_id = 'public');

-- Policy: Authenticated users can upload files
CREATE POLICY "Authenticated users can upload files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  auth.role() = 'authenticated'
);

-- Policy: Users can update their own files
CREATE POLICY "Users can update own files"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'public' AND
  (storage.foldername(name))[1] = 'profile_images' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Policy: Users can delete their own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'public' AND
  (
    -- Users can delete their profile images
    ((storage.foldername(name))[1] = 'profile_images' AND
     (storage.foldername(name))[2] = auth.uid()::text)
    OR
    -- Admins can delete any file
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  )
);

-- Policy: Admins can upload to any folder
CREATE POLICY "Admins can upload anywhere"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  EXISTS (
    SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
  )
);

-- Policy: Admins can update any file
CREATE POLICY "Admins can update any file"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'public' AND
  EXISTS (
    SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
  )
);

-- Policy: Admins can delete any file
CREATE POLICY "Admins can delete any file"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'public' AND
  EXISTS (
    SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
  )
);

-- ============================================================================
-- 4. HELPER FUNCTIONS FOR STORAGE
-- ============================================================================

-- Function to get public URL for a file
CREATE OR REPLACE FUNCTION get_storage_url(bucket_name TEXT, file_path TEXT)
RETURNS TEXT AS $$
DECLARE
  project_url TEXT;
BEGIN
  -- Get the Supabase project URL from environment
  -- Note: Replace with your actual Supabase project URL
  project_url := 'https://ebbrnljnmtoxnxiknfqp.supabase.co';
  
  RETURN project_url || '/storage/v1/object/public/' || bucket_name || '/' || file_path;
END;
$$ LANGUAGE plpgsql;

-- Function to validate file upload
CREATE OR REPLACE FUNCTION validate_file_upload(
  bucket_id TEXT,
  file_name TEXT,
  file_size BIGINT,
  mime_type TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  max_size BIGINT := 52428800; -- 50 MB
  allowed_types TEXT[] := ARRAY[
    'image/jpeg', 'image/png', 'image/gif', 'image/webp',
    'video/mp4', 'video/mpeg', 'video/quicktime',
    'application/pdf'
  ];
BEGIN
  -- Check file size
  IF file_size > max_size THEN
    RAISE EXCEPTION 'File size exceeds maximum allowed size of 50 MB';
  END IF;
  
  -- Check MIME type
  IF NOT (mime_type = ANY(allowed_types)) THEN
    RAISE EXCEPTION 'File type not allowed. Allowed types: %, %, %, %, %, %, %, %',
      allowed_types[1], allowed_types[2], allowed_types[3], allowed_types[4],
      allowed_types[5], allowed_types[6], allowed_types[7], allowed_types[8];
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. STORAGE STATISTICS VIEW
-- ============================================================================

-- View to get storage usage statistics by folder
CREATE OR REPLACE VIEW storage_stats AS
SELECT 
  (storage.foldername(name))[1] AS folder,
  COUNT(*) AS file_count,
  SUM((metadata->>'size')::bigint) AS total_size_bytes,
  ROUND(SUM((metadata->>'size')::bigint) / 1024.0 / 1024.0, 2) AS total_size_mb
FROM storage.objects
WHERE bucket_id = 'public'
GROUP BY (storage.foldername(name))[1]
ORDER BY total_size_bytes DESC;

-- ============================================================================
-- 6. CLEANUP FUNCTION FOR OLD FILES
-- ============================================================================

-- Function to delete files older than specified days
CREATE OR REPLACE FUNCTION cleanup_old_files(
  folder_path TEXT,
  days_old INTEGER DEFAULT 90
)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM storage.objects
  WHERE bucket_id = 'public'
    AND (storage.foldername(name))[1] = folder_path
    AND created_at < NOW() - (days_old || ' days')::INTERVAL;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- END OF STORAGE SETUP
-- ============================================================================

-- To verify storage setup, run:
-- SELECT * FROM storage.buckets;
-- SELECT * FROM storage_stats;
-- SELECT get_storage_url('public', 'service_images/sample.jpg');

