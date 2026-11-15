-- M08-L05 Normalisation: 1NF, 2NF, 3NF (Chai Corner, fictional data)
-- Needs the sales table (Build 1) and Chai Corner update 4 (M08-L03).

-- Step 1 (1NF, one value per cell): sales already has one item per row
SELECT sale_id, order_id, branch, item, category, price
FROM sales
ORDER BY sale_id
LIMIT 8;
-- 8 rows; order 2 has three rows: Samosa 25, Masala Chai 30, Cutting Chai 20

-- Step 2 (2NF, the whole key): order_items has a two-column key (order_id, item_id)
SELECT * FROM order_items ORDER BY order_id, item_id LIMIT 8;
-- qty depends on both columns of the key; no item name here
-- 8 rows: (1,3,1) (2,3,1) (2,7,2) (2,8,1) (3,4,1) (3,8,1) (4,3,3) (5,1,1)

-- Step 3: the item name depends only on item_id, so it lives once in menu_items
SELECT item_id, name, category, price
FROM menu_items
ORDER BY item_id;
-- 10 rows: 1 Bun Maska Snack 35 ... 7 Masala Chai Chai 30 ... 10 Veg Sandwich Snack 70

-- Step 4 (3NF, nothing but the key): price depends on the item, not the sale
SELECT item, price, COUNT(*) AS copies
FROM sales
GROUP BY item, price
ORDER BY copies DESC;
-- 10 rows: Masala Chai 30 1093, Cutting Chai 20 1038, Vada Pav 30 666, Bun Maska 35 620,
--          Samosa 25 570, Ginger Chai 30 569, Filter Coffee 40 423, Maggi 60 412,
--          Cold Coffee 80 401, Veg Sandwich 70 236

-- Step 5: the branch depends on the order, so orders stores branch_id once per order
SELECT * FROM orders WHERE order_id = 2;
-- 1 row: 2 cust 7 branch 1 2026-03-10 18:34

-- Your task: how many rows in sales store the word Pune?
SELECT COUNT(*) AS pune_rows FROM sales WHERE branch = 'Pune';
-- 1 row: 3054
