-- Enforce unique usernames across all users.
-- Usernames are public-facing handles used for profile lookup and social
-- features. Duplicates would cause ambiguity — enforce at the DB level.
ALTER TABLE profile.users ADD CONSTRAINT users_username_key UNIQUE (username);
