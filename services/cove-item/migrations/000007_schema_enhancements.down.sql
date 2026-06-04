ALTER TABLE catalog.entity_signals
    DROP COLUMN IF EXISTS verified_by,
    DROP COLUMN IF EXISTS cert_expires_at,
    DROP COLUMN IF EXISTS cert_number;

-- Restore item_id FK to ON DELETE CASCADE (reverting the RESTRICT change)
ALTER TABLE catalog.availability
    DROP CONSTRAINT IF EXISTS availability_item_id_fkey;

ALTER TABLE catalog.availability
    ADD CONSTRAINT availability_item_id_fkey
        FOREIGN KEY (item_id) REFERENCES catalog.items(id) ON DELETE CASCADE;

DROP INDEX IF EXISTS catalog.availability_storefront_id_idx;

ALTER TABLE catalog.availability
    DROP COLUMN IF EXISTS is_active,
    DROP COLUMN IF EXISTS listing_url,
    DROP COLUMN IF EXISTS listing_source;

ALTER TABLE catalog.signals
    DROP COLUMN IF EXISTS is_active,
    DROP COLUMN IF EXISTS has_expiry;

DROP INDEX IF EXISTS directory.storefronts_is_active_idx;
DROP INDEX IF EXISTS directory.storefronts_slug_idx;

ALTER TABLE directory.storefronts
    DROP COLUMN IF EXISTS updated_at,
    DROP COLUMN IF EXISTS is_active,
    DROP COLUMN IF EXISTS website_url,
    DROP COLUMN IF EXISTS zip,
    DROP COLUMN IF EXISTS state,
    DROP COLUMN IF EXISTS city,
    DROP COLUMN IF EXISTS slug;

-- Note: restoring NOT NULL on address/location would fail if null rows exist.
-- Only uncomment if staging has been rolled back cleanly:
-- ALTER TABLE directory.storefronts ALTER COLUMN address  SET NOT NULL;
-- ALTER TABLE directory.storefronts ALTER COLUMN location SET NOT NULL;

DROP INDEX IF EXISTS directory.makers_is_active_idx;
DROP INDEX IF EXISTS directory.makers_location_idx;
DROP INDEX IF EXISTS directory.makers_slug_idx;

ALTER TABLE directory.makers
    DROP COLUMN IF EXISTS updated_at,
    DROP COLUMN IF EXISTS is_active,
    DROP COLUMN IF EXISTS location,
    DROP COLUMN IF EXISTS zip,
    DROP COLUMN IF EXISTS state,
    DROP COLUMN IF EXISTS city,
    DROP COLUMN IF EXISTS slug;
