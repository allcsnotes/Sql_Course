-- M20-L03 setup: DB update 13 (catch-up only)
-- Use this ONLY if you skipped the lesson. If you follow the lesson, run the
-- migration files 000, 001 and 002 instead (they are what the video ran).
-- Safe to run again: every step checks first.
-- Result: table schema_migrations (versions 1 and 2),
--         customers.phone text, customers.signup_year int NOT NULL (19 customers).

BEGIN;

CREATE TABLE IF NOT EXISTS schema_migrations (
  version    int PRIMARY KEY,
  name       text NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now()
);

-- migration 1
ALTER TABLE customers ADD COLUMN IF NOT EXISTS phone text;
INSERT INTO schema_migrations (version, name) VALUES (1, 'add_customer_phone')
ON CONFLICT (version) DO NOTHING;

-- migration 2: add, fill, then require
ALTER TABLE customers ADD COLUMN IF NOT EXISTS signup_year int;
UPDATE customers SET signup_year = EXTRACT(YEAR FROM joined_on)::int
WHERE signup_year IS NULL;
ALTER TABLE customers ALTER COLUMN signup_year SET NOT NULL;
INSERT INTO schema_migrations (version, name) VALUES (2, 'add_signup_year')
ON CONFLICT (version) DO NOTHING;

COMMIT;

-- check: 2 rows (1 add_customer_phone, 2 add_signup_year)
SELECT version, name FROM schema_migrations ORDER BY version;
