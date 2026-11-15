-- M07-L03 · The three beginner mistakes.

-- Mistake 1: a column that is not in the GROUP BY. Each pile holds many names.
SELECT category, name, COUNT(*) AS items
FROM menu_items
GROUP BY category;
-- SQL Error [42803]: ERROR: column "menu_items.name" must appear in the GROUP BY clause or be used in an aggregate function

-- Mistake 2: COUNT inside WHERE. WHERE runs before the piles exist.
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE COUNT(*) > 2
GROUP BY category;
-- SQL Error [42803]: ERROR: aggregate functions are not allowed in WHERE
-- Fix: to filter the piles, use HAVING (the next lesson).
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING COUNT(*) > 2;
-- 2 rows: Chai 3, Snack 5   (order may differ: there is no ORDER BY)

-- Mistake 3: grouping by a column that is different in every row. Every count is 1.
SELECT name, COUNT(*) AS items
FROM menu_items
GROUP BY name
ORDER BY name;
-- 10 rows, all with items = 1. Group by the column that repeats, like category.
