-- M06-L04 · The three beginner mistakes.

-- Mistake 1: tests in the wrong order. 'mid' catches Samosa first, and no row ever reaches 'low'.
SELECT name, price,
  CASE WHEN price < 60 THEN 'mid'
       WHEN price < 30 THEN 'low'
       ELSE 'high' END AS band
FROM menu_items;
-- no 'low' at all. Fix: put the smallest test first (step 2).

-- Mistake 2: no ELSE. Every row that matches no test gets NULL.
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly' END AS tag
FROM menu_items;
-- 7 rows get [NULL]

-- Mistake 3: answers with different types ('costly' is text, price is a number).
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly' ELSE price END AS tag
FROM menu_items;
-- SQL Error [22P02]: ERROR: invalid input syntax for type integer: "costly"
-- Fix: cast the number to text.
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly' ELSE price::text END AS tag
FROM menu_items;
-- Cold Coffee, Maggi, Veg Sandwich: costly; the others show their price as text (35, 20, 40 ...)
