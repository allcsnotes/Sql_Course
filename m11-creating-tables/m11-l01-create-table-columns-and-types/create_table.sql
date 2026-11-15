-- Module 11, Lesson 1: CREATE TABLE (Chai Corner)
-- Run these one at a time, in this order, on your chai_corner database.

-- Step 1: a new table for Meera's suppliers
CREATE TABLE suppliers (
  supplier_id int PRIMARY KEY,
  name        varchar(60),
  city        varchar(30),
  supplies    text,
  since       date,
  rating      numeric(2,1)
);
-- Updated Rows 0 (the table is made, and it is still empty)

-- Step 2: check, which columns does the new table have?
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'suppliers'
ORDER BY ordinal_position;
-- 6 rows: supplier_id integer, name character varying, city character varying,
--         supplies text, since date, rating numeric

-- Step 3: the new table is empty
SELECT * FROM suppliers;
-- 6 column headers, no rows

-- Step 4: put three suppliers in it (INSERT is explained fully in Module 12)
INSERT INTO suppliers VALUES
  (1, 'Nilgiri Tea Co', 'Coonoor', 'tea leaves', '2019-03-01', 4.5),
  (2, 'Pune Dairy', 'Pune', 'milk', '2019-04-10', 4.8),
  (3, 'Sahyadri Snacks', 'Pune', 'samosa, vada pav', '2021-06-15', 4.2);
-- Updated Rows 3

-- Step 5: now look again
SELECT * FROM suppliers;
-- 3 rows: Nilgiri Tea Co (Coonoor), Pune Dairy (Pune), Sahyadri Snacks (Pune)

-- Step 6: safe to run again, only create it if it is not there yet
CREATE TABLE IF NOT EXISTS suppliers (
  supplier_id int PRIMARY KEY,
  name        varchar(60)
);
-- NOTICE: relation "suppliers" already exists, skipping

-- The three mistakes from the video are in README.md (they stop with an error on purpose).

-- Your task: a table for customer feedback (5 columns), then check its columns.
-- The answer is at the bottom of README.md.
