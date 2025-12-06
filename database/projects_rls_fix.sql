-- ============================================================================
-- PROJECTS RLS POLICY FIX
-- ============================================================================
-- This file fixes the RLS policies for the projects table to ensure:
-- 1. Users can see their own projects (by email match, case-insensitive)
-- 2. Users can see projects where they have bookings
-- 3. Admins can see all projects
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own projects" ON projects;
DROP POLICY IF EXISTS "Admins can read all projects" ON projects;
DROP POLICY IF EXISTS "Admins can update all projects" ON projects;
DROP POLICY IF EXISTS "Admins can delete projects" ON projects;

-- Create improved policy that checks email (case-insensitive) and bookings
-- Note: Database columns are lowercase: clientemail, bookeddates (not camelCase)
CREATE POLICY "Users can read own projects" ON projects
  FOR SELECT USING (
    -- Match by email (case-insensitive) - using actual DB column name: clientemail
    LOWER(clientemail) = LOWER((SELECT email FROM users WHERE id::text = auth.uid()::text))
    OR
    -- Match if user has bookings in bookeddates JSONB array - using actual DB column name
    EXISTS (
      SELECT 1 FROM jsonb_array_elements(bookeddates) AS booking
      WHERE (booking->>'clientId')::text = auth.uid()::text
    )
  );

-- Allow admins to read all projects
CREATE POLICY "Admins can read all projects" ON projects
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  );

-- Allow admins to update all projects
CREATE POLICY "Admins can update all projects" ON projects
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  );

-- Allow admins to delete projects
CREATE POLICY "Admins can delete projects" ON projects
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  );

