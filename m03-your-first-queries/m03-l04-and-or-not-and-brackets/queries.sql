-- M03-L04 · AND, OR, NOT and Brackets

-- Step 1: AND, a row must pass both tests
SELECT name, price FROM menu_items WHERE price >= 30 AND price <= 40;
-- 5 rows: Bun Maska 35, Filter Coffee 40, Ginger Chai 30, Masala Chai 30, Vada Pav 30

-- Step 2: OR, a row only needs to pass one test
SELECT name, price FROM menu_items WHERE name = 'Samosa' OR name = 'Maggi';
-- 2 rows: Maggi 60, Samosa 25

-- Step 3: OR with numbers, the very cheap and the very costly
SELECT name, price FROM menu_items WHERE price < 25 OR price > 60;
-- 3 rows: Cold Coffee 80, Cutting Chai 20, Veg Sandwich 70

-- Step 4: NOT flips a test
SELECT name, price FROM menu_items WHERE NOT price > 40;
-- 7 rows, all 40 or less: Bun Maska, Cutting Chai, Filter Coffee, Ginger Chai, Masala Chai, Samosa, Vada Pav

-- Step 5: mixing AND and OR without brackets (AND runs first!)
SELECT name, price FROM menu_items WHERE name = 'Samosa' OR name = 'Maggi' AND price > 30;
-- 2 rows: Maggi 60, Samosa 25  <- Samosa costs 25, so why is it here?

-- Step 6: the fix, brackets run first
SELECT name, price FROM menu_items WHERE (name = 'Samosa' OR name = 'Maggi') AND price > 30;
-- 1 row: Maggi 60
