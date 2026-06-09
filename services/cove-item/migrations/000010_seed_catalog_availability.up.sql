-- Seed catalog.availability — one listing per item at its maker's storefront.

INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
VALUES (
    'f3000001-1234-0000-0000-000000000001',
    'f2000001-cafe-0000-0000-000000000001',
    'maker_listed',
    'https://ritualcoffee.com/coffee/colombia-familia-montano',
    true
)
ON CONFLICT (item_id, storefront_id) DO NOTHING;

INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
VALUES (
    'f3000001-1234-0000-0000-000000000002',
    'f2000001-cafe-0000-0000-000000000002',
    'maker_listed',
    'https://onyxcoffeelab.com/products/southern-weather-blend',
    true
)
ON CONFLICT (item_id, storefront_id) DO NOTHING;

INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
VALUES (
    'f3000001-1234-0000-0000-000000000003',
    'f2000001-cafe-0000-0000-000000000003',
    'maker_listed',
    'https://www.urbanoutfitters.com/shop/iets-franz-balloon-cargo-pant',
    true
)
ON CONFLICT (item_id, storefront_id) DO NOTHING;

INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
VALUES (
    'f3000001-1234-0000-0000-000000000004',
    'f2000001-cafe-0000-0000-000000000004',
    'maker_listed',
    'https://homeshake.bandcamp.com/album/under-the-weather',
    true
)
ON CONFLICT (item_id, storefront_id) DO NOTHING;
