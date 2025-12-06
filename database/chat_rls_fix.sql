-- ============================================================================
-- CHAT RLS POLICY FIX
-- ============================================================================
-- This file fixes the RLS policies for chat_rooms and chat_messages tables
-- to use the correct database column names (lowercase, no underscores)
-- ============================================================================

-- Drop existing chat room policies
DROP POLICY IF EXISTS "Users can read own chat rooms" ON chat_rooms;
DROP POLICY IF EXISTS "Users can create own chat rooms" ON chat_rooms;

-- Recreate with correct column name: customerid (not customerId)
CREATE POLICY "Users can read own chat rooms" ON chat_rooms
  FOR SELECT USING (customerid = auth.uid()::text);

-- Allow users to create their own chat rooms
CREATE POLICY "Users can create own chat rooms" ON chat_rooms
  FOR INSERT WITH CHECK (customerid = auth.uid()::text);

-- Drop existing chat message policies
DROP POLICY IF EXISTS "Users can read messages in own chat rooms" ON chat_messages;
DROP POLICY IF EXISTS "Users can send messages" ON chat_messages;

-- Recreate with correct column names: chatroomid (not chatRoomId)
CREATE POLICY "Users can read messages in own chat rooms" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_rooms 
      WHERE id = chat_messages.chatroomid 
      AND (customerid = auth.uid()::text OR senderid = auth.uid()::text)
    )
  );

CREATE POLICY "Users can send messages" ON chat_messages
  FOR INSERT WITH CHECK (senderid = auth.uid()::text);

