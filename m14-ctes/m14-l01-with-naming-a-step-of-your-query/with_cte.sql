-- M14-L01 WITH: giving a name to one step of your query
-- Runs on the Chai Corner database (sales table, Jan to Mar 2026).
-- Run one query at a time (select it, then Ctrl+Enter in DBeaver).

-- Step 1: WITH gives a name to one step
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT * FROM daily ORDER BY day LIMIT 5;
-- 5 rows: 2026-01-02 60, 2026-01-03 170, 2026-01-04 445, 2026-01-05 250, 2026-01-06 370

-- Step 2: the name works like a table
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT COUNT(*) AS days, ROUND(AVG(total), 2) AS avg_day FROM daily;
-- 1 row: days 89, avg_day 3047.92

-- Step 3: use the same name twice
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT day, total FROM daily
WHERE total > (SELECT AVG(total) FROM daily)
ORDER BY total DESC LIMIT 5;
-- 5 rows: 2026-03-23 7325, 2026-03-27 6505, 2026-03-20 6285, 2026-03-28 6225, 2026-03-21 6000

-- Step 4: the same answer, without WITH
SELECT day, total FROM (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
) d
WHERE total > (SELECT AVG(total) FROM (
  SELECT SUM(qty * price) AS total FROM sales GROUP BY sold_at::date
) d2)
ORDER BY total DESC LIMIT 5;
-- 5 rows: exactly the same five days as Step 3

-- Your task: how many days beat the average? (answer: 42)
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT COUNT(*) AS good_days FROM daily
WHERE total > (SELECT AVG(total) FROM daily);
-- 1 row: good_days 42
