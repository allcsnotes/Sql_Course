-- M14-L02 Many CTEs: a long query in small, readable steps
-- Runs on the Chai Corner database (sales table, Jan to Mar 2026).
-- Run one query at a time.

-- Step 1: two steps, a comma joins them
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
), good AS (
  SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
)
SELECT * FROM good ORDER BY day LIMIT 5;
-- 5 rows: 2026-02-12 4255, 2026-02-14 3985, 2026-02-16 3515, 2026-02-17 3385, 2026-02-18 4595

-- Step 2: the main query reads the last step
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
), good AS (
  SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
)
SELECT EXTRACT(MONTH FROM day) AS month, COUNT(*) AS good_days
FROM good GROUP BY month ORDER BY month;
-- 2 rows: month 2 -> 12, month 3 -> 30 (January has none)

-- Step 3: each branch's share of all sales
WITH branch_sales AS (
  SELECT branch, SUM(qty * price) AS total FROM sales GROUP BY branch
), overall AS (
  SELECT SUM(total) AS all_total FROM branch_sales
)
SELECT branch, total, ROUND(100.0 * total / all_total, 1) AS pct
FROM branch_sales CROSS JOIN overall
ORDER BY total DESC;
-- 3 rows: Pune 138705 51.1, Mumbai 87545 32.3, Delhi 45015 16.6

-- Your task: the average total of the good days (answer: 4619.40)
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
), good AS (
  SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
)
SELECT ROUND(AVG(total), 2) AS good_avg FROM good;
-- 1 row: good_avg 4619.40
