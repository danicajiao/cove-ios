-- profile schema v2
--
-- Changes:
--   profile.users    — add surrogate UUID primary key (id), rename uid → auth_uid,
--                      drop email (Firebase owns auth data; we store only what is ours)
--   profile.favorites,
--   profile.follows,
--   profile.interests,
--   profile.events   — replace uid text FK with user_id uuid FK referencing profile.users(id)
--
-- The rename uid → auth_uid makes the external-identity origin explicit and
-- decouples the schema from a specific auth provider (Firebase today, anything tomorrow).

-- ── Step 1: Add surrogate id column to profile.users ──────────────────────────
-- gen_random_uuid() populates existing rows automatically.
ALTER TABLE profile.users ADD COLUMN id uuid NOT NULL DEFAULT gen_random_uuid();

-- ── Step 2: Drop child FKs referencing profile.users(uid) ────────────────────
-- Must drop before we can alter the referenced column.
ALTER TABLE profile.favorites DROP CONSTRAINT favorites_uid_fkey;
ALTER TABLE profile.favorites DROP CONSTRAINT favorites_pkey;
ALTER TABLE profile.follows   DROP CONSTRAINT follows_uid_fkey;
ALTER TABLE profile.interests DROP CONSTRAINT interests_uid_fkey;
ALTER TABLE profile.interests DROP CONSTRAINT interests_pkey;
ALTER TABLE profile.events    DROP CONSTRAINT events_uid_fkey;

-- ── Step 3: Restructure profile.users ─────────────────────────────────────────
ALTER TABLE profile.users DROP CONSTRAINT users_pkey;
ALTER TABLE profile.users ADD PRIMARY KEY (id);
ALTER TABLE profile.users RENAME COLUMN uid TO auth_uid;
ALTER TABLE profile.users ADD CONSTRAINT users_auth_uid_key UNIQUE (auth_uid);
ALTER TABLE profile.users DROP COLUMN email;

-- ── Step 4: Rewire child tables to use user_id uuid → profile.users(id) ───────

-- profile.favorites
ALTER TABLE profile.favorites ADD COLUMN user_id uuid;
UPDATE profile.favorites f
   SET user_id = u.id
  FROM profile.users u
 WHERE f.uid = u.auth_uid;
ALTER TABLE profile.favorites ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE profile.favorites DROP COLUMN uid;
ALTER TABLE profile.favorites ADD PRIMARY KEY (user_id, item_id);
ALTER TABLE profile.favorites ADD CONSTRAINT favorites_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES profile.users(id) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.favorites_uid_created_at_idx;
CREATE INDEX ON profile.favorites (user_id, created_at DESC);

-- profile.follows
ALTER TABLE profile.follows ADD COLUMN user_id uuid;
UPDATE profile.follows f
   SET user_id = u.id
  FROM profile.users u
 WHERE f.uid = u.auth_uid;
ALTER TABLE profile.follows ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE profile.follows DROP COLUMN uid;
ALTER TABLE profile.follows ADD CONSTRAINT follows_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES profile.users(id) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.follows_uid_created_at_idx;
CREATE INDEX ON profile.follows (user_id, created_at DESC);

-- profile.interests
ALTER TABLE profile.interests ADD COLUMN user_id uuid;
UPDATE profile.interests i
   SET user_id = u.id
  FROM profile.users u
 WHERE i.uid = u.auth_uid;
ALTER TABLE profile.interests ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE profile.interests DROP COLUMN uid;
ALTER TABLE profile.interests ADD PRIMARY KEY (user_id, category_id);
ALTER TABLE profile.interests ADD CONSTRAINT interests_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES profile.users(id) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.interests_uid_idx;
CREATE INDEX ON profile.interests (user_id);

-- profile.events
ALTER TABLE profile.events ADD COLUMN user_id uuid;
UPDATE profile.events e
   SET user_id = u.id
  FROM profile.users u
 WHERE e.uid = u.auth_uid;
ALTER TABLE profile.events ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE profile.events DROP COLUMN uid;
ALTER TABLE profile.events ADD CONSTRAINT events_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES profile.users(id) ON DELETE CASCADE;
DROP INDEX IF EXISTS profile.events_uid_created_at_idx;
DROP INDEX IF EXISTS profile.events_uid_category_id_idx;
DROP INDEX IF EXISTS profile.events_uid_item_id_idx;
CREATE INDEX ON profile.events (user_id, created_at DESC);
CREATE INDEX ON profile.events (user_id, category_id) WHERE category_id IS NOT NULL;
CREATE INDEX ON profile.events (user_id, item_id)     WHERE item_id     IS NOT NULL;
