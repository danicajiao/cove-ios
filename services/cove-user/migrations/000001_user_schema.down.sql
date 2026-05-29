-- Drop in reverse FK dependency order.
DROP TABLE IF EXISTS profile.events    CASCADE;
DROP TABLE IF EXISTS profile.interests CASCADE;
DROP TABLE IF EXISTS profile.follows   CASCADE;
DROP TABLE IF EXISTS profile.favorites CASCADE;
DROP TABLE IF EXISTS profile.users     CASCADE;

DROP SCHEMA IF EXISTS profile;
