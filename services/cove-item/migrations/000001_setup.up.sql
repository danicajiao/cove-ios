-- Extensions are already created in the CNPG cluster bootstrap
-- (postInitApplicationSQL), but IF NOT EXISTS makes this idempotent.
CREATE EXTENSION IF NOT EXISTS ltree;
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS directory;
CREATE SCHEMA IF NOT EXISTS catalog;

-- Roles and their search_path defaults are managed in the CNPG cluster
-- bootstrap (postInitApplicationSQL) — both CREATE ROLE and ALTER ROLE
-- require superuser, which the app user does not have.

-- Schema-level grants — app owns the schemas it creates, so GRANT is permitted.
GRANT USAGE ON SCHEMA catalog   TO cove_item;
GRANT USAGE ON SCHEMA directory TO cove_item;

GRANT USAGE ON SCHEMA catalog, directory TO cove_user;
