-- M04-L02 · LIMIT and OFFSET

-- Step 1: sort first, then cut. The three most expensive items
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3;
-- 3 rows: Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Step 2: the three cheapest. Watch out for ties
SELECT name, price FROM menu_items ORDER BY price LIMIT 3;
-- Cutting Chai 20, Samosa 25, Ginger Chai 30 in the video: the third place is a tie pick
-- (Masala Chai or Vada Pav could have taken it; yours may differ)

-- Step 3: a tie breaker makes the cut the same every time
SELECT name, price FROM menu_items ORDER BY price, name LIMIT 3;
-- Cutting Chai 20, Samosa 25, Ginger Chai 30 (G comes first)

-- Step 4: page one, four items per page, sorted by name
SELECT name, price FROM menu_items ORDER BY name LIMIT 4;
-- Bun Maska, Cold Coffee, Cutting Chai, Filter Coffee

-- Step 5: page two, skip the first four
SELECT name, price FROM menu_items ORDER BY name LIMIT 4 OFFSET 4;
-- Ginger Chai, Maggi, Masala Chai, Samosa

-- Step 6: page three, skip two pages of four
SELECT name, price FROM menu_items ORDER BY name LIMIT 4 OFFSET 8;
-- only 2 rows left: Vada Pav, Veg Sandwich
