-- M15-L05 LAG and LEAD (chai_corner)
-- Runs on the Chai Corner database (sales table). Run one query at a time.

-- Step 1: LAG: the total from the row before
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAG(total) OVER (ORDER BY day) AS yesterday
FROM daily ORDER BY day;
-- 8 rows: yesterday NULL, 60, 170, 445, 250, 370, 260, 485

-- Step 2: the change from yesterday
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  total - LAG(total) OVER (ORDER BY day) AS change
FROM daily ORDER BY day;
-- 8 rows: change NULL, 110, 275, -195, 120, -110, 225, 170

-- Step 3: LEAD: the total from the row after
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LEAD(total) OVER (ORDER BY day) AS tomorrow
FROM daily ORDER BY day;
-- 8 rows: tomorrow 170, 445, 250, 370, 260, 485, 655, NULL

-- Step 4: a default instead of NULL for the first row
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAG(total, 1, 0) OVER (ORDER BY day) AS yesterday
FROM daily ORDER BY day;
-- 8 rows: yesterday 0, 60, 170, 445, 250, 370, 260, 485

-- Mistake 1: window functions are not allowed in WHERE
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total
FROM daily
WHERE total > LAG(total) OVER (ORDER BY day);
-- ERROR 42P20: window functions are not allowed in WHERE

-- Mistake 1 fixed: work out LAG in a CTE, then filter
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
), d2 AS (
  SELECT day, total, LAG(total) OVER (ORDER BY day) AS yesterday
  FROM daily
)
SELECT day, total, yesterday FROM d2
WHERE total > yesterday ORDER BY day;
-- 5 rows: 01-03 170/60, 01-04 445/170, 01-06 370/250, 01-08 485/260, 01-09 655/485

-- Mistake 2: no PARTITION BY, so Mumbai gets Delhi's total
WITH daily AS (
  SELECT branch, sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-06' GROUP BY 1, 2
)
SELECT branch, day, total,
  LAG(total) OVER (ORDER BY branch, day) AS yesterday
FROM daily ORDER BY branch, day;
-- 8 rows: Mumbai 2026-01-02 shows 250 (Delhi's last day), Pune 2026-01-04 shows 180 (Mumbai's)

-- Mistake 2 fixed: PARTITION BY branch, each branch starts with NULL
WITH daily AS (
  SELECT branch, sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-06' GROUP BY 1, 2
)
SELECT branch, day, total,
  LAG(total) OVER (PARTITION BY branch ORDER BY day) AS yesterday
FROM daily ORDER BY branch, day;
-- 8 rows: the first day of Delhi, Mumbai and Pune each shows NULL

-- Your task: the total from two days before
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAG(total, 2) OVER (ORDER BY day) AS two_days_ago
FROM daily ORDER BY day;
-- 8 rows: two_days_ago NULL, NULL, 60, 170, 445, 250, 370, 260
