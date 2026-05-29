-- Drop in reverse FK dependency order.
DROP TABLE IF EXISTS "user".events    CASCADE;
DROP TABLE IF EXISTS "user".interests CASCADE;
DROP TABLE IF EXISTS "user".follows   CASCADE;
DROP TABLE IF EXISTS "user".favorites CASCADE;
DROP TABLE IF EXISTS "user".users     CASCADE;

DROP SCHEMA IF EXISTS "user";
