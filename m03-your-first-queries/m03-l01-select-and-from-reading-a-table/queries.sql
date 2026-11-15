-- M03-L01 · SELECT and FROM: Reading a Table
-- Run in DBeaver (SQL editor on chai_corner) or psql (\c chai_corner first).

-- Step 1: every column of the menu
SELECT * FROM menu_items;
-- 10 rows, 3 columns (item_id, name, price): Bun Maska 35 ... Veg Sandwich 70

-- Step 2: every branch
SELECT * FROM branches;
-- 10 rows: branch_id, city, opened_on (Pune 2019-04-12 ... Kochi 2024-01-29)

-- Step 3: every customer
SELECT * FROM customers;
-- 15 rows: Asha ... Kiran

-- Step 4: capitals do not matter
select * from menu_items;
-- the same 10 rows

-- Step 5: new lines do not matter, only the semicolon ends the query
SELECT *
FROM menu_items;
-- the same 10 rows
