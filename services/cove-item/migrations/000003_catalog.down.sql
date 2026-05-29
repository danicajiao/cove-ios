-- Drop in reverse FK dependency order.
DROP TABLE IF EXISTS catalog.media          CASCADE;
DROP TABLE IF EXISTS catalog.entity_signals CASCADE;
DROP TABLE IF EXISTS catalog.availability   CASCADE;
DROP TABLE IF EXISTS catalog.items          CASCADE;
DROP TABLE IF EXISTS catalog.signals        CASCADE;
DROP TABLE IF EXISTS catalog.categories     CASCADE;
