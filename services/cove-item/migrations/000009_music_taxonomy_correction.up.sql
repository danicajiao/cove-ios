-- Remove format-specific leaves from music.recorded.
--
-- vinyl, cd, and cassette are product variants (packaging) of the same creative
-- work, not structural category distinctions. Format is better expressed as an
-- attribute on catalog.items (e.g. attributes->>'format' = 'cassette') where it
-- is filterable without polluting the category tree.
--
-- After these three rows are deleted, the categories_recheck_parent_leaf trigger
-- (000006) automatically sets music.recorded.is_leaf = true, making it the
-- catch-all leaf for all recorded music.

DELETE FROM catalog.categories WHERE path = 'music.recorded.vinyl';
DELETE FROM catalog.categories WHERE path = 'music.recorded.cd';
DELETE FROM catalog.categories WHERE path = 'music.recorded.cassette';

-- Add music.merch as a leaf for artist merchandise (t-shirts, posters, accessories, etc.)
-- Distinct from apparel.* which covers clothing brands — merch is tied to a music artist.
-- Kept at 2 levels intentionally; sub-categories (music.merch.apparel, etc.) can be added later.
INSERT INTO catalog.categories (id, name, path)
VALUES (gen_random_uuid(), 'Merch', 'music.merch');
