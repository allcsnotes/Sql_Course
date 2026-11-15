-- M03-L05 · three beginner mistakes (no errors, just 0 rows)

-- Mistake 1: BETWEEN with the big number first
SELECT name, price FROM menu_items WHERE price BETWEEN 40 AND 30;
-- 0 rows. Fix: BETWEEN 30 AND 40

-- Mistake 2: LIKE without the percent sign
SELECT name, price FROM menu_items WHERE name LIKE 'Chai';
-- 0 rows: it looks for a name that is exactly Chai. Fix: LIKE '%Chai'

-- Mistake 3: = with a percent sign
SELECT name, price FROM menu_items WHERE name = '%Chai';
-- 0 rows: = does not understand %. Only LIKE does
