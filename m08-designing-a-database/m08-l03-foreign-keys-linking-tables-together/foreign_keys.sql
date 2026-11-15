-- M08-L03 Foreign keys: linking tables together (Chai Corner, fictional data)
-- Run setup.sql (Chai Corner update 4) once first. Then run each statement on its own.

-- Step 1: the new orders table
SELECT * FROM orders ORDER BY order_id LIMIT 5;
-- 5 rows: 1 cust 5 branch 2 2026-02-24 20:03, 2 cust 7 branch 1 2026-03-10 18:34,
--         3 cust 6 branch 1, 4 cust 11 branch 1, 5 cust 9 branch 3

-- Step 2: order 1 says branch 2. Look it up.
SELECT * FROM branches WHERE branch_id = 2;
-- 1 row: 2 Mumbai 2019-09-02

-- Step 3: order 1 says customer 5. Look it up.
SELECT customer_id, name FROM customers WHERE customer_id = 5;
-- 1 row: 5 Kabir  (order 1 is Kabir, at the Mumbai branch)

-- Step 4: an order for branch 99, which does not exist. This FAILS on purpose.
INSERT INTO orders VALUES (3001, 1, 99, '2026-04-01 10:00');
-- SQL Error [23503]: ERROR: insert or update on table "orders" violates foreign key constraint "orders_branch_id_fkey"
--   Detail: Key (branch_id)=(99) is not present in table "branches".

-- Step 5: every foreign key in the database
SELECT conrelid::regclass AS from_table,
       confrelid::regclass AS points_to
FROM pg_constraint
WHERE contype = 'f'
ORDER BY 1, 2;
-- 4 rows: orders -> branches, orders -> customers, order_items -> menu_items, order_items -> orders

-- Step 6: delete the Pune branch, which orders still point to. This FAILS on purpose.
DELETE FROM branches WHERE branch_id = 1;
-- SQL Error [23503]: ERROR: update or delete on table "branches" violates foreign key constraint "orders_branch_id_fkey" on table "orders"
--   Detail: Key (branch_id)=(1) is still referenced from table "orders".
-- (1522 orders point to Pune.)

-- Your task: which customer placed order 2?
SELECT * FROM orders WHERE order_id = 2;
-- 1 row: 2 cust 7 branch 1 2026-03-10 18:34
SELECT customer_id, name FROM customers WHERE customer_id = 7;
-- 1 row: 7 Rohan
