-- Quick fix: Add missing columns to existing bookings table
-- First, let's see what columns currently exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'bookings' 
ORDER BY ordinal_position;

-- Add missing columns (only if they don't exist)
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS serviceName VARCHAR(255);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS clientName VARCHAR(255);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS clientEmail VARCHAR(255);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS clientPhone VARCHAR(50);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS price DECIMAL(10, 2);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS location TEXT;

-- Make sure we have the date column (try both possible names)
DO $$
BEGIN
    -- Try to rename booking_date to date if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'booking_date') THEN
        ALTER TABLE bookings RENAME COLUMN booking_date TO date;
    END IF;
    
    -- Add date column if neither exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'date') THEN
        ALTER TABLE bookings ADD COLUMN date TIMESTAMP NOT NULL DEFAULT NOW();
    END IF;
END $$;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_bookings_clientEmail ON bookings(clientEmail);

SELECT 'Missing columns added successfully!' as message;