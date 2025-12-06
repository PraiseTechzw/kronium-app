-- ============================================================================
-- KNOWLEDGE BASE TABLES
-- ============================================================================
-- Tables for community-driven Q&A knowledge base

-- Knowledge Questions Table
CREATE TABLE IF NOT EXISTS knowledge_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question TEXT NOT NULL,
  category VARCHAR(50), -- 'General', 'Booking', 'Projects', 'Payment', 'Technical'
  authorid VARCHAR(255), -- User ID who asked the question
  authorname VARCHAR(255), -- User name for display
  ispinned BOOLEAN DEFAULT false,
  viewcount INTEGER DEFAULT 0,
  createdat TIMESTAMP DEFAULT NOW(),
  updatedat TIMESTAMP DEFAULT NOW()
);

-- Knowledge Answers Table
CREATE TABLE IF NOT EXISTS knowledge_answers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  questionid UUID REFERENCES knowledge_questions(id) ON DELETE CASCADE,
  answer TEXT NOT NULL,
  authorid VARCHAR(255), -- User ID who provided the answer
  authorname VARCHAR(255), -- User name for display
  helpfulcount INTEGER DEFAULT 0,
  isaccepted BOOLEAN DEFAULT false, -- Marked as accepted answer by question author
  createdat TIMESTAMP DEFAULT NOW(),
  updatedat TIMESTAMP DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_knowledge_questions_category ON knowledge_questions(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_questions_ispinned ON knowledge_questions(ispinned);
CREATE INDEX IF NOT EXISTS idx_knowledge_questions_viewcount ON knowledge_questions(viewcount);
CREATE INDEX IF NOT EXISTS idx_knowledge_answers_questionid ON knowledge_answers(questionid);
CREATE INDEX IF NOT EXISTS idx_knowledge_answers_isaccepted ON knowledge_answers(isaccepted);

-- Enable Row Level Security
ALTER TABLE knowledge_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_answers ENABLE ROW LEVEL SECURITY;

-- RLS Policies for knowledge_questions
-- Everyone can read questions
CREATE POLICY "Anyone can view knowledge questions"
  ON knowledge_questions FOR SELECT
  USING (true);

-- Authenticated users can insert questions
CREATE POLICY "Authenticated users can create questions"
  ON knowledge_questions FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Users can update their own questions
CREATE POLICY "Users can update their own questions"
  ON knowledge_questions FOR UPDATE
  USING (auth.uid()::text = authorid OR auth.jwt() ->> 'role' = 'admin');

-- Admins can delete questions
CREATE POLICY "Admins can delete questions"
  ON knowledge_questions FOR DELETE
  USING (auth.jwt() ->> 'role' = 'admin');

-- RLS Policies for knowledge_answers
-- Everyone can read answers
CREATE POLICY "Anyone can view knowledge answers"
  ON knowledge_answers FOR SELECT
  USING (true);

-- Authenticated users can insert answers
CREATE POLICY "Authenticated users can create answers"
  ON knowledge_answers FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Users can update their own answers
CREATE POLICY "Users can update their own answers"
  ON knowledge_answers FOR UPDATE
  USING (auth.uid()::text = authorid OR auth.jwt() ->> 'role' = 'admin');

-- Users can delete their own answers, admins can delete any
CREATE POLICY "Users can delete their own answers"
  ON knowledge_answers FOR DELETE
  USING (auth.uid()::text = authorid OR auth.jwt() ->> 'role' = 'admin');

-- Trigger to update updatedat timestamp
CREATE OR REPLACE FUNCTION update_knowledge_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updatedat = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_knowledge_questions_updated_at
  BEFORE UPDATE ON knowledge_questions
  FOR EACH ROW
  EXECUTE FUNCTION update_knowledge_updated_at();

CREATE TRIGGER update_knowledge_answers_updated_at
  BEFORE UPDATE ON knowledge_answers
  FOR EACH ROW
  EXECUTE FUNCTION update_knowledge_updated_at();

-- Insert some sample questions
INSERT INTO knowledge_questions (question, category, authorname, ispinned) VALUES
  ('How do I book a service?', 'Booking', 'Admin', true),
  ('What payment methods do you accept?', 'Payment', 'Admin', true),
  ('How can I track my project progress?', 'Projects', 'Admin', true),
  ('What services do you offer?', 'General', 'Admin', false),
  ('How long does a typical project take?', 'Projects', 'Admin', false),
  ('Can I cancel my booking?', 'Booking', 'Admin', false),
  ('How do I contact support?', 'General', 'Admin', false),
  ('What is the warranty on your services?', 'Technical', 'Admin', false)
ON CONFLICT DO NOTHING;

-- Insert some sample answers
INSERT INTO knowledge_answers (questionid, answer, authorname, isaccepted)
SELECT 
  kq.id,
  'You can book a service by browsing our services page, selecting a service, and choosing your preferred date and time. Fill in the booking form and submit your request.',
  'Admin',
  true
FROM knowledge_questions kq
WHERE kq.question = 'How do I book a service?'
ON CONFLICT DO NOTHING;

INSERT INTO knowledge_answers (questionid, answer, authorname, isaccepted)
SELECT 
  kq.id,
  'We accept various payment methods including credit cards, debit cards, bank transfers, and mobile money. Payment details will be provided during the booking process.',
  'Admin',
  true
FROM knowledge_questions kq
WHERE kq.question = 'What payment methods do you accept?'
ON CONFLICT DO NOTHING;

INSERT INTO knowledge_answers (questionid, answer, authorname, isaccepted)
SELECT 
  kq.id,
  'You can track your project progress in the Projects section of the app. You will see real-time updates, photos, and status changes as your project progresses.',
  'Admin',
  true
FROM knowledge_questions kq
WHERE kq.question = 'How can I track my project progress?'
ON CONFLICT DO NOTHING;

