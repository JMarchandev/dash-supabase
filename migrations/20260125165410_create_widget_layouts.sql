-- Table for widget layouts (react-grid-layout)
CREATE TABLE widget_layouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  breakpoint TEXT NOT NULL CHECK (breakpoint IN ('lg', 'md', 'sm')),
  layout_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, breakpoint)
);

-- Index for fast queries
CREATE INDEX idx_widget_layouts_user ON widget_layouts(user_id);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_widget_layouts_updated_at
  BEFORE UPDATE ON widget_layouts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
