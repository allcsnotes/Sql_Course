-- M09-L04 Joining three or more tables (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders, order_items) from M08-L03.

-- Step 1: three tables: each order with a name and a city
SELECT orders.order_id, customers.name, branches.city
FROM orders
JOIN customers ON customers.customer_id = orders.customer_id
JOIN branches  ON branches.branch_id = orders.branch_id
ORDER BY orders.order_id
LIMIT 5;
-- 5 rows: 1 Kabir Mumbai, 2 Rohan Pune, 3 Ananya Pune, 4 Arjun Pune, 5 Vikram Delhi

-- Step 2: four tables: order 2 with item names and prices
SELECT customers.name, menu_items.name AS item,
       order_items.qty, menu_items.price
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE orders.order_id = 2;
-- 3 rows: Rohan Cutting Chai 1 20, Rohan Masala Chai 2 30, Rohan Samosa 1 25

-- Step 3: five tables: Rohan's bill
SELECT customers.name, branches.city,
       SUM(order_items.qty * menu_items.price) AS bill
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN branches    ON branches.branch_id = orders.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE orders.order_id = 2
GROUP BY customers.name, branches.city;
-- 1 row: Rohan Pune 105

-- Step 4: a real report: who spends the most?
SELECT customers.name, COUNT(DISTINCT orders.order_id) AS orders,
       SUM(order_items.qty * menu_items.price) AS spent
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
GROUP BY customers.name
ORDER BY spent DESC
LIMIT 5;
-- 5 rows: Tara 218 19940, Kiran 198 19585, Isha 204 19530, Neha 200 19305, Lukas 205 19055

-- Mistake 1: using a table you never joined. FAILS on purpose.
SELECT customers.name, menu_items.name AS item
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
WHERE orders.order_id = 2;
-- SQL Error [42P01]: ERROR: missing FROM-clause entry for table "menu_items"  Position: 24

-- Mistake 2: counting rows after a join
SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT orders.order_id) AS real_orders
FROM orders
JOIN order_items ON order_items.order_id = orders.order_id;
-- 1 row: joined_rows 5530, real_orders 3000

-- Your task: what were Mumbai's total sales?
SELECT SUM(order_items.qty * menu_items.price) AS mumbai_sales
FROM orders
JOIN branches    ON branches.branch_id = orders.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE branches.city = 'Mumbai';
-- 1 row: 87545
