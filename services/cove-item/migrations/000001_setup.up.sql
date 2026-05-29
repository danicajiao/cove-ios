-- Extensions are already created in the CNPG cluster bootstrap
-- (postInitApplicationSQL), but IF NOT EXISTS makes this idempotent.
CREATE EXTENSION IF NOT EXISTS ltree;
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS directory;
CREATE SCHEMA IF NOT EXISTS catalog;

-- Service roles. Passwords are managed externally via Kubernetes secrets
-- (ESO → GCP Secret Manager) and set with ALTER ROLE after provisioning.
-- cove_directory is intentionally omitted — the directory schema exists
-- but cove-item owns it for v1 reads until cove-directory ships.
DO $$ BEGIN
    CREATE ROLE cove_item WITH LOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE ROLE cove_user WITH LOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Schema-level grants
GRANT USAGE ON SCHEMA catalog  TO cove_item;
GRANT USAGE ON SCHEMA directory TO cove_item;

GRANT USAGE ON SCHEMA catalog, directory TO cove_user;

-- Default search paths
ALTER ROLE cove_item SET search_path = catalog, directory, public;
ALTER ROLE cove_user  SET search_path = profile, public;
