-- M08-L02 Primary keys: one unique ID per row (Chai Corner, fictional data)
-- Run each statement on its own (DBeaver: Ctrl+Enter).

-- Step 1: every customer has a customer_id, 1 to 15, no repeats
SELECT customer_id, name, joined_on FROM customers ORDER BY customer_id;
-- 15 rows: 1 Asha 2024-11-11, 2 Lukas, 3 Priya, ... 7 Rohan 2025-03-05, ... 15 Kiran 2026-06-10

-- Step 2: ask for one ID, get exactly one row
SELECT * FROM customers WHERE customer_id = 7;
-- 1 row: 7 Rohan 2025-03-05 rohan@example.com

-- Step 3: rule 1, no repeats (Pune already has branch_id 1). This FAILS on purpose.
INSERT INTO branches VALUES (1, 'Goa', '2026-11-14');
-- SQL Error [23505]: ERROR: duplicate key value violates unique constraint "branches_pkey"
--   Detail: Key (branch_id)=(1) already exists.

-- Step 4: rule 2, never empty. This FAILS on purpose.
INSERT INTO branches VALUES (NULL, 'Goa', '2026-11-14');
-- SQL Error [23502]: ERROR: null value in column "branch_id" of relation "branches" violates not-null constraint
--   Detail: Failing row contains (null, Goa, 2026-11-14).
-- Both inserts failed, so nothing changed.

-- Step 5: ask the database which column is the key of each table
SELECT table_name, column_name
FROM information_schema.key_column_usage
WHERE constraint_name LIKE '%pkey'
ORDER BY table_name;
-- 4 rows: branches branch_id, customers customer_id, menu_items item_id, sales sale_id

-- Mistake 1: order_id repeats, so it cannot be the key of sales
SELECT COUNT(*) AS sale_rows,
       COUNT(DISTINCT order_id) AS different_orders
FROM sales;
-- 1 row: sale_rows 6028, different_orders 3000

-- Mistake 2: the row number on the left is not the ID
SELECT item_id, name, price FROM menu_items ORDER BY price;
-- row 1 is item_id 3 Cutting Chai 20, row 2 is item_id 8 Samosa 25, ...

-- Mistake 3: email can be empty, so it cannot be the key
SELECT COUNT(*) AS customers,
       COUNT(email) AS with_email
FROM customers;
-- 1 row: customers 15, with_email 11

-- Your task: prove that item_id is unique in menu_items
SELECT COUNT(*) AS item_rows,
       COUNT(DISTINCT item_id) AS different_ids
FROM menu_items;
-- 1 row: item_rows 10, different_ids 10 (equal, so no repeats)
