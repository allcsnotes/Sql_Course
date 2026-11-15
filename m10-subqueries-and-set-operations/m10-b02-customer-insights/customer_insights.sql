-- Build 2: Customer Insights (Chai Corner, fictional data). Run setup.sql (update 6) first.

-- How many customers came each month?
SELECT DATE_TRUNC('month', ordered_at)::date AS month,
       COUNT(DISTINCT customer_id) AS customers
FROM orders
GROUP BY month
ORDER BY month;

-- New in April: came in April, but never before
SELECT customer_id FROM orders
WHERE ordered_at >= '2026-04-01'
EXCEPT
SELECT customer_id FROM orders
WHERE ordered_at < '2026-04-01'
ORDER BY customer_id;

-- The new customers, with their names
SELECT name, joined_on FROM customers
WHERE customer_id IN (
  SELECT customer_id FROM orders WHERE ordered_at >= '2026-04-01'
  EXCEPT
  SELECT customer_id FROM orders WHERE ordered_at < '2026-04-01'
)
ORDER BY joined_on;

-- Returning: came before April, and came again in April
SELECT name FROM customers
WHERE customer_id IN (
  SELECT customer_id FROM orders WHERE ordered_at < '2026-04-01'
  INTERSECT
  SELECT customer_id FROM orders WHERE ordered_at >= '2026-04-01'
)
ORDER BY name;

-- Lost: their last order was before April
SELECT c.name, MAX(o.ordered_at)::date AS last_order
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
HAVING MAX(o.ordered_at) < '2026-04-01'
ORDER BY last_order;

-- Items nobody has ever ordered
SELECT m.name, m.price
FROM menu_items m
WHERE NOT EXISTS (
  SELECT 1 FROM order_items oi
  WHERE oi.item_id = m.item_id
);

-- Same question, with a LEFT JOIN
SELECT m.name, m.price
FROM menu_items m
LEFT JOIN order_items oi ON oi.item_id = m.item_id
WHERE oi.item_id IS NULL;

-- Step 1: orders per customer, in Pune only
SELECT c.name, COUNT(*) AS orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.branch_id = 1
GROUP BY c.name
ORDER BY orders DESC;

-- Step 2: the top customer in each branch
SELECT b.city, c.name, COUNT(*) AS orders
FROM orders o
JOIN branches b ON b.branch_id = o.branch_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.branch_id, b.city, c.name
HAVING COUNT(*) = (SELECT MAX(n) FROM (
    SELECT COUNT(*) AS n FROM orders o2
    WHERE o2.branch_id = o.branch_id GROUP BY o2.customer_id) AS per_customer)
ORDER BY orders DESC;

-- Check: new + returning = April customers (4 + 12 = 16),
-- and returning + lost = customers before April (12 + 3 = 15).

-- Mistake 1: WHERE instead of HAVING (15 rows, every last order is 2026-03-31)
SELECT c.name, MAX(o.ordered_at)::date AS last_order
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.ordered_at < '2026-04-01'
GROUP BY c.customer_id, c.name
ORDER BY last_order;

-- Mistake 2: the two lists swapped around EXCEPT (the lost customers: Kabir, Neha, Tara)
SELECT name, joined_on FROM customers
WHERE customer_id IN (
  SELECT customer_id FROM orders WHERE ordered_at < '2026-04-01'
  EXCEPT
  SELECT customer_id FROM orders WHERE ordered_at >= '2026-04-01'
)
ORDER BY joined_on;

-- Mistake 3: the inner query forgot its branch (1 row: Pune, Kiran, 151)
SELECT b.city, c.name, COUNT(*) AS orders
FROM orders o
JOIN branches b ON b.branch_id = o.branch_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.branch_id, b.city, c.name
HAVING COUNT(*) = (SELECT MAX(n) FROM (
    SELECT COUNT(*) AS n FROM orders o2
    GROUP BY o2.branch_id, o2.customer_id) AS per_customer)
ORDER BY orders DESC;

-- Your task: which customer placed the most orders in April? (answer: Rohan, 79)
SELECT c.name, COUNT(*) AS orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.ordered_at >= '2026-04-01'
GROUP BY c.name
ORDER BY orders DESC;
