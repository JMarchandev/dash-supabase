-- Migration: Add browser sessions support for web navigation widgets

-- Step 1: Create browser_sessions table
CREATE TABLE browser_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  url TEXT NOT NULL,
  title TEXT,
  favicon_url TEXT,
  position INTEGER NOT NULL,
  is_visible BOOLEAN DEFAULT true,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Add constraints and indexes
CREATE INDEX idx_browser_sessions_user ON browser_sessions(user_id);
CREATE INDEX idx_browser_sessions_user_position ON browser_sessions(user_id, position);

-- Step 3: Add trigger to auto-update updated_at
CREATE TRIGGER update_browser_sessions_updated_at
  BEFORE UPDATE ON browser_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Step 4: Enable RLS on browser_sessions table
ALTER TABLE browser_sessions ENABLE ROW LEVEL SECURITY;

-- Step 5: Create RLS policies for browser_sessions
CREATE POLICY "Users can view their own browser sessions"
  ON browser_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own browser sessions"
  ON browser_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own browser sessions"
  ON browser_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own browser sessions"
  ON browser_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- Step 6: Add comments for documentation
COMMENT ON TABLE browser_sessions IS 'Browser sessions store web pages opened as widgets in the dashboard';
COMMENT ON COLUMN browser_sessions.url IS 'URL of the web page to display in the widget';
COMMENT ON COLUMN browser_sessions.title IS 'Title of the web page (extracted from page or user-defined)';
COMMENT ON COLUMN browser_sessions.favicon_url IS 'URL of the favicon for the web page';
COMMENT ON COLUMN browser_sessions.position IS 'Display order in the browser stack (0-based)';
COMMENT ON COLUMN browser_sessions.is_visible IS 'Whether the session is visible in the stack';
COMMENT ON COLUMN browser_sessions.last_accessed_at IS 'Timestamp of last access to track active sessions';
