-- B01 · The Café Sales Report
-- Needs the sales table from setup.sql (Chai Corner update 3).
-- Put the cursor inside a query and press Ctrl+Enter.
-- Two rules for the whole report:
--   sales  = SUM(qty * price)
--   orders = COUNT(DISTINCT order_id)   (one order can have many rows)

-- Stage 1: look at the data.
SELECT branch, item, qty, price, sold_at
FROM sales
LIMIT 5;
-- 5 rows: the first lines of orders 1 and 2 (see README)

-- One order can have many rows. qty * price = the money for each line.
SELECT order_id, item, qty, price,
  qty * price AS line_total
FROM sales
WHERE order_id = 2;
-- 3 rows: Samosa 1 x 25 = 25, Masala Chai 2 x 30 = 60, Cutting Chai 1 x 20 = 20   (order total ₹105)

-- The whole quarter.
SELECT COUNT(DISTINCT order_id) AS orders,
  SUM(qty * price) AS sales
FROM sales;
-- 3000 | 271265

-- Stage 2: sales over time.
-- Daily: ::date turns each time into just a date.
SELECT sold_at::date AS day,
  SUM(qty * price) AS sales
FROM sales
GROUP BY day
ORDER BY day;
-- 89 rows, starting 2026-01-02 60, 2026-01-03 170, 2026-01-04 445 ...

-- Weekly: DATE_TRUNC('week', ...) rounds down to the Monday of the week.
SELECT DATE_TRUNC('week', sold_at)::date AS week,
  SUM(qty * price) AS sales
FROM sales
GROUP BY week
ORDER BY week;
-- 14 rows, starting 2025-12-29 675, 2026-01-05 3175, 2026-01-12 7155 ... growing to over 30000

-- Monthly, with the number of orders.
SELECT DATE_TRUNC('month', sold_at)::date AS month,
  COUNT(DISTINCT order_id) AS orders,
  SUM(qty * price) AS sales
FROM sales
GROUP BY month
ORDER BY month;
-- 3 rows: 2026-01-01 383 34490, 2026-02-01 932 86770, 2026-03-01 1685 150005

-- Stage 3: best items and busy hours.
-- Top 5 items by money.
SELECT item,
  SUM(qty) AS sold,
  SUM(qty * price) AS sales
FROM sales
GROUP BY item
ORDER BY sales DESC
LIMIT 5;
-- Masala Chai 1382 41460, Cold Coffee 503 40240, Maggi 516 30960, Bun Maska 764 26740, Cutting Chai 1294 25880

-- Top 5 items by cups sold.
SELECT item,
  SUM(qty) AS sold,
  SUM(qty * price) AS sales
FROM sales
GROUP BY item
ORDER BY sold DESC
LIMIT 5;
-- Masala Chai 1382 41460, Cutting Chai 1294 25880, Vada Pav 815 24450, Bun Maska 764 26740, Samosa 717 17925

-- Busy hours: EXTRACT(HOUR ...) pulls the hour out of each time.
SELECT EXTRACT(HOUR FROM sold_at) AS hour,
  COUNT(DISTINCT order_id) AS orders
FROM sales
GROUP BY hour
ORDER BY orders DESC
LIMIT 5;
-- 9 438, 18 392, 17 294, 8 291, 20 163

-- Stage 4: each branch. Average order = sales / orders (made numeric first).
SELECT branch,
  COUNT(DISTINCT order_id) AS orders,
  SUM(qty * price) AS sales,
  ROUND(SUM(qty * price)::numeric / COUNT(DISTINCT order_id), 2) AS avg_order
FROM sales
GROUP BY branch
ORDER BY sales DESC;
-- Pune 1522 138705 91.13, Mumbai 976 87545 89.70, Delhi 502 45015 89.67
-- Check: 138705 + 87545 + 45015 = 271265 and 34490 + 86770 + 150005 = 271265 (the total)

-- Stage 5: make it cleaner. One small table, a column for each branch.
SELECT DATE_TRUNC('month', sold_at)::date AS month,
  SUM(qty * price) FILTER (WHERE branch = 'Pune') AS pune,
  SUM(qty * price) FILTER (WHERE branch = 'Mumbai') AS mumbai,
  SUM(qty * price) FILTER (WHERE branch = 'Delhi') AS delhi,
  SUM(qty * price) AS total
FROM sales
GROUP BY month ORDER BY month;
-- 2026-01-01 18450  9310  6730  34490
-- 2026-02-01 43985 29215 13570  86770
-- 2026-03-01 76270 49020 24715 150005
