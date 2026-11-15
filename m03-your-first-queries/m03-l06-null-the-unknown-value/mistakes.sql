-- M03-L06 · three beginner mistakes

-- Mistake 1: = NULL. No error, but zero rows. Always write IS NULL
SELECT name, email FROM customers WHERE email = NULL;
-- 0 rows

-- Mistake 2: NULL inside quotes looks for the word NULL, written as text
SELECT name, email FROM customers WHERE email = 'NULL';
-- 0 rows

-- Mistake 3: thinking NULL means zero
SELECT 5 + NULL;
-- NULL, not 5
