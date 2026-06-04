-- Enhance directory.makers: url-friendly slug, location, soft-delete, audit timestamp
ALTER TABLE directory.makers
    ADD COLUMN slug        text UNIQUE,
    ADD COLUMN city        text,
    ADD COLUMN state       text,
    ADD COLUMN zip         text,
    ADD COLUMN location    geography(Point, 4326),
    ADD COLUMN website_url text,
    ADD COLUMN is_active   boolean     NOT NULL DEFAULT true,
    ADD COLUMN updated_at  timestamptz NOT NULL DEFAULT now();

CREATE INDEX ON directory.makers (slug);
CREATE INDEX ON directory.makers USING GIST (location);
CREATE INDEX ON directory.makers (is_active) WHERE is_active = true;

-- Enhance directory.storefronts: slug, structured location, soft-delete, audit timestamp.
-- Drop NOT NULL on address and location — online storefronts have neither.
ALTER TABLE directory.storefronts
    ALTER COLUMN address  DROP NOT NULL,
    ALTER COLUMN location DROP NOT NULL,
    ADD COLUMN slug        text UNIQUE,
    ADD COLUMN city        text,
    ADD COLUMN state       text,
    ADD COLUMN zip         text,
    ADD COLUMN website_url text,
    ADD COLUMN is_active   boolean     NOT NULL DEFAULT true,
    ADD COLUMN updated_at  timestamptz NOT NULL DEFAULT now();

CREATE INDEX ON directory.storefronts (slug);
CREATE INDEX ON directory.storefronts (is_active) WHERE is_active = true;

-- Enhance catalog.signals: expiry flag (b_corp, usda_organic, etc. renew annually)
-- and soft-delete so retired signals stay attached to historical entity_signals rows.
ALTER TABLE catalog.signals
    ADD COLUMN has_expiry boolean NOT NULL DEFAULT false,
    ADD COLUMN is_active  boolean NOT NULL DEFAULT true;

-- Enhance catalog.availability: provenance flag + soft-delete.
-- listing_source tracks who listed the item at this storefront.
-- is_active = false delists from a storefront without losing the history of it
-- ever being listed there (supports re-listing and audit trail).
ALTER TABLE catalog.availability
    ADD COLUMN listing_source text    NOT NULL DEFAULT 'storefront_listed'
        CHECK (listing_source IN ('maker_listed', 'storefront_listed')),
    ADD COLUMN listing_url    text,
    ADD COLUMN is_active      boolean NOT NULL DEFAULT true;

CREATE INDEX ON catalog.availability (storefront_id) WHERE is_active = true;

-- Change item_id FK from ON DELETE CASCADE to ON DELETE RESTRICT.
-- A maker delisting from their own storefront should delete their availability row only,
-- not the catalog.items record. If the items record itself is deleted, Postgres should
-- block it if any storefront still lists it — preventing silent removal of a consignment
-- store's inventory when the original maker removes their product.
ALTER TABLE catalog.availability
    DROP CONSTRAINT availability_item_id_fkey;

ALTER TABLE catalog.availability
    ADD CONSTRAINT availability_item_id_fkey
        FOREIGN KEY (item_id) REFERENCES catalog.items(id) ON DELETE RESTRICT;

-- Enhance catalog.entity_signals: cert metadata for verified signals
-- (cert_number and cert_expires_at are null for non-cert signals like identity_verified)
ALTER TABLE catalog.entity_signals
    ADD COLUMN cert_number     text,
    ADD COLUMN cert_expires_at timestamptz,
    ADD COLUMN verified_by     text;
