-- M10-L03 Subqueries in SELECT and FROM (derived tables) (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders, order_items) from M08-L03.

-- Step 1: a subquery in SELECT: the menu average on every row
SELECT name, price,
       (SELECT ROUND(AVG(price)) FROM menu_items) AS menu_avg
FROM menu_items
ORDER BY price DESC;
-- 10 rows, menu_avg 42 on every row: Cold Coffee 80 42, Veg Sandwich 70 42, ... Cutting Chai 20 42

-- Step 2: how far is each price from the average?
SELECT name, price,
       price - (SELECT ROUND(AVG(price)) FROM menu_items) AS vs_avg
FROM menu_items
ORDER BY price DESC;
-- 10 rows: Cold Coffee 80 38, Veg Sandwich 70 28, Maggi 60 18, Filter Coffee 40 -2, Bun Maska 35 -7,
--          then the three 30s -12, Samosa 25 -17, Cutting Chai 20 -22

-- Step 3: the problem: WHERE cannot see a name made in SELECT. FAILS on purpose.
SELECT customer_id, COUNT(*) AS order_count
FROM orders
WHERE order_count > 200
GROUP BY customer_id;
-- SQL Error [42703]: ERROR: column "order_count" does not exist

-- Step 4: a subquery in FROM: a table made on the fly
SELECT customer_id, order_count
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS per_customer
WHERE order_count > 200
ORDER BY order_count DESC;
-- 6 rows: 14 218, 9 209, 2 205, 6 205, 8 204, 4 203 (2 and 6 tie, so they can swap places)

-- Step 5: an average of counts
SELECT ROUND(AVG(order_count), 1) AS avg_orders
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS per_customer;
-- 1 row: 200.0

-- Mistake 1: a column the inner query did not keep. FAILS on purpose.
SELECT name, order_count
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS per_customer;
-- SQL Error [42703]: ERROR: column "name" does not exist

-- Mistake 2: a SELECT subquery that gives back many rows. FAILS on purpose.
SELECT name, price,
       (SELECT price FROM menu_items) AS other_price
FROM menu_items;
-- SQL Error [21000]: ERROR: more than one row returned by a subquery used as an expression

-- Your task: items in an average order
SELECT ROUND(AVG(items), 2) AS avg_items
FROM (SELECT order_id, SUM(qty) AS items
      FROM order_items
      GROUP BY order_id) AS per_order;
-- 1 row: 2.51
