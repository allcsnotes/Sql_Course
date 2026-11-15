-- M06-L04 · CASE WHEN
-- Each query spans several lines: select all of its lines (or put the cursor inside it) and press Ctrl+Enter.

-- Step 1: one choice. WHEN = the test, THEN = the answer when true, ELSE = every other row.
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly'
       ELSE 'cheap' END AS tag
FROM menu_items;
-- 10 rows: Cold Coffee, Maggi, Veg Sandwich are costly; the other 7 are cheap

-- Step 2: many choices. Checked from top to bottom; the first true test wins.
SELECT name, price,
  CASE WHEN price < 30 THEN 'low'
       WHEN price < 60 THEN 'mid'
       ELSE 'high' END AS band
FROM menu_items;
-- low: Cutting Chai 20, Samosa 25; high: Cold Coffee 80, Maggi 60, Veg Sandwich 70; the other 5 are mid

-- Step 3: choices on dates.
SELECT name, joined_on,
  CASE WHEN joined_on < '2025-01-01' THEN 'early'
       ELSE 'new' END AS member
FROM customers;
-- 15 rows: Asha, Lukas, Priya are early; the other 12 are new
