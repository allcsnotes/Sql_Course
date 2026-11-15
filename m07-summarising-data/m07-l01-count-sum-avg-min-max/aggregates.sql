-- M07-L01 · COUNT, SUM, AVG, MIN, MAX
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).
-- The ten menu prices: 35, 80, 20, 40, 30, 60, 30, 25, 30, 70.

-- Step 1: COUNT(*) counts the rows. One row comes back, with one number.
SELECT COUNT(*) AS total_items FROM menu_items;
-- 10

-- Step 2: SUM adds up a column.
SELECT SUM(price) AS menu_total FROM menu_items;
-- 420

-- Step 3: AVG adds up, then divides by how many there are.
SELECT AVG(price) AS average_price_of_one_item FROM menu_items;
-- 42.0000000000000000

-- Step 4: wrap it in ROUND with two places.
SELECT ROUND(AVG(price), 2) AS average_price FROM menu_items;
-- 42.00

-- Step 5: MIN = the smallest value, MAX = the biggest.
SELECT MIN(price) AS cheapest, MAX(price) AS dearest FROM menu_items;
-- 20 | 80

-- Step 6: they work on dates too.
SELECT MIN(joined_on) AS first_joined, MAX(joined_on) AS last_joined FROM customers;
-- 2024-11-11 | 2026-06-10

-- Step 7: WHERE runs first, then COUNT and AVG work on the rows that are left.
SELECT COUNT(*) AS chai_items, ROUND(AVG(price), 2) AS avg_chai FROM menu_items WHERE category = 'Chai';
-- 3 | 26.67
