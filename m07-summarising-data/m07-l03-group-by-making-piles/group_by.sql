-- M07-L03 · GROUP BY: Making Piles
-- Put the cursor inside a query and press Ctrl+Enter.

-- Step 1: GROUP BY puts rows with the same category into one pile. COUNT runs once per pile.
SELECT category, COUNT(*) AS items FROM menu_items GROUP BY category ORDER BY category;
-- 3 rows: Chai 3, Coffee 2, Snack 5

-- Step 2: any summary works on the piles.
SELECT category, SUM(price) AS total, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category
ORDER BY category;
-- 3 rows: Chai 80 26.67, Coffee 120 60.00, Snack 220 44.00

-- Step 3: group by a calculation: the year each customer joined.
SELECT EXTRACT(YEAR FROM joined_on) AS join_year, COUNT(*) AS customers
FROM customers
GROUP BY join_year
ORDER BY join_year;
-- 3 rows: 2024 3, 2025 9, 2026 3

-- Step 4: ORDER BY at the end sorts the summary. DESC puts the biggest pile first.
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
ORDER BY items DESC;
-- 3 rows: Snack 5, Chai 3, Coffee 2
