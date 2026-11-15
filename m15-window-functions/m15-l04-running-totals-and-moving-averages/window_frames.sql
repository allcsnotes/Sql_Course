-- M15-L04 Running totals and moving averages (chai_corner)
-- Runs on the Chai Corner database (sales table). Run one query at a time.

-- Step 1: a running total: each day adds to all the days before it
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  SUM(total) OVER (ORDER BY day) AS running
FROM daily ORDER BY day;
-- 8 rows: running 60, 230, 675, 925, 1295, 1555, 2040, 2695

-- Step 2: a 3-day moving average: this row and the 2 before it
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  ROUND(AVG(total) OVER (
    ORDER BY day
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  )) AS avg3
FROM daily ORDER BY day;
-- 8 rows: avg3 60, 115, 225, 288, 355, 293, 372, 467

-- Step 3: one running total per branch
WITH daily AS (
  SELECT branch, sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-06' GROUP BY 1, 2
)
SELECT branch, day, total,
  SUM(total) OVER (PARTITION BY branch ORDER BY day) AS running
FROM daily ORDER BY branch, day;
-- 8 rows: Delhi 145, 395; Mumbai 60, 85, 135, 315; Pune 145, 215

-- Mistake 3 fixed: break ties with a unique column
SELECT sold_at::date AS day, qty * price AS amount,
  SUM(qty * price) OVER (ORDER BY sold_at, sale_id) AS running
FROM sales WHERE sold_at < '2026-01-04'
ORDER BY sold_at, sale_id;
-- 6 rows: running 30, 60, 85, 125, 205, 230

-- Your task: a two day total (each day plus the day before it)
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  SUM(total) OVER (
    ORDER BY day
    ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
  ) AS two_days
FROM daily ORDER BY day;
-- 8 rows: two_days 60, 230, 615, 695, 620, 630, 745, 1140
