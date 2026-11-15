-- Module 12, Lesson 5: Importing and exporting CSV files
-- Chai Corner database (PostgreSQL 18)
--
-- The video runs COPY in DBeaver with full file paths: the Postgres SERVER reads
-- and writes the files itself. This file uses psql's \copy instead, which reads
-- and writes files on YOUR computer, relative to the folder you started psql in.
-- Start psql in this folder:   psql -U postgres -d chai_corner
-- then run:                    \i csv_import_export.sql
-- (\copy must stay on one line.)

-- Step 1: export, write a table to a CSV file
\copy menu_items TO 'menu_items.csv' WITH (FORMAT csv, HEADER)
-- COPY 12   (DBeaver: Updated Rows 12)

-- Step 2: import, part 1, a table shaped like the file (price_list.csv: item_id,new_price)
CREATE TABLE price_updates (
  item_id   int PRIMARY KEY,
  new_price numeric(6,2) NOT NULL
);

-- Step 3: import, part 2, read the file into the table
\copy price_updates FROM 'price_list.csv' WITH (FORMAT csv, HEADER)
-- COPY 4   (DBeaver: Updated Rows 4)

-- Check what came in, next to today's prices
SELECT m.name, m.price, p.new_price
FROM price_updates p
JOIN menu_items m ON m.item_id = p.item_id
ORDER BY p.item_id;
-- Bun Maska 35 38.00, Cutting Chai 20 22.00, Ginger Chai 30 32.00, Samosa 25 28.00

-- Step 4: export only some rows, put a query in brackets
\copy (SELECT name, price FROM menu_items WHERE category = 'Chai' ORDER BY price) TO 'chai_menu.csv' WITH (FORMAT csv, HEADER)
-- COPY 4

-- Mistake 1: forgetting HEADER
\copy price_updates FROM 'price_list.csv' WITH (FORMAT csv)
-- ERROR 22P02: invalid input syntax for type integer: "item_id"

-- Mistake 2: a typo in the file path
\copy price_updates FROM 'pricelist.csv' WITH (FORMAT csv, HEADER)
-- psql: pricelist.csv: No such file or directory
-- (server-side COPY in the video: ERROR 58P01 could not open file ... No such file or directory)

-- Mistake 3: importing the same file twice
\copy price_updates FROM 'price_list.csv' WITH (FORMAT csv, HEADER)
-- ERROR 23505: duplicate key value violates unique constraint "price_updates_pkey"
--              Key (item_id)=(1) already exists.

-- Your task: export every customer's name and join date (answer in README.md)
