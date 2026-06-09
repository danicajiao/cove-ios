-- profile schema: users, favorites, follows, interests, events
--
-- Consolidates original 000001_user_schema + 000002_profile_schema_v2 + 000003_username_unique
-- into a single clean starting state:
--
--   profile.users       — surrogate UUID primary key (id), auth_uid (provider-agnostic),
--                         unique username, no email (Firebase owns auth data)
--   profile.favorites,
--   profile.follows,
--   profile.interests,
--   profile.events      — user_id uuid FK referencing profile.users(id)
--
-- Depends on cove-item migrations (000001–000003) having been applied first so that
-- catalog.items, catalog.categories, directory.makers, and directory.storefronts exist.

CREATE SCHEMA IF NOT EXISTS profile;

GRANT USAGE ON SCHEMA profile TO cove_user;

CREATE TABLE profile.users (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_uid   text        NOT NULL UNIQUE,  -- constraint: users_auth_uid_key
    username   text        NOT NULL UNIQUE,  -- constraint: users_username_key
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE profile.favorites (
    user_id    uuid        NOT NULL REFERENCES profile.users(id)   ON DELETE CASCADE,
    item_id    uuid        NOT NULL REFERENCES catalog.items(id)   ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, item_id)
);

CREATE INDEX ON profile.favorites (user_id, created_at DESC);

-- Follows target a maker OR a storefront — exclusive arc enforces exactly one.
CREATE TABLE profile.follows (
    user_id       uuid        NOT NULL REFERENCES profile.users(id)         ON DELETE CASCADE,
    maker_id      uuid        REFERENCES directory.makers(id)               ON DELETE CASCADE,
    storefront_id uuid        REFERENCES directory.storefronts(id)          ON DELETE CASCADE,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CHECK (num_nonnulls(maker_id, storefront_id) = 1)
);

CREATE INDEX ON profile.follows (user_id, created_at DESC);

-- Explicit onboarding interest picks — editable later in settings.
CREATE TABLE profile.interests (
    user_id     uuid        NOT NULL REFERENCES profile.users(id)       ON DELETE CASCADE,
    category_id uuid        NOT NULL REFERENCES catalog.categories(id),
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, category_id)
);

CREATE INDEX ON profile.interests (user_id);

-- Implicit behavioral signals for recommendation ranking.
-- event_type: 'category_tap' | 'item_view' | 'result_dwell' | 'search'
CREATE TABLE profile.events (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     uuid        NOT NULL REFERENCES profile.users(id) ON DELETE CASCADE,
    event_type  text        NOT NULL,
    category_id uuid        REFERENCES catalog.categories(id),
    item_id     uuid        REFERENCES catalog.items(id),
    metadata    jsonb       NOT NULL DEFAULT '{}',
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON profile.events (user_id, created_at DESC);
CREATE INDEX ON profile.events (user_id, category_id) WHERE category_id IS NOT NULL;
CREATE INDEX ON profile.events (user_id, item_id)     WHERE item_id     IS NOT NULL;

GRANT SELECT, INSERT, UPDATE, DELETE ON profile.users     TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.favorites TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.follows   TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.interests TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.events    TO cove_user;
