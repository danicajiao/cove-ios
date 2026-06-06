-- Reverse of 000002_profile_schema_v2.up.sql
-- Note: email data cannot be recovered (was dropped). Down migration restores
-- the column with an empty-string default for structural completeness only.

-- ── Step 1: Drop new user_id FKs from child tables ────────────────────────────
ALTER TABLE profile.favorites DROP CONSTRAINT favorites_user_id_fkey;
ALTER TABLE profile.favorites DROP CONSTRAINT favorites_pkey;
ALTER TABLE profile.follows   DROP CONSTRAINT follows_user_id_fkey;
ALTER TABLE profile.interests DROP CONSTRAINT interests_user_id_fkey;
ALTER TABLE profile.interests DROP CONSTRAINT interests_pkey;
ALTER TABLE profile.events    DROP CONSTRAINT events_user_id_fkey;

-- ── Step 2: Restore profile.users ─────────────────────────────────────────────
ALTER TABLE profile.users DROP CONSTRAINT users_pkey;
ALTER TABLE profile.users DROP CONSTRAINT users_auth_uid_key;
ALTER TABLE profile.users RENAME COLUMN auth_uid TO uid;
ALTER TABLE profile.users ADD COLUMN email text NOT NULL DEFAULT '';
ALTER TABLE profile.users ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE profile.users DROP COLUMN id;
ALTER TABLE profile.users ADD PRIMARY KEY (uid);

-- ── Step 3: Restore uid text column in child tables ───────────────────────────

-- profile.favorites
ALTER TABLE profile.favorites ADD COLUMN uid text;
UPDATE profile.favorites f SET uid = u.uid FROM profile.users u WHERE f.user_id = u.id;
ALTER TABLE profile.favorites ALTER COLUMN uid SET NOT NULL;
ALTER TABLE profile.favorites DROP COLUMN user_id;
ALTER TABLE profile.favorites ADD PRIMARY KEY (uid, item_id);
ALTER TABLE profile.favorites ADD CONSTRAINT favorites_uid_fkey
    FOREIGN KEY (uid) REFERENCES profile.users(uid) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.favorites_user_id_created_at_idx;
CREATE INDEX ON profile.favorites (uid, created_at DESC);

-- profile.follows
ALTER TABLE profile.follows ADD COLUMN uid text;
UPDATE profile.follows f SET uid = u.uid FROM profile.users u WHERE f.user_id = u.id;
ALTER TABLE profile.follows ALTER COLUMN uid SET NOT NULL;
ALTER TABLE profile.follows DROP COLUMN user_id;
ALTER TABLE profile.follows ADD CONSTRAINT follows_uid_fkey
    FOREIGN KEY (uid) REFERENCES profile.users(uid) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.follows_user_id_created_at_idx;
CREATE INDEX ON profile.follows (uid, created_at DESC);

-- profile.interests
ALTER TABLE profile.interests ADD COLUMN uid text;
UPDATE profile.interests i SET uid = u.uid FROM profile.users u WHERE i.user_id = u.id;
ALTER TABLE profile.interests ALTER COLUMN uid SET NOT NULL;
ALTER TABLE profile.interests DROP COLUMN user_id;
ALTER TABLE profile.interests ADD PRIMARY KEY (uid, category_id);
ALTER TABLE profile.interests ADD CONSTRAINT interests_uid_fkey
    FOREIGN KEY (uid) REFERENCES profile.users(uid) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.interests_user_id_idx;
CREATE INDEX ON profile.interests (uid);

-- profile.events
ALTER TABLE profile.events ADD COLUMN uid text;
UPDATE profile.events e SET uid = u.uid FROM profile.users u WHERE e.user_id = u.id;
ALTER TABLE profile.events ALTER COLUMN uid SET NOT NULL;
ALTER TABLE profile.events DROP COLUMN user_id;
ALTER TABLE profile.events ADD CONSTRAINT events_uid_fkey
    FOREIGN KEY (uid) REFERENCES profile.users(uid) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.events_user_id_created_at_idx;
DROP INDEX IF EXISTS profile.events_user_id_category_id_idx;
DROP INDEX IF EXISTS profile.events_user_id_item_id_idx;
CREATE INDEX ON profile.events (uid, created_at DESC);
CREATE INDEX ON profile.events (uid, category_id) WHERE category_id IS NOT NULL;
CREATE INDEX ON profile.events (uid, item_id)     WHERE item_id     IS NOT NULL;
