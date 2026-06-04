-- Remove in reverse FK dependency order.
-- catalog.availability.item_id is ON DELETE RESTRICT (changed in 000007), so
-- availability rows must be deleted before items. catalog.media.item_id is
-- ON DELETE CASCADE so media is cleaned up automatically when items are deleted.

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

DELETE FROM catalog.items
WHERE name IN (
    'Colombia Familia Montano',
    'Southern Weather Blend',
    'Balloon Cargo Pant',
    'Under The Weather'
);

DELETE FROM directory.storefronts
WHERE slug IN (
    'ritual-coffee-roasters-online',
    'onyx-coffee-lab-online',
    'iets-franz-online',
    'homeshake-bandcamp'
);

DELETE FROM directory.makers
WHERE slug IN (
    'ritual-coffee-roasters',
    'onyx-coffee-lab',
    'iets-franz',
    'homeshake'
);
