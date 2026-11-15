-- M07-L04 · HAVING vs WHERE
-- Put the cursor inside a query and press Ctrl+Enter.

-- Step 1: HAVING keeps the piles you want. Piles first, then HAVING checks each pile.
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING COUNT(*) >= 3;
-- 2 rows: Chai 3, Snack 5   (Coffee has only 2, so that pile is thrown away)

-- Step 2: HAVING works with any summary.
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category
HAVING AVG(price) > 40
ORDER BY category;
-- 2 rows: Coffee 60.00, Snack 44.00   (Chai averages 26.67, so it goes)

-- Step 3: WHERE keeps the rows you want, before any piles exist.
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price >= 30
GROUP BY category
ORDER BY category;
-- 3 rows: Chai 2, Coffee 2, Snack 4   (Cutting Chai 20 and Samosa 25 are thrown out first)

-- Step 4: both together. WHERE (8 rows) -> GROUP BY (3 piles) -> HAVING (piles with 3 or more).
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price >= 30
GROUP BY category
HAVING COUNT(*) >= 3;
-- 1 row: Snack 4
