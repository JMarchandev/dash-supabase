-- Migration: Add support for multiple Google accounts per user

-- Step 1: Drop existing unique constraint on user_credentials
ALTER TABLE user_credentials DROP CONSTRAINT IF EXISTS user_credentials_user_id_service_key;

-- Step 2: Add account_email column to user_credentials (nullable for existing records)
ALTER TABLE user_credentials ADD COLUMN IF NOT EXISTS account_email TEXT;

-- Step 3: Add account_label column for custom labels (e.g., "Perso", "Pro")
ALTER TABLE user_credentials ADD COLUMN IF NOT EXISTS account_label TEXT;

-- Step 4: For existing Google accounts without email, mark them to be updated
-- They will get their email automatically on next OAuth callback

-- Step 5: Create new unique constraint allowing multiple accounts per service
-- Note: This allows NULL account_email temporarily for existing records
CREATE UNIQUE INDEX IF NOT EXISTS user_credentials_unique_account 
ON user_credentials(user_id, service, account_email) 
WHERE account_email IS NOT NULL;

-- Step 6: Add index for faster queries by account_email
CREATE INDEX IF NOT EXISTS idx_user_credentials_account_email 
ON user_credentials(user_id, service, account_email);

-- Step 7: Comment for documentation
COMMENT ON COLUMN user_credentials.account_email IS 'Email address of the connected account (for multi-account support). NULL for legacy records to be updated.';
COMMENT ON COLUMN user_credentials.account_label IS 'Custom label for the account (e.g., "Personal", "Work")';
