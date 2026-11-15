-- M22-L04 · Classic interview problems 2 (PostgreSQL, chai_corner)
-- Run setup.sql first (it creates daily_visits).

-- Step 1: the visits
SELECT * FROM daily_visits ORDER BY customer, visited_on;
-- 13 rows: Asha Mar 1, 2, 3, 5, 6, 9, 10, 11, 12; Rahul Mar 2, 4, 5, 8

-- Step 2: LAG, the gap in days since the visit before
SELECT visited_on,
       LAG(visited_on) OVER (ORDER BY visited_on) AS prev_day,
       visited_on - LAG(visited_on) OVER (ORDER BY visited_on) AS gap
FROM daily_visits WHERE customer = 'Asha' ORDER BY visited_on;
-- 9 rows, gap: NULL, 1, 1, 2, 1, 3, 1, 1, 1

-- Step 3: the islands trick. Date minus row number is the same for every day of a streak
SELECT visited_on,
       ROW_NUMBER() OVER (ORDER BY visited_on) AS rn,
       visited_on - (ROW_NUMBER() OVER (ORDER BY visited_on))::int AS grp
FROM daily_visits WHERE customer = 'Asha' ORDER BY visited_on;
-- 9 rows, grp: 2026-02-28 x3, 2026-03-01 x2, 2026-03-03 x4

-- Step 4: one row for each streak (island)
WITH g AS (
  SELECT customer, visited_on,
         visited_on - (ROW_NUMBER() OVER (PARTITION BY customer ORDER BY visited_on))::int AS grp
  FROM daily_visits)
SELECT customer, MIN(visited_on) AS first_day, MAX(visited_on) AS last_day, COUNT(*) AS days
FROM g GROUP BY customer, grp ORDER BY customer, first_day;
-- 6 rows: Asha 03-01..03-03 3, 03-05..03-06 2, 03-09..03-12 4;
--         Rahul 03-02..03-02 1, 03-04..03-05 2, 03-08..03-08 1

-- Step 5: the longest streak for each customer
WITH g AS (
  SELECT customer, visited_on,
         visited_on - (ROW_NUMBER() OVER (PARTITION BY customer ORDER BY visited_on))::int AS grp
  FROM daily_visits),
streaks AS (SELECT customer, COUNT(*) AS days FROM g GROUP BY customer, grp)
SELECT customer, MAX(days) AS longest_streak FROM streaks GROUP BY customer ORDER BY customer;
-- 2 rows: Asha 4, Rahul 2

-- Step 6: the gaps (the days that were missed)
WITH p AS (
  SELECT customer, visited_on,
         LAG(visited_on) OVER (PARTITION BY customer ORDER BY visited_on) AS prev_day
  FROM daily_visits)
SELECT customer, prev_day + 1 AS gap_starts, visited_on - 1 AS gap_ends
FROM p WHERE visited_on - prev_day > 1 ORDER BY customer, gap_starts;
-- 4 rows: Asha 03-04..03-04, 03-07..03-08; Rahul 03-03..03-03, 03-06..03-07

-- Your task: every streak of 3 days or more
WITH g AS (
  SELECT customer, visited_on,
         visited_on - (ROW_NUMBER() OVER (PARTITION BY customer ORDER BY visited_on))::int AS grp
  FROM daily_visits)
SELECT customer, MIN(visited_on) AS first_day, COUNT(*) AS days
FROM g GROUP BY customer, grp HAVING COUNT(*) >= 3 ORDER BY customer, first_day;
-- 2 rows: Asha 2026-03-01 3, Asha 2026-03-09 4
