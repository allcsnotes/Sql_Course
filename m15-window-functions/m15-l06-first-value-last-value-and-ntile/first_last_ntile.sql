-- M15-L06 FIRST_VALUE, LAST_VALUE, NTILE and percentiles (chai_corner)
-- Runs on the Chai Corner database (sales table). Run one query at a time.

-- Step 1: FIRST_VALUE: the total of the first row, on every row
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  FIRST_VALUE(total) OVER (ORDER BY day) AS first_day
FROM daily ORDER BY day;
-- 8 rows: first_day 60 on every row

-- Step 2 (the trap): LAST_VALUE with the default frame only sees up to the current row
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAST_VALUE(total) OVER (ORDER BY day) AS last_day
FROM daily ORDER BY day;
-- 8 rows: last_day = its own total (60, 170, 445, 250, 370, 260, 485, 655)

-- Step 3 (the fix): the full frame lets every row see the last day
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAST_VALUE(total) OVER (
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_day
FROM daily ORDER BY day;
-- 8 rows: last_day 655 on every row

-- Step 4: NTILE: sort busiest first, split into 4 groups
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  NTILE(4) OVER (ORDER BY total DESC) AS band
FROM daily ORDER BY total DESC;
-- 8 rows: band 1: 655, 485; band 2: 445, 370; band 3: 260, 250; band 4: 170, 60

-- Step 5: percentiles: the median (CONT) and a real value (DISC)
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median,
  PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY total) AS real_day
FROM daily;
-- 1 row: median 315, real_day 260

-- Mistake 2: no WITHIN GROUP
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT PERCENTILE_CONT(0.5) AS median
FROM daily;
-- ERROR 42883: function percentile_cont(numeric) does not exist

-- Mistake 3: NTILE(3) on 8 rows gives groups of 3, 3 and 2
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  NTILE(3) OVER (ORDER BY total DESC) AS band
FROM daily ORDER BY total DESC;
-- 8 rows: band 1: 655, 485, 445; band 2: 370, 260, 250; band 3: 170, 60

-- Your task: a busy half and a quiet half
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  NTILE(2) OVER (ORDER BY total DESC) AS half
FROM daily ORDER BY total DESC;
-- 8 rows: half 1: 655, 485, 445, 370; half 2: 260, 250, 170, 60
