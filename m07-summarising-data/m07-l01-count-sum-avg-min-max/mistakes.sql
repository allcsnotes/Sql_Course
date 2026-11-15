-- M07-L01 · The three beginner mistakes.

-- Mistake 1: a plain column next to MAX. Ten names, but only one row comes back.
SELECT name, MAX(price) AS top_price FROM menu_items;
-- SQL Error [42803]: ERROR: column "menu_items.name" must appear in the GROUP BY clause or be used in an aggregate function
-- Fix: to get the top item, sort by price and take one row.
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 1;
-- Cold Coffee | 80

-- Mistake 2: AVG inside WHERE. The filter checks one row at a time.
SELECT name, price FROM menu_items WHERE price > AVG(price);
-- SQL Error [42803]: ERROR: aggregate functions are not allowed in WHERE
-- Fix: find the average first (42), then filter with that number.
SELECT name, price FROM menu_items WHERE price > 42;
-- 3 rows: Cold Coffee 80, Maggi 60, Veg Sandwich 70

-- Mistake 3: SUM on text. SUM and AVG need numbers.
SELECT SUM(name) AS total_names FROM menu_items;
-- SQL Error [42883]: ERROR: function sum(character varying) does not exist
-- To count the rows, use COUNT(*).
