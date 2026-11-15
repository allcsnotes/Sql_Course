-- M08-L04 Relationships: one to one, one to many, many to many (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders, order_items) from M08-L03.

-- Step 1: one to many. One branch has many orders.
SELECT branch_id, COUNT(*) AS orders
FROM orders
GROUP BY branch_id
ORDER BY branch_id;
-- 3 rows: 1 -> 1522 (Pune), 2 -> 976 (Mumbai), 3 -> 502 (Delhi)

-- Step 2: many to many. The junction table order_items links orders and menu items.
SELECT * FROM order_items ORDER BY order_id, item_id LIMIT 8;
-- 8 rows: (1,3,1) (2,3,1) (2,7,2) (2,8,1) (3,4,1) (3,8,1) (4,3,3) (5,1,1)
-- order 2 has three rows: item 3 Cutting Chai, item 7 Masala Chai, item 8 Samosa

-- Step 3: one item is in many orders
SELECT item_id, COUNT(*) AS orders
FROM order_items
GROUP BY item_id
ORDER BY item_id;
-- 10 rows: 1 575, 2 375, 3 920, 4 407, 5 528, 6 396, 7 961, 8 534, 9 606, 10 228
-- item 7 (Masala Chai) is in 961 orders

-- Step 4: the pair (order_id, item_id) is the key. Cutting Chai again in order 1 FAILS on purpose.
INSERT INTO order_items VALUES (1, 3, 1);
-- SQL Error [23505]: ERROR: duplicate key value violates unique constraint "order_items_pkey"
--   Detail: Key (order_id, item_id)=(1, 3) already exists.

-- Your task: how many orders did Kabir (customer 5) place?
SELECT COUNT(*) AS kabir_orders FROM orders WHERE customer_id = 5;
-- 1 row: 188
