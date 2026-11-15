-- M21-L03 Pivoting rows into columns (Chai Corner sales table)
-- The queries in the order the video runs them, with the real results. No database changes.

-- Step 1: long: one row per branch AND category
SELECT branch, category, SUM(qty) AS cups
FROM sales
GROUP BY branch, category
ORDER BY branch, category;
-- 9 rows: Delhi 559/176/534, Mumbai 1093/348/998, Pune 1730/520/1577 (Chai/Coffee/Snack)

-- Step 2: pivot with CASE: one row per branch, one column per category
SELECT branch,
       SUM(CASE WHEN category = 'Chai'   THEN qty ELSE 0 END) AS chai,
       SUM(CASE WHEN category = 'Coffee' THEN qty ELSE 0 END) AS coffee,
       SUM(CASE WHEN category = 'Snack'  THEN qty ELSE 0 END) AS snack
FROM sales
GROUP BY branch
ORDER BY branch;
-- 3 rows: Delhi 559 176 534, Mumbai 1093 348 998, Pune 1730 520 1577

-- Step 3: the same pivot, shorter: FILTER picks the rows for each column
SELECT branch,
       SUM(qty) FILTER (WHERE category = 'Chai')   AS chai,
       SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee,
       SUM(qty) FILTER (WHERE category = 'Snack')  AS snack,
       SUM(qty) AS total
FROM sales
GROUP BY branch
ORDER BY branch;
-- 3 rows: Delhi 559 176 534 1269, Mumbai 1093 348 998 2439, Pune 1730 520 1577 3827

-- Step 4: months as columns: one row per category
SELECT category,
       SUM(qty) FILTER (WHERE date_trunc('month', sold_at) = '2026-01-01') AS jan,
       SUM(qty) FILTER (WHERE date_trunc('month', sold_at) = '2026-02-01') AS feb,
       SUM(qty) FILTER (WHERE date_trunc('month', sold_at) = '2026-03-01') AS mar
FROM sales
GROUP BY category
ORDER BY category;
-- 3 rows: Chai 394 1077 1911, Coffee 127 341 576, Snack 417 1006 1686

-- Mistake 1: CASE without SUM
-- SELECT branch, CASE WHEN category = 'Chai' THEN qty ELSE 0 END AS chai FROM sales GROUP BY branch;
-- ERROR [42803]: column "sales.category" must appear in the GROUP BY clause or be used in an aggregate function

-- Mistake 2: 'chai' with a small c matches nothing
SELECT branch,
       SUM(qty) FILTER (WHERE category = 'chai') AS chai
FROM sales
GROUP BY branch
ORDER BY branch;
-- 3 rows: Delhi NULL, Mumbai NULL, Pune NULL (no error, just an empty column)
