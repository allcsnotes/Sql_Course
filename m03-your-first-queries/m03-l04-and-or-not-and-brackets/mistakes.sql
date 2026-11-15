-- M03-L04 · three beginner mistakes

-- Mistake 1: leaving out the column in the second test
SELECT name, price FROM menu_items WHERE price > 30 AND < 50;
-- ERROR:  syntax error at or near "<"
-- Fix: WHERE price > 30 AND price < 50

-- Mistake 2: AND when you mean OR. No error, but zero rows
SELECT name, price FROM menu_items WHERE name = 'Samosa' AND name = 'Maggi';
-- 0 rows: one item cannot have two names at once

-- Mistake 3: half an OR
SELECT name, price FROM menu_items WHERE price = 30 OR 40;
-- ERROR:  argument of OR must be type boolean, not type integer
-- Fix: WHERE price = 30 OR price = 40
