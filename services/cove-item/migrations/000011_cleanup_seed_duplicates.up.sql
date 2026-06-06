-- Migration 000010 used gen_random_uuid() for all IDs with no ON CONFLICT
-- guards. The original Firestore port also pre-populated makers/storefronts
-- without slugs, so running 000010 created a second set of rows with slugs
-- alongside the original slug-less rows.
--
-- This migration removes ALL rows associated with the placeholder seed data
-- (identified by the known entity names), leaving a clean slate for the
-- Denver seed data that follows in a subsequent migration.
--
-- Note: catalog.media has ON DELETE CASCADE on item_id, so deleting items
-- automatically removes their media rows.

-- 1. Availability must go first (ON DELETE RESTRICT on item_id since 000007).
DELETE FROM catalog.availability
WHERE item_id IN (
    SELECT id FROM catalog.items
    WHERE name IN (
        'Colombia Familia Montano',
        'Southern Weather Blend',
        'Balloon Cargo Pant',
        'Under The Weather'
    )
);

-- 2. Items (cascades to catalog.media).
DELETE FROM catalog.items
WHERE name IN (
    'Colombia Familia Montano',
    'Southern Weather Blend',
    'Balloon Cargo Pant',
    'Under The Weather'
);

-- 3. Storefronts — delete by name to catch both slug and slug-less rows.
DELETE FROM directory.storefronts
WHERE name IN (
    'Ritual Coffee Roasters',
    'Onyx Coffee Lab',
    'iets franz…',
    'HOMESHAKE Bandcamp'
);

-- 4. Makers — delete by name to catch both slug and slug-less rows.
DELETE FROM directory.makers
WHERE name IN (
    'Ritual Coffee Roasters',
    'Onyx Coffee Lab',
    'iets franz…',
    'HOMESHAKE'
);
