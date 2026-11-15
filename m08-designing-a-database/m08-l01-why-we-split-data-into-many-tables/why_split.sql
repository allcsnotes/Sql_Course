-- M08-L01 Why we split data into many tables (Chai Corner, fictional data)
-- Run each query on its own (DBeaver: Ctrl+Enter with the cursor in the query).

-- Step 1: every Masala Chai sale repeats the same three facts
SELECT branch, item, category, price
FROM sales
WHERE item = 'Masala Chai'
LIMIT 8;
-- 8 rows, all "Masala Chai · Chai · 30" (branches Pune, Delhi, Delhi, Pune, Pune, Delhi, Pune, Pune)

-- Step 2: how many times is that price copied?
SELECT COUNT(*) AS copies_of_price
FROM sales
WHERE item = 'Masala Chai';
-- 1 row: 1093

-- Step 3: many rows, but only a few different things
SELECT COUNT(*) AS sale_rows,
   COUNT(DISTINCT item) AS items,
   COUNT(DISTINCT branch) AS branches
FROM sales;
-- 1 row: sale_rows 6028, items 10, branches 3

-- Step 4: one typo and the rows "disappear"
SELECT COUNT(*) FILTER (WHERE branch = 'Pune') AS exact,
   COUNT(*) FILTER (WHERE branch = 'pune') AS small_p,
   COUNT(*) FILTER (WHERE branch = 'Pune ') AS extra_space
FROM sales;
-- 1 row: exact 3054, small_p 0, extra_space 0

-- Step 5: menu_items already stores each item once
SELECT * FROM menu_items
ORDER BY item_id;
-- 10 rows: 1 Bun Maska 35 ... 7 Masala Chai 30 ... 10 Veg Sandwich 70

-- Step 6: branches stores each city once, with an ID
SELECT * FROM branches
WHERE city IN ('Pune', 'Mumbai', 'Delhi');
-- 3 rows: 1 Pune 2019-04-12, 2 Mumbai 2019-09-02, 3 Delhi 2020-01-20

-- Your task: how many times is the price of Cutting Chai copied?
SELECT COUNT(*) AS copies_of_price
FROM sales
WHERE item = 'Cutting Chai';
-- 1 row: 1038
