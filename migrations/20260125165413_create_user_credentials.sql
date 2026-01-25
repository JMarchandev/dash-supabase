-- Table for OAuth credentials (encrypted tokens)
CREATE TABLE user_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  service TEXT NOT NULL CHECK (service IN ('spotify', 'google', 'github', 'sentry')),
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  expires_at TIMESTAMPTZ,
  scope TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, service)
);

-- Index for fast queries
CREATE INDEX idx_user_credentials_user_service ON user_credentials(user_id, service);

-- Trigger to auto-update updated_at
CREATE TRIGGER update_user_credentials_updated_at
  BEFORE UPDATE ON user_credentials
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
