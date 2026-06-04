-- Restore format-specific leaves under music.recorded.
-- Inserting them fires the categories_set_parent_non_leaf trigger (000005)
-- which automatically sets music.recorded.is_leaf = false.

DELETE FROM catalog.categories WHERE path = 'music.merch';

INSERT INTO catalog.categories (id, name, path) VALUES
    (gen_random_uuid(), 'Vinyl',    'music.recorded.vinyl'),
    (gen_random_uuid(), 'CD',       'music.recorded.cd'),
    (gen_random_uuid(), 'Cassette', 'music.recorded.cassette');
