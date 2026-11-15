-- M22-L01 · SQLite session (run inside the sqlite3 shell: sqlite3 chai.db)
-- Load the 10 menu items first:  .read seed.sql
-- If your sqlite3 prints plain a|b lines, type  .mode box  to get the boxes shown below.

-- Step 1: which tables are in the file
.tables
-- menu_items

-- Step 2: the same query as PostgreSQL and MySQL
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3;
-- 3 rows: Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Step 3: two bars join text (same as PostgreSQL)
SELECT 'Masala' || ' Chai' AS item;
-- 1 row: Masala Chai

-- Step 4: LIKE does not care about capital letters in SQLite
SELECT name FROM menu_items WHERE name LIKE 'masala%';
-- 1 row: Masala Chai

-- Step 5: the month of a date
SELECT strftime('%Y-%m', '2026-03-14') AS month;
-- 1 row: 2026-03

-- Step 6: a word in a number column. SQLite keeps it, with no error
INSERT INTO menu_items (name, category, price) VALUES ('Lassi', 'Drink', 'forty');
SELECT name, price, typeof(price) FROM menu_items WHERE name = 'Lassi';
-- 1 row: Lassi | forty | text

-- Step 7: SQLite also understands FILTER
SELECT SUM(price) FILTER (WHERE category = 'Chai') AS chai FROM menu_items;
-- 1 row: 80

-- Clean up the test row
DELETE FROM menu_items WHERE name = 'Lassi';
