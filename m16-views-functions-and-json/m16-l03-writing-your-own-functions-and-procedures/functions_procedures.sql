-- M16-L03 Writing your own functions and procedures (chai_corner)
-- Runs on the Chai Corner database (sales and newsletter tables).
-- Run one statement at a time.

-- Step 1: a function: input in, answer out (DBeaver: Updated Rows 0)
CREATE FUNCTION cups_for(b text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE branch = b;
$$;

-- Step 2: use it on its own
SELECT cups_for('Pune');
-- 1 row: 3827

-- Step 3: use it inside a query, once per row
SELECT DISTINCT branch, cups_for(branch) AS cups
FROM sales
ORDER BY branch;
-- 3 rows: Delhi 1269, Mumbai 2439, Pune 3827

-- Step 4: a procedure: does a job, returns nothing
CREATE PROCEDURE add_signup(e text) LANGUAGE sql AS $$
  INSERT INTO newsletter (email, joined_on) VALUES (e, '2026-03-12');
$$;

-- Step 5: run a procedure with CALL
CALL add_signup('neha@mail.com');

SELECT COUNT(*) AS people FROM newsletter;
-- 1 row: 6

-- Mistake 1: running a procedure with SELECT
SELECT add_signup('ravi@mail.com');
-- ERROR 42809: add_signup(unknown) is a procedure
-- HINT: To call a procedure, use CALL.

-- Mistake 2: passing the wrong type
SELECT cups_for(42);
-- ERROR 42883: function cups_for(integer) does not exist

-- Mistake 3: running CREATE FUNCTION twice
CREATE FUNCTION cups_for(b text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE branch = b;
$$;
-- ERROR 42723: function "cups_for" already exists with same argument types

-- Fix: CREATE OR REPLACE
CREATE OR REPLACE FUNCTION cups_for(b text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE branch = b;
$$;

-- Your task: a function for cups of one item
CREATE FUNCTION item_cups(i text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE item = i;
$$;

SELECT item_cups('Masala Chai');
-- 1 row: 1382
