-- B01 · The three beginner mistakes.

-- Mistake 1: counting orders with COUNT(*). That counts rows (lines), not orders.
SELECT branch,
  COUNT(*) AS orders,
  SUM(qty * price) AS sales
FROM sales
GROUP BY branch
ORDER BY sales DESC;
-- Pune 3054, Mumbai 1952, Delhi 1022   (wrong: these are rows)
-- Fix: COUNT(DISTINCT order_id) gives 1522, 976, 502.

-- Mistake 2: dividing two whole numbers drops the decimals.
SELECT branch,
  SUM(qty * price) / COUNT(DISTINCT order_id) AS avg_order
FROM sales
GROUP BY branch
ORDER BY avg_order DESC;
-- Pune 91, Delhi 89, Mumbai 89   (Mumbai and Delhi both show 89)
-- Fix: SUM(qty * price)::numeric / COUNT(DISTINCT order_id) gives 91.13, 89.70, 89.67.

-- Mistake 3: missing days. A day with no rows never shows up.
SELECT COUNT(*) AS rows_on_jan_1
FROM sales
WHERE sold_at::date = '2026-01-01';
-- 0   (so the daily report starts on 2026-01-02: look for gaps)
