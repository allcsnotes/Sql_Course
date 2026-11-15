-- M20-L03 · the queries the video runs between the migration files
-- Run them in this order, together with 000, 001 and 002.

-- Step 1: run 000_schema_migrations.sql      -- CREATE TABLE
-- Step 2: run 001_add_customer_phone.sql     -- 4 queries, 1 row into the list

-- Step 3: look at the list
SELECT * FROM schema_migrations ORDER BY version;
-- 1 row: 1 | add_customer_phone | (the time it ran)

-- Step 4: running migration 001 a second time, by mistake
ALTER TABLE customers ADD COLUMN phone text;
-- ERROR [42701]: column "phone" of relation "customers" already exists

-- Step 5: a required column, in one step
ALTER TABLE customers ADD COLUMN signup_year int NOT NULL;
-- ERROR [23502]: column "signup_year" of relation "customers" contains null values

-- Step 6: run 002_add_signup_year.sql        -- 6 queries, 20 rows changed (19 customers + 1 list row)

-- Step 7: every customer now has a year
SELECT customer_id, name, joined_on, signup_year
FROM customers ORDER BY customer_id LIMIT 5;
-- 5 rows: Asha 2024-11-11 2024, Lukas 2024-11-14 2024, Priya 2024-12-02 2024,
--         Rahul 2025-01-09 2025, Kabir 2025-01-21 2025

-- Step 8: the list shows two versions
SELECT * FROM schema_migrations ORDER BY version;
-- 2 rows: 1 add_customer_phone, 2 add_signup_year
