-- migration 002_add_signup_year.sql
-- a required column on a table that already has rows: add, fill, then require
BEGIN;
ALTER TABLE customers ADD COLUMN signup_year int;                         -- 1. add it, empty is allowed
UPDATE customers SET signup_year = EXTRACT(YEAR FROM joined_on)::int;    -- 2. fill every row
ALTER TABLE customers ALTER COLUMN signup_year SET NOT NULL;              -- 3. now make it required
INSERT INTO schema_migrations (version, name) VALUES (2, 'add_signup_year');
COMMIT;

-- check
SELECT * FROM schema_migrations ORDER BY version;
