-- Port Firestore products, product_details, and brands to Postgres.
-- Source collections: products (4 docs), product_details (4 docs)
--
-- Items seeded:
--   Colombia Familia Montano  — Ritual Coffee Roasters  — food.coffee.whole_bean
--   Southern Weather Blend    — Onyx Coffee Lab          — food.coffee.whole_bean
--   Balloon Cargo Pant        — iets franz…              — apparel.unisex.bottoms
--   Under The Weather         — HOMESHAKE                — music.recorded
--
-- width/height on catalog.media are 0 — to be backfilled by the image pipeline.
-- Dollar-quote tags: $d$ = description text, $j$ = jsonb literals.
--
-- Fixed UUIDs are used throughout so this migration is idempotent — re-running
-- it on an already-seeded database is a safe no-op. Each INSERT uses
-- ON CONFLICT DO NOTHING, and downstream CTEs SELECT by the known fixed UUID
-- rather than relying on RETURNING (which returns nothing on a no-op conflict).

WITH

-- ─── Makers ──────────────────────────────────────────────────────────────────

maker_ritual_insert AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, city, state, location, website_url)
    VALUES (
        'f1000001-c0ff-0000-0000-000000000001',
        'Ritual Coffee Roasters',
        'ritual-coffee-roasters',
        $d$A fully independent, woman-owned coffee sourcing and roasting company. Pioneer of specialty coffee on Valencia Street in San Francisco since 2005.$d$,
        'verified_business',
        'San Francisco',
        'CA',
        ST_Point(-122.4213, 37.7582)::geography,
        'https://ritualcoffee.com'
    )
    ON CONFLICT (slug) DO NOTHING
),

maker_onyx_insert AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, city, state, location, website_url)
    VALUES (
        'f1000001-c0ff-0000-0000-000000000002',
        'Onyx Coffee Lab',
        'onyx-coffee-lab',
        $d$Specialty coffee roaster in Springdale, Arkansas, built on direct relationships with farms, organic practices, and ethical trading.$d$,
        'verified_business',
        'Springdale',
        'AR',
        ST_Point(-94.1288, 36.1867)::geography,
        'https://onyxcoffeelab.com'
    )
    ON CONFLICT (slug) DO NOTHING
),

maker_iets_insert AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, website_url)
    VALUES (
        'f1000001-c0ff-0000-0000-000000000003',
        'iets franz…',
        'iets-franz',
        $d$Modern athleisure label crafting elevated sportswear basics, fresh silhouettes, and technical fabrications.$d$,
        'verified_business',
        'https://www.urbanoutfitters.com/brands/iets-frans'
    )
    ON CONFLICT (slug) DO NOTHING
),

maker_homeshake_insert AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, website_url)
    VALUES (
        'f1000001-c0ff-0000-0000-000000000004',
        'HOMESHAKE',
        'homeshake',
        $d$Peter Sagar, known as HOMESHAKE, is a Montreal-based musician making dreamy, lo-fi R&B.$d$,
        'individual_lister',
        'https://homeshake.bandcamp.com'
    )
    ON CONFLICT (slug) DO NOTHING
),

-- Resolve maker IDs by slug — works whether the INSERT above ran or was a no-op.
maker_ritual    AS (SELECT id FROM directory.makers WHERE slug = 'ritual-coffee-roasters'),
maker_onyx      AS (SELECT id FROM directory.makers WHERE slug = 'onyx-coffee-lab'),
maker_iets      AS (SELECT id FROM directory.makers WHERE slug = 'iets-franz'),
maker_homeshake AS (SELECT id FROM directory.makers WHERE slug = 'homeshake'),

-- ─── Storefronts (one online storefront per maker) ───────────────────────────

sf_ritual_insert AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT 'f2000001-cafe-0000-0000-000000000001', id, 'Ritual Coffee Roasters', 'ritual-coffee-roasters-online', 'online', 'https://ritualcoffee.com'
    FROM maker_ritual
    ON CONFLICT (slug) DO NOTHING
),

sf_onyx_insert AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT 'f2000001-cafe-0000-0000-000000000002', id, 'Onyx Coffee Lab', 'onyx-coffee-lab-online', 'online', 'https://onyxcoffeelab.com'
    FROM maker_onyx
    ON CONFLICT (slug) DO NOTHING
),

sf_iets_insert AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT 'f2000001-cafe-0000-0000-000000000003', id, 'iets franz…', 'iets-franz-online', 'online', 'https://www.urbanoutfitters.com/brands/iets-franz'
    FROM maker_iets
    ON CONFLICT (slug) DO NOTHING
),

