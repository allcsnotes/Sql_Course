-- M03-L02 · Choosing Columns, Maths and AS

-- Step 1: only the columns you want
SELECT name, price FROM menu_items;
-- 10 rows, 2 columns: Bun Maska 35, Cold Coffee 80, ... Veg Sandwich 70

-- Step 2: the order is up to you
SELECT price, name FROM menu_items;
-- 10 rows, price first: 35 Bun Maska, 80 Cold Coffee, ...

-- Step 3: maths on every row (here * means times)
SELECT name, price, price * 2 FROM menu_items;
-- 10 rows: Bun Maska 35 70, Cold Coffee 80 160, ... ; the new column is called ?column?

-- Step 4: name the result with AS
SELECT name, price, price * 2 AS two_cups FROM menu_items;
-- same numbers, column now called two_cups

-- Step 5: the division surprise
SELECT name, price, price / 2 AS half FROM menu_items;
-- Bun Maska 35 17 (not 17.5): whole number / whole number drops the decimals

-- Step 6: the fix, one decimal in the maths
SELECT name, price, price / 2.0 AS half FROM menu_items;
-- Bun Maska 35 17.5, Samosa 25 12.5, Cold Coffee 80 40
-- (DBeaver shows 17.5; psql shows 17.5000000000000000)
