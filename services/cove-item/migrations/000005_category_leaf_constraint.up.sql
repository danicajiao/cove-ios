-- Add is_leaf flag to catalog.categories and enforce that catalog.items
-- can only reference leaf categories (those with no children).

ALTER TABLE catalog.categories ADD COLUMN is_leaf boolean NOT NULL DEFAULT true;

-- Mark all non-leaf nodes: any category that has at least one direct child.
UPDATE catalog.categories parent
SET is_leaf = false
WHERE EXISTS (
    SELECT 1 FROM catalog.categories child
    WHERE child.path ~ (parent.path::text || '.*{1}')::lquery
);

-- Trigger function: when a new category is inserted, mark its parent as non-leaf.
CREATE FUNCTION catalog.mark_parent_non_leaf() RETURNS trigger AS $$
BEGIN
    UPDATE catalog.categories
    SET is_leaf = false
    WHERE path = subpath(NEW.path, 0, nlevel(NEW.path) - 1)
      AND nlevel(NEW.path) > 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER categories_mark_parent_non_leaf
    AFTER INSERT ON catalog.categories
    FOR EACH ROW EXECUTE FUNCTION catalog.mark_parent_non_leaf();

-- Trigger function: enforce that items only reference leaf categories.
CREATE FUNCTION catalog.enforce_leaf_category() RETURNS trigger AS $$
BEGIN
    IF NOT (SELECT is_leaf FROM catalog.categories WHERE id = NEW.category_id) THEN
        RAISE EXCEPTION 'category_id must reference a leaf category (path: %)',
            (SELECT path FROM catalog.categories WHERE id = NEW.category_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER items_enforce_leaf_category
    BEFORE INSERT OR UPDATE ON catalog.items
    FOR EACH ROW EXECUTE FUNCTION catalog.enforce_leaf_category();
