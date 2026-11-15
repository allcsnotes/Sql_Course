-- M07-L05 · The Order SQL Runs Your Query
-- Put the cursor inside a query and press Ctrl+Enter.

-- Step 1: a query with all seven parts.
-- Written order: SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT
-- Run order:     FROM (10 rows) -> WHERE (8 rows) -> GROUP BY (3 piles) -> HAVING (3 piles stay)
--                -> SELECT (names COUNT(*) "items") -> ORDER BY -> LIMIT (top 2)
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price >= 30
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY items DESC, category
LIMIT 2;
-- 2 rows: Snack 4, Chai 2

-- Step 2: ORDER BY runs after SELECT, so it can use the new name two_cups.
SELECT name, price * 2 AS two_cups
FROM menu_items
ORDER BY two_cups DESC
LIMIT 3;
-- 3 rows: Cold Coffee 160, Veg Sandwich 140, Maggi 120
