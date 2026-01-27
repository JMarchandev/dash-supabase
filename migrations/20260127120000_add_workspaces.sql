-- Migration: Add workspaces support for multiple dashboard pages

-- Step 1: Create workspaces table
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Add constraints and indexes
CREATE UNIQUE INDEX workspaces_user_name_unique ON workspaces(user_id, name);
CREATE INDEX idx_workspaces_user_position ON workspaces(user_id, position);

-- Step 3: Add workspace_id to widget_layouts
ALTER TABLE widget_layouts ADD COLUMN workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE;

-- Step 4: Migrate existing layouts to a default workspace
-- For each user with existing layouts, create a "Dashboard principal" workspace
DO $$
DECLARE
  user_record RECORD;
  new_workspace_id UUID;
BEGIN
  FOR user_record IN 
    SELECT DISTINCT user_id FROM widget_layouts WHERE workspace_id IS NULL
  LOOP
    -- Create default workspace for this user
    INSERT INTO workspaces (user_id, name, position)
    VALUES (user_record.user_id, 'Dashboard principal', 0)
    RETURNING id INTO new_workspace_id;
    
    -- Update all layouts for this user to reference the new workspace
    UPDATE widget_layouts
    SET workspace_id = new_workspace_id
    WHERE user_id = user_record.user_id AND workspace_id IS NULL;
  END LOOP;
END $$;

-- Step 5: Make workspace_id NOT NULL after migration
ALTER TABLE widget_layouts ALTER COLUMN workspace_id SET NOT NULL;

-- Step 6: Drop old unique constraint and add new one with workspace_id
ALTER TABLE widget_layouts DROP CONSTRAINT IF EXISTS widget_layouts_user_id_breakpoint_key;
CREATE UNIQUE INDEX widget_layouts_workspace_breakpoint_unique ON widget_layouts(workspace_id, breakpoint);

-- Step 7: Add trigger to auto-update updated_at on workspaces
CREATE TRIGGER update_workspaces_updated_at
  BEFORE UPDATE ON workspaces
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Step 8: Enable RLS on workspaces table
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- Step 9: Create RLS policies for workspaces
CREATE POLICY "Users can view their own workspaces"
  ON workspaces FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workspaces"
  ON workspaces FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workspaces"
  ON workspaces FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workspaces"
  ON workspaces FOR DELETE
  USING (auth.uid() = user_id);

-- Step 10: Add comments for documentation
COMMENT ON TABLE workspaces IS 'Workspaces allow users to organize widgets across multiple dashboard pages';
COMMENT ON COLUMN workspaces.name IS 'User-defined name for the workspace';
COMMENT ON COLUMN workspaces.position IS 'Display order of workspace tabs (0-based)';
COMMENT ON COLUMN widget_layouts.workspace_id IS 'References the workspace this layout belongs to';