sf_homeshake_insert AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT 'f2000001-cafe-0000-0000-000000000004', id, 'HOMESHAKE Bandcamp', 'homeshake-bandcamp', 'online', 'https://homeshake.bandcamp.com'
    FROM maker_homeshake
    ON CONFLICT (slug) DO NOTHING
),

-- Resolve storefront IDs by slug.
sf_ritual    AS (SELECT id FROM directory.storefronts WHERE slug = 'ritual-coffee-roasters-online'),
sf_onyx      AS (SELECT id FROM directory.storefronts WHERE slug = 'onyx-coffee-lab-online'),
sf_iets      AS (SELECT id FROM directory.storefronts WHERE slug = 'iets-franz-online'),
sf_homeshake AS (SELECT id FROM directory.storefronts WHERE slug = 'homeshake-bandcamp'),

-- ─── Category lookups ────────────────────────────────────────────────────────

cat_whole_bean AS (
    SELECT id FROM catalog.categories WHERE path = 'food.coffee.whole_bean'
),

cat_bottoms AS (
    SELECT id FROM catalog.categories WHERE path = 'apparel.unisex.bottoms'
),

-- music.recorded.vinyl/cd/cassette were removed in 000009 (format = attribute).
-- music.recorded is now the leaf for all recorded music.
cat_recorded AS (
    SELECT id FROM catalog.categories WHERE path = 'music.recorded'
),

-- ─── Items ───────────────────────────────────────────────────────────────────

item_familia_insert AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        'f3000001-1234-0000-0000-000000000001',
        maker_ritual.id,
        cat_whole_bean.id,
        'Colombia Familia Montano',
        $d$Carefully roasted by Ritual Coffee Roasters. Grown by Familia Montano in the Huila Department of Colombia using a Fully Washed process. Tasting notes: bing cherries, sugarcane, milk chocolate, and citrus.$d$,
        2300,
        $j${"roastery": "Ritual Coffee Roasters", "process": "Fully Washed", "origin_country": "Colombia", "producer": "Familia Montano", "region": "Palermo, Huila"}$j$::jsonb,
        $j${"about": "Both internationally renowned and a local favorite, Ritual Coffee is a fully independent, woman-owned coffee sourcing and roasting company. Pioneer of the specialty coffee movement on Valencia Street in San Francisco since 2005.", "origin": [{"title": "Country", "content": "Colombia"}, {"title": "Variety", "content": "Colombia, Castillo"}, {"title": "Producer", "content": "Familia Montano"}, {"title": "Region", "content": "Palermo, Huila"}, {"title": "Process", "content": "Fully Washed"}]}$j$::jsonb
    FROM maker_ritual, cat_whole_bean
    ON CONFLICT (id) DO NOTHING
),

item_southern_insert AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        'f3000001-1234-0000-0000-000000000002',
        maker_onyx.id,
        cat_whole_bean.id,
        'Southern Weather Blend',
        $d$Blended and roasted by Onyx Coffee Lab. Features coffees from Colombia and Ethiopia with notes of milk chocolate, plum, candied walnuts, and juicy citrus acidity.$d$,
        2300,
        $j${"roastery": "Onyx Coffee Lab", "process": "Fully Washed", "origin_country": "Colombia, Ethiopia", "altitude_m": 1850}$j$::jsonb,
        $j${"about": "Onyx Coffee Lab is built on direct relationships with farms. Set on the East side of Springdale, Arkansas, it is a passion project from owners Jon and Andrea, committed to organic practices and ethical trading.", "origin": [{"title": "Country", "content": "Colombia, Ethiopia"}, {"title": "Process", "content": "Fully Washed"}, {"title": "Altitude", "content": "1850m"}, {"title": "Producer", "content": "Various Small Holder Producers"}]}$j$::jsonb
    FROM maker_onyx, cat_whole_bean
    ON CONFLICT (id) DO NOTHING
),

item_pants_insert AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        'f3000001-1234-0000-0000-000000000003',
        maker_iets.id,
        cat_bottoms.id,
        'Balloon Cargo Pant',
        $d$Light and easy Y2K tech pants in a baggy parachute fit. Slouchy at the low drawcord waist and loose through the leg with a gathered drawcord at the hem. 100% Cotton.$d$,
        7500,
        $j${"brand": "iets franz…", "material": "100% Cotton", "fit": "Baggy", "rise": "Low"}$j$::jsonb,
        $j${"about": "Crafting modern athleisure pieces, iets franz… is the go-to for elevated sportswear basics, fresh silhouettes, and technical fabrications.", "specifications": [{"title": "Features", "content": ["Baggy parachute pants", "Low-rise waist"]}, {"title": "Content + Care", "content": ["100% Cotton", "Machine wash", "Imported"]}, {"title": "Size + Fit", "content": ["Rise: 11.5\"", "Inseam: 30\"", "Leg opening: 10\""]}]}$j$::jsonb
    FROM maker_iets, cat_bottoms
    ON CONFLICT (id) DO NOTHING
),

