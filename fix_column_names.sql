-- Fix Column Naming Issues in Database
-- The database has inconsistent column naming (createdat vs created_at)

-- First, let's check the current column names
SELECT 'Current services table columns:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'services' 
ORDER BY ordinal_position;

-- Check if we have createdat or created_at
DO $$
BEGIN
    -- Rename createdat to created_at if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'services' AND column_name = 'createdat') THEN
        ALTER TABLE services RENAME COLUMN createdat TO created_at;
        RAISE NOTICE 'Renamed createdat to created_at';
    END IF;
    
    -- Rename updatedat to updated_at if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'services' AND column_name = 'updatedat') THEN
        ALTER TABLE services RENAME COLUMN updatedat TO updated_at;
        RAISE NOTICE 'Renamed updatedat to updated_at';
    END IF;
    
    -- Add created_at if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'services' AND column_name = 'created_at') THEN
        ALTER TABLE services ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added created_at column';
    END IF;
    
    -- Add updated_at if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'services' AND column_name = 'updated_at') THEN
        ALTER TABLE services ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column';
    END IF;
END $$;

-- Do the same for other tables that might have this issue
-- Fix users table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'createdat') THEN
        ALTER TABLE users RENAME COLUMN createdat TO created_at;
        RAISE NOTICE 'Renamed users.createdat to created_at';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'updatedat') THEN
        ALTER TABLE users RENAME COLUMN updatedat TO updated_at;
        RAISE NOTICE 'Renamed users.updatedat to updated_at';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'created_at') THEN
        ALTER TABLE users ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added users.created_at column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'updated_at') THEN
        ALTER TABLE users ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added users.updated_at column';
    END IF;
END $$;

-- Fix bookings table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'createdat') THEN
        ALTER TABLE bookings RENAME COLUMN createdat TO created_at;
        RAISE NOTICE 'Renamed bookings.createdat to created_at';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'updatedat') THEN
        ALTER TABLE bookings RENAME COLUMN updatedat TO updated_at;
        RAISE NOTICE 'Renamed bookings.updatedat to updated_at';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'created_at') THEN
        ALTER TABLE bookings ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added bookings.created_at column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'updated_at') THEN
        ALTER TABLE bookings ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added bookings.updated_at column';
    END IF;
END $$;

-- Fix projects table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'createdat') THEN
        ALTER TABLE projects RENAME COLUMN createdat TO created_at;
        RAISE NOTICE 'Renamed projects.createdat to created_at';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'updatedat') THEN
        ALTER TABLE projects RENAME COLUMN updatedat TO updated_at;
        RAISE NOTICE 'Renamed projects.updatedat to updated_at';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'created_at') THEN
        ALTER TABLE projects ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added projects.created_at column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'updated_at') THEN
        ALTER TABLE projects ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added projects.updated_at column';
    END IF;
END $$;

-- Update existing records to have proper timestamps if they're null
UPDATE services SET created_at = NOW() WHERE created_at IS NULL;
UPDATE services SET updated_at = NOW() WHERE updated_at IS NULL;

UPDATE users SET created_at = NOW() WHERE created_at IS NULL;
UPDATE users SET updated_at = NOW() WHERE updated_at IS NULL;

UPDATE bookings SET created_at = NOW() WHERE created_at IS NULL;
UPDATE bookings SET updated_at = NOW() WHERE updated_at IS NULL;

UPDATE projects SET created_at = NOW() WHERE created_at IS NULL;
UPDATE projects SET updated_at = NOW() WHERE updated_at IS NULL;

-- Show the final column structure
SELECT 'Final services table columns:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'services' 
ORDER BY ordinal_position;

SELECT 'Column naming fixed successfully!' as message;