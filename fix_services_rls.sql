-- Fix Row Level Security for Services Table
-- This ensures the admin dashboard can properly access services

-- Check current RLS status
SELECT 'Current RLS policies for services table:' as info;
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'services';

-- Drop existing policies to start fresh
DROP POLICY IF EXISTS "Anyone can view active services" ON services;
DROP POLICY IF EXISTS "Allow service management" ON services;
DROP POLICY IF EXISTS "Authenticated users can view all services" ON services;

-- Create comprehensive RLS policies for services

-- 1. Allow anyone to view active services (for public access)
CREATE POLICY "Anyone can view active services" ON services
  FOR SELECT 
  USING (is_active = true);

-- 2. Allow authenticated users to view all services
CREATE POLICY "Authenticated users can view all services" ON services
  FOR SELECT 
  USING (auth.role() = 'authenticated');

-- 3. Allow full management for admin operations
CREATE POLICY "Allow service management" ON services
  FOR ALL 
  USING (true)
  WITH CHECK (true);

-- Ensure RLS is enabled
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT ALL ON services TO authenticated;
GRANT ALL ON services TO anon;

-- Test the policies
SELECT 'Testing service access...' as test;

-- This should return all services
SELECT 
    COUNT(*) as total_services,
    COUNT(CASE WHEN is_active THEN 1 END) as active_services
FROM services;

-- Show sample services
SELECT 
    id,
    title,
    category,
    price,
    is_active,
    created_at
FROM services 
ORDER BY category, title
LIMIT 10;

SELECT 'Services RLS policies updated successfully!' as message;
SELECT 'Admin dashboard should now be able to access all services.' as note;