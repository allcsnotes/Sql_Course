-- M07-L04 · The three beginner mistakes.

-- Mistake 1: HAVING on a plain column. A pile holds many prices.
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING price > 30;
-- SQL Error [42803]: ERROR: column "menu_items.price" must appear in the GROUP BY clause or be used in an aggregate function
-- Fix: to check each row, use WHERE.
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price > 30
GROUP BY category
ORDER BY category;
-- 2 rows: Coffee 2, Snack 3   (no Chai item costs more than 30, so there is no Chai pile)

-- Mistake 2: the new name from the SELECT inside HAVING.
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING items >= 3;
-- SQL Error [42703]: ERROR: column "items" does not exist
-- Fix: write the summary itself: HAVING COUNT(*) >= 3 (step 1).

-- Mistake 3: a plain filter inside HAVING works, but every row is grouped first,
-- then most piles are thrown away.
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING category = 'Snack';
-- 1 row: Snack 5
-- Better: remove the rows early with WHERE.
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE category = 'Snack'
GROUP BY category;
-- 1 row: Snack 5
