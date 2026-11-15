-- M01-L04 · One Language, Many Databases
-- The same three lines, typed into PostgreSQL, MySQL and SQLite.

-- Step 1: the same question in every database
SELECT name, price FROM menu_items WHERE price < 30 ORDER BY price;
-- 2 rows in all three: Cutting Chai 20, Samosa 25

-- Step 2: dividing two whole numbers
SELECT 7 / 2 AS result;
-- PostgreSQL 3 · SQLite 3 · MySQL 3.5000

-- Step 3: joining text with two straight lines
SELECT 'Chai' || ' Corner' AS shop;
-- PostgreSQL and SQLite: Chai Corner · MySQL: 0, with 3 warnings
