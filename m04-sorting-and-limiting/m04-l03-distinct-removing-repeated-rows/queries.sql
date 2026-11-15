-- M04-L03 · DISTINCT: Removing Repeated Rows
-- Run setup.sql (Chai Corner update 2) first. Uses customers.email from update 1 (M03-L06).

-- Step 1: the new category column
SELECT name, category FROM menu_items ORDER BY category, name;
-- 10 rows: Chai (Cutting, Ginger, Masala), Coffee (Cold, Filter), Snack (Bun Maska, Maggi, Samosa, Vada Pav, Veg Sandwich)

-- Step 2: only the category column, with repeats
SELECT category FROM menu_items ORDER BY category;
-- 10 rows: Chai 3 times, Coffee twice, Snack 5 times

-- Step 3: DISTINCT, right after SELECT
SELECT DISTINCT category FROM menu_items ORDER BY category;
-- 3 rows: Chai, Coffee, Snack

-- Step 4: DISTINCT on numbers
SELECT DISTINCT price FROM menu_items ORDER BY price;
-- 8 rows: 20, 25, 30, 35, 40, 60, 70, 80 (30 shows up once)

-- Step 5: two columns, with repeats
SELECT category, price FROM menu_items ORDER BY category, price;
-- 10 rows: Chai 30 shows up twice (Ginger Chai and Masala Chai)

-- Step 6: DISTINCT looks at the whole row
SELECT DISTINCT category, price FROM menu_items ORDER BY category, price;
-- 9 rows: Chai 20, Chai 30, Coffee 40, Coffee 80, Snack 25, Snack 30, Snack 35, Snack 60, Snack 70

-- Step 7: all NULLs count as one value
SELECT DISTINCT email FROM customers ORDER BY email;
-- 12 rows: 11 real emails, then one NULL at the end
