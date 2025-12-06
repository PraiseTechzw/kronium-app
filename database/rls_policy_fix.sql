-- ============================================================================
-- RLS POLICY FIX FOR USERS TABLE
-- ============================================================================
-- This file contains the missing INSERT policy for the users table
-- Run this in your Supabase SQL Editor to fix the RLS issue
-- ============================================================================

-- Allow authenticated users to insert their own user record
-- The id must match their auth.uid() from Supabase Auth
CREATE POLICY "Users can insert own data" ON users
  FOR INSERT 
  WITH CHECK (auth.uid()::text = id::text);

-- Alternative: Allow any authenticated user to create a user record
-- (if you want to allow users to create records for others, use this instead)
-- CREATE POLICY "Authenticated users can insert" ON users
--   FOR INSERT 
--   WITH CHECK (auth.uid() IS NOT NULL);

