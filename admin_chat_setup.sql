-- Admin Chat System Setup
-- This script creates the necessary tables and policies for the admin chat system

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
  message TEXT NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_messages_is_admin ON chat_messages(is_admin);

-- Enable Row Level Security
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
-- Users can read their own messages
CREATE POLICY "Users can read own messages" ON chat_messages
  FOR SELECT USING (
    user_id = auth.uid()::uuid OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND role = 'admin')
  );

-- Users can insert their own messages
CREATE POLICY "Users can insert own messages" ON chat_messages
  FOR INSERT WITH CHECK (
    user_id = auth.uid()::uuid OR
    (is_admin = true AND EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND role = 'admin'))
  );

-- Admins can read all messages
CREATE POLICY "Admins can read all messages" ON chat_messages
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND role = 'admin')
  );

-- Admins can insert messages for any user
CREATE POLICY "Admins can insert messages" ON chat_messages
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND role = 'admin')
  );

-- Add update trigger
CREATE TRIGGER update_chat_messages_updated_at 
  BEFORE UPDATE ON chat_messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable real-time
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;

-- Create chat_rooms table for better organization (optional)
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
  status VARCHAR(20) DEFAULT 'active', -- 'active', 'closed', 'archived'
  last_message_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Create indexes for chat_rooms
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user_id ON chat_rooms(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_status ON chat_rooms(status);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_last_message_at ON chat_rooms(last_message_at);

-- Enable RLS for chat_rooms
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chat_rooms
CREATE POLICY "Users can read own chat room" ON chat_rooms
  FOR SELECT USING (
    user_id = auth.uid()::uuid OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND role = 'admin')
  );

CREATE POLICY "Admins can manage chat rooms" ON chat_rooms
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND role = 'admin')
  );

-- Add update trigger for chat_rooms
CREATE TRIGGER update_chat_rooms_updated_at 
  BEFORE UPDATE ON chat_rooms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable real-time for chat_rooms
ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;

-- Function to automatically create/update chat room when message is sent
CREATE OR REPLACE FUNCTION handle_new_chat_message()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert or update chat room
  INSERT INTO chat_rooms (user_id, admin_id, last_message_at)
  VALUES (NEW.user_id, NEW.admin_id, NEW.created_at)
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    admin_id = NEW.admin_id,
    last_message_at = NEW.created_at,
    updated_at = NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for chat room management
CREATE TRIGGER on_chat_message_insert
  AFTER INSERT ON chat_messages
  FOR EACH ROW EXECUTE FUNCTION handle_new_chat_message();

SELECT 'Admin chat system setup completed successfully!' as message;