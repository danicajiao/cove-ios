ALTER ROLE cove_item RESET search_path;
ALTER ROLE cove_user  RESET search_path;

REVOKE USAGE ON SCHEMA catalog, directory FROM cove_item;
REVOKE USAGE ON SCHEMA catalog, directory FROM cove_user;

DROP ROLE IF EXISTS cove_item;
DROP ROLE IF EXISTS cove_user;

DROP SCHEMA IF EXISTS catalog  CASCADE;
DROP SCHEMA IF EXISTS directory CASCADE;
