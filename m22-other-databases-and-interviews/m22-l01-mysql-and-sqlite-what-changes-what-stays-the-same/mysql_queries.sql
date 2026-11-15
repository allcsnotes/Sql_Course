-- M22-L01 · MySQL 8.4 session (run inside: docker exec -it chai-mysql mysql chai_corner)
-- Load the 10 menu items first (from your terminal, in this folder):
--   docker exec -i chai-mysql mysql chai_corner < seed_mysql.sql

-- Step 1: the same query as PostgreSQL and SQLite
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3;
-- 3 rows: Cold Coffee 80, Veg Sandwich 70, Maggi 60

-- Step 2: two bars mean OR in MySQL, so both words become numbers
SELECT 'Masala' || ' Chai' AS item;
-- 1 row: 0 (no error, 3 warnings)
SHOW WARNINGS;
-- Warning 1287 '|| as a synonym for OR' is deprecated ...
-- Warning 1292 Truncated incorrect DOUBLE value: 'Masala'
-- Warning 1292 Truncated incorrect DOUBLE value: ' Chai'

-- Step 3: use CONCAT to join text in MySQL
SELECT CONCAT('Masala', ' Chai') AS item;
-- 1 row: Masala Chai

-- Step 4: LIKE does not care about capital letters in MySQL
SELECT name FROM menu_items WHERE name LIKE 'masala%';
-- 1 row: Masala Chai

-- Step 5: the month of a date
SELECT DATE_FORMAT('2026-03-14', '%Y-%m') AS month;
-- 1 row: 2026-03

-- Step 6: MySQL checks types and refuses a word in a number column
INSERT INTO menu_items (name, category, price) VALUES ('Lassi', 'Drink', 'forty');
-- ERROR 1366 (HY000): Incorrect integer value: 'forty' for column 'price' at row 1

-- Step 7: MySQL has no FILTER
SELECT SUM(price) FILTER (WHERE category = 'Chai') AS chai FROM menu_items;
-- ERROR 1064 (42000): You have an error in your SQL syntax ... near '(WHERE category = 'Chai') AS chai FROM menu_items'

-- Step 8: write SUM of CASE instead
SELECT SUM(CASE WHEN category = 'Chai' THEN price ELSE 0 END) AS chai FROM menu_items;
-- 1 row: 80

-- Your task: what does this return?
SELECT CONCAT('Chai', 'Corner');
-- 1 row: ChaiCorner (no space in between)
