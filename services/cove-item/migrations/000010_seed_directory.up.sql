-- Port Firestore products, product_details, and brands to Postgres.
-- Source collections: products (4 docs), product_details (4 docs)
--
-- Items seeded:
--   Colombia Familia Montano  — Ritual Coffee Roasters  — food.coffee.whole_bean
--   Southern Weather Blend    — Onyx Coffee Lab          — food.coffee.whole_bean
--   Balloon Cargo Pant        — iets franz…              — apparel.unisex.bottoms
--   Under The Weather         — HOMESHAKE                — music.recorded.vinyl
--
-- width/height on catalog.media are 0 — to be backfilled by the image pipeline.
-- Dollar-quote tags: $d$ = description text, $j$ = jsonb literals.

WITH

-- ─── Makers ──────────────────────────────────────────────────────────────────

maker_ritual AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, city, state, location, website_url)
    VALUES (
        gen_random_uuid(),
        'Ritual Coffee Roasters',
        'ritual-coffee-roasters',
        $d$A fully independent, woman-owned coffee sourcing and roasting company. Pioneer of specialty coffee on Valencia Street in San Francisco since 2005.$d$,
        'verified_business',
        'San Francisco',
        'CA',
        ST_Point(-122.4213, 37.7582)::geography,
        'https://ritualcoffee.com'
    )
    RETURNING id
),

maker_onyx AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, city, state, location, website_url)
    VALUES (
        gen_random_uuid(),
        'Onyx Coffee Lab',
        'onyx-coffee-lab',
        $d$Specialty coffee roaster in Springdale, Arkansas, built on direct relationships with farms, organic practices, and ethical trading.$d$,
        'verified_business',
        'Springdale',
        'AR',
        ST_Point(-94.1288, 36.1867)::geography,
        'https://onyxcoffeelab.com'
    )
    RETURNING id
),

maker_iets AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, website_url)
    VALUES (
        gen_random_uuid(),
        'iets franz…',
        'iets-franz',
        $d$Modern athleisure label crafting elevated sportswear basics, fresh silhouettes, and technical fabrications.$d$,
        'verified_business',
        'https://www.urbanoutfitters.com/brands/iets-frans'
    )
    RETURNING id
),

maker_homeshake AS (
    INSERT INTO directory.makers (id, name, slug, description, tier, website_url)
    VALUES (
        gen_random_uuid(),
        'HOMESHAKE',
        'homeshake',
        $d$Peter Sagar, known as HOMESHAKE, is a Montreal-based musician making dreamy, lo-fi R&B.$d$,
        'individual_lister',
        'https://homeshake.bandcamp.com'
    )
    RETURNING id
),

-- ─── Storefronts (one online storefront per maker) ───────────────────────────

sf_ritual AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT gen_random_uuid(), id, 'Ritual Coffee Roasters', 'ritual-coffee-roasters-online', 'online', 'https://ritualcoffee.com'
    FROM maker_ritual
    RETURNING id
),

sf_onyx AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT gen_random_uuid(), id, 'Onyx Coffee Lab', 'onyx-coffee-lab-online', 'online', 'https://onyxcoffeelab.com'
    FROM maker_onyx
    RETURNING id
),

sf_iets AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT gen_random_uuid(), id, 'iets franz…', 'iets-franz-online', 'online', 'https://www.urbanoutfitters.com/brands/iets-frans'
    FROM maker_iets
    RETURNING id
),

sf_homeshake AS (
    INSERT INTO directory.storefronts (id, operated_by_maker_id, name, slug, type, website_url)
    SELECT gen_random_uuid(), id, 'HOMESHAKE Bandcamp', 'homeshake-bandcamp', 'online', 'https://homeshake.bandcamp.com'
    FROM maker_homeshake
    RETURNING id
),

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

item_familia AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        gen_random_uuid(),
        maker_ritual.id,
        cat_whole_bean.id,
        'Colombia Familia Montano',
        $d$Carefully roasted by Ritual Coffee Roasters. Grown by Familia Montano in the Huila Department of Colombia using a Fully Washed process. Tasting notes: bing cherries, sugarcane, milk chocolate, and citrus.$d$,
        2300,
        $j${"roastery": "Ritual Coffee Roasters", "process": "Fully Washed", "origin_country": "Colombia", "producer": "Familia Montano", "region": "Palermo, Huila"}$j$::jsonb,
        $j${"about": "Both internationally renowned and a local favorite, Ritual Coffee is a fully independent, woman-owned coffee sourcing and roasting company. Pioneer of the specialty coffee movement on Valencia Street in San Francisco since 2005.", "origin": [{"title": "Country", "content": "Colombia"}, {"title": "Variety", "content": "Colombia, Castillo"}, {"title": "Producer", "content": "Familia Montano"}, {"title": "Region", "content": "Palermo, Huila"}, {"title": "Process", "content": "Fully Washed"}]}$j$::jsonb
    FROM maker_ritual, cat_whole_bean
    RETURNING id
),

