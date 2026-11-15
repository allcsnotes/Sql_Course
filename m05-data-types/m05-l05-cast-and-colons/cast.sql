-- M05-L05 · CAST and ::
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: two ways to cast. CAST(value AS type), or value::type.
SELECT CAST('42' AS integer) AS with_cast, '42'::integer AS with_colons;
-- 42 | 42

-- Step 2: text is compared letter by letter, like words in a dictionary.
SELECT '10' < '9' AS compared_as_text, 10 < 9 AS compared_as_numbers;
-- true | false

-- Step 3: cast both to integer and the answer is correct again.
SELECT '10'::integer < '9'::integer AS compared_after_cast;
-- false

-- Step 4: cast to numeric to keep the part after the point.
SELECT 7 / 2 AS integer_division, 7::numeric / 2 AS numeric_division;
-- 3 | 3.5000000000000000

-- Step 5: cast a number to text to join it with words (|| joins text).
SELECT name, price::text || ' rupees' AS price_label FROM menu_items ORDER BY price LIMIT 3;
-- 3 rows: Cutting Chai 20 rupees, Samosa 25 rupees, Ginger Chai 30 rupees
-- (the third row is one of the three ₹30 items; yours may differ)

-- Step 6: ->> gives back text. Cast it to integer to do maths.
SELECT ('{"name": "Samosa", "price": 25}'::jsonb ->> 'price')::integer + 5 AS new_price;
-- 30
