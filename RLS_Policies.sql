ALTER TABLE profiles
    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by users who created them."
  ON profiles for SELECT
  USING ( auth.uid() = profile_id );

CREATE POLICY "Users can insert their own profile." on profiles
    FOR INSERT WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Users can update their own profile." on profiles
    FOR UPDATE USING (auth.uid() = profile_id);