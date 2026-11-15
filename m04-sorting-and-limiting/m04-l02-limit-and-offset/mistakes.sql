-- M04-L02 · three beginner mistakes

-- Mistake 1: LIMIT before ORDER BY
SELECT name, price FROM menu_items LIMIT 3 ORDER BY price DESC;
-- ERROR:  syntax error at or near "ORDER"

-- Mistake 2: LIMIT with no ORDER BY: three rows, but not the top three of anything
SELECT name, price FROM menu_items LIMIT 3;
-- Bun Maska 35, Cold Coffee 80, Cutting Chai 20 in the video (whatever order the database likes)

-- Mistake 3: the wrong OFFSET for page two skips only one row
SELECT name, price FROM menu_items ORDER BY name LIMIT 4 OFFSET 1;
-- Cold Coffee, Cutting Chai, Filter Coffee, Ginger Chai: three of them were already on page one
