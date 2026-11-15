-- M06-L01 · The three beginner mistakes.

-- Mistake 1: text functions need text. price is a number.
SELECT UPPER(price) AS loud_price FROM menu_items;
-- SQL Error [42883]: ERROR: function upper(integer) does not exist
-- Hint: No function matches the given name and argument types. You might need to add explicit type casts.
-- Fix: cast the number to text first.
SELECT UPPER(price::text) AS loud_price FROM menu_items LIMIT 3;
-- 35, 80, 20

-- Mistake 2: joining with NULL gives NULL, with no error. CONCAT skips the NULL.
SELECT 'Chai' || NULL AS with_bars, CONCAT('Chai', NULL) AS with_concat;
-- [NULL] | Chai

-- Mistake 3: positions start at 1, not 0.
SELECT SUBSTRING('Masala' FROM 0 FOR 3) AS from_zero, SUBSTRING('Masala' FROM 1 FOR 3) AS from_one;
-- Ma | Mas
