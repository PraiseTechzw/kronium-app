-- Enhanced Bookings Table Schema
-- This script adds new fields to support the enhanced booking form

-- Add new columns to the bookings table
ALTER TABLE bookings 
ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'Normal',
ADD COLUMN IF NOT EXISTS is_urgent BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS emergency_contact VARCHAR(50),
ADD COLUMN IF NOT EXISTS contact_person VARCHAR(255);

-- Create indexes for the new fields
CREATE INDEX IF NOT EXISTS idx_bookings_priority ON bookings(priority);
CREATE INDEX IF NOT EXISTS idx_bookings_is_urgent ON bookings(is_urgent);
CREATE INDEX IF NOT EXISTS idx_bookings_emergency_contact ON bookings(emergency_contact);

-- Update the RLS policies to include the new fields
-- (The existing policies should still work, but we can add specific ones if needed)

-- Add a policy for urgent bookings (admins can see all urgent bookings)
CREATE POLICY "Admins can see urgent bookings" ON bookings
  FOR SELECT USING (
    is_urgent = true AND 
    EXISTS (SELECT 1 FROM admins WHERE email = (SELECT email FROM users WHERE id::text = auth.uid()::text))
  );

-- Add comments to document the new fields
COMMENT ON COLUMN bookings.priority IS 'Booking priority level: Low, Normal, High, Urgent';
COMMENT ON COLUMN bookings.is_urgent IS 'Whether this is an emergency service request';
COMMENT ON COLUMN bookings.emergency_contact IS 'Emergency contact phone number';
COMMENT ON COLUMN bookings.contact_person IS 'Contact person name if different from client';

SELECT 'Enhanced bookings schema updated successfully!' as message;