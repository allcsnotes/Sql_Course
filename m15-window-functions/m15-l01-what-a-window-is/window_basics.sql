-- M15-L01 What a window is: look at other rows, keep every row
-- Runs on the Chai Corner database (menu_items: 12 items).
-- Run one query at a time.

-- Step 1: GROUP BY: many rows become one row per group
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category ORDER BY category;
-- 3 rows: Chai 30.00, Coffee 60.00, Snack 51.67

-- Step 2: a window: the average sits next to every row
SELECT name, price,
  ROUND(AVG(price) OVER (), 2) AS avg_all
FROM menu_items ORDER BY price;
-- 12 rows, every one with avg_all 45.83 (Cutting Chai 20 first, Paneer Roll 90 last)

-- Step 3: compare each row with the whole
SELECT name, price,
  ROUND(price - AVG(price) OVER (), 2) AS vs_avg
FROM menu_items ORDER BY price DESC;
-- 12 rows: Paneer Roll 90 44.17 ... Cutting Chai 20 -25.83

-- Step 4: COUNT and SUM can be windows too
SELECT name, price,
  COUNT(*) OVER () AS items,
  SUM(price) OVER () AS menu_total
FROM menu_items ORDER BY price DESC;
-- 12 rows, every one with items 12 and menu_total 550

-- Mistake 1 fixed: a window can not go in WHERE, work it out in a CTE first
WITH priced AS (
  SELECT name, price, AVG(price) OVER () AS avg_all
  FROM menu_items
)
SELECT name, price FROM priced
WHERE price > avg_all ORDER BY price DESC;
-- 4 rows: Paneer Roll 90, Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Your task: what percent of the whole menu total is each item? (Paneer Roll: 16.4)
SELECT name, price,
  ROUND(100.0 * price / SUM(price) OVER (), 1) AS pct
FROM menu_items ORDER BY price DESC;
-- 12 rows: Paneer Roll 16.4, Cold Coffee 14.5, Veg Sandwich 12.7, Maggi 10.9 ... Cutting Chai 3.6
