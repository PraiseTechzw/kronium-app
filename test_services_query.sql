-- Test Services Query
-- This query matches what the admin dashboard is trying to do

-- Check what columns actually exist
SELECT 'Current services table structure:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'services' 
ORDER BY ordinal_position;

-- Test the exact query the admin dashboard uses
SELECT 'Testing services query...' as test;
SELECT * FROM services ORDER BY createdat DESC LIMIT 5;

-- Check if we have any services
SELECT 'Service count:' as info, COUNT(*) as total FROM services;

-- Show sample services with key fields
SELECT 
    id,
    title,
    category,
    price,
    is_active,
    createdat
FROM services 
WHERE is_active = true
ORDER BY createdat DESC
LIMIT 10;