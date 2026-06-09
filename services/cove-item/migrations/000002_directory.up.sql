-- directory schema: makers and storefronts
--
-- Consolidates original 000002_directory + 000007_schema_enhancements (directory parts):
--   - slug, city, state, zip, website_url, is_active, updated_at baked in from the start
--   - address and location are nullable (online-first; physical storefronts set them)
--   - trust_score retained for compatibility (ranking signal for future use)
--
-- Run order: after 000001_setup (extensions + schemas + grants).

CREATE TABLE directory.makers (
    id           uuid                  PRIMARY KEY DEFAULT gen_random_uuid(),
    name         text                  NOT NULL,
    slug         text                  UNIQUE,
    description  text,
    tier         text                  NOT NULL DEFAULT 'individual_lister',
        -- 'verified_business' | 'individual_lister'
    trust_score  numeric               NOT NULL DEFAULT 0,
    city         text,
    state        text,
    zip          text,
    address      text,
    location     geography(Point,4326),
    website_url  text,
    is_active    boolean               NOT NULL DEFAULT true,
    created_at   timestamptz           NOT NULL DEFAULT now(),
    updated_at   timestamptz           NOT NULL DEFAULT now()
);

CREATE INDEX ON directory.makers (slug);
CREATE INDEX ON directory.makers USING GIST (location);
CREATE INDEX ON directory.makers (trust_score DESC);
CREATE INDEX ON directory.makers (is_active) WHERE is_active = true;

CREATE TABLE directory.storefronts (
    id                   uuid                  PRIMARY KEY DEFAULT gen_random_uuid(),
    operated_by_maker_id uuid                  REFERENCES directory.makers(id),
    name                 text                  NOT NULL,
    description          text,
    slug                 text                  UNIQUE,
    type                 text                  NOT NULL,
        -- 'shop' | 'gallery' | 'studio' | 'market' | 'taproom' | 'online'
    city                 text,
    state                text,
    zip                  text,
    address              text,
    location             geography(Point,4326),
    website_url          text,
    trust_score          numeric               NOT NULL DEFAULT 0,
    is_active            boolean               NOT NULL DEFAULT true,
    created_at           timestamptz           NOT NULL DEFAULT now(),
    updated_at           timestamptz           NOT NULL DEFAULT now()
);

CREATE INDEX ON directory.storefronts (operated_by_maker_id);
CREATE INDEX ON directory.storefronts USING GIST (location);
CREATE INDEX ON directory.storefronts (trust_score DESC);
CREATE INDEX ON directory.storefronts (slug);
CREATE INDEX ON directory.storefronts (is_active) WHERE is_active = true;

-- cove_item owns directory writes for v1 (until cove-directory ships)
GRANT SELECT, INSERT, UPDATE, DELETE ON directory.makers      TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON directory.storefronts TO cove_item;
GRANT REFERENCES                     ON directory.makers      TO cove_item;
GRANT REFERENCES                     ON directory.storefronts TO cove_item;

-- cove_user reads directory for favorites/follows cross-schema FKs
GRANT SELECT     ON directory.makers, directory.storefronts TO cove_user;
GRANT REFERENCES ON directory.makers, directory.storefronts TO cove_user;
