-- M03-L01 · three beginner mistakes (each one fails on purpose)

-- Mistake 1: a misspelled table name (no s)
SELECT * FROM menu_item;
-- ERROR:  relation "menu_item" does not exist

-- Mistake 2: forgetting FROM
SELECT * menu_items;
-- ERROR:  syntax error at or near "menu_items"

-- Mistake 3: a space instead of the underscore
SELECT * FROM menu items;
-- ERROR:  relation "menu" does not exist