item_southern AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        gen_random_uuid(),
        maker_onyx.id,
        cat_whole_bean.id,
        'Southern Weather Blend',
        $d$Blended and roasted by Onyx Coffee Lab. Features coffees from Colombia and Ethiopia with notes of milk chocolate, plum, candied walnuts, and juicy citrus acidity.$d$,
        2300,
        $j${"roastery": "Onyx Coffee Lab", "process": "Fully Washed", "origin_country": "Colombia, Ethiopia", "altitude_m": 1850}$j$::jsonb,
        $j${"about": "Onyx Coffee Lab is built on direct relationships with farms. Set on the East side of Springdale, Arkansas, it is a passion project from owners Jon and Andrea, committed to organic practices and ethical trading.", "origin": [{"title": "Country", "content": "Colombia, Ethiopia"}, {"title": "Process", "content": "Fully Washed"}, {"title": "Altitude", "content": "1850m"}, {"title": "Producer", "content": "Various Small Holder Producers"}]}$j$::jsonb
    FROM maker_onyx, cat_whole_bean
    RETURNING id
),

item_pants AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        gen_random_uuid(),
        maker_iets.id,
        cat_bottoms.id,
        'Balloon Cargo Pant',
        $d$Light and easy Y2K tech pants in a baggy parachute fit. Slouchy at the low drawcord waist and loose through the leg with a gathered drawcord at the hem. 100% Cotton.$d$,
        7500,
        $j${"brand": "iets franz…", "material": "100% Cotton", "fit": "Baggy", "rise": "Low"}$j$::jsonb,
        $j${"about": "Crafting modern athleisure pieces, iets franz… is the go-to for elevated sportswear basics, fresh silhouettes, and technical fabrications.", "specifications": [{"title": "Features", "content": ["Baggy parachute pants", "Low-rise waist"]}, {"title": "Content + Care", "content": ["100% Cotton", "Machine wash", "Imported"]}, {"title": "Size + Fit", "content": ["Rise: 11.5\"", "Inseam: 30\"", "Leg opening: 10\""]}]}$j$::jsonb
    FROM maker_iets, cat_bottoms
    RETURNING id
),

item_utw AS (
    INSERT INTO catalog.items (id, maker_id, category_id, name, description, price_cents, attributes, details)
    SELECT
        gen_random_uuid(),
        maker_homeshake.id,
        cat_recorded.id,
        'Under The Weather',
        $d$HOMESHAKE fifth studio album, written in 2019 during a long period of introspection in Montreal. Includes high-quality download in MP3, FLAC, and more.$d$,
        900,
        $j${"artist": "HOMESHAKE", "album": "Under The Weather", "format": "cassette"}$j$::jsonb,
        $j${"about": "Peter Sagar wrote the majority of Under the Weather in 2019, when he was going through a long, unrelenting period of sadness. The album captures that quiet and restraint.", "tracklist": [{"title": "Wake Up!", "durationSec": 22}, {"title": "Feel Better", "durationSec": 254}, {"title": "Vacuum", "durationSec": 182}]}$j$::jsonb
    FROM maker_homeshake, cat_recorded
    RETURNING id
),

-- ─── Availability ────────────────────────────────────────────────────────────

avail_familia AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    SELECT item_familia.id, sf_ritual.id, 'maker_listed', 'https://ritualcoffee.com/coffee/colombia-familia-montano', true
    FROM item_familia, sf_ritual
    RETURNING item_id
),

avail_southern AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    SELECT item_southern.id, sf_onyx.id, 'maker_listed', 'https://onyxcoffeelab.com/products/southern-weather-blend', true
    FROM item_southern, sf_onyx
    RETURNING item_id
),

avail_pants AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    SELECT item_pants.id, sf_iets.id, 'maker_listed', 'https://www.urbanoutfitters.com/shop/iets-franz-balloon-cargo-pant', true
    FROM item_pants, sf_iets
    RETURNING item_id
),

avail_utw AS (
    INSERT INTO catalog.availability (item_id, storefront_id, listing_source, listing_url, is_active)
    SELECT item_utw.id, sf_homeshake.id, 'maker_listed', 'https://homeshake.bandcamp.com/album/under-the-weather', true
    FROM item_utw, sf_homeshake
    RETURNING item_id
),

-- ─── Media (primary images) ──────────────────────────────────────────────────
-- Chained from avail_* to ensure availability rows exist first.
-- media_key values are the image storage paths carried over from Firestore.

media_familia AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    SELECT gen_random_uuid(), avail_familia.item_id,
           'images/198bd677d60fe63e71f2364a5b2f8b7f9dc390ab1a835179d37cc2b24a6f5680.webp',
           'primary', 0, 0, 0
    FROM avail_familia
    RETURNING id
),

media_southern AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    SELECT gen_random_uuid(), avail_southern.item_id,
           'images/782551befe683f93faab8047495213e78a8d8f5f74a1cf57e727fb09beed34e3.webp',
           'primary', 0, 0, 0
    FROM avail_southern
    RETURNING id
),

media_pants AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    SELECT gen_random_uuid(), avail_pants.item_id,
           'images/c700ae97872641c582c4dfdfa3769a0645cbfe4db33203b7e584a8e822a0d6a0.webp',
           'primary', 0, 0, 0
    FROM avail_pants
    RETURNING id
),

media_utw AS (
    INSERT INTO catalog.media (id, item_id, media_key, role, sort_order, width, height)
    SELECT gen_random_uuid(), avail_utw.item_id,
           'images/4b57be3e93a3aadd9df795b69490ef787647c9158b2dfbfdebd2a94c45680924.webp',
           'primary', 0, 0, 0
    FROM avail_utw
    RETURNING id
)

-- Reference all leaf CTEs to ensure the full chain executes.
SELECT 'Seeded 4 makers, 4 storefronts, 4 items, 4 availability rows, 4 media rows' AS result
FROM media_familia, media_southern, media_pants, media_utw;
