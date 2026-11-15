-- M22-L01 · the PostgreSQL side of the comparison table (run on your chai_corner database)

-- Step 1: LIKE cares about capital letters in PostgreSQL
SELECT name FROM menu_items WHERE name LIKE 'masala%';
-- 0 rows (use ILIKE, from M03-L05, to ignore case)

-- Step 2: the month of a date
SELECT date_trunc('month', DATE '2026-03-14') AS month;
-- 1 row: 2026-03-01 00:00:00 with your time zone (the first moment of the month)

-- Step 3: two bars join text
SELECT 'Masala' || ' Chai' AS item;
-- 1 row: Masala Chai
