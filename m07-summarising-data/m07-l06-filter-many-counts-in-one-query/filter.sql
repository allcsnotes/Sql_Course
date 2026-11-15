-- M07-L06 · FILTER: Many Counts in One Query
-- Put the cursor inside a query and press Ctrl+Enter.

-- Step 1: three numbers, one query, one pass over the table.
SELECT COUNT(*) AS all_items,
  COUNT(*) FILTER (WHERE category = 'Chai') AS chai,
  COUNT(*) FILTER (WHERE price >= 50) AS pricey
FROM menu_items;
-- 10 | 3 | 3   (pricey: Cold Coffee, Maggi, Veg Sandwich)

-- Step 2: the old way, CASE WHEN inside SUM. Each chai row adds 1, every other row adds 0.
SELECT COUNT(*) AS all_items,
  SUM(CASE WHEN category = 'Chai' THEN 1 ELSE 0 END) AS chai
FROM menu_items;
-- 10 | 3

-- Step 3: FILTER inside each pile (with GROUP BY).
SELECT category, COUNT(*) AS items,
  COUNT(*) FILTER (WHERE price >= 35) AS big
FROM menu_items
GROUP BY category
ORDER BY category;
-- 3 rows: Chai 3 0, Coffee 2 2, Snack 5 3

-- Step 4: many questions at once.
SELECT COUNT(*) AS customers,
  COUNT(*) FILTER (WHERE joined_on < '2025-01-01') AS y2024,
  COUNT(*) FILTER (WHERE joined_on >= '2025-01-01'
                     AND joined_on < '2026-01-01') AS y2025,
  COUNT(*) FILTER (WHERE joined_on >= '2026-01-01') AS y2026
FROM customers;
-- 15 | 3 | 9 | 3
