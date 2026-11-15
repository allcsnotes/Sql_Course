-- M06-L02 · Number Functions
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: ROUND keeps the places you ask for. No second value = a whole number.
SELECT ROUND(42.567, 2) AS two_places, ROUND(42.567) AS whole, ROUND(42.5) AS half_up;
-- 42.57 | 43 | 43   (.5 or more goes up)

-- Step 2: a real use: add 5% tax to each price and round to 2 places.
SELECT name, price, ROUND(price * 1.05, 2) AS with_tax FROM menu_items ORDER BY price LIMIT 3;
-- 3 rows: Cutting Chai 20 21.00, Samosa 25 26.25, Ginger Chai 30 31.50

-- Step 3: CEIL always goes up, FLOOR always goes down.
SELECT CEIL(4.1) AS ceil_up, FLOOR(4.9) AS floor_down;
-- 5 | 4

-- Step 4: the division trap. % gives what is left over. A decimal point keeps the rest.
SELECT 10 / 3 AS whole_part, 10 % 3 AS leftover, 10 / 3.0 AS exact;
-- 3 | 1 | 3.3333333333333333
