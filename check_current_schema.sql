-- Check current database schema
SELECT 'Current bookings table structure:' as info;

SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'bookings' 
ORDER BY ordinal_position;

-- Also check if the table exists at all
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') 
        THEN 'bookings table EXISTS' 
        ELSE 'bookings table DOES NOT EXIST' 
    END as table_status;