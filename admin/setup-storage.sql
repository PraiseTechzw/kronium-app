-- Setup Supabase Storage for Service Images
-- Run this in your Supabase SQL Editor after running the main database setup

-- 1. Create storage bucket for service images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'service-images',
  'service-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- 2. Create RLS policies for the storage bucket
-- Allow anyone to view service images (public bucket)
CREATE POLICY IF NOT EXISTS "Anyone can view service images" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'service-images');

-- Allow authenticated users to upload service images
CREATE POLICY IF NOT EXISTS "Authenticated users can upload service images" 
ON storage.objects FOR INSERT 
WITH CHECK (
  bucket_id = 'service-images' 
  AND auth.role() = 'authenticated'
);

-- Allow authenticated users to update service images
CREATE POLICY IF NOT EXISTS "Authenticated users can update service images" 
ON storage.objects FOR UPDATE 
USING (
  bucket_id = 'service-images' 
  AND auth.role() = 'authenticated'
);

-- Allow authenticated users to delete service images
CREATE POLICY IF NOT EXISTS "Authenticated users can delete service images" 
ON storage.objects FOR DELETE 
USING (
  bucket_id = 'service-images' 
  AND auth.role() = 'authenticated'
);

-- 3. Update services table with new image columns (if not already done)
ALTER TABLE services 
ADD COLUMN IF NOT EXISTS image_path TEXT,
ADD COLUMN IF NOT EXISTS image_filename TEXT,
ADD COLUMN IF NOT EXISTS image_size INTEGER,
ADD COLUMN IF NOT EXISTS image_type TEXT;

-- 4. Add index for better performance on image queries
CREATE INDEX IF NOT EXISTS idx_services_image_path ON services(image_path);

-- 5. Add constraint to ensure price is positive
ALTER TABLE services 
ADD CONSTRAINT IF NOT EXISTS check_price_positive CHECK (price >= 0);

SELECT 'Storage setup completed successfully! You can now upload service images.' as message;