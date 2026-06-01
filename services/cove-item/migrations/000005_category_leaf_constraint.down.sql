DROP TRIGGER IF EXISTS items_enforce_leaf_category ON catalog.items;
DROP FUNCTION IF EXISTS catalog.enforce_leaf_category();

DROP TRIGGER IF EXISTS categories_mark_parent_non_leaf ON catalog.categories;
DROP FUNCTION IF EXISTS catalog.mark_parent_non_leaf();

ALTER TABLE catalog.categories DROP COLUMN is_leaf;
