-- M07-L05 · The three beginner mistakes.

-- Mistake 1: using a new name too early. WHERE runs before SELECT.
SELECT name, price * 2 AS two_cups
FROM menu_items
WHERE two_cups > 100;
-- SQL Error [42703]: ERROR: column "two_cups" does not exist
-- Fix: repeat the calculation.
SELECT name, price * 2 AS two_cups
FROM menu_items
WHERE price * 2 > 100;
-- 3 rows: Cold Coffee 160, Maggi 120, Veg Sandwich 140

-- Mistake 2: writing the parts in the wrong order (LIMIT before ORDER BY).
SELECT name, price
FROM menu_items
LIMIT 3
ORDER BY price DESC;
-- SQL Error [42601]: ERROR: syntax error at or near "ORDER"
-- Fix: the written order is fixed: ORDER BY first, then LIMIT.
SELECT name, price
FROM menu_items
ORDER BY price DESC
LIMIT 3;
-- 3 rows: Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Mistake 3: the same thing with HAVING. It runs before SELECT, so "items" does not exist yet.
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING items >= 3;
-- SQL Error [42703]: ERROR: column "items" does not exist
-- Fix: write the summary itself: HAVING COUNT(*) >= 3
