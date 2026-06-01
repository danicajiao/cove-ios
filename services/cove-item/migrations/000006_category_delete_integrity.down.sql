DROP TRIGGER IF EXISTS categories_recheck_parent_leaf ON catalog.categories;
DROP FUNCTION IF EXISTS catalog.recheck_parent_leaf();

DROP TRIGGER IF EXISTS categories_prevent_non_leaf_delete ON catalog.categories;
DROP FUNCTION IF EXISTS catalog.prevent_non_leaf_category_delete();
