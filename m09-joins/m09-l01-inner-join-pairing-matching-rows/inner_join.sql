-- M09-L01 INNER JOIN: pairing matching rows (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders, order_items) from M08-L03.

-- Step 1: orders store only a customer number
SELECT order_id, customer_id
FROM orders
ORDER BY order_id
LIMIT 5;
-- 5 rows: 1 -> 5, 2 -> 7, 3 -> 6, 4 -> 11, 5 -> 9

-- Step 2: the names live in customers
SELECT customer_id, name
FROM customers
ORDER BY customer_id;
-- 15 rows: 1 Asha, 2 Lukas, 3 Priya, 4 Rahul, 5 Kabir, 6 Ananya, 7 Rohan, 8 Isha,
--          9 Vikram, 10 Neha, 11 Arjun, 12 Sara, 13 Dev, 14 Tara, 15 Kiran

-- Step 3: the join pairs each order with its customer
SELECT orders.order_id, customers.name
FROM orders
INNER JOIN customers
  ON orders.customer_id = customers.customer_id
ORDER BY orders.order_id
LIMIT 5;
-- 5 rows: 1 Kabir, 2 Rohan, 3 Ananya, 4 Arjun, 5 Vikram

-- Step 4: the same idea for items: names, not numbers
SELECT order_items.order_id, menu_items.name, order_items.qty
FROM order_items
INNER JOIN menu_items
  ON order_items.item_id = menu_items.item_id
WHERE order_items.order_id = 2;
-- 3 rows: 2 Cutting Chai 1, 2 Masala Chai 2, 2 Samosa 1

-- Mistake 1: customer_id is in both tables, so without a table name it is ambiguous. FAILS on purpose.
SELECT order_id, customer_id, name
FROM orders
INNER JOIN customers
  ON orders.customer_id = customers.customer_id;
-- SQL Error [42702]: ERROR: column reference "customer_id" is ambiguous  Position: 18

-- Your task: which city was order 1 placed in?
SELECT orders.order_id, branches.city
FROM orders
INNER JOIN branches
  ON orders.branch_id = branches.branch_id
WHERE orders.order_id = 1;
-- 1 row: 1 Mumbai
