-- M03-L02 · three beginner mistakes

-- Mistake 1 (the sneaky one): a missing comma. No error!
SELECT name price FROM menu_items;
-- 10 rows, ONE column called price, full of names (Bun Maska, Cold Coffee, ...)

-- Mistake 2: an extra comma just before FROM
SELECT name, price, FROM menu_items;
-- ERROR:  syntax error at or near "FROM"

-- Mistake 3: a misspelled column
SELECT nme, price FROM menu_items;
-- ERROR:  column "nme" does not exist
-- HINT:  Perhaps you meant to reference the column "menu_items.name".
