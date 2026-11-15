-- M09-L02 LEFT JOIN and RIGHT JOIN: keeping rows with no match (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders) from M08-L03. Branches 4 to 10 have no orders.

-- Step 1: the inner join shows only 3 of the 10 branches
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
INNER JOIN orders
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC;
-- 3 rows: Pune 1522, Mumbai 976, Delhi 502

-- Step 2: change one word: INNER becomes LEFT
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
-- 10 rows: Pune 1522, Mumbai 976, Delhi 502, then Ahmedabad, Bengaluru, Chennai,
--          Hyderabad, Jaipur, Kochi, Kolkata with 0

-- Step 3: without the count, each lonely branch gets one row with order_id NULL
SELECT branches.city, orders.order_id
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
ORDER BY orders.order_id DESC, branches.city
LIMIT 9;
-- 9 rows: Ahmedabad, Bengaluru, Chennai, Hyderabad, Jaipur, Kochi, Kolkata (all NULL),
--         then Mumbai 3000, Mumbai 2999  (NULLs sort first with DESC)

-- Step 4: only the rows with no match
SELECT branches.city
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
WHERE orders.order_id IS NULL
ORDER BY branches.city;
-- 7 rows: Ahmedabad, Bengaluru, Chennai, Hyderabad, Jaipur, Kochi, Kolkata

-- Step 5: RIGHT JOIN is the mirror image (orders first, branches second): same 10 rows
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM orders
RIGHT JOIN branches
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
-- 10 rows, same as step 2

-- Mistake 1: WHERE on the right table removes the empty branches again
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
WHERE orders.ordered_at >= '2026-03-01'
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
-- 3 rows: Pune 857, Mumbai 551, Delhi 277

-- Fix: put that condition inside ON
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
 AND orders.ordered_at >= '2026-03-01'
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
-- 10 rows: Pune 857, Mumbai 551, Delhi 277, then 7 branches with 0

-- Mistake 2: COUNT(*) counts the row itself, so empty branches show 1
SELECT branches.city, COUNT(*) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
-- 10 rows: Pune 1522, Mumbai 976, Delhi 502, then 7 branches with 1 (wrong)

-- Your task: how many customers have never placed an order?
SELECT COUNT(*) AS never_ordered
FROM customers
LEFT JOIN orders
  ON orders.customer_id = customers.customer_id
WHERE orders.order_id IS NULL;
-- 1 row: 0
