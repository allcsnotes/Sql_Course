-- Build 4: The Business Dashboard (Chai Corner)
-- Runs on the Chai Corner database (orders, order_items, branches, menu_items;
-- January to April 2026). Run one statement at a time.

-- Step 1: a view: orders per month (this view stays in the database)
CREATE VIEW monthly_orders AS
SELECT date_trunc('month', ordered_at)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month;

-- Question 1: Are we growing? (month over month)
SELECT month, orders,
  LAG(orders) OVER (ORDER BY month) AS last_month,
  ROUND(100.0 * (orders - LAG(orders) OVER (ORDER BY month))
    / LAG(orders) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly_orders
ORDER BY month;
-- 4 rows: 2026-01-01 383 NULL NULL | 2026-02-01 932 383 143.3
--         2026-03-01 1685 932 80.8  | 2026-04-01 900 1685 -46.6

-- Question 2: Who comes back? (retention by cohort)
WITH firsts AS (
  SELECT customer_id,
    date_trunc('month', MIN(ordered_at))::date AS cohort
  FROM orders GROUP BY customer_id
)
SELECT f.cohort, o.month, COUNT(DISTINCT customer_id) AS customers
FROM firsts f
JOIN (SELECT customer_id, date_trunc('month', ordered_at)::date AS month
      FROM orders) o USING (customer_id)
GROUP BY f.cohort, o.month ORDER BY 1, 2;
-- 5 rows: Jan cohort: Jan 15, Feb 15, Mar 15, Apr 12 | Apr cohort: Apr 4

-- Question 3: Do they buy more? (the funnel)
WITH per_order AS (
  SELECT order_id, COUNT(*) AS items
  FROM order_items
  GROUP BY order_id
)
SELECT COUNT(*) AS all_orders,
  COUNT(*) FILTER (WHERE items >= 2) AS two_plus,
  COUNT(*) FILTER (WHERE items >= 3) AS three_plus
FROM per_order;
-- 1 row: all_orders 3900, two_plus 2433, three_plus 884

-- Question 4: Which branch wins? (rankings)
SELECT b.city, SUM(oi.qty * m.price) AS revenue,
  RANK() OVER (ORDER BY SUM(oi.qty * m.price) DESC) AS rnk
FROM orders o
JOIN branches b USING (branch_id)
JOIN order_items oi USING (order_id)
JOIN menu_items m USING (item_id)
GROUP BY b.city
ORDER BY rnk;
-- 3 rows: Pune 182145 1, Mumbai 116220 2, Delhi 56145 3

-- Mistake 1: dividing whole numbers drops the decimals
SELECT month, orders,
  (orders - LAG(orders) OVER (ORDER BY month))
    / LAG(orders) OVER (ORDER BY month) AS growth
FROM monthly_orders
ORDER BY month;
-- 4 rows: growth NULL, 1, 0, 0 (fix: multiply by 100.0 first, as in Question 1)

-- Mistake 2: grouping by the full time
SELECT ordered_at, COUNT(*) AS orders
FROM orders
GROUP BY ordered_at
ORDER BY ordered_at;
-- 3,795 rows, almost every one with orders = 1 (fix: group by the month)

-- Mistake 3: filtering on the rank with WHERE
SELECT b.city, COUNT(*) AS orders,
  RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM orders o
JOIN branches b USING (branch_id)
WHERE rnk = 1
GROUP BY b.city;
-- ERROR 42703: column "rnk" does not exist

-- Mistake 3 fix: rank in a CTE, filter outside
WITH ranked AS (
  SELECT b.city, COUNT(*) AS orders,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
  FROM orders o
  JOIN branches b USING (branch_id)
  GROUP BY b.city
)
SELECT * FROM ranked
WHERE rnk = 1;
-- 1 row: Pune 1999 1

-- Your task: which branch had the most orders in April?
SELECT b.city, COUNT(*) AS april_orders
FROM orders o
JOIN branches b USING (branch_id)
WHERE ordered_at >= '2026-04-01'
GROUP BY b.city
ORDER BY april_orders DESC;
-- 3 rows: Pune 477, Mumbai 305, Delhi 118
