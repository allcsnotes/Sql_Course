-- M19-L02 SQL injection, and how parameterised queries stop it
-- Runs on the Chai Corner database (menu_items has 12 rows). Nothing here changes data.
-- Run each statement on its own.

-- Step 1: what the app builds when the user types  Samosa
SELECT name, price
FROM menu_items
WHERE name = 'Samosa';
-- 1 row: Samosa 25

-- Step 2: what the app builds when the user types  x' OR '1'='1
-- The typed text became code: every row comes back
SELECT name, price
FROM menu_items
WHERE name = 'x' OR '1'='1';
-- 12 rows: Bun Maska 35, Cold Coffee 80, Cutting Chai 20, Filter Coffee 40, Ginger Chai 30,
--          Maggi 60, Samosa 25, Vada Pav 30, Veg Sandwich 70, Kulhad Chai 40, Paneer Roll 90, Masala Chai 30

-- Step 3: the fix, send the query and the value separately.
-- PREPARE saves the query with a placeholder ($1).
PREPARE find_item(text) AS
SELECT name, price
FROM menu_items
WHERE name = $1;
-- PREPARE

-- Step 4: a normal value
EXECUTE find_item('Samosa');
-- 1 row: Samosa 25

-- Step 5: the attack text is now only a value to compare
-- (in SQL text, a quote inside a string is typed twice)
EXECUTE find_item('x'' OR ''1''=''1');
-- 0 rows

-- Step 6: clean up
DEALLOCATE find_item;

-- In app code, use your library's placeholders, for example (Python, psycopg):
--   cur.execute("SELECT name, price FROM menu_items WHERE name = %s", (typed,))
