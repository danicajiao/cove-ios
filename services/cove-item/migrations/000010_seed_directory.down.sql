-- Remove in reverse FK dependency order.
-- catalog.availability and catalog.media both have ON DELETE CASCADE from catalog.items,
-- so deleting items cleans those up automatically.

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
