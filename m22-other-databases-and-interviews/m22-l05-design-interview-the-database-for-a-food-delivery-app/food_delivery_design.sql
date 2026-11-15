-- M22-L05 · Design interview: testing the food delivery design with queries (PostgreSQL)
-- Run setup.sql first: it builds the delivery schema (step 2 and step 3 tables) and the sample data.

SET search_path TO delivery;

-- Step 1: the receipt for order 101 (four joins)
SELECT c.name AS customer, r.name AS restaurant, m.name AS item,
  oi.qty, oi.price_at_order, oi.qty * oi.price_at_order AS line_total
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN restaurants r ON r.id = o.restaurant_id
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items m ON m.id = oi.menu_item_id
WHERE o.id = 101;
-- 2 rows: Rahul | Spice Box | Paneer Roll | 2 | 120 | 240
--         Rahul | Spice Box | Veg Biryani | 1 | 180 | 180

-- Step 2: the bill for every order
SELECT o.id AS order_id, o.status, SUM(oi.qty * oi.price_at_order) AS total
FROM orders o JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.status ORDER BY o.id;
-- 2 rows: 101 delivered 420, 102 on_the_way 260

-- Step 3: the CHECK rule refuses a status that does not exist
UPDATE orders SET status = 'lost' WHERE id = 102;
-- ERROR: new row for relation "orders" violates check constraint "orders_status_check" (SQLSTATE 23514)

-- Step 4: the price goes up, but order 101 keeps the price it was sold at
UPDATE menu_items SET price = 150 WHERE id = 1;
-- UPDATE 1
SELECT m.name AS item, m.price AS price_now, oi.price_at_order
FROM order_items oi JOIN menu_items m ON m.id = oi.menu_item_id
WHERE oi.order_id = 101;
-- 2 rows: Veg Biryani 180 180, Paneer Roll 150 120

-- Your task: money earned by each restaurant
SELECT r.name AS restaurant, SUM(oi.qty * oi.price_at_order) AS revenue
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY r.name ORDER BY revenue DESC;
-- 2 rows: Spice Box 420, Dosa Hut 260

-- back to the Chai Corner tables
SET search_path TO public;
