ALTER ROLE cove_item RESET search_path;
ALTER ROLE cove_user  RESET search_path;

REVOKE USAGE ON SCHEMA catalog, directory FROM cove_item;
REVOKE USAGE ON SCHEMA catalog, directory FROM cove_user;

DROP SCHEMA IF EXISTS catalog   CASCADE;
DROP SCHEMA IF EXISTS directory CASCADE;

-- Roles are NOT dropped here — they are cluster-level objects managed by
-- the CNPG bootstrap. Dropping them requires superuser access.
