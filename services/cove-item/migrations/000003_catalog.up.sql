-- Categories must come before items (items.category_id FK).
-- Signals must come before entity_signals (entity_signals.signal_id FK).
-- Items must come before availability, entity_signals, and media.

CREATE TABLE catalog.categories (
    id   uuid  PRIMARY KEY DEFAULT gen_random_uuid(),
    name text  NOT NULL,
    path ltree NOT NULL UNIQUE -- e.g. 'food.alcoholic_beverages.beer'
);

CREATE INDEX ON catalog.categories USING GIST  (path);
CREATE INDEX ON catalog.categories USING BTREE (path);

-- Signal taxonomy — one row per signal type, referenced by entity_signals.
CREATE TABLE catalog.signals (
    id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    code                text        NOT NULL UNIQUE, -- 'b_corp' | 'usda_organic' | 'living_wage' | ...
    name                text        NOT NULL,
    description         text,
    verification_method text        NOT NULL, -- 'directory_crossref' | 'duns' | 'community_vouch'
    weight              numeric     NOT NULL DEFAULT 1
);

CREATE TABLE catalog.items (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    maker_id    uuid        NOT NULL REFERENCES directory.makers(id),
    category_id uuid        NOT NULL REFERENCES catalog.categories(id),
    name        text        NOT NULL,
    description text,
    price_cents integer,
    attributes  jsonb       NOT NULL DEFAULT '{}',
    details     jsonb       NOT NULL DEFAULT '{}',
    search_vec  tsvector    GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, ''))
    ) STORED,
    is_active   boolean     NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON catalog.items USING GIN (search_vec);
CREATE INDEX ON catalog.items USING GIN (attributes);
CREATE INDEX ON catalog.items (category_id) WHERE is_active = true;
CREATE INDEX ON catalog.items (maker_id);

-- Many-to-many: an item can be available at multiple storefronts.
CREATE TABLE catalog.availability (
    item_id       uuid        NOT NULL REFERENCES catalog.items(id)              ON DELETE CASCADE,
    storefront_id uuid        NOT NULL REFERENCES directory.storefronts(id)      ON DELETE CASCADE,
    created_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (item_id, storefront_id)
);

CREATE INDEX ON catalog.availability (storefront_id);

-- Polymorphic trust signal attachment — links a signal to exactly one entity
-- via an exclusive arc (exactly one of maker_id, storefront_id, item_id is set).
CREATE TABLE catalog.entity_signals (
    id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_id     uuid        NOT NULL REFERENCES catalog.signals(id),
    maker_id      uuid REFERENCES directory.makers(id)        ON DELETE CASCADE,
    storefront_id uuid REFERENCES directory.storefronts(id)   ON DELETE CASCADE,
    item_id       uuid REFERENCES catalog.items(id)           ON DELETE CASCADE,
    status        text        NOT NULL DEFAULT 'pending', -- 'verified' | 'pending' | 'community_vouched'
    verified_at   timestamptz,
    verified_via  text,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CHECK (num_nonnulls(maker_id, storefront_id, item_id) = 1)
);

CREATE INDEX ON catalog.entity_signals (maker_id);
CREATE INDEX ON catalog.entity_signals (storefront_id);
CREATE INDEX ON catalog.entity_signals (item_id);

-- Polymorphic media — links an image to exactly one entity.
CREATE TABLE catalog.media (
    id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    maker_id      uuid REFERENCES directory.makers(id)        ON DELETE CASCADE,
    storefront_id uuid REFERENCES directory.storefronts(id)   ON DELETE CASCADE,
    item_id       uuid REFERENCES catalog.items(id)           ON DELETE CASCADE,
    media_key     text        NOT NULL,
    role          text        NOT NULL DEFAULT 'gallery', -- 'primary' | 'gallery' | 'logo'
    sort_order    integer     NOT NULL DEFAULT 0,
    alt_text      text,
    width         integer     NOT NULL,
    height        integer     NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CHECK (num_nonnulls(maker_id, storefront_id, item_id) = 1)
);

CREATE INDEX ON catalog.media (item_id, sort_order);
CREATE INDEX ON catalog.media (storefront_id);
CREATE INDEX ON catalog.media (maker_id);

-- cove_item owns the full catalog
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.categories    TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.signals       TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.items         TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.availability  TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.entity_signals TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.media         TO cove_item;

-- cove_user reads items and categories for favorites/interests cross-schema FKs
GRANT SELECT     ON catalog.items      TO cove_user;
GRANT SELECT     ON catalog.categories TO cove_user;
GRANT REFERENCES ON catalog.items      TO cove_user;
GRANT REFERENCES ON catalog.categories TO cove_user;
