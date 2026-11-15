-- Module 11, Lesson 5: DROP vs TRUNCATE vs DELETE, how not to lose data
-- Chai Corner database (PostgreSQL 18)
-- Every command below runs on a practice copy, never the real table.

-- Step 1: a practice copy, so the real table stays safe
CREATE TABLE practice AS
  SELECT * FROM deliveries;
-- Updated Rows 3

-- Step 2: DELETE, remove the rows you pick
DELETE FROM practice
WHERE item = 'milk';
-- Updated Rows 1

-- Milk is gone, the other rows stay
SELECT delivery_id, item, status
FROM practice;
-- 2 rows: 2 tea leaves ordered, 3 samosa delivered

-- Step 3: TRUNCATE, empty the whole table, fast
TRUNCATE practice;
-- Updated Rows 0 (TRUNCATE does not count the rows)

-- No rows left, but the table and its columns stay
SELECT delivery_id, item, status
FROM practice;
-- 0 rows, 3 column headers

-- Step 4: DROP, remove the whole table, columns and all
-- (DBeaver asks: "Possible data loss. Are you sure?")
DROP TABLE practice;
-- Updated Rows 0

-- The table itself is gone
SELECT * FROM practice;
-- ERROR 42P01: relation "practice" does not exist

-- Three mistakes:
-- 1. DELETE with no WHERE empties everything (on a fresh practice copy)
CREATE TABLE practice AS SELECT * FROM deliveries;
DELETE FROM practice;
-- DBeaver asks first ("Execute dangerous queries"), then: Updated Rows 3
DROP TABLE practice;

-- 2. DROP a table other tables point to
DROP TABLE suppliers;
-- ERROR 2BP01: cannot drop table suppliers because other objects depend on it

-- 3. TRUNCATE a table other tables point to
TRUNCATE suppliers;
-- ERROR 0A000: cannot truncate a table referenced in a foreign key constraint

-- Your task: copy restocks, empty the copy, check restocks (answer in README.md)
