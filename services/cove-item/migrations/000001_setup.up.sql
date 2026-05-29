-- Extensions are already created in the CNPG cluster bootstrap
-- (postInitApplicationSQL), but IF NOT EXISTS makes this idempotent.
CREATE EXTENSION IF NOT EXISTS ltree;
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS directory;
CREATE SCHEMA IF NOT EXISTS catalog;

-- Roles (cove_item, cove_user) are created in the CNPG cluster bootstrap
-- via postInitApplicationSQL. They exist before migrations run.

-- Schema-level grants
GRANT USAGE ON SCHEMA catalog   TO cove_item;
GRANT USAGE ON SCHEMA directory TO cove_item;

GRANT USAGE ON SCHEMA catalog, directory TO cove_user;

-- Default search paths
ALTER ROLE cove_item SET search_path = catalog, directory, public;
ALTER ROLE cove_user  SET search_path = profile, public;
