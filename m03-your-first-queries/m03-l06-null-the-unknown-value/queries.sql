-- M03-L06 · NULL: the Unknown Value
-- Run setup.sql (Chai Corner update 1) first.

-- Step 1: the new email column
SELECT * FROM customers;
-- 15 rows; email is NULL for Lukas, Kabir, Isha and Dev (DBeaver shows [NULL])

-- Step 2: the equals trap. No error, but zero rows
SELECT name, email FROM customers WHERE email = NULL;
-- 0 rows

-- Step 3: ask SQL directly
SELECT NULL = NULL;
-- NULL (not true)

-- Step 4: maths with NULL
SELECT 5 + NULL;
-- NULL

-- Step 5: IS NULL
SELECT name, email FROM customers WHERE email IS NULL;
-- 4 rows: Lukas, Kabir, Isha, Dev

-- Step 6: IS NOT NULL
SELECT name, email FROM customers WHERE email IS NOT NULL;
-- 11 rows (4 + 11 = 15)

-- Step 7: NULL hides from not equal
SELECT name, email FROM customers WHERE email <> 'asha@example.com';
-- 10 rows, not 14: the four NULL customers are dropped too

-- Step 8: keep them with OR ... IS NULL
SELECT name, email FROM customers WHERE email <> 'asha@example.com' OR email IS NULL;
-- 14 rows: everyone except Asha
