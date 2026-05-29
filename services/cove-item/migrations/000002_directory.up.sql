CREATE TABLE directory.makers (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    description text,
    tier        text        NOT NULL DEFAULT 'individual_lister', -- 'verified_business' | 'individual_lister'
    trust_score numeric     NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE directory.storefronts (
    id                   uuid                  PRIMARY KEY DEFAULT gen_random_uuid(),
    name                 text                  NOT NULL,
    description          text,
    type                 text                  NOT NULL, -- 'shop' | 'gallery' | 'studio' | 'market' | 'taproom'
    address              text                  NOT NULL,
    location             geography(Point,4326) NOT NULL,
    operated_by_maker_id uuid REFERENCES directory.makers(id),
    trust_score          numeric               NOT NULL DEFAULT 0,
    created_at           timestamptz           NOT NULL DEFAULT now()
);

CREATE INDEX ON directory.storefronts USING GIST (location);
CREATE INDEX ON directory.storefronts (operated_by_maker_id);
CREATE INDEX ON directory.makers      (trust_score DESC);
CREATE INDEX ON directory.storefronts (trust_score DESC);

-- cove_item owns directory writes for v1 (until cove-directory ships)
GRANT SELECT, INSERT, UPDATE, DELETE ON directory.makers      TO cove_item;
GRANT SELECT, INSERT, UPDATE, DELETE ON directory.storefronts TO cove_item;
GRANT REFERENCES                     ON directory.makers      TO cove_item;
GRANT REFERENCES                     ON directory.storefronts TO cove_item;

-- cove_user reads directory for favorites/follows cross-schema FKs
GRANT SELECT     ON directory.makers, directory.storefronts TO cove_user;
GRANT REFERENCES ON directory.makers, directory.storefronts TO cove_user;
