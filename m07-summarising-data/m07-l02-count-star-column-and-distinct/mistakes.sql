-- M07-L02 · The three beginner mistakes.

-- Mistake 1: DISTINCT with a star.
SELECT COUNT(DISTINCT *) AS different_rows FROM menu_items;
-- SQL Error [42601]: ERROR: syntax error at or near "*"   Position: 23
-- Fix: name one column instead, e.g. COUNT(DISTINCT category).

-- Mistake 2: counting nothing. COUNT gives 0, but SUM gives NULL.
SELECT COUNT(*) AS how_many, SUM(price) AS total FROM menu_items WHERE price > 100;
-- 0 | [NULL]
-- Fix: wrap the sum in COALESCE with 0 as the backup.
SELECT COUNT(*) AS how_many, COALESCE(SUM(price), 0) AS total FROM menu_items WHERE price > 100;
-- 0 | 0

-- Mistake 3: counting the wrong thing. To count customers use COUNT(*);
-- COUNT(email) only counts the customers who have an email (11, not 15). See steps 1 and 2.
