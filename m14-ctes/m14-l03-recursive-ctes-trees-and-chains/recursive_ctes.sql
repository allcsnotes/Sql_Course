-- M14-L03 Recursive CTEs: a step that reads itself
-- Runs on the Chai Corner database (staff table: manager_id points to the boss).
-- Run one query at a time.

-- Step 1: count from 1 to 5
WITH RECURSIVE counter AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM counter WHERE n < 5
)
SELECT n FROM counter;
-- 5 rows: 1, 2, 3, 4, 5

-- Step 2: one row for every day of the first week of March
WITH RECURSIVE days AS (
  SELECT DATE '2026-03-01' AS day
  UNION ALL
  SELECT day + 1 FROM days WHERE day < DATE '2026-03-07'
)
SELECT day FROM days;
-- 7 rows: 2026-03-01 to 2026-03-07

-- Step 3: walk up the chain: Nisha, her boss, their boss...
WITH RECURSIVE chain AS (
  SELECT staff_id, name, manager_id, 1 AS step
  FROM staff WHERE name = 'Nisha'
  UNION ALL
  SELECT s.staff_id, s.name, s.manager_id, c.step + 1
  FROM staff s JOIN chain c ON s.staff_id = c.manager_id
)
SELECT step, name FROM chain;
-- 4 rows: 1 Nisha, 2 Pooja, 3 Imran, 4 Meera

-- Step 4: walk down the tree: the top boss, then everyone below
WITH RECURSIVE tree AS (
  SELECT staff_id, name, 1 AS level
  FROM staff WHERE manager_id IS NULL
  UNION ALL
  SELECT s.staff_id, s.name, t.level + 1
  FROM staff s JOIN tree t ON s.manager_id = t.staff_id
)
SELECT level, name FROM tree ORDER BY level, staff_id;
-- 10 rows: 1 Meera; 2 Imran; 3 Pooja, Sameer, Kavya, Farhan; 4 Ravi, Nisha, Aman, Leela

-- Mistake 3 fixed: both parts give numbers with a point
WITH RECURSIVE counter AS (
  SELECT 1.0 AS n
  UNION ALL
  SELECT n + 0.5 FROM counter WHERE n < 3
)
SELECT n FROM counter;
-- 5 rows: 1.0, 1.5, 2.0, 2.5, 3.0

-- Your task: how many people work under Imran, at any level? (answer: 8)
WITH RECURSIVE team AS (
  SELECT staff_id FROM staff WHERE name = 'Imran'
  UNION ALL
  SELECT s.staff_id
  FROM staff s JOIN team t ON s.manager_id = t.staff_id
)
SELECT COUNT(*) - 1 AS team_size FROM team;
-- 1 row: team_size 8
