-- M03-L03 · WHERE: Keeping Only the Rows You Want

-- Step 1: your first WHERE
SELECT name, price FROM menu_items WHERE price > 40;
-- 3 rows: Cold Coffee 80, Maggi 60, Veg Sandwich 70

-- Step 2: equals is one = sign
SELECT name, price FROM menu_items WHERE price = 30;
-- 3 rows: Ginger Chai, Masala Chai, Vada Pav

-- Step 3: less than or equal
SELECT name, price FROM menu_items WHERE price <= 30;
-- 5 rows: Cutting Chai 20, Ginger Chai 30, Masala Chai 30, Samosa 25, Vada Pav 30

-- Step 4: not equal
SELECT name, price FROM menu_items WHERE price <> 30;
-- 7 rows: Bun Maska, Cold Coffee, Cutting Chai, Filter Coffee, Maggi, Samosa, Veg Sandwich (3 + 7 = 10)

-- Step 5: text goes inside single quotes
SELECT * FROM branches WHERE city = 'Pune';
-- 1 row: 1 Pune 2019-04-12

-- Step 6: dates go inside single quotes, as year-month-day
SELECT * FROM branches WHERE opened_on >= '2022-01-01';
-- 4 rows: Kolkata 2022-03-14, Jaipur 2022-11-05, Ahmedabad 2023-06-19, Kochi 2024-01-29