item_utw_insert AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        'f3000001-1234-0000-0000-000000000004',
        maker_homeshake.id,
        cat_recorded.id,
        'Under The Weather',
        $d$HOMESHAKE fifth studio album, written in 2019 during a long period of introspection in Montreal. Includes high-quality download in MP3, FLAC, and more.$d$,
        900,
        $j${"artist": "HOMESHAKE", "album": "Under The Weather", "format": "cassette"}$j$::jsonb,
        $j${"about": "Peter Sagar wrote the majority of Under the Weather in 2019, when he was going through a long, unrelenting period of sadness. The album captures that quiet and restraint.", "tracklist": [{"title": "Wake Up!", "durationSec": 22}, {"title": "Feel Better", "durationSec": 254}, {"title": "Vacuum", "durationSec": 182}]}$j$::jsonb
    FROM maker_homeshake, cat_recorded
    ON CONFLICT (id) DO NOTHING
),

-- ─── Availability ────────────────────────────────────────────────────────────

avail_familia AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    VALUES ('f3000001-1234-0000-0000-000000000001', 'f2000001-cafe-0000-0000-000000000001', 'maker_listed', 'https://ritualcoffee.com/coffee/colombia-familia-montano', true)
    ON CONFLICT (item_id, storefront_id) DO NOTHING
),

avail_southern AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    VALUES ('f3000001-1234-0000-0000-000000000002', 'f2000001-cafe-0000-0000-000000000002', 'maker_listed', 'https://onyxcoffeelab.com/products/southern-weather-blend', true)
    ON CONFLICT (item_id, storefront_id) DO NOTHING
),

avail_pants AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    VALUES ('f3000001-1234-0000-0000-000000000003', 'f2000001-cafe-0000-0000-000000000003', 'maker_listed', 'https://www.urbanoutfitters.com/shop/iets-franz-balloon-cargo-pant', true)
    ON CONFLICT (item_id, storefront_id) DO NOTHING
),

avail_utw AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    VALUES ('f3000001-1234-0000-0000-000000000004', 'f2000001-cafe-0000-0000-000000000004', 'maker_listed', 'https://homeshake.bandcamp.com/album/under-the-weather', true)
    ON CONFLICT (item_id, storefront_id) DO NOTHING
),

-- ─── Media (primary images) ──────────────────────────────────────────────────
-- media_key values are the image storage paths carried over from Firestore.

media_familia AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    VALUES ('f4000001-abcd-0000-0000-000000000001', 'f3000001-1234-0000-0000-000000000001',
            'images/198bd677d60fe63e71f2364a5b2f8b7f9dc390ab1a835179d37cc2b24a6f5680.webp',
            'primary', 0, 0, 0)
    ON CONFLICT (id) DO NOTHING
),

media_southern AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    VALUES ('f4000001-abcd-0000-0000-000000000002', 'f3000001-1234-0000-0000-000000000002',
            'images/782551befe683f93faab8047495213e78a8d8f5f74a1cf57e727fb09beed34e3.webp',
            'primary', 0, 0, 0)
    ON CONFLICT (id) DO NOTHING
),

media_pants AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    VALUES ('f4000001-abcd-0000-0000-000000000003', 'f3000001-1234-0000-0000-000000000003',
            'images/c700ae97872641c582c4dfdfa3769a0645cbfe4db33203b7e584a8e822a0d6a0.webp',
            'primary', 0, 0, 0)
    ON CONFLICT (id) DO NOTHING
),

media_utw AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    VALUES ('f4000001-abcd-0000-0000-000000000004', 'f3000001-1234-0000-0000-000000000004',
            'images/4b57be3e93a3aadd9df795b69490ef787647c9158b2dfbfdebd2a94c45680924.webp',
            'primary', 0, 0, 0)
    ON CONFLICT (id) DO NOTHING
)

SELECT 'Seeded 4 makers, 4 storefronts, 4 items, 4 availability rows, 4 media rows (idempotent)' AS result
FROM media_familia, media_southern, media_pants, media_utw;
