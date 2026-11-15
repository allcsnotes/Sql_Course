-- M07-L06 · The three beginner mistakes.

-- Mistake 1: forgetting the word WHERE inside FILTER.
SELECT COUNT(*) AS all_items,
  COUNT(*) FILTER (category = 'Chai') AS chai
FROM menu_items;
-- SQL Error [42601]: ERROR: syntax error at or near "category"
-- Fix: inside the brackets, WHERE always comes first: FILTER (WHERE category = 'Chai')

-- Mistake 2: putting the condition at the bottom. That WHERE throws away rows for EVERY count.
SELECT COUNT(*) AS all_items,
  COUNT(*) FILTER (WHERE price >= 50) AS pricey
FROM menu_items
WHERE category = 'Chai';
-- 3 | 0   (all_items shows 3, not 10)
-- Fix: put each condition inside its own FILTER (step 1).

-- Mistake 3: forgetting the names. Both columns are called "count".
SELECT COUNT(*) FILTER (WHERE category = 'Chai'),
  COUNT(*) FILTER (WHERE category = 'Snack')
FROM menu_items;
-- count | count  ->  3 | 5
-- Fix: give each one a name, like AS chai and AS snack.
