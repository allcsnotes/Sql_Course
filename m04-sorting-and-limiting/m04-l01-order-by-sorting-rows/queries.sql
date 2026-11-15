-- M04-L01 · ORDER BY: Sorting Rows
-- Needs Chai Corner update 1 (M03-L06 setup.sql) for customers.email.
-- Rows that tie (the three items at 30) can come back in a different order on your computer.

-- Step 1: cheapest first (ascending, ASC, is the default)
SELECT name, price FROM menu_items ORDER BY price;
-- 10 rows: Cutting Chai 20, Samosa 25, the three at 30, Bun Maska 35, Filter Coffee 40, Maggi 60, Veg Sandwich 70, Cold Coffee 80
-- (in the video the 30s came out Masala Chai, Vada Pav, Ginger Chai: ties have no fixed order)

-- Step 2: biggest first
SELECT name, price FROM menu_items ORDER BY price DESC;
-- Cold Coffee 80 on top ... Cutting Chai 20 last

-- Step 3: text sorts A to Z
SELECT name, price FROM menu_items ORDER BY name;
-- Bun Maska first ... Veg Sandwich last

-- Step 4: a tie breaker
SELECT name, price FROM menu_items ORDER BY price, name;
-- the 30s now always go Ginger Chai, Masala Chai, Vada Pav

-- Step 5: each column gets its own direction
SELECT name, price FROM menu_items ORDER BY price DESC, name;
-- Cold Coffee 80, Veg Sandwich 70, Maggi 60, Filter Coffee 40, Bun Maska 35, Ginger Chai 30, Masala Chai 30, Vada Pav 30, Samosa 25, Cutting Chai 20

-- Step 6: NULLs go last when sorting up
SELECT name, email FROM customers ORDER BY email;
-- 11 emails A to Z (ananya@ ... vikram@), then the 4 NULLs (Lukas, Kabir, Isha, Dev, in any order)

-- Step 7: and first with DESC (NULL counts as bigger than every value)
SELECT name, email FROM customers ORDER BY email DESC;
-- the 4 NULLs on top, then vikram@ ... ananya@

-- Step 8: choose for yourself
SELECT name, email FROM customers ORDER BY email DESC NULLS LAST;
-- vikram@ ... ananya@ (Z to A), then the 4 NULLs at the bottom

-- Step 9: WHERE first, then ORDER BY
SELECT name, price FROM menu_items WHERE price < 50 ORDER BY price;
-- 7 rows: Cutting Chai 20, Samosa 25, the three at 30 (Ginger, Masala, Vada Pav in the video), Bun Maska 35, Filter Coffee 40
