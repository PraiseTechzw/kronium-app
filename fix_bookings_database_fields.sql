-- Fix Bookings Database Field Names and Add New Columns
-- This script ensures the bookings table has the correct structure

-- First, let's check if the table exists and what columns it has
DO $$
BEGIN
    -- Add new columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'priority') THEN
        ALTER TABLE bookings ADD COLUMN priority VARCHAR(20) DEFAULT 'Normal';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'is_urgent') THEN
        ALTER TABLE bookings ADD COLUMN is_urgent BOOLEAN DEFAULT FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'emergency_contact') THEN
        ALTER TABLE bookings ADD COLUMN emergency_contact VARCHAR(50);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'contact_person') THEN
        ALTER TABLE bookings ADD COLUMN contact_person VARCHAR(255);
    END IF;
END $$;

-- Create indexes for the new fields
CREATE INDEX IF NOT EXISTS idx_bookings_priority ON bookings(priority);
CREATE INDEX IF NOT EXISTS idx_bookings_is_urgent ON bookings(is_urgent);
CREATE INDEX IF NOT EXISTS idx_bookings_emergency_contact ON bookings(emergency_contact);

-- Update RLS policies to handle urgent bookings
CREATE POLICY IF NOT EXISTS "Admins can see urgent bookings" ON bookings
  FOR SELECT USING (
    is_urgent = true AND 
    EXISTS (SELECT 1 FROM admins WHERE email = (SELECT email FROM users WHERE id::text = auth.uid()::text))
  );

-- Add comments to document the new fields
COMMENT ON COLUMN bookings.priority IS 'Booking priority level: Low, Normal, High, Urgent';
COMMENT ON COLUMN bookings.is_urgent IS 'Whether this is an emergency service request';
COMMENT ON COLUMN bookings.emergency_contact IS 'Emergency contact phone number';
COMMENT ON COLUMN bookings.contact_person IS 'Contact person name if different from client';

SELECT 'Bookings database fields updated successfully!' as message;