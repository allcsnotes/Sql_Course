-- M07-L02 · COUNT(*), COUNT(column) and COUNT(DISTINCT)
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: COUNT(*) counts every row, even a row with NULLs in it.
SELECT COUNT(*) AS all_rows FROM customers;
-- 15

-- Step 2: COUNT(column) skips the NULLs. Four customers have no email.
SELECT COUNT(email) AS with_email FROM customers;
-- 11

-- Step 3: both side by side. The difference is the number of missing emails.
SELECT COUNT(*) AS all_rows, COUNT(email) AS with_email, COUNT(*) - COUNT(email) AS missing FROM customers;
-- 15 | 11 | 4

-- Step 4: COUNT(DISTINCT ...) counts each different value only once.
SELECT COUNT(category) AS all_values, COUNT(DISTINCT category) AS different_values FROM menu_items;
-- 10 | 3   (Chai, Coffee, Snack)

-- Step 5: prices work the same way. 30 appears three times.
SELECT COUNT(price) AS all_prices, COUNT(DISTINCT price) AS different_prices FROM menu_items;
-- 10 | 8
