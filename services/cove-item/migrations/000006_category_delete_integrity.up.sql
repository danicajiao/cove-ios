-- Enforce integrity when categories are deleted:
--   1. Block deletion of any category that still has children (prevents orphaned paths).
--   2. When a leaf category is deleted, re-evaluate whether its parent should become
--      a leaf again (i.e. it has no remaining children).
--
-- Note: deletion of a leaf that has items referencing it is already blocked by the
-- RESTRICT foreign key on catalog.items.category_id (000003_catalog).

-- 1. Block deletion of non-leaf categories.
CREATE FUNCTION catalog.prevent_non_leaf_category_delete() RETURNS trigger AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM catalog.categories child
        WHERE child.path ~ (OLD.path::text || '.*{1}')::lquery
    ) THEN
        RAISE EXCEPTION 'cannot delete category "%" because it still has children', OLD.path;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER categories_prevent_non_leaf_delete
    BEFORE DELETE ON catalog.categories
    FOR EACH ROW EXECUTE FUNCTION catalog.prevent_non_leaf_category_delete();

-- 2. After a leaf is deleted, re-evaluate the parent's is_leaf flag.
CREATE FUNCTION catalog.recheck_parent_leaf() RETURNS trigger AS $$
BEGIN
    IF nlevel(OLD.path) > 1 THEN
        UPDATE catalog.categories
        SET is_leaf = NOT EXISTS (
            SELECT 1 FROM catalog.categories child
            WHERE child.path ~ (subpath(OLD.path, 0, nlevel(OLD.path) - 1)::text || '.*{1}')::lquery
        )
        WHERE path = subpath(OLD.path, 0, nlevel(OLD.path) - 1);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER categories_recheck_parent_leaf
    AFTER DELETE ON catalog.categories
    FOR EACH ROW EXECUTE FUNCTION catalog.recheck_parent_leaf();
