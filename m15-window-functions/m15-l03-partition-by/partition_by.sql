-- M15-L03 PARTITION BY (chai_corner)
-- Runs on the Chai Corner database (menu_items: 12 items). Run one query at a time.

-- Step 1: a separate average for each category
SELECT name, category, price,
  ROUND(AVG(price) OVER (PARTITION BY category), 2) AS cat_avg
FROM menu_items ORDER BY category, price DESC;
-- 12 rows: every Chai row 30.00, both Coffee rows 60.00, every Snack row 51.67

-- Step 2: the whole menu vs. each category
SELECT name, category, price,
  ROUND(AVG(price) OVER (), 2) AS all_avg,
  ROUND(AVG(price) OVER (PARTITION BY category), 2) AS cat_avg
FROM menu_items ORDER BY category, price DESC;
-- 12 rows: all_avg 45.83 on every row; Masala Chai 30: all_avg 45.83, cat_avg 30.00

-- Step 3: number the items inside each category
SELECT name, category, price,
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
FROM menu_items ORDER BY category, rn;
-- 12 rows: Kulhad Chai 1 in Chai, Cold Coffee 1 in Coffee, Paneer Roll 1 in Snack

-- Your task: how many items are in each item's category?
SELECT name, category,
  COUNT(*) OVER (PARTITION BY category) AS in_cat
FROM menu_items ORDER BY category, name;
-- 12 rows: Chai items 4, Coffee items 2, Snack items 6
