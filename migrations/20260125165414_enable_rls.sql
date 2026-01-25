-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE widget_layouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_credentials ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Policies for widget_layouts
CREATE POLICY "Users can view own layouts"
  ON widget_layouts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own layouts"
  ON widget_layouts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own layouts"
  ON widget_layouts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own layouts"
  ON widget_layouts FOR DELETE
  USING (auth.uid() = user_id);

-- Policies for user_credentials
CREATE POLICY "Users can view own credentials"
  ON user_credentials FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own credentials"
  ON user_credentials FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own credentials"
  ON user_credentials FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own credentials"
  ON user_credentials FOR DELETE
  USING (auth.uid() = user_id);
