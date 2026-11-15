-- M04-L03 · three beginner mistakes

-- Mistake 1: DISTINCT with a column that is always different. Nothing is removed
SELECT DISTINCT name, category FROM menu_items ORDER BY category;
-- still 10 rows

-- Mistake 2: DISTINCT in the middle
SELECT category, DISTINCT price FROM menu_items;
-- ERROR:  syntax error at or near "DISTINCT"

-- Mistake 3: sorting by a column you did not select
SELECT DISTINCT category FROM menu_items ORDER BY price;
-- ERROR:  for SELECT DISTINCT, ORDER BY expressions must appear in select list
