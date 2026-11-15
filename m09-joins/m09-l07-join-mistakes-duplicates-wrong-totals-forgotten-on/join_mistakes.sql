-- M09-L07 JOIN mistakes: duplicates, wrong totals, forgotten ON (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders, order_items) and update 5 (staff).

-- Step 1: duplicated rows: one row per order
-- Which customers have ordered?
SELECT customers.name
FROM customers
JOIN orders ON orders.customer_id = customers.customer_id
ORDER BY customers.name;
-- 3000 rows: Ananya, Ananya, Ananya, ... (each customer once per order)

-- Fix: DISTINCT
SELECT DISTINCT customers.name
FROM customers
JOIN orders ON orders.customer_id = customers.customer_id
ORDER BY customers.name;
-- 15 rows: Ananya, Arjun, Asha, Dev, Isha, Kabir, Kiran, Lukas, Neha, Priya, Rahul, Rohan, Sara, Tara, Vikram

-- Step 2: wrong counts: joining staff copies each order
SELECT branches.city, COUNT(*) AS orders
FROM branches
JOIN orders ON orders.branch_id = branches.branch_id
JOIN staff  ON staff.branch_id  = branches.branch_id
WHERE branches.city = 'Pune'
GROUP BY branches.city;
-- 1 row: Pune 4566  (1,522 orders x 3 staff)

-- Fix: COUNT(DISTINCT ...)
SELECT branches.city,
       COUNT(DISTINCT orders.order_id) AS orders,
       COUNT(DISTINCT staff.staff_id)  AS staff
FROM branches
JOIN orders ON orders.branch_id = branches.branch_id
JOIN staff  ON staff.branch_id  = branches.branch_id
WHERE branches.city = 'Pune'
GROUP BY branches.city;
-- 1 row: Pune 1522 3

-- Step 3: wrong totals
-- Pune sales, with staff joined in
SELECT SUM(order_items.qty * menu_items.price) AS sales
FROM branches
JOIN orders      ON orders.branch_id = branches.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
JOIN staff       ON staff.branch_id = branches.branch_id
WHERE branches.city = 'Pune';
-- 1 row: 416115

-- Fix: sales do not need staff, so remove that join
SELECT SUM(order_items.qty * menu_items.price) AS sales
FROM branches
JOIN orders      ON orders.branch_id = branches.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE branches.city = 'Pune';
-- 1 row: 138705  (exactly one third)

-- Step 4: the forgotten link
-- How many orders did Rohan place?
SELECT COUNT(*) AS rohan_orders
FROM customers, orders
WHERE customers.name = 'Rohan';
-- 1 row: 3000 (wrong: Rohan is paired with every order)

-- Fix: a real JOIN with an ON link
SELECT COUNT(*) AS rohan_orders
FROM customers
JOIN orders ON orders.customer_id = customers.customer_id
WHERE customers.name = 'Rohan';
-- 1 row: 188

-- Your task: Delhi's orders joined with its staff
SELECT COUNT(*) AS rows_after_join,
       COUNT(DISTINCT orders.order_id) AS real_orders
FROM branches
JOIN orders ON orders.branch_id = branches.branch_id
JOIN staff  ON staff.branch_id  = branches.branch_id
WHERE branches.city = 'Delhi';
-- 1 row: 1004 502
