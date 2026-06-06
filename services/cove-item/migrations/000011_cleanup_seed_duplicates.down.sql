-- The placeholder seed data removed by this migration will be superseded by
-- real Denver seed data in a subsequent migration. There is no meaningful
-- rollback — re-applying 000010 would re-insert the Firestore placeholder
-- data, which is not the desired state after this cleanup.
--
-- If you need to roll back: run `migrate down 1` to undo this migration,
-- then manually verify the state of the seed data.
SELECT 'No-op: placeholder seed data is not restored on rollback' AS result;
