-- Update Services Table for Image Upload Support
-- This script modifies the services table to better support image uploads

-- Add new columns for image handling
ALTER TABLE services 
ADD COLUMN IF NOT EXISTS image_path TEXT,
ADD COLUMN IF NOT EXISTS image_filename TEXT,
ADD COLUMN IF NOT EXISTS image_size INTEGER,
ADD COLUMN IF NOT EXISTS image_type TEXT;

-- Update existing services to have proper image handling
-- For now, keep image_url for backward compatibility but prefer image_path for new uploads

-- Create a storage bucket for service images (if using Supabase Storage)
-- This would typically be done in the Supabase dashboard or via API
-- INSERT INTO storage.buckets (id, name, public) VALUES ('service-images', 'service-images', true);

-- Create RLS policies for the storage bucket (if using Supabase Storage)
-- CREATE POLICY "Anyone can view service images" ON storage.objects FOR SELECT USING (bucket_id = 'service-images');
-- CREATE POLICY "Authenticated users can upload service images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'service-images' AND auth.role() = 'authenticated');
-- CREATE POLICY "Authenticated users can update service images" ON storage.objects FOR UPDATE USING (bucket_id = 'service-images' AND auth.role() = 'authenticated');
-- CREATE POLICY "Authenticated users can delete service images" ON storage.objects FOR DELETE USING (bucket_id = 'service-images' AND auth.role() = 'authenticated');

-- Add index for better performance on image queries
CREATE INDEX IF NOT EXISTS idx_services_image_path ON services(image_path);

-- Update the services table to ensure all required fields are present
ALTER TABLE services 
ALTER COLUMN title SET NOT NULL,
ALTER COLUMN description SET NOT NULL,
ALTER COLUMN price SET NOT NULL,
ALTER COLUMN category SET NOT NULL;

-- Ensure proper constraints
ALTER TABLE services 
ADD CONSTRAINT IF NOT EXISTS check_price_positive CHECK (price >= 0);

SELECT 'Services table updated for image upload support!' as message;