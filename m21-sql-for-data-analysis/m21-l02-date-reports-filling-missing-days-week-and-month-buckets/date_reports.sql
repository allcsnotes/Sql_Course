-- M21-L02 Date reports: filling missing days, week and month buckets
-- The queries in the order the video runs them, with the real results.
-- Already ran setup.sql? Run this first:  DROP TABLE stall_sales;

-- Step 1: a small tea stall: cups sold per day (it was closed on two days)
CREATE TABLE stall_sales (sold_on date, cups int);
INSERT INTO stall_sales VALUES
 ('2026-03-01', 40), ('2026-03-02', 35), ('2026-03-03', 52),
 ('2026-03-05', 48), ('2026-03-06', 61),
 ('2026-03-08', 30), ('2026-03-09', 44), ('2026-03-10', 57);
-- Updated Rows 8

-- Step 2: a daily report: one row per day (only 8 rows, the 4th and 7th are missing)
SELECT sold_on, SUM(cups) AS cups
FROM stall_sales
GROUP BY sold_on
ORDER BY sold_on;
-- 8 rows: 03-01 40, 03-02 35, 03-03 52, 03-05 48, 03-06 61, 03-08 30, 03-09 44, 03-10 57

-- Step 3: make every day from 1 to 10 March
SELECT day::date AS day
FROM generate_series('2026-03-01'::date,
                     '2026-03-10'::date,
                     interval '1 day') AS day;
-- 10 rows: 2026-03-01 ... 2026-03-10, including the 4th and the 7th

-- Step 4: every day, joined to the sales; a missing day becomes 0
SELECT day::date AS day,
       COALESCE(s.cups, 0) AS cups
FROM generate_series('2026-03-01'::date,
                     '2026-03-10'::date,
                     interval '1 day') AS day
LEFT JOIN stall_sales s ON s.sold_on = day
ORDER BY day;
-- 10 rows: 40, 35, 52, 0, 48, 61, 0, 30, 44, 57

-- Step 5: weekly report: cut each date back to the Monday of its week
SELECT date_trunc('week', sold_on)::date AS week_start,
       SUM(cups) AS cups
FROM stall_sales
GROUP BY week_start
ORDER BY week_start;
-- 3 rows: 2026-02-23 40, 2026-03-02 226, 2026-03-09 101

-- Step 6: monthly report on the real orders table
SELECT date_trunc('month', ordered_at)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;
-- 4 rows: 2026-01-01 383, 2026-02-01 932, 2026-03-01 1685, 2026-04-01 900

-- Task: how many rows?
SELECT day::date FROM generate_series('2026-03-01'::date, '2026-03-31'::date, interval '1 day') AS day;
-- 31 rows
