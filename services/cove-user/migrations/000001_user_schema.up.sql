-- Depends on cove-item migrations (000001–000003) having been applied first.
-- profile.favorites → catalog.items, profile.follows → directory.makers/storefronts,
-- profile.interests → catalog.categories, profile.events → catalog.items/categories.

CREATE SCHEMA IF NOT EXISTS profile;

GRANT USAGE ON SCHEMA profile TO cove_user;

CREATE TABLE profile.users (
    uid        text        PRIMARY KEY, -- Firebase Auth UID
    username   text        NOT NULL,
    email      text        NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE profile.favorites (
    uid        text        NOT NULL REFERENCES profile.users(uid)  ON DELETE CASCADE,
    item_id    uuid        NOT NULL REFERENCES catalog.items(id)   ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (uid, item_id)
);

CREATE INDEX ON profile.favorites (uid, created_at DESC);

-- Follows target a maker OR a storefront — exclusive arc enforces exactly one.
CREATE TABLE profile.follows (
    uid           text        NOT NULL REFERENCES profile.users(uid)        ON DELETE CASCADE,
    maker_id      uuid REFERENCES directory.makers(id)                      ON DELETE CASCADE,
    storefront_id uuid REFERENCES directory.storefronts(id)                 ON DELETE CASCADE,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CHECK (num_nonnulls(maker_id, storefront_id) = 1)
);

CREATE INDEX ON profile.follows (uid, created_at DESC);

-- Explicit onboarding interest picks — editable later in settings.
CREATE TABLE profile.interests (
    uid         text        NOT NULL REFERENCES profile.users(uid)       ON DELETE CASCADE,
    category_id uuid        NOT NULL REFERENCES catalog.categories(id),
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (uid, category_id)
);

CREATE INDEX ON profile.interests (uid);

-- Implicit behavioral signals for recommendation ranking.
-- event_type: 'category_tap' | 'item_view' | 'result_dwell' | 'search'
CREATE TABLE profile.events (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    uid         text        NOT NULL REFERENCES profile.users(uid) ON DELETE CASCADE,
    event_type  text        NOT NULL,
    category_id uuid REFERENCES catalog.categories(id),
    item_id     uuid REFERENCES catalog.items(id),
    metadata    jsonb       NOT NULL DEFAULT '{}',
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON profile.events (uid, created_at DESC);
CREATE INDEX ON profile.events (uid, category_id) WHERE category_id IS NOT NULL;
CREATE INDEX ON profile.events (uid, item_id)     WHERE item_id     IS NOT NULL;

GRANT SELECT, INSERT, UPDATE, DELETE ON profile.users     TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.favorites TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.follows   TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.interests TO cove_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON profile.events    TO cove_user;
