-- M05-L04 · Boolean, UUID and JSON
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: every comparison gives a boolean (true or false).
SELECT 5 > 3 AS is_5_bigger_than_3, 5 < 3 AS is_5_smaller_than_3;
-- true | false   (DBeaver: [v] ticked box, [ ] empty box; psql: t, f)

-- Step 2: a comparison as a column.
SELECT name, price, price < 30 AS is_cheap FROM menu_items ORDER BY price;
-- 10 rows: Cutting Chai 20 true, Samosa 25 true, every other item false
-- (Masala Chai, Vada Pav, Ginger Chai 30, Bun Maska 35, Filter Coffee 40, Maggi 60, Veg Sandwich 70, Cold Coffee 80)

-- Step 3: gen_random_uuid makes a new random ID every time.
SELECT gen_random_uuid() AS id_one, gen_random_uuid() AS id_two;
-- two different codes, for example 5ba77508-84b9-4a4d-82e6-7f489fe7b1e7 and 7cc80b64-c5fd-4287-95b8-6a51ef3b560e
-- (yours will be different every time you run it)

-- Step 4: JSON stores names and values inside curly brackets. jsonb is the fast, checked form.
SELECT '{"name": "Masala Chai", "price": 30, "sizes": ["small", "large"]}'::jsonb AS menu_item;
-- {"name": "Masala Chai", "price": 30, "sizes": ["small", "large"]}

-- Step 5: ->> reads one value out (as text).
SELECT '{"name": "Masala Chai", "price": 30}'::jsonb ->> 'name' AS item_name;
-- Masala Chai
