-- M10-L01 A query inside a query: subquery in WHERE (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders) from M08-L03.

-- Step 1: the average price on the menu
SELECT ROUND(AVG(price), 2) AS avg_price
FROM menu_items;
-- 1 row: 42.00

-- Step 2: type the number by hand
SELECT name, price
FROM menu_items
WHERE price > 42
ORDER BY price DESC;
-- 3 rows: Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Step 3: let a subquery find the number
SELECT name, price
FROM menu_items
WHERE price > (SELECT AVG(price) FROM menu_items)
ORDER BY price DESC;
-- 3 rows: Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Step 4: the most expensive item on the menu
SELECT name, price
FROM menu_items
WHERE price = (SELECT MAX(price) FROM menu_items);
-- 1 row: Cold Coffee 80

-- Step 5: orders from the Pune branch, without a JOIN
SELECT COUNT(*) AS pune_orders
FROM orders
WHERE branch_id = (SELECT branch_id FROM branches WHERE city = 'Pune');
-- 1 row: 1522

-- Mistake 1: the subquery gives back many rows. FAILS on purpose.
SELECT COUNT(*) AS orders
FROM orders
WHERE branch_id = (SELECT branch_id FROM branches);
-- SQL Error [21000]: ERROR: more than one row returned by a subquery used as an expression

-- Mistake 2: the subquery gives back two columns. FAILS on purpose.
SELECT name, price
FROM menu_items
WHERE price > (SELECT AVG(price), MAX(price) FROM menu_items);
-- SQL Error [42601]: ERROR: subquery must return only one column

-- Mistake 3: the brackets are missing. FAILS on purpose.
SELECT name, price
FROM menu_items
WHERE price > SELECT AVG(price) FROM menu_items;
-- SQL Error [42601]: ERROR: syntax error at or near "SELECT"

-- Your task: items cheaper than the average
SELECT name, price
FROM menu_items
WHERE price < (SELECT AVG(price) FROM menu_items)
ORDER BY price;
-- 7 rows: Cutting Chai 20, Samosa 25, Ginger Chai 30, Masala Chai 30, Vada Pav 30, Bun Maska 35, Filter Coffee 40
