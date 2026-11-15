-- M03-L05 · IN, BETWEEN, LIKE and ILIKE

-- Step 1: the long way, three tests joined with OR
SELECT name, price FROM menu_items WHERE name = 'Samosa' OR name = 'Maggi' OR name = 'Vada Pav';
-- 3 rows: Maggi 60, Samosa 25, Vada Pav 30

-- Step 2: the short way, IN and a list
SELECT name, price FROM menu_items WHERE name IN ('Samosa', 'Maggi', 'Vada Pav');
-- the same 3 rows

-- Step 3: NOT IN keeps everything else
SELECT city FROM branches WHERE city NOT IN ('Pune', 'Mumbai', 'Delhi');
-- 7 rows: Bengaluru, Chennai, Hyderabad, Kolkata, Jaipur, Ahmedabad, Kochi

-- Step 4: BETWEEN, small number first, both ends included
SELECT name, price FROM menu_items WHERE price BETWEEN 30 AND 40;
-- 5 rows: Bun Maska 35, Filter Coffee 40, Ginger Chai 30, Masala Chai 30, Vada Pav 30

-- Step 5: LIKE, % means any letters (or none): ends with Chai
SELECT name, price FROM menu_items WHERE name LIKE '%Chai';
-- 3 rows: Cutting Chai 20, Ginger Chai 30, Masala Chai 30

-- Step 6: starts with C
SELECT name, price FROM menu_items WHERE name LIKE 'C%';
-- 2 rows: Cold Coffee 80, Cutting Chai 20

-- Step 7: _ means exactly one letter: P plus exactly three letters
SELECT city FROM branches WHERE city LIKE 'P___';
-- 1 row: Pune

-- Step 8: LIKE cares about capitals
SELECT name, price FROM menu_items WHERE name LIKE '%chai';
-- 0 rows (the menu writes Chai with a capital C)

-- Step 9: ILIKE ignores capitals
SELECT name, price FROM menu_items WHERE name ILIKE '%chai';
-- 3 rows: Cutting Chai, Ginger Chai, Masala Chai
